from __future__ import annotations

import re
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CODE_SUFFIXES = {".py", ".ps1", ".cs", ".cmd", ".lua"}
CJK = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")
PRIVATE_PATH = re.compile(
    rb"[A-Za-z]:\\" + b"Users" + rb"\\|/home/[^/]+|/" + b"Users" + rb"/[^/]+"
)
EMAIL = re.compile(
    rb"[A-Z0-9._%+-]+" + b"@" + rb"[A-Z0-9.-]+\.[A-Z]{2,}",
    re.IGNORECASE,
)
AI_TRACE = re.compile(
    "|".join(
        (
            "chat" + "gpt",
            "open" + "ai",
            "anth" + "ropic",
            "clau" + "de",
            "gem" + "ini",
            "co" + "pilot",
            "l" + "lm",
        )
    ),
    re.IGNORECASE,
)


def tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "ls-files"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return [ROOT / line for line in result.stdout.splitlines() if line]


def is_compiled_lua(path: Path) -> bool:
    return path.suffix == ".lua" and path.read_bytes().startswith(b"\x1bLJ")


class RepositoryHygieneTests(unittest.TestCase):
    def test_no_private_paths_or_emails(self) -> None:
        failures: list[str] = []
        for path in tracked_files():
            if path.resolve() == Path(__file__).resolve():
                continue
            content = path.read_bytes()
            if PRIVATE_PATH.search(content):
                failures.append(str(path.relative_to(ROOT)))
                continue
            try:
                text = content.decode("utf-8")
            except UnicodeDecodeError:
                continue
            if EMAIL.search(text.encode("utf-8")):
                failures.append(str(path.relative_to(ROOT)))
        self.assertEqual([], failures)

    def test_no_ai_traces_in_project_code(self) -> None:
        failures: list[str] = []
        roots = [ROOT / "tools", ROOT / "tests"]
        for directory in roots:
            for path in directory.rglob("*"):
                if not path.is_file() or path.suffix not in CODE_SUFFIXES:
                    continue
                if AI_TRACE.search(path.read_text(encoding="utf-8")):
                    failures.append(str(path.relative_to(ROOT)))
        self.assertEqual([], failures)

    def test_no_code_comments(self) -> None:
        failures: list[str] = []
        for path in tracked_files():
            if path.suffix not in CODE_SUFFIXES or is_compiled_lua(path):
                continue
            for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
                stripped = line.lstrip()
                if path.suffix == ".py" and stripped.startswith("#"):
                    failures.append(f"{path.relative_to(ROOT)}:{number}")
                elif path.suffix in {".lua", ".cs"} and stripped.startswith(("--", "//")):
                    failures.append(f"{path.relative_to(ROOT)}:{number}")
                elif path.suffix == ".ps1" and stripped.startswith("#"):
                    failures.append(f"{path.relative_to(ROOT)}:{number}")
                elif path.suffix == ".cmd" and stripped.lower().startswith(("rem ", "::")):
                    failures.append(f"{path.relative_to(ROOT)}:{number}")
        self.assertEqual([], failures)

    def test_python_contains_no_translation_text(self) -> None:
        failures = [
            str(path.relative_to(ROOT))
            for path in tracked_files()
            if path.suffix == ".py" and CJK.search(path.read_text(encoding="utf-8"))
        ]
        self.assertEqual([], failures)

    def test_compiled_translation_payloads_are_preserved(self) -> None:
        directory = (
            ROOT
            / "patch"
            / "assets"
            / "payload"
            / "bridge"
            / "game"
            / "Saved"
            / "Mods"
            / "lua"
            / "cpdd_translation"
        )
        payloads = [path for path in directory.rglob("*.lua") if is_compiled_lua(path)]
        self.assertEqual(46, len(payloads))


if __name__ == "__main__":
    unittest.main()
