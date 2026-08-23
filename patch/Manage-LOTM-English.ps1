[CmdletBinding()]
param(
    [ValidateSet('Install', 'Update', 'Uninstall', 'Verify')]
    [string]$Action = 'Verify',
    [string]$GameRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PackageRoot = $PSScriptRoot
$AssetsRoot = Join-Path $PackageRoot 'assets'
$ReleasePath = Join-Path $AssetsRoot 'release.json'
$BackupRelative = 'Saved\Mods\.lotm-english-safe-patch-backup'
$StateFileName = 'state.json'

function Get-FileSha256Lower([string]$Path) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        return ([System.BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $stream.Dispose()
        $sha.Dispose()
    }
}

function Get-BytesSha256Lower([byte[]]$Bytes) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Resolve-SafeChild([string]$Root, [string]$RelativePath) {
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $rootFull ($RelativePath -replace '/', '\')))
    if (-not $candidate.StartsWith($rootFull + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe relative path rejected: $RelativePath"
    }
    return $candidate
}

function Read-FileBlock([string]$Path, [int64]$Offset, [int]$Length) {
    $buffer = New-Object byte[] $Length
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    try {
        [void]$stream.Seek($Offset, [System.IO.SeekOrigin]::Begin)
        $total = 0
        while ($total -lt $Length) {
            $count = $stream.Read($buffer, $total, $Length - $total)
            if ($count -le 0) { throw "Unexpected end of file while reading $Path" }
            $total += $count
        }
        return $buffer
    }
    finally {
        $stream.Dispose()
    }
}

function Write-FileBlock([string]$Path, [int64]$Offset, [byte[]]$Bytes) {
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    try {
        [void]$stream.Seek($Offset, [System.IO.SeekOrigin]::Begin)
        $stream.Write($Bytes, 0, $Bytes.Length)
        $stream.Flush($true)
    }
    finally {
        $stream.Dispose()
    }
}

function Install-PakBridge([object]$Game, [byte[]]$Replacement, [string]$ExpectedFullHash) {
    try {
        Write-FileBlock $Game.Pak ([int64]$Game.Block.offset) $Replacement
        return $null
    }
    catch [System.Management.Automation.MethodInvocationException] {
    }

    $temporaryPak = $Game.Pak + '.lotm-safe-new'
    $fullBackup = Join-Path $Game.BackupRoot 'pakchunk0-Windows.original.pak'
    if ((Test-Path -LiteralPath $temporaryPak) -or (Test-Path -LiteralPath $fullBackup)) {
        throw 'Cannot use safe PAK replacement because a temporary or full-backup file already exists.'
    }

    $source = [System.IO.File]::Open($Game.Pak, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    $destination = [System.IO.File]::Open($temporaryPak, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    try {
        $source.CopyTo($destination, 4 * 1024 * 1024)
        [void]$destination.Seek([int64]$Game.Block.offset, [System.IO.SeekOrigin]::Begin)
        $destination.Write($Replacement, 0, $Replacement.Length)
        $destination.Flush($true)
    }
    finally {
        $destination.Dispose()
        $source.Dispose()
    }

    if ((Get-FileSha256Lower $temporaryPak) -ne $ExpectedFullHash.ToLowerInvariant()) {
        throw 'The complete replacement PAK failed SHA-256 verification; the original PAK was left untouched.'
    }

    try {
        Move-Item -LiteralPath $Game.Pak -Destination $fullBackup
        Move-Item -LiteralPath $temporaryPak -Destination $Game.Pak
    }
    catch {
        if (-not (Test-Path -LiteralPath $Game.Pak) -and (Test-Path -LiteralPath $fullBackup)) {
            Move-Item -LiteralPath $fullBackup -Destination $Game.Pak
        }
        throw
    }
    return $fullBackup
}

function Assert-GameClosed {
    $running = @(Get-Process -Name 'C7-Win64-Shipping' -ErrorAction SilentlyContinue)
    if ($running.Count -gt 0) {
        throw 'LOTM is running. Close the game before installing or uninstalling the patch.'
    }
}

function Test-IsAdministrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-Release {
    if (-not (Test-Path -LiteralPath $ReleasePath -PathType Leaf)) {
        throw "Missing package manifest: $ReleasePath"
    }
    return Get-Content -LiteralPath $ReleasePath -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Resolve-GameRoot {
    if (-not [string]::IsNullOrWhiteSpace($GameRoot)) {
        return [System.IO.Path]::GetFullPath($GameRoot).TrimEnd('\')
    }

    $documents = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
    $candidates = @(
        (Join-Path $documents 'Bilibili\GMZZLauncher\Game\C7'),
        (Join-Path $env:USERPROFILE 'Documents\Bilibili\GMZZLauncher\Game\C7'),
        (Join-Path $env:USERPROFILE 'OneDrive\Documents\Bilibili\GMZZLauncher\Game\C7')
    ) | Select-Object -Unique

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath (Join-Path $candidate 'Content\Paks\pakchunk0-Windows.pak') -PathType Leaf) {
            return [System.IO.Path]::GetFullPath($candidate).TrimEnd('\')
        }
    }

    Add-Type -AssemblyName System.Windows.Forms
    $dialog = [System.Windows.Forms.FolderBrowserDialog]::new()
    $dialog.Description = 'Select the Lord of Mysteries C7 game folder.'
    $dialog.ShowNewFolderButton = $false
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        throw 'No game folder was selected.'
    }
    $selected = [System.IO.Path]::GetFullPath($dialog.SelectedPath).TrimEnd('\')
    if (-not (Test-Path -LiteralPath (Join-Path $selected 'Content\Paks\pakchunk0-Windows.pak') -PathType Leaf)) {
        throw 'The selected folder is not a supported C7 game folder.'
    }
    return $selected
}

function Assert-Package([object]$Release) {
    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in @($Release.external_bridge.files)) {
        $source = Resolve-SafeChild $AssetsRoot ([string]$entry.payload)
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            $failures.Add("missing: $($entry.payload)")
            continue
        }
        $item = Get-Item -LiteralPath $source
        if ($item.Length -ne [int64]$entry.size) {
            $failures.Add("wrong size: $($entry.payload)")
            continue
        }
        if ((Get-FileSha256Lower $source) -ne ([string]$entry.sha256).ToLowerInvariant()) {
            $failures.Add("wrong hash: $($entry.payload)")
        }
    }

    $block = $Release.external_bridge.launch_block
    $blockPath = Resolve-SafeChild $AssetsRoot ([string]$block.payload)
    if (-not (Test-Path -LiteralPath $blockPath -PathType Leaf)) {
        $failures.Add("missing: $($block.payload)")
    }
    else {
        $blockItem = Get-Item -LiteralPath $blockPath
        if ($blockItem.Length -ne [int64]$block.size) { $failures.Add('wrong launch block size') }
        if ((Get-FileSha256Lower $blockPath) -ne ([string]$block.sha256).ToLowerInvariant()) {
            $failures.Add('wrong launch block hash')
        }
    }

    if ($failures.Count -gt 0) {
        throw "Package validation failed:`n - $($failures -join "`n - ")"
    }
}

function Get-GameInfo([object]$Release) {
    $root = $GameRoot
    if (-not (Test-Path -LiteralPath $root -PathType Container)) {
        throw "Game folder not found: $root"
    }
    $block = $Release.external_bridge.launch_block
    $pak = Resolve-SafeChild $root ([string]$block.pak_relative_path)
    if (-not (Test-Path -LiteralPath $pak -PathType Leaf)) {
        throw "Game PAK not found: $pak"
    }
    return [pscustomobject]@{
        Root = $root
        Pak = $pak
        PakHash = Get-FileSha256Lower $pak
        PakSize = (Get-Item -LiteralPath $pak).Length
        Block = $block
        BackupRoot = Resolve-SafeChild $root $BackupRelative
    }
}

function Get-SupportedCleanHash([object]$Release, [int64]$Size) {
    foreach ($base in @($Release.supported_base_paks)) {
        if ([int64]$base.size -eq $Size) {
            return ([string]$base.sha256).ToLowerInvariant()
        }
    }
    return $null
}

function Install-Patch([object]$Release) {
    Assert-GameClosed
    Assert-Package $Release
    $game = Get-GameInfo $Release
    $cleanHash = Get-SupportedCleanHash $Release $game.PakSize
    $installedHash = ([string]$game.Block.installed_pak_sha256).ToLowerInvariant()

    if ($game.PakHash -eq $installedHash) {
        Write-Host 'The PAK bridge is already installed. Running verification instead.' -ForegroundColor Yellow
        Verify-Patch $Release
        return
    }
    if (-not $cleanHash -or $game.PakHash -ne $cleanHash) {
        throw "Unsupported or modified game PAK. Expected clean SHA-256 $cleanHash, got $($game.PakHash)."
    }

    $originalBlock = Read-FileBlock $game.Pak ([int64]$game.Block.offset) ([int]$game.Block.size)
    $originalBlockHash = Get-BytesSha256Lower $originalBlock
    if ($originalBlockHash -ne ([string]$game.Block.clean_sha256).ToLowerInvariant()) {
        throw "The target PAK block does not match the expected clean hash. No changes were made."
    }

    $statePath = Join-Path $game.BackupRoot $StateFileName
    if (Test-Path -LiteralPath $statePath) {
        $existingState = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not [bool]$existingState.pak_patched -and $game.PakHash -eq $cleanHash) {
            foreach ($entry in @($Release.external_bridge.files)) {
                $destination = Resolve-SafeChild $game.Root ([string]$entry.relative_path)
                if (-not (Test-Path -LiteralPath $destination -PathType Leaf) -or
                    (Get-FileSha256Lower $destination) -ne ([string]$entry.sha256).ToLowerInvariant()) {
                    throw "Cannot resume: translation file is missing or changed: $($entry.relative_path)"
                }
            }
            $savedOriginal = Join-Path $game.BackupRoot 'LaunchInstance.original.oodle'
            if (-not (Test-Path -LiteralPath $savedOriginal -PathType Leaf) -or
                (Get-FileSha256Lower $savedOriginal) -ne ([string]$game.Block.clean_sha256).ToLowerInvariant()) {
                throw 'Cannot resume: original launch-block backup is missing or invalid.'
            }
            $resumeReplacementPath = Resolve-SafeChild $AssetsRoot ([string]$game.Block.payload)
            $resumeFullBackup = Install-PakBridge $game ([System.IO.File]::ReadAllBytes($resumeReplacementPath)) $installedHash
            $resumedPakHash = Get-FileSha256Lower $game.Pak
            if ($resumedPakHash -ne $installedHash) {
                if ($resumeFullBackup -and (Test-Path -LiteralPath $resumeFullBackup)) {
                    throw 'Resumed PAK verification failed after a full-file replacement. The verified original full PAK is retained in the backup folder.'
                }
                Write-FileBlock $game.Pak ([int64]$game.Block.offset) ([System.IO.File]::ReadAllBytes($savedOriginal))
                throw "Resumed PAK verification failed. The original block was restored. Got $resumedPakHash."
            }
            $existingState | Add-Member -NotePropertyName full_pak_backup -NotePropertyValue $resumeFullBackup -Force
            $existingState.pak_patched = $true
            $existingState | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
            Write-Host "LOTM English patch installation resumed and completed successfully ($($Release.display_version))." -ForegroundColor Green
            return
        }
        throw "A previous backup state already exists at $statePath. Verify or uninstall it first."
    }
    New-Item -ItemType Directory -Force -Path $game.BackupRoot | Out-Null
    $originalBlockPath = Join-Path $game.BackupRoot 'LaunchInstance.original.oodle'
    [System.IO.File]::WriteAllBytes($originalBlockPath, $originalBlock)

    $installedFiles = [System.Collections.Generic.List[object]]::new()
    $changedFiles = [System.Collections.Generic.List[object]]::new()
    $fullBackup = $null
    try {
        foreach ($entry in @($Release.external_bridge.files)) {
            $source = Resolve-SafeChild $AssetsRoot ([string]$entry.payload)
            $destination = Resolve-SafeChild $game.Root ([string]$entry.relative_path)
            $targetHash = ([string]$entry.sha256).ToLowerInvariant()
            $originalExisted = Test-Path -LiteralPath $destination -PathType Leaf
            $backupFile = $null
            if ($originalExisted) {
                $backupFile = Resolve-SafeChild (Join-Path $game.BackupRoot 'files') ([string]$entry.relative_path)
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backupFile) | Out-Null
                Copy-Item -LiteralPath $destination -Destination $backupFile -Force
            }
            $changedFiles.Add([pscustomobject]@{
                destination = $destination
                backup_file = $backupFile
                original_existed = [bool]$originalExisted
                target_sha256 = $targetHash
            })
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $source -Destination $destination -Force
            if ((Get-FileSha256Lower $destination) -ne $targetHash) {
                throw "Installed file failed verification: $($entry.relative_path)"
            }
            $installedFiles.Add([pscustomobject]@{
                relative_path = [string]$entry.relative_path
                source_sha256 = $targetHash
                original_existed = [bool]$originalExisted
            })
        }

        $state = [ordered]@{
            package_release = [string]$Release.release_id
            installed_at = (Get-Date).ToString('o')
            original_pak_sha256 = $game.PakHash
            installed_pak_sha256 = $installedHash
            original_block_sha256 = $originalBlockHash
            installed_block_sha256 = ([string]$game.Block.sha256).ToLowerInvariant()
            full_pak_backup = $null
            pak_patched = $false
            files = @($installedFiles)
        }
        $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8

        $replacementPath = Resolve-SafeChild $AssetsRoot ([string]$game.Block.payload)
        $replacement = [System.IO.File]::ReadAllBytes($replacementPath)
        $fullBackup = Install-PakBridge $game $replacement $installedHash
        $patchedPakHash = Get-FileSha256Lower $game.Pak
        if ($patchedPakHash -ne $installedHash) {
            throw "Patched PAK verification failed. Got $patchedPakHash."
        }

        $state.full_pak_backup = $fullBackup
        $state.pak_patched = $true
        $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
        Write-Host "LOTM English patch installed successfully ($($Release.display_version))." -ForegroundColor Green
        Write-Host "Backup: $($game.BackupRoot)"
    }
    catch {
        $failure = $_
        $rollbackFailures = [System.Collections.Generic.List[string]]::new()
        try {
            if ((Test-Path -LiteralPath $game.Pak -PathType Leaf) -and
                (Get-FileSha256Lower $game.Pak) -eq $installedHash) {
                if ($fullBackup -and (Test-Path -LiteralPath $fullBackup -PathType Leaf)) {
                    $failedPak = $game.Pak + '.lotm-safe-failed'
                    if (Test-Path -LiteralPath $failedPak) { throw "Rollback path already exists: $failedPak" }
                    Move-Item -LiteralPath $game.Pak -Destination $failedPak
                    Move-Item -LiteralPath $fullBackup -Destination $game.Pak
                    if ((Get-FileSha256Lower $game.Pak) -ne $game.PakHash) { throw 'Restored PAK hash mismatch.' }
                    Remove-Item -LiteralPath $failedPak -Force
                }
                else {
                    Write-FileBlock $game.Pak ([int64]$game.Block.offset) $originalBlock
                    if ((Get-FileSha256Lower $game.Pak) -ne $game.PakHash) { throw 'Restored PAK hash mismatch.' }
                }
            }
        }
        catch {
            $rollbackFailures.Add("PAK rollback failed: $($_.Exception.Message)")
        }
        foreach ($record in @($changedFiles) | Select-Object -Reverse) {
            try {
                if ([bool]$record.original_existed) {
                    Copy-Item -LiteralPath ([string]$record.backup_file) -Destination ([string]$record.destination) -Force
                }
                elseif ((Test-Path -LiteralPath ([string]$record.destination) -PathType Leaf) -and
                    (Get-FileSha256Lower ([string]$record.destination)) -eq ([string]$record.target_sha256)) {
                    Remove-Item -LiteralPath ([string]$record.destination) -Force
                }
            }
            catch {
                $rollbackFailures.Add("File rollback failed: $($record.destination): $($_.Exception.Message)")
            }
        }
        if ($rollbackFailures.Count -eq 0 -and (Test-Path -LiteralPath $statePath -PathType Leaf)) {
            Remove-Item -LiteralPath $statePath -Force
        }
        if ($rollbackFailures.Count -gt 0) {
            throw "$($failure.Exception.Message)`n$($rollbackFailures -join "`n")"
        }
        throw $failure
    }
}

function Update-Patch([object]$Release) {
    Assert-GameClosed
    Assert-Package $Release
    $game = Get-GameInfo $Release
    $installedHash = ([string]$game.Block.installed_pak_sha256).ToLowerInvariant()
    if ($game.PakHash -ne $installedHash) {
        throw 'The runtime update requires the existing SafePatch PAK bridge. Install the patch first.'
    }

    $statePath = Join-Path $game.BackupRoot $StateFileName
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        throw "SafePatch state not found: $statePath"
    }
    $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not [bool]$state.pak_patched -or
        ([string]$state.installed_pak_sha256).ToLowerInvariant() -ne $installedHash) {
        throw 'The installed SafePatch state does not match the active PAK bridge.'
    }

    $oldByPath = @{}
    foreach ($entry in @($state.files)) {
        $relative = [string]$entry.relative_path
        $oldByPath[$relative.ToLowerInvariant()] = $entry
    }

    foreach ($entry in @($Release.external_bridge.files)) {
        $relative = [string]$entry.relative_path
        $key = $relative.ToLowerInvariant()
        $destination = Resolve-SafeChild $game.Root $relative
        if (-not $oldByPath.ContainsKey($key) -and
            (Test-Path -LiteralPath $destination -PathType Leaf) -and
            (Get-FileSha256Lower $destination) -ne ([string]$entry.sha256).ToLowerInvariant()) {
            throw "New managed destination already contains an unrelated file: $relative"
        }
    }
    $newPaths = @{}
    foreach ($entry in @($Release.external_bridge.files)) {
        $newPaths[([string]$entry.relative_path).ToLowerInvariant()] = $true
    }
    $obsolete = [System.Collections.Generic.List[object]]::new()
    foreach ($relative in @($oldByPath.Keys)) {
        if (-not $newPaths.ContainsKey($relative)) {
            $obsolete.Add($oldByPath[$relative])
        }
    }

    $updateRoot = Join-Path $game.BackupRoot ('updates\' + (Get-Date -Format 'yyyyMMdd-HHmmssfff'))
    New-Item -ItemType Directory -Force -Path $updateRoot | Out-Null
    $stateBackup = Join-Path $updateRoot 'state.before.json'
    Copy-Item -LiteralPath $statePath -Destination $stateBackup
    $changed = [System.Collections.Generic.List[object]]::new()
    $newStateFiles = [System.Collections.Generic.List[object]]::new()

    try {
        foreach ($entry in @($obsolete)) {
            $relative = [string]$entry.relative_path
            $destination = Resolve-SafeChild $game.Root $relative
            $destinationExisted = Test-Path -LiteralPath $destination -PathType Leaf
            $rollbackFile = Resolve-SafeChild (Join-Path $updateRoot 'files') $relative
            if ($destinationExisted) {
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $rollbackFile) | Out-Null
                Copy-Item -LiteralPath $destination -Destination $rollbackFile
            }
            $changed.Add([pscustomobject]@{
                relative_path = $relative
                destination = $destination
                rollback_file = $rollbackFile
                existed = [bool]$destinationExisted
                target_sha256 = ''
            })
            if ([bool]$entry.original_existed) {
                $original = Resolve-SafeChild (Join-Path $game.BackupRoot 'files') $relative
                if (-not (Test-Path -LiteralPath $original -PathType Leaf)) {
                    throw "Original backup is missing for retired managed file: $relative"
                }
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
                Copy-Item -LiteralPath $original -Destination $destination -Force
            }
            elseif ($destinationExisted) {
                Remove-Item -LiteralPath $destination -Force
            }
        }

        foreach ($entry in @($Release.external_bridge.files)) {
            $relative = [string]$entry.relative_path
            $key = $relative.ToLowerInvariant()
            $source = Resolve-SafeChild $AssetsRoot ([string]$entry.payload)
            $destination = Resolve-SafeChild $game.Root $relative
            $destinationExisted = Test-Path -LiteralPath $destination -PathType Leaf
            $currentHash = if ($destinationExisted) { Get-FileSha256Lower $destination } else { '' }
            $targetHash = ([string]$entry.sha256).ToLowerInvariant()

            if ($currentHash -ne $targetHash) {
                $rollbackFile = Resolve-SafeChild (Join-Path $updateRoot 'files') $relative
                if ($destinationExisted) {
                    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $rollbackFile) | Out-Null
                    Copy-Item -LiteralPath $destination -Destination $rollbackFile
                }
                $changed.Add([pscustomobject]@{
                    relative_path = $relative
                    destination = $destination
                    rollback_file = $rollbackFile
                    existed = [bool]$destinationExisted
                    target_sha256 = $targetHash
                })

                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
                $temporary = $destination + ".lotm-update-$PID.tmp"
                if (Test-Path -LiteralPath $temporary) {
                    throw "Temporary update path already exists: $temporary"
                }
                Copy-Item -LiteralPath $source -Destination $temporary
                if ((Get-FileSha256Lower $temporary) -ne $targetHash) {
                    Remove-Item -LiteralPath $temporary -Force
                    throw "Staged update file failed verification: $relative"
                }
                Move-Item -LiteralPath $temporary -Destination $destination -Force
                if ((Get-FileSha256Lower $destination) -ne $targetHash) {
                    throw "Updated file failed verification: $relative"
                }
            }

            $old = if ($oldByPath.ContainsKey($key)) { $oldByPath[$key] } else { $null }
            $newStateFiles.Add([pscustomobject]@{
                relative_path = $relative
                source_sha256 = $targetHash
                original_existed = if ($null -ne $old) { [bool]$old.original_existed } else { $false }
            })
        }

        $state.package_release = [string]$Release.release_id
        $state.files = @($newStateFiles)
        $state | Add-Member -NotePropertyName updated_at -NotePropertyValue (Get-Date).ToString('o') -Force
        $state | Add-Member -NotePropertyName last_update_backup -NotePropertyValue $updateRoot -Force
        $stateTemporary = $statePath + ".lotm-update-$PID.tmp"
        $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $stateTemporary -Encoding UTF8
        Move-Item -LiteralPath $stateTemporary -Destination $statePath -Force

        Verify-Patch $Release
        Write-Host "LOTM English runtime updated successfully ($($Release.display_version))." -ForegroundColor Green
        Write-Host "Rollback snapshot: $updateRoot"
    }
    catch {
        foreach ($record in @($changed) | Select-Object -Reverse) {
            if ([bool]$record.existed) {
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([string]$record.destination)) | Out-Null
                Copy-Item -LiteralPath ([string]$record.rollback_file) -Destination ([string]$record.destination) -Force
            }
            elseif (Test-Path -LiteralPath ([string]$record.destination) -PathType Leaf) {
                Remove-Item -LiteralPath ([string]$record.destination) -Force
            }
        }
        Copy-Item -LiteralPath $stateBackup -Destination $statePath -Force
        throw
    }
}

function Uninstall-Patch([object]$Release) {
    Assert-GameClosed
    $game = Get-GameInfo $Release
    $statePath = Join-Path $game.BackupRoot $StateFileName
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
        throw "No safe-patch backup state found at $statePath"
    }
    $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $installedHash = ([string]$state.installed_pak_sha256).ToLowerInvariant()
    $originalHash = ([string]$state.original_pak_sha256).ToLowerInvariant()

    if ($game.PakHash -eq $installedHash) {
        $fullBackupPath = if ($state.PSObject.Properties.Name -contains 'full_pak_backup') { [string]$state.full_pak_backup } else { '' }
        if ($fullBackupPath -and (Test-Path -LiteralPath $fullBackupPath -PathType Leaf)) {
            if ((Get-FileSha256Lower $fullBackupPath) -ne $originalHash) { throw 'Full original PAK backup hash mismatch.' }
            $removedPak = $game.Pak + '.lotm-safe-remove'
            if (Test-Path -LiteralPath $removedPak) { throw "Temporary uninstall path already exists: $removedPak" }
            try {
                Move-Item -LiteralPath $game.Pak -Destination $removedPak
                Move-Item -LiteralPath $fullBackupPath -Destination $game.Pak
                if ((Get-FileSha256Lower $game.Pak) -ne $originalHash) { throw 'Restored full PAK hash mismatch.' }
                Remove-Item -LiteralPath $removedPak -Force
            }
            catch {
                if (-not (Test-Path -LiteralPath $game.Pak) -and (Test-Path -LiteralPath $removedPak)) {
                    Move-Item -LiteralPath $removedPak -Destination $game.Pak
                }
                throw
            }
        }
        else {
            $backupBlock = Join-Path $game.BackupRoot 'LaunchInstance.original.oodle'
            if (-not (Test-Path -LiteralPath $backupBlock -PathType Leaf)) { throw 'Original PAK block backup is missing.' }
            $bytes = [System.IO.File]::ReadAllBytes($backupBlock)
            if ((Get-BytesSha256Lower $bytes) -ne ([string]$state.original_block_sha256).ToLowerInvariant()) {
                throw 'Original PAK block backup hash mismatch.'
            }
            Write-FileBlock $game.Pak ([int64]$game.Block.offset) $bytes
        }
        if ((Get-FileSha256Lower $game.Pak) -ne $originalHash) {
            throw 'The original PAK block was written, but the full PAK hash is unexpected. Run the official launcher repair.'
        }
    }
    elseif ($game.PakHash -ne $originalHash) {
        throw "The game PAK changed since installation. Refusing to overwrite it. Current SHA-256: $($game.PakHash)"
    }

    $warnings = [System.Collections.Generic.List[string]]::new()
    foreach ($entry in @($state.files)) {
        $destination = Resolve-SafeChild $game.Root ([string]$entry.relative_path)
        if ([bool]$entry.original_existed) {
            $backupFile = Resolve-SafeChild (Join-Path $game.BackupRoot 'files') ([string]$entry.relative_path)
            if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) {
                $warnings.Add("missing original file backup: $($entry.relative_path)")
                continue
            }
            if (Test-Path -LiteralPath $destination -PathType Leaf) {
                $currentHash = Get-FileSha256Lower $destination
                if ($currentHash -ne ([string]$entry.source_sha256).ToLowerInvariant()) {
                    $warnings.Add("kept user-modified file: $($entry.relative_path)")
                    continue
                }
            }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item -LiteralPath $backupFile -Destination $destination -Force
        }
        elseif (Test-Path -LiteralPath $destination -PathType Leaf) {
            $currentHash = Get-FileSha256Lower $destination
            if ($currentHash -eq ([string]$entry.source_sha256).ToLowerInvariant()) {
                Remove-Item -LiteralPath $destination -Force
            }
            else {
                $warnings.Add("kept user-modified file: $($entry.relative_path)")
            }
        }
    }

    $state | Add-Member -NotePropertyName uninstalled_at -NotePropertyValue (Get-Date).ToString('o') -Force
    $state.pak_patched = $false
    $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
    Write-Host 'LOTM English patch removed; original PAK restored.' -ForegroundColor Green
    if ($warnings.Count -gt 0) {
        Write-Warning ($warnings -join "`n")
    }
    Write-Host "Recovery backup retained at $($game.BackupRoot)"
}

function Verify-Patch([object]$Release) {
    Assert-Package $Release
    $game = Get-GameInfo $Release
    $cleanHash = Get-SupportedCleanHash $Release $game.PakSize
    $installedHash = ([string]$game.Block.installed_pak_sha256).ToLowerInvariant()
    $status = if ($game.PakHash -eq $installedHash) { 'installed' } elseif ($cleanHash -and $game.PakHash -eq $cleanHash) { 'clean' } else { 'unknown' }
    $missing = 0
    $changed = 0
    foreach ($entry in @($Release.external_bridge.files)) {
        $destination = Resolve-SafeChild $game.Root ([string]$entry.relative_path)
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { $missing++; continue }
        if ((Get-FileSha256Lower $destination) -ne ([string]$entry.sha256).ToLowerInvariant()) { $changed++ }
    }
    Write-Host "PAK status: $status"
    Write-Host "Translation files: $(@($Release.external_bridge.files).Count - $missing - $changed) valid, $missing missing, $changed changed"
    if ($status -eq 'installed' -and $missing -eq 0 -and $changed -eq 0) {
        Write-Host 'Patch verification passed.' -ForegroundColor Green
    }
    elseif ($status -eq 'clean' -and $missing -eq @($Release.external_bridge.files).Count) {
        Write-Host 'Game is clean; patch is not installed.' -ForegroundColor Yellow
    }
    else {
        throw 'Patch verification did not produce a consistent clean or installed state.'
    }
}

function Invoke-Main {
    $script:GameRoot = Resolve-GameRoot

    if ($Action -ne 'Verify' -and -not (Test-IsAdministrator)) {
        $quotedScript = '"' + $PSCommandPath.Replace('"', '\"') + '"'
        $quotedRoot = '"' + $GameRoot.Replace('"', '\"') + '"'
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File $quotedScript -Action $Action -GameRoot $quotedRoot"
        Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $arguments
        Write-Host 'Administrator approval requested in the Windows UAC dialog.' -ForegroundColor Yellow
        exit 0
    }

    $release = Get-Release
    switch ($Action) {
        'Install' { Install-Patch $release }
        'Update' { Update-Patch $release }
        'Uninstall' { Uninstall-Patch $release }
        'Verify' { Verify-Patch $release }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Invoke-Main
}
