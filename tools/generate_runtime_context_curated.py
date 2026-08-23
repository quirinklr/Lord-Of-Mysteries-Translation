from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "translations" / "runtime_context_curated.json"
OUTPUT = ROOT / "src" / "cpdd_runtime_fixes" / "RuntimeContextCurated.lua"
CJK = re.compile(r"[\u3400-\u9fff]")
MARKUP = re.compile(r"<[^>]*>")
PERCENT_PLACEHOLDER = re.compile(r"%(?:\d+\$)?[-+#0 ]*(?:\d+|\*)?(?:\.\d+)?[cdeEfgGiouqsxX%]")
GAME_PLACEHOLDER = re.compile(r"\*[A-Za-z]+\**")


def lua_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def structural_braces(value: str) -> str:
    normalized = value.replace("【", "[").replace("】", "]")
    return "".join(character for character in normalized if character in "{}[]")


def load_entries(path: Path) -> list[dict[str, str]]:
    document = json.loads(path.read_text(encoding="utf-8"))
    if document.get("format_version") != 1 or not isinstance(document.get("entries"), list):
        raise ValueError("unsupported context translation catalog")
    entries: list[dict[str, str]] = []
    seen: set[tuple[str, str]] = set()
    for index, raw in enumerate(document["entries"], 1):
        if not isinstance(raw, dict):
            raise ValueError(f"entry {index} is not an object")
        required = ("table", "key", "field", "source", "translation")
        if not all(isinstance(raw.get(name), str) and raw[name] for name in required):
            raise ValueError(f"entry {index} requires non-empty {required}")
        entry = {name: str(raw[name]) for name in required}
        identity = (entry["table"], entry["source"])
        if identity in seen:
            raise ValueError(f"duplicate table/source at entry {index}: {identity!r}")
        seen.add(identity)
        if not CJK.search(entry["source"]):
            raise ValueError(f"entry {index} source contains no CJK text")
        if CJK.search(entry["translation"]):
            raise ValueError(f"entry {index} translation still contains CJK text")
        for label, pattern in (
            ("markup", MARKUP),
            ("percent placeholder", PERCENT_PLACEHOLDER),
            ("game placeholder", GAME_PLACEHOLDER),
        ):
            if pattern.findall(entry["source"]) != pattern.findall(entry["translation"]):
                raise ValueError(f"entry {index} changes {label}s")
        if structural_braces(entry["source"]) != structural_braces(entry["translation"]):
            raise ValueError(f"entry {index} changes brace structure")
        if entry["source"].count("\n") != entry["translation"].count("\n"):
            raise ValueError(f"entry {index} changes line count")
        entries.append(entry)
    return entries


def render(entries: list[dict[str, str]]) -> str:
    grouped: dict[str, list[dict[str, str]]] = {}
    for entry in entries:
        grouped.setdefault(entry["table"], []).append(entry)
    lines = ["return {"]
    for table_name in sorted(grouped, key=str.casefold):
        lines.append(f"    [{lua_string(table_name)}] = {{")
        for entry in sorted(grouped[table_name], key=lambda value: (value["key"], value["source"])):
            lines.append(f"        [{lua_string(entry['source'])}] = {lua_string(entry['translation'])},")
        lines.append("    },")
    lines.extend(["}", ""])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    rendered = render(load_entries(SOURCE))
    if args.check:
        if not OUTPUT.is_file() or OUTPUT.read_text(encoding="utf-8") != rendered:
            raise SystemExit(f"generated file is stale: {OUTPUT}")
        print(f"Validated {OUTPUT}")
        return
    OUTPUT.write_text(rendered, encoding="utf-8", newline="\n")
    print(f"Generated {OUTPUT}")


if __name__ == "__main__":
    main()
