from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


CJK = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")
TOKEN = re.compile(r"<[^>]*>|\{\{[^{}]*\}\}|\{[^{}]*\}|%[-+0-9.#]*[A-Za-z%]")


def lua_quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("queue", type=Path)
    parser.add_argument("chunks", type=Path)
    parser.add_argument("--corrections", type=Path, nargs="*")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--lua", type=Path, required=True)
    args = parser.parse_args()

    expected = json.loads(args.queue.read_text(encoding="utf-8"))
    expected_by_source = {row["source"]: row for row in expected}
    if len(expected_by_source) != len(expected):
        raise ValueError("source queue contains duplicate sources")

    merged: dict[str, dict[str, object]] = {}
    for path in sorted(args.chunks.glob("chunk-*.json")):
        for row in json.loads(path.read_text(encoding="utf-8")):
            source = row.get("source")
            translation = row.get("translation")
            if source not in expected_by_source:
                raise ValueError(f"{path}: unknown source {source!r}")
            if source in merged:
                raise ValueError(f"{path}: duplicate source {source!r}")
            if row.get("modules") != expected_by_source[source].get("modules"):
                raise ValueError(f"{path}: modules changed for {source!r}")
            if not isinstance(translation, str) or not translation.strip():
                raise ValueError(f"{path}: empty translation for {source!r}")
            if CJK.search(translation):
                raise ValueError(f"{path}: CJK remains in translation for {source!r}")
            source_tokens = TOKEN.findall(source)
            translated_tokens = TOKEN.findall(translation)
            if source_tokens != translated_tokens:
                raise ValueError(
                    f"{path}: markup/token mismatch for {source!r}: "
                    f"{source_tokens!r} != {translated_tokens!r}"
                )
            if source.count("#") != translation.count("#"):
                raise ValueError(f"{path}: # markup count changed for {source!r}")
            merged[source] = row

    missing = sorted(set(expected_by_source) - set(merged))
    if missing:
        raise ValueError(f"missing {len(missing)} translations; first={missing[0]!r}")

    if args.corrections:
        for correction_path in args.corrections:
            for correction in json.loads(correction_path.read_text(encoding="utf-8")):
                source = correction.get("source")
                current = correction.get("current_translation")
                translated = correction.get("corrected_translation")
                if source not in merged:
                    raise ValueError(f"correction references unknown source {source!r}")
                if merged[source].get("translation") != current:
                    raise ValueError(f"stale correction for {source!r}")
                if not isinstance(translated, str) or not translated.strip() or CJK.search(translated):
                    raise ValueError(f"invalid corrected translation for {source!r}")
                if TOKEN.findall(source) != TOKEN.findall(translated):
                    raise ValueError(f"correction changes markup/tokens for {source!r}")
                if source.count("#") != translated.count("#"):
                    raise ValueError(f"correction changes # markup for {source!r}")
                merged[source]["translation"] = translated

    rows = [merged[source] for source in sorted(merged)]
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(
        json.dumps(rows, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    args.lua.parent.mkdir(parents=True, exist_ok=True)
    with args.lua.open("w", encoding="utf-8", newline="\n") as output:
        output.write("return {\n")
        for row in rows:
            output.write(f"    [{lua_quote(row['source'])}] = {lua_quote(row['translation'])},\n")
        output.write("}\n")
    print(f"merged and validated {len(rows)} full-corpus translations")


if __name__ == "__main__":
    main()
