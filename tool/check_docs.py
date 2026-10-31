"""Check repository-relative Markdown links and consecutive ADR filenames."""

from pathlib import Path
import os
import re
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
IGNORED = {".git", ".local", ".dart_tool", ".serverpod", "build", "node_modules"}


def main():
    count = 0
    failures = []
    for folder, directories, files in os.walk(ROOT):
        directories[:] = [name for name in directories if name not in IGNORED]
        for name in files:
            if not name.endswith(".md"):
                continue
            page = Path(folder) / name
            for raw in re.findall(r"\]\(([^)]+)\)", page.read_text(encoding="utf-8")):
                target = raw.split("#", 1)[0].strip("<>")
                if not target or re.match(r"[a-z]+:", target, re.I) or target.startswith("/"):
                    continue
                count += 1
                destination = (page.parent / unquote(target)).resolve()
                if not destination.is_relative_to(ROOT) or not destination.exists():
                    failures.append(f"{page.relative_to(ROOT)}: {target}")
    adrs = sorted(int(p.name[:4]) for p in (ROOT / "docs/adr").glob("[0-9][0-9][0-9][0-9]-*.md"))
    if adrs != list(range(1, len(adrs) + 1)):
        failures.append("ADR filenames are not unique and consecutive from 0001")
    if failures:
        raise SystemExit("\n".join(failures))
    print(f"PASS: {count} repository-relative Markdown links; ADRs 0001-{len(adrs):04d} consecutive.")


if __name__ == "__main__":
    main()
