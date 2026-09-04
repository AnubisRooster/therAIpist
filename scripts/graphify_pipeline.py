"""Self-contained graphify pipeline for CI.

Builds a knowledge graph over this repository and writes
graphify-out/{graph.json,GRAPH_REPORT.md} for HTML export and commit.

- Code is extracted structurally (AST, deterministic, no LLM, no key).
- Docs get semantic extraction via Gemini when GEMINI_API_KEY is set;
  otherwise the semantic pass is skipped and the graph is code-only.
- Community labels are deterministic: each community is named after its
  highest-degree member.
"""
import json
import os
import sys
from pathlib import Path

ROOT = Path(os.environ.get("GRAPHIFY_ROOT", Path.cwd())).resolve()
OUT = ROOT / "graphify-out"
OUT.mkdir(exist_ok=True)

from graphify.detect import detect
from graphify.extract import collect_files, extract
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json

EXCLUDE = (
    "graphify-out",
    ".gitnexus",
    "docs/gitnexus",
    "docs/graphify",
    "node_modules",
    "/.git/",
    ".github/workflows",
    "githooks",
)


def keep(p: str) -> bool:
    ps = str(p).replace("\\", "/")
    return not any(part in ps for part in EXCLUDE)


# ---- Detect (with generated/infra dirs filtered out) ----
result = detect(ROOT)
result["files"] = {cat: [f for f in lst if keep(f)] for cat, lst in result.get("files", {}).items()}
result["total_files"] = sum(len(v) for v in result["files"].values())
print(f"Detected {result['total_files']} files")

# ---- Part A: AST extraction for code (free, deterministic) ----
code_files = []
for f in result["files"].get("code", []):
    p = Path(f)
    code_files.extend(collect_files(p) if p.is_dir() else [p])
if code_files:
    ast = extract(code_files, cache_root=ROOT)
    print(f"AST: {len(ast['nodes'])} nodes, {len(ast['edges'])} edges")
else:
    ast = {"nodes": [], "edges": [], "input_tokens": 0, "output_tokens": 0}
    print("No code files - skipping AST extraction")

# ---- Part B: semantic extraction for docs (Gemini when key present) ----
sem = {"nodes": [], "edges": [], "hyperedges": [], "input_tokens": 0, "output_tokens": 0}
doc_files = [f for cat in ("document", "paper") for f in result["files"].get(cat, [])]
if doc_files and os.environ.get("GEMINI_API_KEY"):
    from graphify.llm import extract_corpus_parallel

    sem = extract_corpus_parallel(doc_files, backend="gemini")
    print(f"Semantic (Gemini): {len(sem.get('nodes', []))} nodes from {len(doc_files)} docs")
elif doc_files:
    print(f"NOTE: {len(doc_files)} doc files found but GEMINI_API_KEY not set - graph is code-only")

# ---- Part C: merge AST + semantic ----
seen = {n["id"] for n in ast["nodes"]}
nodes = list(ast["nodes"])
for n in sem.get("nodes", []):
    if n["id"] not in seen:
        nodes.append(n)
        seen.add(n["id"])
merged = {
    "nodes": nodes,
    "edges": ast["edges"] + sem.get("edges", []),
    "hyperedges": sem.get("hyperedges", []),
    "input_tokens": sem.get("input_tokens", 0),
    "output_tokens": sem.get("output_tokens", 0),
}

# ---- Build, cluster, analyze, report ----
G = build_from_json(merged, root=str(ROOT), directed=False)
if G.number_of_nodes() == 0:
    print("ERROR: Graph is empty - extraction produced no nodes.")
    sys.exit(1)

communities = cluster(G)
cohesion = score_all(G, communities)
gods = god_nodes(G)
surprises = surprising_connections(G, communities)

# Deterministic labels: name each community after its highest-degree member.
labels = {}
for cid, members in communities.items():
    top = max(members, key=lambda n: G.degree(n))
    lbl = G.nodes[top].get("label") if isinstance(G.nodes[top], dict) else None
    labels[cid] = (str(lbl) if lbl else str(top))[:40]

questions = suggest_questions(G, communities, labels)
tokens = {"input": merged.get("input_tokens", 0), "output": merged.get("output_tokens", 0)}

wrote = to_json(G, communities, str(OUT / "graph.json"), community_labels=labels)
if not wrote:
    print("WARN: graph.json write refused (shrink guard #479) - keeping previous graph.json")

report = generate(
    G, communities, cohesion, labels, gods, surprises,
    result, tokens, str(ROOT), suggested_questions=questions,
)
(OUT / "GRAPH_REPORT.md").write_text(report, encoding="utf-8")
(OUT / ".graphify_labels.json").write_text(
    json.dumps({str(k): v for k, v in labels.items()}, ensure_ascii=False), encoding="utf-8"
)

print(f"Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges, {len(communities)} communities")
print(f"Tokens: {tokens['input']:,} in / {tokens['output']:,} out")
