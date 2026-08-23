from __future__ import annotations

import argparse
import bisect
import json
import re
from collections import defaultdict
from pathlib import Path

import language_tool_python


CUSTOM_RULES = {
    "OBJECT_PRONOUN_AFTER_VERB": re.compile(
        r"\b(?:send|sent|give|gave|tell|told|ask|asked|show|showed|take|took|"
        r"bring|brought|help|helped|follow|followed|see|saw|meet|met|call|called|"
        r"kill|killed|save|saved|protect|protected|join|joined|leave|left)\s+"
        r"(?:he|she|they|we|I)\b",
        re.IGNORECASE,
    ),
    "SUBJECT_VERB_AGREEMENT": re.compile(
        r"\b(?:he|she|it)\s+(?:are|were|have|do|don't)\b|"
        r"\b(?:they|we|you)\s+(?:is|was|has|does)\b|"
        r"\bI\s+(?:is|are|has)\b",
        re.IGNORECASE,
    ),
    "BROKEN_MISS_TITLE": re.compile(r"\bMis\s+s\b", re.IGNORECASE),
    "DUPLICATE_WORD": re.compile(r"\b([A-Za-z]{3,})\s+\1\b", re.IGNORECASE),
}
TAG_PATTERN = re.compile(r"<[^>]*>|\{[^{}]*\}|%[-+0-9.#]*[A-Za-z%]")


def sanitized(value: str) -> str:
    return TAG_PATTERN.sub(lambda match: " " * len(match.group(0)), value)


def load_rows(path: Path) -> tuple[list[dict[str, object]], dict[str, list[int]]]:
    rows: list[dict[str, object]] = []
    indices: dict[str, list[int]] = defaultdict(list)
    with path.open("r", encoding="utf-8") as stream:
        for line in stream:
            if not line.strip():
                continue
            row = json.loads(line)
            translation = str(row.get("translation", ""))
            if translation not in indices:
                rows.append(row)
            indices[translation].append(len(rows) - 1)
    return rows, indices


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("corpus", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--batch-chars", type=int, default=12000)
    args = parser.parse_args()

    unique_rows: list[dict[str, object]] = []
    provenance: dict[str, list[dict[str, object]]] = defaultdict(list)
    raw = args.corpus.read_text(encoding="utf-8")
    input_rows = json.loads(raw) if raw.lstrip().startswith("[") else (
        json.loads(line) for line in raw.splitlines() if line.strip()
    )
    for row in input_rows:
        translation = str(row.get("translation", ""))
        if not provenance[translation]:
            unique_rows.append(row)
        provenance[translation].append(row)

    findings: dict[tuple[str, str, int, int], dict[str, object]] = {}

    def add_finding(
        row: dict[str, object], rule: str, message: str, offset: int, length: int,
        replacements: list[str] | None = None,
    ) -> None:
        translation = str(row.get("translation", ""))
        key = (translation, rule, offset, length)
        findings[key] = {
            "rule": rule,
            "message": message,
            "offset": offset,
            "length": length,
            "context": translation[max(0, offset - 80): offset + length + 80],
            "replacements": replacements or [],
            "translation": translation,
            "occurrences": len(provenance[translation]),
            "examples": provenance[translation][:3],
        }

    for row in unique_rows:
        text = str(row.get("translation", ""))
        for rule, pattern in CUSTOM_RULES.items():
            for match in pattern.finditer(text):
                add_finding(row, rule, "Deterministic grammar pattern", match.start(), len(match.group(0)))

    tool = language_tool_python.LanguageTool("en-US")
    try:
        index = 0
        while index < len(unique_rows):
            batch: list[dict[str, object]] = []
            starts: list[int] = []
            parts: list[str] = []
            size = 0
            while index < len(unique_rows):
                text = sanitized(str(unique_rows[index].get("translation", "")))
                addition = len(text) + (2 if parts else 0)
                if parts and size + addition > args.batch_chars:
                    break
                if parts:
                    parts.append("\n\n")
                    size += 2
                starts.append(size)
                parts.append(text)
                size += len(text)
                batch.append(unique_rows[index])
                index += 1

            combined = "".join(parts)
            for match in tool.check(combined):
                if str(match.category) != "GRAMMAR":
                    continue
                row_index = bisect.bisect_right(starts, match.offset) - 1
                if row_index < 0:
                    continue
                local_offset = match.offset - starts[row_index]
                row_text = str(batch[row_index].get("translation", ""))
                if local_offset < 0 or local_offset + match.error_length > len(row_text):
                    continue
                add_finding(
                    batch[row_index],
                    match.rule_id,
                    match.message,
                    local_offset,
                    match.error_length,
                    list(match.replacements[:8]),
                )
            if index % 10000 < len(batch):
                print(f"checked {index}/{len(unique_rows)} unique translations", flush=True)
    finally:
        tool.close()

    result = sorted(
        findings.values(),
        key=lambda row: (str(row["rule"]), str(row["translation"]), int(row["offset"])),
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"quality findings={len(result)} unique translations={len(unique_rows)}")


if __name__ == "__main__":
    main()
