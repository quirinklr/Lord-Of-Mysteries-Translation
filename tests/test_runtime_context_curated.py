from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

from tools.generate_runtime_context_curated import load_entries


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "translations" / "runtime_context_curated.json"
GENERATOR = ROOT / "tools" / "generate_runtime_context_curated.py"


class ContextCuratedTests(unittest.TestCase):
    def test_catalog_validates_and_has_expected_coverage_after_merge(self) -> None:
        entries = load_entries(SOURCE)
        self.assertEqual(95, len(entries))
        keys = {(entry["table"], entry["source"]) for entry in entries}
        self.assertEqual(len(entries), len(keys))

    def test_generated_context_table_is_current(self) -> None:
        subprocess.run([sys.executable, str(GENERATOR), "--check"], cwd=ROOT, check=True)


if __name__ == "__main__":
    unittest.main()
