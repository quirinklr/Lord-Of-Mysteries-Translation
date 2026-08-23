from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path


CJK = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")
TOKEN = re.compile(r"<[^>]*>|\{\{[^{}]*\}\}|\{[^{}]*\}|%[-+0-9.#]*[A-Za-z%]")


def lua_quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("corpus", type=Path)
    parser.add_argument("reviewed", type=Path)
    parser.add_argument("--seed", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--lua", type=Path, required=True)
    args = parser.parse_args()

    occurrences: Counter[str] = Counter()
    with args.corpus.open("r", encoding="utf-8") as stream:
        for line in stream:
            if line.strip():
                occurrences[str(json.loads(line).get("translation", ""))] += 1

    corrections: dict[str, dict[str, object]] = {}

    def add(source: str, target: str, reason: str, origin: str, allow_absent: bool = False) -> None:
        if not source or not target or source == target:
            raise ValueError(f"{origin}: invalid correction")
        if source not in occurrences and not allow_absent:
            raise ValueError(f"{origin}: source translation not present in corpus: {source!r}")
        if CJK.search(target):
            raise ValueError(f"{origin}: corrected English still contains CJK")
        if TOKEN.findall(source) != TOKEN.findall(target):
            raise ValueError(f"{origin}: markup/placeholders changed for {source!r}")
        existing = corrections.get(source)
        if existing and existing["translation"] != target:
            raise ValueError(
                f"conflicting corrections for {source!r}: "
                f"{existing['translation']!r} vs {target!r} ({origin})"
            )
        corrections[source] = {
            "source": source,
            "translation": target,
            "reason": reason,
            "occurrences": occurrences.get(source, 0),
        }

    for row in json.loads(args.seed.read_text(encoding="utf-8")):
        add(
            str(row["source"]), str(row["translation"]),
            str(row.get("scene") or row.get("reason") or "Reviewed correction"),
            str(args.seed), True,
        )

    reviewed_rows: list[tuple[dict[str, object], str]] = []
    for path in sorted(args.reviewed.glob("quality-*.json")):
        for row in json.loads(path.read_text(encoding="utf-8")):
            reviewed_rows.append((row, str(path)))

    for row, origin in reviewed_rows:
        add(
            str(row["source_translation"]), str(row["corrected_translation"]),
            str(row.get("reason") or "Manually reviewed grammar correction"), origin,
        )

    for source in occurrences:
        if source.startswith("Use to ") and source not in corrections:
            add(
                source,
                "Use this item to " + source[len("Use to "):],
                "Expanded elliptical item-tooltip imperative for grammatical English.",
                "systematic USE_TO_VERB review",
            )

    rows = sorted(corrections.values(), key=lambda row: str(row["source"]).casefold())
    args.json.write_text(
        json.dumps(rows, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    with args.lua.open("w", encoding="utf-8", newline="\n") as output:
        output.write("return {\n")
        for row in rows:
            output.write(f"    [{lua_quote(row['source'])}] = {lua_quote(row['translation'])},\n")
        output.write("}\n")
    print(f"merged {len(rows)} reviewed English quality corrections")


if __name__ == "__main__":
    main()
