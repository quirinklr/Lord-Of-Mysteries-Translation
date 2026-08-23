from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.collect_unresolved import collect, find_logs, parse_marker


class CollectUnresolvedTests(unittest.TestCase):
    def test_structured_marker_round_trips_escapes(self) -> None:
        parsed = parse_marker(
            "prefix unresolved localized Chinese [aggregate-result]\t42\t\u7b2c\u4e00\u884c\\n\u7b2c\u4e8c\u884c\\t\u5c3e\\\\\u90e8"
        )
        self.assertEqual(
            ("aggregate-result", "42", "\u7b2c\u4e00\u884c\n\u7b2c\u4e8c\u884c\t\u5c3e\\\u90e8"),
            parsed,
        )

    def test_directory_collection_is_chronological_and_filters_diagnostics(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            older = root / "C7-backup.log"
            newer = root / "C7.log"
            older.write_text(
                "unresolved aggregate localization key \u65e7\u6587\u672c\n"
                "unresolved aggregate localization key <Empty>\n",
                encoding="utf-8",
            )
            newer.write_text(
                "unresolved aggregate localization key \u65b0\u6587\u672c\n"
                "unresolved aggregate localization key \u65e7\u6587\u672c\n",
                encoding="utf-8",
            )
            older.touch()
            newer.touch()
            entries = collect(find_logs(root), context_lines=0)
            self.assertEqual(["\u65e7\u6587\u672c", "\u65b0\u6587\u672c"], [entry["source"] for entry in entries])


if __name__ == "__main__":
    unittest.main()
