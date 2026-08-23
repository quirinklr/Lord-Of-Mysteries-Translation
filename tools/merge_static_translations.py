from __future__ import annotations

import argparse
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_QUEUE = ROOT / "work" / "static-review-0.8.16.json"
DEFAULT_OUTPUT = ROOT / "translations" / "runtime_context_curated.json"


def identity(entry: dict[str, object]) -> tuple[str, str, str, str]:
    return tuple(str(entry.get(name, "")) for name in ("table", "key", "field", "source"))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--queue", type=Path, default=DEFAULT_QUEUE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("inputs", nargs="+", type=Path)
    args = parser.parse_args()

    queue = json.loads(args.queue.read_text(encoding="utf-8"))
    expected = {identity(entry): entry for entry in queue["gaps"]}
    reviewed: dict[tuple[str, str, str, str], dict[str, str]] = {}
    for input_path in args.inputs:
        values = json.loads(input_path.read_text(encoding="utf-8"))
        if not isinstance(values, list):
            raise ValueError(f"agent output must be an array: {input_path}")
        for raw in values:
            if not isinstance(raw, dict):
                raise ValueError(f"agent entry must be an object: {raw!r}")
            key = identity(raw)
            if key not in expected:
                raise ValueError(f"unexpected or changed gap in {input_path}: {key!r}")
            translation = raw.get("translation")
            if not isinstance(translation, str) or not translation.strip():
                raise ValueError(f"missing translation in {input_path}: {key!r}")
            if key in reviewed and reviewed[key]["translation"] != translation:
                raise ValueError(f"conflicting reviews for {key!r}")
            reviewed[key] = {name: str(raw[name]) for name in ("table", "key", "field", "source", "translation")}

    missing = sorted(set(expected) - set(reviewed))
    if missing:
        raise ValueError(f"{len(missing)} gaps remain unreviewed; first: {missing[0]!r}")

    context_entries: dict[tuple[str, str], dict[str, str]] = {}
    for entry in reviewed.values():
        context_key = (entry["table"], entry["source"])
        existing = context_entries.get(context_key)
        if existing and existing["translation"] != entry["translation"]:
            raise ValueError(f"same table/source has conflicting translations: {context_key!r}")
        context_entries.setdefault(context_key, entry)

    ordered = sorted(
        context_entries.values(),
        key=lambda entry: (entry["table"].casefold(), entry["key"], entry["field"], entry["source"]),
    )
    document = {"format_version": 1, "entries": ordered}
    args.output.write_text(
        json.dumps(document, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"Merged {len(reviewed)} reviewed gaps into {len(ordered)} context entries")


if __name__ == "__main__":
    main()
