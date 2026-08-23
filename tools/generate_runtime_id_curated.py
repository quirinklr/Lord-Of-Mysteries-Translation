from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "translations" / "runtime_id_curated.json"
OUTPUT = ROOT / "src" / "cpdd_runtime_fixes" / "RuntimeIdCurated.lua"
CJK = re.compile(r"[\u3400-\u9fff]")


def lua_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def validate_entry(entry: dict[str, object]) -> tuple[str | None, int, str]:
    scope = str(entry.get("scope", ""))
    tag = entry.get("tag")
    if scope == "aggregate":
        normalized_tag = None
    elif scope == "split" and isinstance(tag, str) and tag:
        normalized_tag = tag
    else:
        raise ValueError(f"invalid scope/tag: {entry!r}")
    language_id = entry.get("id")
    if not isinstance(language_id, int) or language_id < 0:
        raise ValueError(f"invalid localization id: {entry!r}")
    translation = entry.get("translation")
    if not isinstance(translation, str) or not translation.strip() or CJK.search(translation):
        raise ValueError(f"translation must be nonempty English: {entry!r}")
    source = entry.get("source")
    if not isinstance(source, str) or not source:
        raise ValueError(f"source must be retained for review: {entry!r}")
    return normalized_tag, language_id, translation


def generate(document: dict[str, object]) -> str:
    if document.get("format_version") != 1 or not isinstance(document.get("entries"), list):
        raise ValueError("unsupported runtime ID catalog")
    aggregate: dict[int, str] = {}
    split: dict[str, dict[int, str]] = {}
    for raw_entry in document["entries"]:
        if not isinstance(raw_entry, dict):
            raise ValueError(f"entry must be an object: {raw_entry!r}")
        tag, language_id, translation = validate_entry(raw_entry)
        target = aggregate if tag is None else split.setdefault(tag, {})
        if language_id in target:
            raise ValueError(f"duplicate localization ID: {tag or 'aggregate'}:{language_id}")
        target[language_id] = translation

    lines = ["return {", "    Aggregate = {"]
    for language_id, translation in sorted(aggregate.items()):
        lines.append(f"        [{language_id}] = {lua_string(translation)},")
    lines.extend(["    },", "    Split = {"])
    for tag in sorted(split, key=str.casefold):
        lines.append(f"        [{lua_string(tag)}] = {{")
        for language_id, translation in sorted(split[tag].items()):
            lines.append(f"            [{language_id}] = {lua_string(translation)},")
        lines.append("        },")
    lines.extend(["    },", "}", ""])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    rendered = generate(json.loads(SOURCE.read_text(encoding="utf-8")))
    if args.check:
        if not OUTPUT.is_file() or OUTPUT.read_text(encoding="utf-8") != rendered:
            raise SystemExit(f"generated file is stale: {OUTPUT}")
        print(f"Validated {OUTPUT}")
        return
    OUTPUT.write_text(rendered, encoding="utf-8", newline="\n")
    print(f"Generated {OUTPUT}")


if __name__ == "__main__":
    main()
