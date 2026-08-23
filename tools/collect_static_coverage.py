from __future__ import annotations

import argparse
import json
from pathlib import Path


def load_report(path: Path) -> tuple[list[dict[str, object]], dict[str, object]]:
    records: list[dict[str, object]] = []
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not raw_line.strip():
            continue
        try:
            record = json.loads(raw_line)
        except json.JSONDecodeError as error:
            raise ValueError(f"invalid JSON on line {line_number}: {error}") from error
        if not isinstance(record, dict) or "type" not in record:
            raise ValueError(f"invalid record on line {line_number}")
        records.append(record)

    summaries = [record for record in records if record.get("type") == "summary"]
    if len(summaries) != 1 or records[-1] is not summaries[0]:
        raise ValueError("report must end with exactly one summary record")
    return records, summaries[0]


def build_queue(records: list[dict[str, object]], summary: dict[str, object]) -> dict[str, object]:
    tables = [record for record in records if record.get("type") == "table-summary"]
    failed = [record for record in tables if record.get("loaded") is not True]
    if failed:
        details = "; ".join(
            f"{record.get('table')}: {record.get('load_error')}" for record in failed
        )
        raise ValueError(f"localization tables failed to load: {details}")
    if int(summary.get("failed_tables", 0)) != 0:
        raise ValueError("summary reports failed localization tables")
    if int(summary.get("loaded_tables", -1)) != len(tables):
        raise ValueError("summary/table count mismatch")

    seen: set[tuple[str, str, str, str]] = set()
    gaps: list[dict[str, str]] = []
    for record in records:
        if record.get("type") != "gap":
            continue
        identity = tuple(str(record.get(field, "")) for field in ("table", "key", "field", "source"))
        if not all(identity):
            raise ValueError(f"incomplete gap record: {record!r}")
        if identity in seen:
            continue
        seen.add(identity)
        table, key, field, source = identity
        gaps.append(
            {
                "table": table,
                "key": key,
                "field": field,
                "source": source,
                "translation": "",
                "status": "needs-review",
            }
        )

    gaps.sort(key=lambda value: (value["table"].casefold(), value["key"], value["field"], value["source"]))
    expected = int(summary.get("unresolved", -1))
    if expected < len(gaps):
        raise ValueError("summary unresolved count is smaller than the unique gap count")

    return {
        "format_version": 1,
        "runtime_version": summary.get("runtime_version"),
        "audit_id": summary.get("audit_id"),
        "table_count": len(tables),
        "rows_scanned": int(summary.get("rows", 0)),
        "strings_scanned": int(summary.get("strings", 0)),
        "reported_gap_count": expected,
        "unique_gap_count": len(gaps),
        "gaps": gaps,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    records, summary = load_report(args.report)
    queue = build_queue(records, summary)
    encoded = json.dumps(queue, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8", newline="\n")
    else:
        print(encoded, end="")


if __name__ == "__main__":
    main()
