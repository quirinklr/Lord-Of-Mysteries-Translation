from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path


def read_report(path: Path) -> tuple[list[dict[str, object]], dict[str, object]]:
    records: list[dict[str, object]] = []
    summary: dict[str, object] | None = None
    with path.open("r", encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as error:
                raise ValueError(f"{path}:{line_number}: {error}") from error
            if record.get("type") == "summary":
                summary = record
            else:
                records.append(record)
    if summary is None:
        raise ValueError(f"{path}: missing final summary")
    return records, summary


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    records, summary = read_report(args.report)
    args.output_dir.mkdir(parents=True, exist_ok=True)

    contexts: dict[str, set[str]] = defaultdict(set)
    paired_sources: set[str] = set()
    quality_rows: list[dict[str, object]] = []
    errors: list[dict[str, object]] = []

    for record in records:
        kind = record.get("type")
        if kind == "literal":
            source = str(record.get("source", ""))
            module = str(record.get("module", ""))
            if source:
                contexts[source].add(module)
        elif kind == "translation-pair":
            source = str(record.get("source", ""))
            if source:
                paired_sources.add(source)
            quality_rows.append(record)
        elif kind == "pair-error":
            errors.append(record)

    queue = [
        {
            "source": source,
            "translation": "",
            "modules": sorted(modules, key=str.casefold),
        }
        for source, modules in contexts.items()
        if source not in paired_sources
    ]
    queue.sort(key=lambda row: str(row["source"]))
    quality_rows.sort(
        key=lambda row: (
            str(row.get("table", "")).casefold(),
            str(row.get("path", "")).casefold(),
        )
    )

    (args.output_dir / "full-translation-queue.json").write_text(
        json.dumps(queue, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    with (args.output_dir / "english-quality-corpus.jsonl").open(
        "w", encoding="utf-8", newline="\n"
    ) as output:
        for row in quality_rows:
            output.write(json.dumps(row, ensure_ascii=False) + "\n")
    (args.output_dir / "full-corpus-summary.json").write_text(
        json.dumps(
            {
                "runtime_summary": summary,
                "unique_cjk_literals": len(contexts),
                "unpaired_literals": len(queue),
                "translation_pairs": len(quality_rows),
                "pair_errors": errors,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(
        f"literals={len(contexts)} unpaired={len(queue)} "
        f"quality_pairs={len(quality_rows)} pair_errors={len(errors)}"
    )


if __name__ == "__main__":
    main()
