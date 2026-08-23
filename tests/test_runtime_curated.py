from __future__ import annotations

import json
import re
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CURATED = ROOT / "src" / "cpdd_runtime_fixes" / "RuntimeTextCurated.lua"
INIT = ROOT / "src" / "cpdd_runtime_fixes" / "Init.lua"
SOURCE = ROOT / "translations" / "runtime_curated.json"
GENERATOR = ROOT / "tools" / "generate_runtime_curated.py"
ID_GENERATOR = ROOT / "tools" / "generate_runtime_id_curated.py"
CONTEXT_GENERATOR = ROOT / "tools" / "generate_runtime_context_curated.py"

ENTRY = re.compile(
    r'\["((?:[^"\\]|\\.)*)"\]\s*=\s*"((?:[^"\\]|\\.)*)"',
    re.DOTALL,
)
CJK = re.compile(r"[\u3400-\u9fff]")


def decode_lua_string(value: str) -> str:
    return json.loads(f'"{value}"')


def read_entries() -> list[tuple[str, str]]:
    text = CURATED.read_text(encoding="utf-8")
    return [
        (decode_lua_string(source), decode_lua_string(translation))
        for source, translation in ENTRY.findall(text)
    ]


class CuratedRuntimeTextTests(unittest.TestCase):
    def test_expected_entry_count_and_no_duplicate_sources(self) -> None:
        entries = read_entries()
        self.assertGreaterEqual(len(entries), 18)
        self.assertEqual(len(entries), len(dict(entries)))

    def test_translations_are_nonempty_english(self) -> None:
        for source, translation in read_entries():
            self.assertTrue(source.strip())
            self.assertTrue(translation.strip())
            self.assertIsNone(CJK.search(translation), translation)

    def test_every_curated_source_is_packaged(self) -> None:
        source = {
            entry["source"]: entry["translation"]
            for entry in json.loads(SOURCE.read_text(encoding="utf-8"))
        }
        self.assertEqual(source, dict(read_entries()))

    def test_runtime_loader_imports_curated_map(self) -> None:
        init = INIT.read_text(encoding="utf-8")
        self.assertIn('require, "mods.cpdd_runtime_fixes.RuntimeTextCurated"', init)
        self.assertIn('local VERSION = "1.0.2"', init)

    def test_generated_runtime_table_is_current(self) -> None:
        subprocess.run(
            [sys.executable, str(GENERATOR), "--check"],
            cwd=ROOT,
            check=True,
        )
        subprocess.run(
            [sys.executable, str(ID_GENERATOR), "--check"],
            cwd=ROOT,
            check=True,
        )
        subprocess.run(
            [sys.executable, str(CONTEXT_GENERATOR), "--check"],
            cwd=ROOT,
            check=True,
        )


if __name__ == "__main__":
    unittest.main()
