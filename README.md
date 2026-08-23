# LOTM English Patch

Unofficial English patch for the Bilibili PC release of *Lord of Mysteries*.

Supported game build: `1.2018737.2044036`

## Install

1. Download and extract the latest release.
2. Close the game and launcher.
3. Run `Install.cmd`.
4. Approve the Windows administrator prompt.
5. Start the game normally.

The installer finds the default Bilibili installation automatically. If the game is elsewhere, it asks for the `C7` folder.

Use `Update.cmd`, `Verify.cmd`, or `Uninstall.cmd` for maintenance.

## Safety

- No third-party patch executable is used.
- No DLL injection or live process modification is used.
- Package files and the supported game build are checked with SHA-256.
- The original PAK block is backed up before installation.
- Unsupported or modified game builds are rejected.

## Coverage

The patch contains 38 language overlays, reviewed runtime fixes, a 25,058-module Lua corpus, 5,606 additional literal translations, and 1,056 English quality corrections. Runtime logging catches text delivered outside the packaged game corpus.

Text embedded in images or video is outside the Lua translation layer.

## Development

Requirements: Python 3.10+ and Windows PowerShell 5.1.

- `src` contains the maintained runtime source.
- `translations` contains the canonical editable translation data.
- `patch` contains the synchronized Windows release payload.
- `tools` contains build and audit utilities.
- `tests` contains package, generator, and repository checks.

Run `tools\sync_patch_package.py` after changing runtime source or translation data. Files under `patch\assets\payload\bridge\game\Saved\Mods\lua\cpdd_translation` are preserved compatibility bytecode and are not maintained source.

```powershell
python tools\sync_patch_package.py
python -m compileall -q tools tests
python -m unittest discover -s tests -v
dotnet build tools\iostore_inventory\iostore_inventory.csproj --configuration Release -p:RestoreLockedMode=true
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_release.ps1
```

## License

Project code is MIT licensed. Translation data, game-derived identifiers, and binary compatibility assets are excluded from the MIT license. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
