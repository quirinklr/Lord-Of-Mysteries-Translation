
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

local function sortedKeys(value)
    local keys = {}
    for key in pairs(value or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    return keys
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
    return root .. "translation-coverage-" .. safeVersion .. "-" .. safeAuditId .. ".jsonl"
end

return function(loader, repairText, containsCjk, report, version, auditId)
    if type(loader) ~= "table" or type(loader.On) ~= "function" then
        return false
    end
    if type(repairText) ~= "function" or type(containsCjk) ~= "function" then
        return false
    end

    loader.On("after_main", function()
        if type(io) ~= "table" or type(io.open) ~= "function" then
            report("static translation audit unavailable: io.open is unavailable")
            return
        end

        local finalPath = reportPath(version, auditId)
        local existing = io.open(finalPath, "rb")
        if existing then
            existing:close()
            report("static translation audit already exists: " .. finalPath)
            return
        end

        local temporaryPath = finalPath .. ".tmp"
        local output, openError = io.open(temporaryPath, "wb")
        if not output then
            report("static translation audit could not open output: " .. tostring(openError))
            return
        end

        local ok, message = xpcall(function()
            local totalRows, totalStrings, totalUnresolved = 0, 0, 0
            local loadedTables, failedTables = 0, 0
            for _, moduleName in ipairs(sortedKeys(loader.Overlays)) do
                local loadedOk, module = pcall(require, moduleName)
                local data = loadedOk and type(module) == "table" and (module.data or module) or nil
                local loadError = nil
                if loadedOk and type(data) == "table" then
                    loadedTables = loadedTables + 1
                else
                    failedTables = failedTables + 1
                    if loadedOk then
                        loadError = "module did not return a localization table"
                    else
                        loadError = tostring(module)
                    end
                end
                local tableRows, tableStrings, tableUnresolved = 0, 0, 0
                if type(data) == "table" then
                    for _, rowKey in ipairs(sortedKeys(data)) do
                        tableRows = tableRows + 1
                        local row = data[rowKey]
                        if type(row) == "string" then
                            tableStrings = tableStrings + 1
                            local repaired = repairText(moduleName, rowKey, "RawText", row)
                            if containsCjk(repaired) then
                                tableUnresolved = tableUnresolved + 1
                                output:write(
                                    '{"type":"gap","table":', jsonEscape(moduleName),
                                    ',"key":', jsonEscape(stableKey(rowKey)),
                                    ',"field":"RawText","source":', jsonEscape(row), "}\n"
                                )
                            end
                        elseif type(row) == "table" then
                            for _, field in ipairs(sortedKeys(row)) do
                                local value = row[field]
                                if type(value) == "string" then
                                    tableStrings = tableStrings + 1
                                    local repaired = repairText(moduleName, rowKey, field, value)
                                    if containsCjk(repaired) then
                                        tableUnresolved = tableUnresolved + 1
                                        output:write(
                                            '{"type":"gap","table":', jsonEscape(moduleName),
                                            ',"key":', jsonEscape(stableKey(rowKey)),
                                            ',"field":', jsonEscape(field),
                                            ',"source":', jsonEscape(value), "}\n"
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
                totalRows = totalRows + tableRows
                totalStrings = totalStrings + tableStrings
                totalUnresolved = totalUnresolved + tableUnresolved
                output:write(
                    '{"type":"table-summary","table":', jsonEscape(moduleName),
                    ',"loaded":', type(data) == "table" and "true" or "false",
                    ',"load_error":', loadError and jsonEscape(loadError) or "null",
                    ',"rows":', tostring(tableRows),
                    ',"strings":', tostring(tableStrings),
                    ',"unresolved":', tostring(tableUnresolved), "}\n"
                )
            end
            output:write(
                '{"type":"summary","runtime_version":', jsonEscape(version),
                ',"audit_id":', jsonEscape(auditId),
                ',"loaded_tables":', tostring(loadedTables),
                ',"failed_tables":', tostring(failedTables),
                ',"rows":', tostring(totalRows),
                ',"strings":', tostring(totalStrings),
                ',"unresolved":', tostring(totalUnresolved), "}\n"
            )
            output:flush()
            output:close()
            output = nil
            if type(os) ~= "table" or type(os.rename) ~= "function" then
                error("os.rename is unavailable")
            end
            local renamed, renameError = os.rename(temporaryPath, finalPath)
            if not renamed then
                error("could not finalize report: " .. tostring(renameError))
            end
            report(
                "static translation audit complete rows=" .. tostring(totalRows)
                .. " strings=" .. tostring(totalStrings)
                .. " unresolved=" .. tostring(totalUnresolved)
                .. " loaded_tables=" .. tostring(loadedTables)
                .. " failed_tables=" .. tostring(failedTables)
                .. " path=" .. finalPath
            )
        end, debug.traceback)

        if output then
            output:close()
        end
        if not ok then
            if type(os) == "table" and type(os.remove) == "function" then
                os.remove(temporaryPath)
            end
            report("static translation audit failed: " .. tostring(message))
        end
    end, 900000, "cpdd.runtime.static_translation_audit")
    return true
end
