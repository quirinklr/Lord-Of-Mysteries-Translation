# Contributing

Keep changes focused and written in English.

Before submitting a change, run:

```powershell
python tools\sync_patch_package.py
python -m compileall -q tools tests
python -m unittest discover -s tests -v
dotnet build tools\iostore_inventory\iostore_inventory.csproj --configuration Release -p:RestoreLockedMode=true
```

Do not commit game logs, temporary audits, build output, extracted executables, or personal account data.
