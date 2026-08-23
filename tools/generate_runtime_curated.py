from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "translations" / "runtime_curated.json"
DEFAULT_OUTPUT = ROOT / "src" / "cpdd_runtime_fixes" / "RuntimeTextCurated.lua"
CJK = re.compile(r"[\u3400-\u9fff]")
MARKUP = re.compile(r"<[^>]*>")
PLACEHOLDER = re.compile(r"%(?:\d+\$)?[-+#0 ]*(?:\d+|\*)?(?:\.\d+)?[cdeEfgGiouqsxX%]")


def load_entries(path: Path) -> list[dict[str, str]]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, list):
        raise ValueError("translation source must be a JSON array")

    entries: list[dict[str, str]] = []
    seen: set[str] = set()
    for index, raw in enumerate(value, 1):
        if not isinstance(raw, dict):
            raise ValueError(f"entry {index} is not an object")
        entry = {name: raw.get(name) for name in ("scene", "source", "translation")}
        if not all(isinstance(item, str) and item for item in entry.values()):
            raise ValueError(f"entry {index} requires non-empty scene/source/translation")
        source = entry["source"]
        translation = entry["translation"]
        if source in seen:
            raise ValueError(f"duplicate source at entry {index}: {source}")
        seen.add(source)
        if not CJK.search(source):
            raise ValueError(f"entry {index} source contains no CJK text")
        if CJK.search(translation):
            raise ValueError(f"entry {index} translation still contains CJK text")
        if MARKUP.findall(source) != MARKUP.findall(translation):
            raise ValueError(f"entry {index} changes markup tags")
        if PLACEHOLDER.findall(source) != PLACEHOLDER.findall(translation):
            raise ValueError(f"entry {index} changes format placeholders")
        entries.append(entry)
    return entries


def lua_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def render(entries: list[dict[str, str]]) -> str:
    lines = ["return {"]
    for entry in entries:
        lines.append(f"    [{lua_string(entry['source'])}] =")
        lines.append(f"        {lua_string(entry['translation'])},")
    lines.extend(["}", ""])
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    rendered = render(load_entries(args.source))
    if args.check:
        if not args.output.exists() or args.output.read_text(encoding="utf-8") != rendered:
            raise SystemExit(f"generated runtime table is stale: {args.output}")
        print(f"Validated {args.output}")
        return
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(rendered, encoding="utf-8", newline="\n")
    print(f"Generated {args.output}")


if __name__ == "__main__":
    main()
