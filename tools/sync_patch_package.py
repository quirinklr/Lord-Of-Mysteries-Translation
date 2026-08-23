from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PATCH = ROOT / "patch"
ASSETS = PATCH / "assets"
PAYLOAD_GAME = ASSETS / "payload" / "bridge" / "game"
RUNTIME_SOURCE = ROOT / "src" / "cpdd_runtime_fixes"
RUNTIME_DESTINATION = PAYLOAD_GAME / "Saved" / "Mods" / "lua" / "mods" / "cpdd_runtime_fixes"
RELEASE_PATH = ASSETS / "release.json"
TRANSLATION_STATE_PATH = PAYLOAD_GAME / "Saved" / "Mods" / "translation-overrides.state.json"
CURATED_SOURCE_PATH = ROOT / "translations" / "runtime_curated.json"
CONTEXT_SOURCE_PATH = ROOT / "translations" / "runtime_context_curated.json"

DISPLAY_VERSION = "1.0.1"
RELEASE_ID = "lotm-english-1.0.1"
TRANSLATION_RELEASE_ID = "lotm-english-data-20260823"
RUNTIME_VERSION = "1.0.1"
RUNTIME_FILES = (
    "Init.lua",
    "RuntimeTextCurated.lua",
    "RuntimeIdCurated.lua",
    "RuntimeContextCurated.lua",
    "RuntimeStaticAudit.lua",
    "RuntimeFullCorpusAudit.lua",
    "RuntimeQualityFixes.lua",
    "RuntimeFullLiterals.lua",
    "RuntimeInheritedText.lua",
    "LanguageSourceIndex.lua",
    "GameModuleCatalog.lua",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def file_record(path: Path, relative_path: str, mapping_kind: str) -> dict[str, object]:
    return {
        "relativePath": relative_path,
        "mappingKind": mapping_kind,
        "sha256": sha256(path),
        "size": path.stat().st_size,
    }


def owned_record(path: Path, relative_path: str) -> dict[str, object]:
    return {
        "relativePath": relative_path,
        "sha256": sha256(path),
        "size": path.stat().st_size,
    }


def replace_record(records: list[dict[str, object]], record: dict[str, object]) -> None:
    key_name = "relativePath"
    for index, existing in enumerate(records):
        if existing.get(key_name) == record[key_name]:
            records[index] = record
            return
    records.append(record)


def main() -> None:
    for name in RUNTIME_FILES:
        source = RUNTIME_SOURCE / name
        if not source.is_file():
            raise FileNotFoundError(source)
        RUNTIME_DESTINATION.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, RUNTIME_DESTINATION / name)

    state = json.loads(TRANSLATION_STATE_PATH.read_text(encoding="utf-8"))
    state["sourceKind"] = "bundled-certified-release-assets-plus-reviewed-runtime"
    state["translationReleaseId"] = TRANSLATION_RELEASE_ID
    state["installerReleaseId"] = RELEASE_ID
    state["displayVersion"] = DISPLAY_VERSION
    state.setdefault("files", [])
    state.setdefault("ownedFiles", [])
    for name in RUNTIME_FILES:
        payload = RUNTIME_DESTINATION / name
        relative = f"lua/mods/cpdd_runtime_fixes/{name}"
        kind = {
            "Init.lua": "runtime-core",
            "RuntimeTextCurated.lua": "runtime-curated-source",
            "RuntimeIdCurated.lua": "runtime-curated-id",
            "RuntimeContextCurated.lua": "runtime-curated-context",
            "RuntimeStaticAudit.lua": "runtime-audit",
            "RuntimeFullCorpusAudit.lua": "runtime-full-corpus-audit",
            "RuntimeQualityFixes.lua": "runtime-quality-fixes",
            "RuntimeFullLiterals.lua": "runtime-full-literals",
            "RuntimeInheritedText.lua": "runtime-inherited-text",
            "LanguageSourceIndex.lua": "runtime-language-source-index",
            "GameModuleCatalog.lua": "runtime-game-module-catalog",
        }[name]
        replace_record(state["files"], file_record(payload, relative, kind))
        replace_record(
            state["ownedFiles"],
            owned_record(payload, f"Saved/Mods/{relative}"),
        )

    curated_entries = json.loads(CURATED_SOURCE_PATH.read_text(encoding="utf-8"))
    context_document = json.loads(CONTEXT_SOURCE_PATH.read_text(encoding="utf-8"))
    state["reviewedRuntime"] = {
        "runtimeVersion": RUNTIME_VERSION,
        "curatedSource": "translations/runtime_curated.json",
        "curatedEntries": len(curated_entries),
        "contextBoundEntries": len(context_document["entries"]),
        "staticCoverageAudit": True,
    }
    TRANSLATION_STATE_PATH.write_text(
        json.dumps(state, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )

    release = json.loads(RELEASE_PATH.read_text(encoding="utf-8"))
    release["display_version"] = DISPLAY_VERSION
    release["release_id"] = RELEASE_ID
    release["translation_release_id"] = TRANSLATION_RELEASE_ID
    bridge = release["external_bridge"]
    bridge["runtime_version"] = RUNTIME_VERSION
    bridge["translation_release_id"] = TRANSLATION_RELEASE_ID
    bridge["translation_delivery"] = (
        "official-cn-modules-with-reviewed-id-overlays-and-curated-runtime"
    )

    files = bridge["files"]
    package_paths = {
        entry["relative_path"]: entry
        for entry in files
    }
    for name in RUNTIME_FILES:
        relative_path = f"Saved/Mods/lua/mods/cpdd_runtime_fixes/{name}"
        payload = f"payload/bridge/game/{relative_path}"
        package_paths.setdefault(
            relative_path,
            {"payload": payload, "relative_path": relative_path},
        )

    state_relative = "Saved/Mods/translation-overrides.state.json"
    package_paths.setdefault(
        state_relative,
        {
            "payload": f"payload/bridge/game/{state_relative}",
            "relative_path": state_relative,
        },
    )

    refreshed: list[dict[str, object]] = []
    for relative_path in sorted(package_paths, key=str.casefold):
        entry = package_paths[relative_path]
        payload_path = ASSETS / str(entry["payload"])
        if not payload_path.is_file():
            raise FileNotFoundError(payload_path)
        refreshed.append(
            {
                "payload": entry["payload"],
                "relative_path": relative_path,
                "sha256": sha256(payload_path),
                "size": payload_path.stat().st_size,
            }
        )
    bridge["files"] = refreshed
    RELEASE_PATH.write_text(
        json.dumps(release, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(
        f"Synchronized runtime {RUNTIME_VERSION}; package now manages "
        f"{len(refreshed)} files"
    )


if __name__ == "__main__":
    main()
