<h1 align="center">LOTM English Patch</h1>

<p align="center">Unofficial English patch for the Bilibili PC release of <em>Lord of Mysteries</em>.</p>

<p align="center">
  <a href="https://github.com/quirinklr/Lord-Of-Mysteries-Translation/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/quirinklr/Lord-Of-Mysteries-Translation"></a>
  <a href="https://github.com/quirinklr/Lord-Of-Mysteries-Translation/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/quirinklr/Lord-Of-Mysteries-Translation/actions/workflows/ci.yml/badge.svg"></a>
  <a href="LICENSE"><img alt="Code license" src="https://img.shields.io/badge/code_license-MIT-blue"></a>
</p>

<p align="center">
  <a href="https://github.com/quirinklr/Lord-Of-Mysteries-Translation/releases/latest">Download</a> ·
  <a href="#installation">Installation</a> ·
  <a href="https://github.com/quirinklr/Lord-Of-Mysteries-Translation/issues">Issues</a> ·
  <a href="CONTRIBUTING.md">Contributing</a>
</p>

Supported game version: `1.2018737.2044036` on Bilibili PC.

## Installation

1. Download the patch ZIP from the [latest release](https://github.com/quirinklr/Lord-Of-Mysteries-Translation/releases/latest).
2. Extract the ZIP completely.
3. Close the game and Bilibili launcher.
4. Run `Install.cmd` and approve the administrator prompt.
5. Start the game normally.

The installer detects the default game folder. If detection fails, select the `C7` folder when prompted.

No Python, .NET, Git, third-party patch executable, or network accelerator is required.

## Maintenance

| File | Purpose |
| --- | --- |
| `Update.cmd` | Update an existing patch installation |
| `Verify.cmd` | Check the PAK bridge and every managed file |
| `Uninstall.cmd` | Restore the original game files |

## Safety

- Verifies the package and supported game PAK with SHA-256.
- Backs up the original PAK block before installation.
- Rejects unsupported or modified game builds.
- Does not inject a DLL or modify a running process.

## Limitations

Text embedded in images or video is outside the Lua translation layer. Game updates may require a new patch release.

## Contributing

Translation corrections, bug reports, and code changes are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Development

Requirements: Python 3.10+, .NET 10 SDK, and Windows PowerShell 5.1.

```powershell
python tools\sync_patch_package.py
python -m compileall -q tools tests
python -m unittest discover -s tests -v
dotnet build tools\iostore_inventory\iostore_inventory.csproj --configuration Release -p:RestoreLockedMode=true
```

Maintained translation data lives in `translations`. Generated Lua payloads live in `src` and `patch`. The preserved compatibility bytecode under `patch/assets/payload/bridge/game/Saved/Mods/lua/cpdd_translation` is not maintained source.

## License

Project code is licensed under MIT. Translation data, game-derived identifiers, and compatibility assets are excluded from the MIT license. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
