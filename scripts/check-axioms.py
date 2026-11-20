#!/usr/bin/env python3
"""Verify that an upstream PrintAxioms run reported every target and only permitted axioms."""
import json
from pathlib import Path
import re
import sys

lean, log, dest = map(Path, sys.argv[1:4])
queries = re.findall(r"(?m)^#print\s+axioms\s+(\S+)", (lean/"scripts/PrintAxioms.lean").read_text())
policies = {}
all_policies = []
for f in sorted(lean.glob("comparator*.json")):
    cfg = json.loads(f.read_text())
    allowed = set(cfg["permitted_axioms"])
    all_policies.append(allowed)
    for name in cfg["theorem_names"]:
        policies[name] = allowed if name not in policies else policies[name] & allowed
common = set.intersection(*all_policies)
observed, duplicates = {}, []
pattern = r"['‘]([^'’\r\n]+)['’]\s+(?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)"
for match in re.finditer(pattern, log.read_text()):
    name = match[1]
    if name in observed:
        duplicates.append(name)
    observed[name] = sorted(s.strip() for s in (match[2] or "").split(",") if s.strip())
missing = sorted((set(queries) | set(policies)) - observed.keys())
extra = sorted(observed.keys() - set(queries))
disallowed = {name: sorted(set(axioms) - policies.get(name, common)) for name, axioms in observed.items()
              if set(axioms) - policies.get(name, common)}
ok = bool(queries) and not (missing or extra or disallowed or duplicates)
result = {"status": "passed" if ok else "failed", "planned_declarations": queries, "comparators_cover": sorted(policies),
          "reported_count": len(observed), "axioms_by_declaration": observed, "missing": missing,
          "unexpected": extra, "duplicates": duplicates, "disallowed_axioms": disallowed,
          "additional_declarations_allowlist": sorted(common)}
dest.write_text(json.dumps(result, indent=2) + "\n")
print(result["status"], len(observed), "declarations,", len(disallowed), "allowlist violations")
sys.exit(0 if ok else 1)
