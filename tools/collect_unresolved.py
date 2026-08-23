from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


PATTERNS = (
    ("aggregate", re.compile(r"unresolved aggregate localization key (.*)$")),
    ("split", re.compile(r"unresolved split localization key (.*)$")),
    (
        "widget",
        re.compile(r"unresolved live widget Chinese ([^:]+): (.*)$"),
    ),
)
STRUCTURED = re.compile(
    r"unresolved localized Chinese \[([^\]]+)\]\t([^\t]*)\t(.*)$"
)
CJK = re.compile(r"[\u3400-\u9fff]")


def unescape_log_field(value: str) -> str:
    result: list[str] = []
    index = 0
    escapes = {"r": "\r", "n": "\n", "t": "\t", "\\": "\\"}
    while index < len(value):
        if value[index] == "\\" and index + 1 < len(value):
            escaped = value[index + 1]
            if escaped in escapes:
                result.append(escapes[escaped])
                index += 2
                continue
        result.append(value[index])
        index += 1
    return "".join(result)


def parse_marker(line: str) -> tuple[str, str | None, str] | None:
    structured = STRUCTURED.search(line)
    if structured:
        kind = structured.group(1)
        context = unescape_log_field(structured.group(2))
        source = unescape_log_field(structured.group(3))
        return kind, context or None, source
    for kind, pattern in PATTERNS:
        match = pattern.search(line)
        if match:
            widget = match.group(1) if kind == "widget" else None
            source = match.group(2) if kind == "widget" else match.group(1)
            return kind, widget, source
    return None


def find_logs(path: Path) -> list[Path]:
    if path.is_file():
        return [path]
    if path.is_dir():
        return sorted(
            path.glob("C7*.log"),
            key=lambda candidate: (candidate.stat().st_mtime_ns, candidate.name),
        )
    raise FileNotFoundError(path)


def collect(log_paths: list[Path], context_lines: int = 5) -> list[dict[str, object]]:
    found: list[dict[str, object]] = []
    seen: set[tuple[str, str]] = set()

    for log_path in log_paths:
        lines = log_path.read_text(encoding="utf-8", errors="replace").splitlines()
        for index, line in enumerate(lines):
            parsed = parse_marker(line)
            if parsed is None:
                continue
            kind, widget, source = parsed
            identity = (kind, source)
            if identity in seen or not CJK.search(source):
                continue
            seen.add(identity)
            start = max(0, index - context_lines)
            end = min(len(lines), index + context_lines + 1)
            found.append(
                {
                    "kind": kind,
                    "source": source,
                    "widget": widget,
                    "log_file": log_path.name,
                    "line_number": index + 1,
                    "log_line": line,
                    "context": lines[start:end],
                }
            )
    return found


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("log", type=Path, help="one C7 log or its Logs directory")
    parser.add_argument("output", type=Path)
    parser.add_argument("--context-lines", type=int, default=5)
    args = parser.parse_args()

    log_paths = find_logs(args.log)
    entries = collect(log_paths, args.context_lines)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(entries, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        f"Collected {len(entries)} unique unresolved strings "
        f"from {len(log_paths)} log(s) -> {args.output}"
    )


if __name__ == "__main__":
    main()
