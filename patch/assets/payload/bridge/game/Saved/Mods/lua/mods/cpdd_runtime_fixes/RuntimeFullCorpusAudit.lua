
local function jsonEscape(value)
    local escaped = tostring(value or "")
        :gsub("\\", "\\\\")
        :gsub('"', '\\"')
        :gsub("\b", "\\b")
        :gsub("\f", "\\f")
        :gsub("\n", "\\n")
        :gsub("\r", "\\r")
        :gsub("\t", "\\t")
    return '"' .. escaped .. '"'
end

local function stableKey(value)
    if type(value) == "number" and value == math.floor(value) then
        return string.format("%.0f", value)
    end
    return tostring(value)
end

local function reportPath(version, auditId)
    local File = import("LuaFunctionLibrary")
    local Paths = import("BlueprintPathsLibrary")
    local root = File.GetFilePath(Paths.ProjectSavedDir()) .. "/Mods/"
    local safeVersion = tostring(version or "unknown"):gsub("[^%w%.%-]", "_")
    local safeAuditId = tostring(auditId or "unknown"):gsub("[^%w%.%-]", "_")
    return root .. "translation-full-corpus-" .. safeVersion .. "-" .. safeAuditId .. ".jsonl"
end

local function moduleValue(value)
    if type(value) ~= "table" then return nil end
    return type(value.data) == "table" and value.data or value
end

local function executePristine(chunk)
    local environment = setmetatable({}, { __index = _G })
    setfenv(chunk, environment)
    local ok, value = pcall(chunk)
    if not ok then return nil, tostring(value) end
    return moduleValue(value), nil
end

local function walkPairs(output, containsCjk, moduleName, source, translated, path, counters, seen)
    if type(source) == "string" then
        if containsCjk(source) then
            counters.pairs = counters.pairs + 1
            output:write(
                '{"type":"translation-pair","table":', jsonEscape(moduleName),
                ',"path":', jsonEscape(path),
                ',"source":', jsonEscape(source),
                ',"translation":', jsonEscape(type(translated) == "string" and translated or ""), "}\n"
            )
        end
        return
    end
    if type(source) ~= "table" or seen[source] then return end
    seen[source] = true
    for key, child in pairs(source) do
        local translatedChild = type(translated) == "table" and translated[key] or nil
        local childPath = path == "" and stableKey(key) or (path .. "." .. stableKey(key))
        walkPairs(output, containsCjk, moduleName, child, translatedChild, childPath, counters, seen)
    end
end

return function(loader, containsCjk, report, version, auditId)
    if type(loader) ~= "table" or type(loader.On) ~= "function"
        or type(loader.FindOriginalChunk) ~= "function" then
        return false
    end

    loader.On("after_main", function()
        if type(io) ~= "table" or type(io.open) ~= "function" then
            report("full corpus audit unavailable: io.open is unavailable")
            return
        end

        local finalPath = reportPath(version, auditId)
        local existing = io.open(finalPath, "rb")
        if existing then
            existing:close()
            report("full corpus audit already exists: " .. finalPath)
            return
        end

        local okCatalog, catalog = pcall(require, "mods.cpdd_runtime_fixes.GameModuleCatalog")
        local okJit, jutil = pcall(require, "jit.util")
        if not okCatalog or type(catalog) ~= "table" then
            report("full corpus audit module catalog unavailable: " .. tostring(catalog))
            return
        end
        if not okJit or type(jutil.funcinfo) ~= "function" or type(jutil.funck) ~= "function" then
            report("full corpus audit jit.util unavailable")
            return
        end

        local temporaryPath = finalPath .. ".tmp"
        local output, openError = io.open(temporaryPath, "wb")
        if not output then
            report("full corpus audit could not open output: " .. tostring(openError))
            return
        end

        local success, message = xpcall(function()
            local seenObjects = setmetatable({}, { __mode = "k" })
            local seenLiterals = {}
            local counters = { modules = 0, chunks = 0, literals = 0, pairs = 0, failedPairs = 0 }
            local scanProto, scanValue

            local function emitLiteral(moduleName, value)
                local identity = moduleName .. "\0" .. value
                if seenLiterals[identity] then return end
                seenLiterals[identity] = true
                counters.literals = counters.literals + 1
                output:write(
                    '{"type":"literal","module":', jsonEscape(moduleName),
                    ',"source":', jsonEscape(value), "}\n"
                )
            end

            scanValue = function(moduleName, value)
                local kind = type(value)
                if kind == "string" then
                    if containsCjk(value) then emitLiteral(moduleName, value) end
                elseif kind == "function" or kind == "proto" then
                    scanProto(moduleName, value)
                elseif kind == "table" and not seenObjects[value] then
                    seenObjects[value] = true
                    pcall(function()
                        for key, child in pairs(value) do
                            scanValue(moduleName, key)
                            scanValue(moduleName, child)
                        end
                    end)
                end
            end

            scanProto = function(moduleName, proto)
                if seenObjects[proto] then return end
                seenObjects[proto] = true
                local gotInfo, info = pcall(jutil.funcinfo, proto)
                if not gotInfo or type(info) ~= "table" then return end
                for index = -1, -(tonumber(info.gcconsts) or 0), -1 do
                    local gotConstant, constant = pcall(jutil.funck, proto, index)
                    if gotConstant then scanValue(moduleName, constant) end
                end
            end

            for _, moduleName in ipairs(catalog) do
                counters.modules = counters.modules + 1
                local chunk = loader.FindOriginalChunk(moduleName)
                if type(chunk) == "function" then
                    counters.chunks = counters.chunks + 1
                    scanProto(moduleName, chunk)
                end
                if counters.modules % 1000 == 0 then
                    output:flush()
                    report(
                        "full corpus audit progress " .. tostring(counters.modules)
                        .. "/" .. tostring(#catalog)
                        .. " literals=" .. tostring(counters.literals)
                    )
                end
            end

            for moduleName in pairs(loader.Overlays or {}) do
                local chunk = loader.FindOriginalChunk(moduleName)
                local source, sourceError = nil, nil
                if type(chunk) == "function" then
                    source, sourceError = executePristine(chunk)
                else
                    sourceError = "original module chunk unavailable"
                end
                local loadedOk, translatedModule = pcall(require, moduleName)
                local translated = loadedOk and moduleValue(translatedModule) or nil
                if type(source) == "table" and type(translated) == "table" then
                    walkPairs(output, containsCjk, moduleName, source, translated, "", counters, {})
                else
                    counters.failedPairs = counters.failedPairs + 1
                    output:write(
                        '{"type":"pair-error","table":', jsonEscape(moduleName),
                        ',"error":', jsonEscape(sourceError or tostring(translatedModule)), "}\n"
                    )
                end
            end

            output:write(
                '{"type":"summary","runtime_version":', jsonEscape(version),
                ',"audit_id":', jsonEscape(auditId),
                ',"catalog_modules":', tostring(counters.modules),
                ',"chunks_found":', tostring(counters.chunks),
                ',"cjk_literals":', tostring(counters.literals),
                ',"translation_pairs":', tostring(counters.pairs),
                ',"failed_pair_tables":', tostring(counters.failedPairs), "}\n"
            )
            output:flush()
            output:close()
            output = nil
            local renamed, renameError = os.rename(temporaryPath, finalPath)
            if not renamed then error("could not finalize full corpus report: " .. tostring(renameError)) end
            report(
                "full corpus audit complete modules=" .. tostring(counters.modules)
                .. " chunks=" .. tostring(counters.chunks)
                .. " literals=" .. tostring(counters.literals)
                .. " pairs=" .. tostring(counters.pairs)
                .. " path=" .. finalPath
            )
        end, debug.traceback)

        if output then output:close() end
        if not success then
            if type(os) == "table" and type(os.remove) == "function" then os.remove(temporaryPath) end
            report("full corpus audit failed: " .. tostring(message))
        end
    end, 910000, "cpdd.runtime.full_corpus_audit")
    return true
end
