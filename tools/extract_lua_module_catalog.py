from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


PATH_PATTERN = re.compile(
    rb"(?:\.\.[\\/])*Client[\\/]Content[\\/]Script[\\/]"
    rb"[A-Za-z0-9_.\\/-]{4,1024}\.lua"
)
PREFIX_PATTERN = re.compile(r"^(?:\.\./)*Client/Content/Script/")


def extract_paths(source: Path) -> list[str]:
    found: set[str] = set()
    overlap = b""
    with source.open("rb") as stream:
        while block := stream.read(8 * 1024 * 1024):
            payload = overlap + block
            for match in PATH_PATTERN.finditer(payload):
                raw = match.group(0).decode("ascii").replace("\\", "/")
                normalized = re.sub(r"^(?:\.\./)+", "", raw)
                found.add(normalized)
            overlap = payload[-2048:]
    return sorted(found, key=str.casefold)


def module_name(path: str) -> str:
    relative = PREFIX_PATTERN.sub("", path)
    if not relative.endswith(".lua"):
        raise ValueError(path)
    return relative[:-4].replace("/", ".")


def write_lua(path: Path, modules: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as output:
        output.write("return {\n")
        for module in modules:
            output.write(f"    {json.dumps(module)},\n")
        output.write("}\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("pak", type=Path)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--lua", type=Path, required=True)
    args = parser.parse_args()

    paths = extract_paths(args.pak)
    modules = sorted({module_name(path) for path in paths}, key=str.casefold)
    document = {
        "source": str(args.pak),
        "module_count": len(modules),
        "data_excel_count": sum(
            name.startswith("Data.Excel.")
            and not name.startswith("Data.Excel.Annotation.")
            for name in modules
        ),
        "annotation_count": sum(
            name.startswith("Data.Excel.Annotation.") for name in modules
        ),
        "modules": modules,
    }
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(
        json.dumps(document, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    write_lua(args.lua, modules)
    print(
        f"extracted {document['module_count']} modules; "
        f"Data.Excel={document['data_excel_count']} "
        f"annotations={document['annotation_count']}"
    )


if __name__ == "__main__":
    main()
