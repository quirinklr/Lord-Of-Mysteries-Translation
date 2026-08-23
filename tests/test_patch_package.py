from __future__ import annotations

import hashlib
import json
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PATCH = ROOT / "patch"
ASSETS = PATCH / "assets"
RELEASE = ASSETS / "release.json"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


class PatchPackageTests(unittest.TestCase):
    def test_manifest_files_exist_and_match(self) -> None:
        release = json.loads(RELEASE.read_text(encoding="utf-8"))
        files = release["external_bridge"]["files"]
        self.assertEqual(len(files), len({entry["relative_path"].casefold() for entry in files}))
        for entry in files:
            path = ASSETS / entry["payload"]
            self.assertTrue(path.is_file(), path)
            self.assertEqual(entry["size"], path.stat().st_size, path)
            self.assertEqual(entry["sha256"], sha256(path), path)

    def test_runtime_audit_is_packaged(self) -> None:
        release = json.loads(RELEASE.read_text(encoding="utf-8"))
        self.assertEqual("1.0.2", release["external_bridge"]["runtime_version"])
        paths = {entry["relative_path"] for entry in release["external_bridge"]["files"]}
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/RuntimeTextCurated.lua", paths)
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/RuntimeIdCurated.lua", paths)
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/RuntimeContextCurated.lua", paths)
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/RuntimeStaticAudit.lua", paths)
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/RuntimeFullCorpusAudit.lua", paths)
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/RuntimeQualityFixes.lua", paths)
        self.assertIn("Saved/Mods/lua/mods/cpdd_runtime_fixes/GameModuleCatalog.lua", paths)

    def test_powershell_manager_parses(self) -> None:
        manager = PATCH / "Manage-LOTM-English.ps1"
        command = (
            "$e=$null;$t=$null;"
            f"[System.Management.Automation.Language.Parser]::ParseFile('{manager}',[ref]$t,[ref]$e)|Out-Null;"
            "if($e.Count){$e|ForEach-Object{$_.Message};exit 1}"
        )
        subprocess.run(["powershell.exe", "-NoProfile", "-Command", command], check=True)

    def test_manager_rejects_path_traversal(self) -> None:
        manager = PATCH / "Manage-LOTM-English.ps1"
        command = (
            f". '{manager}';"
            "try { Resolve-SafeChild 'C:\\safe-root' '..\\escape'; exit 1 } "
            "catch { exit 0 }"
        )
        subprocess.run(["powershell.exe", "-NoProfile", "-Command", command], check=True)

    def test_install_has_transactional_rollback(self) -> None:
        manager = (PATCH / "Manage-LOTM-English.ps1").read_text(encoding="utf-8")
        self.assertIn("$changedFiles", manager)
        self.assertIn("PAK rollback failed", manager)
        self.assertIn("File rollback failed", manager)

    def test_installer_reports_progress(self) -> None:
        manager = (PATCH / "Manage-LOTM-English.ps1").read_text(encoding="utf-8")
        self.assertIn("function Write-InstallStage", manager)
        self.assertIn("Validating release files", manager)
        self.assertIn("Locating and checking the game", manager)
        self.assertIn("Creating the recovery backup", manager)
        self.assertIn("Installing $(@($Release.external_bridge.files).Count) translation files", manager)
        self.assertIn("Applying and verifying the PAK bridge", manager)

    def test_release_is_portable(self) -> None:
        manager = (PATCH / "Manage-LOTM-English.ps1").read_text(encoding="utf-8")
        self.assertNotIn("C:\\Users\\quiri", manager)
        self.assertIn("Resolve-GameRoot", manager)
        self.assertTrue((PATCH / "START HERE.txt").is_file())
        for name in ("Install.cmd", "Update.cmd", "Verify.cmd", "Uninstall.cmd"):
            self.assertTrue((PATCH / name).is_file(), name)

    def test_update_repairs_managed_files(self) -> None:
        manager = (PATCH / "Manage-LOTM-English.ps1").read_text(encoding="utf-8")
        self.assertNotIn("Managed translation file is missing; refusing partial update", manager)
        self.assertNotIn("Managed translation file was modified; refusing to overwrite it", manager)
        self.assertIn("Original backup is missing for retired managed file", manager)
        self.assertIn("Rollback snapshot", manager)

    def test_release_builder_parses(self) -> None:
        builder = ROOT / "tools" / "build_release.ps1"
        command = (
            "$e=$null;$t=$null;"
            f"[System.Management.Automation.Language.Parser]::ParseFile('{builder}',[ref]$t,[ref]$e)|Out-Null;"
            "if($e.Count){$e|ForEach-Object{$_.Message};exit 1}"
        )
        subprocess.run(["powershell.exe", "-NoProfile", "-Command", command], check=True)


if __name__ == "__main__":
    unittest.main()
