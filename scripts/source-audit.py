#!/usr/bin/env python3
"""Check a working tree against the pinned upstream Git objects. Run with the source directory as argv[1]."""
from collections import defaultdict
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

REVISION = "ad53419de079eb8f95f60313473374624a348546"
TREE = "96db4860a29e55ea2dc3fb8929e76f128fcc1712"
root = Path(sys.argv[1]).resolve()

def git(*args):
    return subprocess.check_output(["git", "-C", str(root), *args])

def require(condition, message):
    if not condition:
        raise ValueError(message)

require(git("rev-parse", "HEAD").decode().strip() == REVISION, "Wrong upstream commit")
require(git("rev-parse", "HEAD^{tree}").decode().strip() == TREE, "Wrong upstream tree")
entries = git("ls-tree", "-rz", "HEAD").split(b"\0")
counts = defaultdict(int)
paper = {}
for entry in filter(None, entries):
    header, raw_name = entry.split(b"\t", 1)
    mode, kind, object_id = header.split()
    name = raw_name.decode()
    require(kind == b"blob" and mode in (b"100644", b"100755"), f"Unexpected entry: {name}")
    file = root / name
    require(file.is_file() and not file.is_symlink(), f"Expected regular file: {name}")
    require(bool(file.stat().st_mode & 0o100) == (mode == b"100755"), f"Mode mismatch: {name}")
    data = file.read_bytes()
    digest = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
    require(digest == object_id.decode(), f"Contents differ: {name}")
    counts["tracked_files_verified"] += 1
    if name.endswith(".lean"):
        counts["lean_files"] += 1
        counts["lean_lines"] += len(data.splitlines())
    if name.startswith("lean/Breakdown/") and name.endswith(".lean"):
        counts["breakdown_modules"] += 1
    if name == "paper/finite-time-blow-up-navier-stokes.pdf":
        paper = {"file": name, "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}

lean = root / "lean"
configs = {}
for path in sorted(lean.glob("comparator*.json")):
    item = json.loads(path.read_bytes())
    for key in ("challenge_module", "solution_module"):
        require((lean / (item[key].replace(".", "/") + ".lean")).is_file(), f"Missing {item[key]}")
    configs[path.name] = {key: item[key] for key in ("challenge_module", "solution_module", "theorem_names", "permitted_axioms")}
targets = {n for item in configs.values() for n in item["theorem_names"]}
upstream_prints = set(re.findall(r"(?m)^#print axioms (\S+)", (lean / "scripts/PrintAxioms.lean").read_text()))
manifest = json.loads((lean / "lake-manifest.json").read_bytes())
print(json.dumps({
    "check": "git_working_tree_and_source_inventory", "status": "passed",
    "upstream": "https://github.com/tristanbuckmaster/navier-stokes",
    "commit": REVISION, "git_tree": TREE, **counts, "paper": paper,
    "toolchain_pin": (lean / "lean-toolchain").read_text().strip(),
    "dependency_pins": {p["name"]: p["rev"] for p in manifest["packages"]},
    "comparator_config_count": len(configs), "unique_comparator_targets": len(targets),
    "upstream_print_axioms_count": len(upstream_prints),
    "targets_missing_from_print_script": sorted(targets - upstream_prints),
    "additional_print_script_targets": sorted(upstream_prints - targets),
    "configs": configs
}, indent=2, ensure_ascii=False))
