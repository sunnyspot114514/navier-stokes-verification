#!/usr/bin/env python3
"""Locate the published certificate digest, then compare it with individual tracked files."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
from pypdf import PdfReader

root = Path(sys.argv[1]).resolve()
paper_name = "paper/finite-time-blow-up-navier-stokes.pdf"
paper = root / paper_name
reader = PdfReader(str(paper))
pages = [page.extract_text() for page in reader.pages]
first = re.search(r"hash\s*is\s*([0-9a-f]{64})", pages[0], re.I)
if not first:
    raise ValueError("No 64-hex-digit digest found in the abstract")
digest = first.group(1).lower()
locations = [i for i, page in enumerate(pages, 1) if digest in re.sub(r"\s+", "", page).lower()]
paths = subprocess.check_output(["git", "-C", str(root), "ls-files", "-z"]).split(b"\0")
matches = []
for raw_path in filter(None, paths):
    path = raw_path.decode()
    if hashlib.sha256((root / path).read_bytes()).hexdigest() == digest:
        matches.append(path)
print(json.dumps({
    "upstream_commit": subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip(),
    "paper": paper_name, "pdf_sha256": hashlib.sha256(paper.read_bytes()).hexdigest(),
    "published_certificate_digest": digest, "pdf_pages_with_digest": locations,
    "pdf_text_contains_sha256_algorithm_name": any(re.search(r"sha[\W_]*256", p, re.I) for p in pages),
    "comparison_algorithm": "SHA-256", "compared_tracked_files": len([p for p in paths if p]),
    "matching_whole_files": matches,
    "numerical_verification": "not_run",
    "reason": "The upstream README states that this revision omits the certificate and its interval-arithmetic verification code.",
    "scope": "Whole tracked file bytes only. The comparison does not establish the contents of a missing certificate."
}, indent=2))
