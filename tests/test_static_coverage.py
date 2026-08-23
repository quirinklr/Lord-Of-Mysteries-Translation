from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.collect_static_coverage import build_queue, load_report


class StaticCoverageTests(unittest.TestCase):
    def test_report_is_validated_and_deduplicated(self) -> None:
        records = [
            {"type": "gap", "table": "T", "key": "2", "field": "RawText", "source": "\u4e2d\u6587"},
            {"type": "gap", "table": "T", "key": "2", "field": "RawText", "source": "\u4e2d\u6587"},
            {"type": "table-summary", "table": "T", "loaded": True, "load_error": None},
            {
                "type": "summary",
                "runtime_version": "0.8.16",
                "audit_id": "build-test",
                "loaded_tables": 1,
                "failed_tables": 0,
                "rows": 2,
                "strings": 2,
                "unresolved": 2,
            },
        ]
        queue = build_queue(records, records[-1])
        self.assertEqual(1, queue["unique_gap_count"])
        self.assertEqual("\u4e2d\u6587", queue["gaps"][0]["source"])

    def test_failed_table_is_rejected(self) -> None:
        records = [
            {"type": "table-summary", "table": "T", "loaded": False, "load_error": "boom"},
            {"type": "summary", "loaded_tables": 0, "failed_tables": 1, "unresolved": 0},
        ]
        with self.assertRaisesRegex(ValueError, "failed to load"):
            build_queue(records, records[-1])

    def test_loader_requires_final_summary(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.jsonl"
            path.write_text(json.dumps({"type": "gap"}) + "\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "summary"):
                load_report(path)


if __name__ == "__main__":
    unittest.main()
