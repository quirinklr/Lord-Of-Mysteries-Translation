# Contributing

Use an issue for bug reports and translation corrections. Use a pull request for finished changes.

## Translation changes

Edit the canonical JSON files in `translations`. Do not edit generated Lua files in `src` or `patch` directly.

Include the following with a correction:

- Current English text
- Suggested English text
- Original Chinese text, if available
- In-game location or quest
- Screenshot, if useful

Preserve placeholders, markup, escape sequences, and formatting tokens.

## Code changes

Keep changes focused and written in English. Do not commit game logs, extracted executables, build output, temporary audits, account data, or release archives.

Run before submitting:

```powershell
python tools\sync_patch_package.py
python -m compileall -q tools tests
python -m unittest discover -s tests -v
dotnet build tools\iostore_inventory\iostore_inventory.csproj --configuration Release -p:RestoreLockedMode=true
```

Open the pull request from a topic branch. CI must pass before merge.
