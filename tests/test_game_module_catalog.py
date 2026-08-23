import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class GameModuleCatalogTests(unittest.TestCase):
    def test_catalog_has_full_official_pak_inventory(self) -> None:
        runtime_lines = (
            ROOT / "src" / "cpdd_runtime_fixes" / "GameModuleCatalog.lua"
        ).read_text(encoding="utf-8").splitlines()
        modules = [
            json.loads(line.strip().removesuffix(","))
            for line in runtime_lines
            if line.lstrip().startswith('"')
        ]
        self.assertEqual(25058, len(modules))
        self.assertEqual(
            419,
            sum(
                name.startswith("Data.Excel.")
                and not name.startswith("Data.Excel.Annotation.")
                for name in modules
            ),
        )
        self.assertEqual(
            1220,
            sum(name.startswith("Data.Excel.Annotation.") for name in modules),
        )
        self.assertEqual(len(modules), len(set(modules)))
        self.assertIn("Data.Excel.Annotation.Anno_DialogueTalkData", modules)
        self.assertIn("Data.Excel.Annotation.Anno_DialogueAssetData", modules)
        self.assertIn("Data.Excel.Annotation.Anno_WidgetBlueprintTextData", modules)

    def test_runtime_catalog_matches_packaged_copy(self) -> None:
        source = ROOT / "src" / "cpdd_runtime_fixes" / "GameModuleCatalog.lua"
        packaged = (
            ROOT
            / "patch"
            / "assets"
            / "payload"
            / "bridge"
            / "game"
            / "Saved"
            / "Mods"
            / "lua"
            / "mods"
            / "cpdd_runtime_fixes"
            / "GameModuleCatalog.lua"
        )
        self.assertEqual(source.read_bytes(), packaged.read_bytes())


if __name__ == "__main__":
    unittest.main()
