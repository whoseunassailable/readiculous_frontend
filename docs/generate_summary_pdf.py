"""
Generates docs/readiculous_ai_agent_summary.pdf using reportlab.
Run from anywhere: python3 docs/generate_summary_pdf.py
"""

import os
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable, PageBreak
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "readiculous_ai_agent_summary.pdf")

doc = SimpleDocTemplate(
    OUT,
    pagesize=letter,
    leftMargin=0.85 * inch,
    rightMargin=0.85 * inch,
    topMargin=0.9 * inch,
    bottomMargin=0.9 * inch,
)

base = getSampleStyleSheet()

def style(name, parent="Normal", **kw):
    return ParagraphStyle(name, parent=base[parent], **kw)

S = {
    "title":    style("title",    "Title",   fontSize=22, textColor=colors.HexColor("#2f2418"), spaceAfter=6),
    "subtitle": style("subtitle", "Normal",  fontSize=11, textColor=colors.HexColor("#7a5230"), spaceAfter=16, alignment=TA_CENTER),
    "h1":       style("h1",       "Heading1", fontSize=15, textColor=colors.HexColor("#2f2418"), spaceBefore=18, spaceAfter=6),
    "h2":       style("h2",       "Heading2", fontSize=12, textColor=colors.HexColor("#7a5230"), spaceBefore=12, spaceAfter=4),
    "body":     style("body",     "Normal",   fontSize=9.5, leading=14, spaceAfter=6),
    "bullet":   style("bullet",   "Normal",   fontSize=9.5, leading=14, leftIndent=16, spaceAfter=3, bulletIndent=6),
    "code":     style("code",     "Code",     fontSize=8.5, leading=13, backColor=colors.HexColor("#f5ede0"),
                      leftIndent=12, rightIndent=12, borderPadding=4),
    "label":    style("label",    "Normal",   fontSize=9, textColor=colors.HexColor("#7a5230"), leading=13),
    "note":     style("note",     "Normal",   fontSize=8.5, textColor=colors.HexColor("#777777"), leading=12, spaceAfter=4),
}

ACCENT = colors.HexColor("#b8743a")

def hr():
    return HRFlowable(width="100%", thickness=0.5, color=ACCENT, spaceAfter=8, spaceBefore=2)

def h1(text):
    return [hr(), Paragraph(text, S["h1"])]

def h2(text):
    return [Paragraph(text, S["h2"])]

def p(text):
    return Paragraph(text, S["body"])

def b(text):
    return Paragraph(f"<bullet>&bull;</bullet> {text}", S["bullet"])

def code(text):
    return Paragraph(text.replace("\n", "<br/>").replace(" ", "&nbsp;"), S["code"])

def table(headers, rows, col_widths=None):
    data = [headers] + rows
    t = Table(data, colWidths=col_widths, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND",   (0, 0), (-1, 0),  colors.HexColor("#f0dcc8")),
        ("TEXTCOLOR",    (0, 0), (-1, 0),  colors.HexColor("#2f2418")),
        ("FONTNAME",     (0, 0), (-1, 0),  "Helvetica-Bold"),
        ("FONTSIZE",     (0, 0), (-1, -1), 8.5),
        ("LEADING",      (0, 0), (-1, -1), 13),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#fdf5ec")]),
        ("GRID",         (0, 0), (-1, -1), 0.4, colors.HexColor("#d4b896")),
        ("LEFTPADDING",  (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING",   (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 4),
        ("VALIGN",       (0, 0), (-1, -1), "TOP"),
    ]))
    return t

# ── Content ──────────────────────────────────────────────────────────────────

story = []

story.append(Spacer(1, 0.2 * inch))
story.append(Paragraph("Readiculous", S["title"]))
story.append(Paragraph("AI Agent Workflow &amp; Configuration Summary", S["subtitle"]))
story.append(Paragraph("Prepared for Saris AI Application Submission", S["note"]))
story.append(Spacer(1, 0.1 * inch))
story.append(hr())

# ── Personal Statement ────────────────────────────────────────────────────────

story += h1("Working with AI Coding Agents")
story.append(p(
    "The most valuable rule I have developed while working with AI coding agents is "
    "forcing the model to ground itself in source-of-truth artifacts before making "
    "changes. In this repository that meant treating <code>schema.sql</code>, "
    "retraining contracts, and API payload examples as authoritative instead of "
    "allowing the agent to infer interfaces. I added the anti-hallucination section "
    "after repeatedly seeing agents invent field names, ports, and join keys that "
    "were \u201calmost correct\u201d but operationally dangerous."
))
story.append(p(
    "I also rely heavily on executable validation loops instead of trusting generated "
    "code by inspection. The <code>user_flow_cli.js</code> integration driver became "
    "especially valuable because it exercises the full backend + ML pipeline end-to-end "
    "without needing the mobile frontend. Over time I\u2019ve found that lightweight "
    "executable workflows and explicit interface contracts produce much more reliable "
    "AI-assisted development than large abstract prompting rules."
))

# ── How I Use Agents ──────────────────────────────────────────────────────────

story += h1("How I Actually Use AI Coding Agents")
for item in [
    "Force the agent to read schema.sql and the relevant route file before touching any data layer \u2014 no assumptions about field names",
    "Treat README + schema as grounding context, not background reading; paste relevant sections directly into context for high-stakes edits",
    "Prefer incremental diffs over large rewrites \u2014 smaller surface area means hallucinations are easier to catch",
    "Use CLI integration flows (user_flow_cli.js pattern) as validation loops instead of trusting generated code by inspection alone",
    "Ask the agent to summarize its assumptions before implementation, then verify each assumption against source",
    "Never trust generated API field names without a grep confirmation against the actual route handler",
    "Keep inter-process contracts (e.g. JSON-to-stdout) explicit and minimal \u2014 complexity at boundaries is where agents make the most mistakes",
    "When the agent proposes a refactor, ask it to identify every callsite first \u2014 agents frequently miss indirect usages",
    "For ML code: pin every numeric constant (thresholds, weights, blend ratios) in comments so the agent cannot silently drift them on a rewrite",
    "Treat the agent\u2019s first draft as a strong starting point for review, not a finished artifact \u2014 the review loop is where the real engineering happens",
]:
    story.append(b(item))

story.append(Spacer(1, 0.1 * inch))

# ── Executive Summary ────────────────────────────────────────────────────────

story += h1("Executive Summary")
story.append(p(
    "This document surveys every AI-agent-relevant configuration, workflow, and "
    "architecture file in the Readiculous monorepo. The repository contains <b>no "
    "dedicated agent config files</b> (no CLAUDE.md, AGENTS.md, .cursorrules, system "
    "prompts, or slash commands). Instead it has a set of high-quality engineering "
    "artifacts that serve as implicit grounding documents for any AI agent working in "
    "this codebase."
))
story.append(p(
    "The stack is: <b>Flutter</b> mobile client &rarr; <b>Node.js/Express</b> REST backend "
    "(MySQL) &rarr; <b>Python/Flask</b> ML microservice (XGBoost + SVD + Cosine Similarity)."
))

# ── Architecture Diagram ─────────────────────────────────────────────────────

story += h1("System Architecture")
story.append(code(
    "Flutter App (iOS + Android)\n"
    "      |\n"
    "      | REST API (:5000)\n"
    "      v\n"
    "Node.js + MySQL Backend\n"
    "      |\n"
    "      | Internal HTTP (:6000)\n"
    "      v\n"
    "Python Flask ML Service\n"
    "  XGBoost + SVD + TF-IDF/Cosine Similarity"
))
story.append(Spacer(1, 0.05 * inch))
story.append(p(
    "Key cross-service identifier: <b>isbn13</b> is the shared key between the "
    "Kaggle CSV, MySQL books table, and ML service. Note: the legacy "
    "<code>database/schema.sql</code> names this column <code>isbn</code> — "
    "an undocumented discrepancy agents must be aware of."
))

# ── Files Found ───────────────────────────────────────────────────────────────

story += h1("Files Found and Their Purpose")

# File 1
story += h2("1. ml/README.md — Primary Architecture + API Reference")
story.append(p("<b>Agent submission value: HIGH</b>"))
story.append(p("The most comprehensive single file in the repo. Covers:"))
for item in [
    "Full 3-tier architecture diagram",
    "ML model design: XGBoost (content) + TF-IDF/Cosine (content similarity) + Surprise SVD (collaborative filtering)",
    "Both recommendation flows: /recommend (reader) and /suggest (library)",
    "All 40+ REST API endpoints across 9 resource groups",
    "/compare endpoint for side-by-side model output comparison during testing",
    "/reload hot-swap endpoint — refreshes .pkl artifacts in memory without process restart",
    "Cold-start vs. warm-start recommendation routing logic",
    "Repository structure with all .pkl file locations",
    "Environment variable requirements and deployment notes",
]:
    story.append(b(item))
story.append(Spacer(1, 0.05 * inch))
story.append(p("<b>Most important rules for agents:</b>"))
for item in [
    "Cold-start users (no history) → content-only recommendations",
    "Partial history → hybrid, weighted toward content",
    "Rich history → hybrid, weighted toward collaborative filtering",
    "isbn13 is the cross-system join key (not book_id)",
    "Required env vars: GOODREADS_CSV, DB_HOST, DB_USER, DB_PASSWORD, DB_NAME",
    "ML service runs on :6000; backend on :5000",
]:
    story.append(b(item))

story.append(Spacer(1, 0.1 * inch))

# File 2
story += h2("2. ml/notebooks/features/user_book_recommender/retrain.py — ML Retraining Pipeline")
story.append(p("<b>Agent submission value: HIGH</b>"))
story.append(p(
    "The most architecturally significant ML file. Called by the Node.js backend via "
    "<code>POST /api/ml/retrain</code>. Outputs a single JSON line to stdout; "
    "Node.js parses this as the response."
))
story.append(p("<b>Pipeline steps:</b>"))
for item in [
    "Pull quality signals from MySQL (user ratings + library STOCKED/ORDERED/IGNORED decisions)",
    "Pull user interactions for collaborative filtering (explicit ratings + implicit from status)",
    "Merge live signals with the Kaggle 100k-book CSV baseline",
    "Feedback loop: books rated by real users but absent from Kaggle CSV are appended to training data",
    "Conditionally retrain XGBoost (content-based) and SVD (collaborative filtering)",
    "Overwrite .pkl files in place; emit structured JSON to stdout",
]:
    story.append(b(item))
story.append(Spacer(1, 0.05 * inch))
story.append(p("<b>Critical constants agents must not invent:</b>"))

constants = table(
    ["Constant", "Value", "Meaning"],
    [
        ["MIN_NEW_ROWS", "100", "Skip XGBoost retrain if fewer MySQL signals"],
        ["MIN_CF_ROWS", "10", "Skip CF retrain if fewer interactions"],
        ["Rating blend", "0.7 kaggle + 0.3 user_avg", "When user rating exists, blend with Kaggle baseline"],
        ["Library weight: STOCKED/ORDERED", "3.0x", "Upweight books librarians approved"],
        ["Library weight: IGNORED", "0.5x", "Downweight books librarians rejected"],
        ["Implicit: read", "3.5", "Finished book — probably liked it"],
        ["Implicit: reading", "3.0", "In progress — neutral positive"],
        ["Implicit: want_to_read", "2.5", "Expressed interest — weaker signal"],
    ],
    col_widths=[1.8*inch, 1.5*inch, 3.1*inch],
)
story.append(constants)
story.append(Spacer(1, 0.05 * inch))
story.append(p("<b>Output contract (always one JSON line to stdout):</b>"))
story.append(code(
    '{"status": "ok", "elapsed_s": 12.3, "xgb_status": "ok", "xgb_accuracy": 0.87,\n'
    ' "cf_status": "ok", "cf_rmse": 0.91, "cf_unique_users": 6, "cf_unique_books": 42}\n\n'
    '{"status": "error", "message": "DB_HOST environment variable is not set."}'
))

story.append(Spacer(1, 0.1 * inch))

# File 3
story += h2("3. backend/scripts/user_flow_cli.js — Interactive E2E Test Driver")
story.append(p("<b>Agent submission value: MEDIUM-HIGH</b>"))
story.append(p(
    "An interactive CLI that exercises the entire backend + ML stack without Flutter. "
    "Run with <code>npm run test:user-flow</code> from <code>backend/</code>. "
    "This is the closest thing to an integration test suite in the repo."
))
story.append(p("<b>Covers:</b>"))
for item in [
    "Reader flow: view reads, add/update book status + rating, generate recommendations, view saved recommendations, trigger ML retrain",
    "Librarian flow: view library inventory, view local reader activity, generate library recommendations, update recommendation state, trigger ML retrain",
    "Reveals endpoints not in README: POST /recommendations/users/:id/generate and POST /recommendations/libraries/:id/generate",
    "Confirms library recommendation state machine: NEW → ORDERED → STOCKED → IGNORED",
    "Calls POST /api/ml/retrain directly — confirms Node-to-Python subprocess contract",
]:
    story.append(b(item))

story.append(Spacer(1, 0.1 * inch))

# File 4
story += h2("4. backend/DEMO_USERS.md — Seed Credentials")
story.append(p("<b>Agent submission value: MEDIUM</b>"))
story.append(p(
    "Documents deterministic test accounts created by <code>node scripts/seed_demo_data.js</code>. "
    "The librarian account is the only account with access to library-role endpoints."
))
tbl = table(
    ["Role", "Email", "Password"],
    [
        ["Reader (x6)", "e.g. ava.reader@readiculous.demo", "AvaReads123!"],
        ["Librarian", "grace.librarian@readiculous.demo", "GraceLibrary123!"],
    ],
    col_widths=[1.2*inch, 2.8*inch, 2.4*inch],
)
story.append(tbl)

story.append(Spacer(1, 0.1 * inch))

# File 5
story += h2("5. database/schema.sql — Source-of-Truth Data Model")
story.append(p("<b>Agent submission value: HIGH</b>"))
story.append(p(
    "Defines all MySQL tables. Essential anti-hallucination ground truth — agents must "
    "cross-reference this before writing SQL or constructing API payloads."
))
tbl = table(
    ["Table", "Key Facts"],
    [
        ["users", "role ENUM('user','librarian') — not 'reader'. user_id is VARCHAR(255) UUID."],
        ["books", "PK is isbn (VARCHAR 20) in schema; ML code calls it isbn13 — discrepancy."],
        ["user_reads", "Has both status (want_to_read/reading/read) AND rating (0–5 float)."],
        ["library_recommendations", "state ENUM: NEW / ORDERED / STOCKED / IGNORED."],
        ["user_genres / book_genres", "Many-to-many join tables; genre_id is INT UNSIGNED."],
        ["user_libraries", "One user → one library (one-to-one PK on user_id)."],
    ],
    col_widths=[1.8*inch, 4.6*inch],
)
story.append(tbl)

story.append(Spacer(1, 0.1 * inch))

# File 6
story += h2("6. backend/BookRecommendation.postman_collection.json — API Contract Artifact")
story.append(p("<b>Agent submission value: MEDIUM</b>"))
story.append(p(
    "Postman collection with pre-built request bodies for all major endpoints. "
    "Useful for extracting exact field names and example payloads without guessing. "
    "Backend base URL: <code>http://localhost:5000</code>."
))

story.append(Spacer(1, 0.1 * inch))

# File 7
story += h2("7. .github/workflows/deploy-pages.yml — CI/CD")
story.append(p("<b>Agent submission value: LOW</b>"))
story.append(p(
    "Deploys <code>docs/</code> to GitHub Pages on push to main. "
    "No test or lint enforcement gates. The pipeline is purely a static site deploy."
))

story.append(Spacer(1, 0.1 * inch))

# File 8
story += h2("8. frontend/analysis_options.yaml — Flutter Linter Config")
story.append(p("<b>Agent submission value: LOW (as a standalone file)</b>"))
story.append(p(
    "Enables <code>package:flutter_lints/flutter.yaml</code> with no custom overrides. "
    "Confirms <code>flutter analyze</code> is the linting command for the Flutter frontend."
))

# ── Summary Table ─────────────────────────────────────────────────────────────

story.append(PageBreak())
story += h1("File Summary Table")

tbl = table(
    ["File", "Type", "Saris AI Value"],
    [
        ["ml/README.md", "Architecture + full API docs", "HIGH"],
        ["ml/.../retrain.py", "ML pipeline with I/O contracts", "HIGH"],
        ["database/schema.sql", "Data model ground truth", "HIGH"],
        ["backend/scripts/user_flow_cli.js", "E2E test driver (CLI)", "MEDIUM-HIGH"],
        ["backend/DEMO_USERS.md", "Seed credentials for demo", "MEDIUM"],
        ["backend/BookRecommendation.postman_collection.json", "API payload examples", "MEDIUM"],
        [".github/workflows/deploy-pages.yml", "CI/CD (no test gates)", "LOW"],
        ["frontend/analysis_options.yaml", "Flutter linter config", "LOW"],
        ["database/.env.example", "Env var contract", "LOW"],
    ],
    col_widths=[2.6*inch, 2.2*inch, 1.6*inch],
)
story.append(tbl)

# ── Reusable Patterns ─────────────────────────────────────────────────────────

story += h1("Reusable Patterns for Saris AI")

patterns = [
    (
        "Tiered Cold-Start Routing",
        "content-only → hybrid (content-weighted) → hybrid (CF-weighted) based on "
        "interaction count thresholds. A clean, reusable ML routing pattern for any "
        "recommendation system."
    ),
    (
        "Library Signal Weighting",
        "Turning domain-expert decisions (librarian STOCKED/ORDERED/IGNORED) into "
        "training sample weights (3.0x / 0.5x). A principled human-in-the-loop "
        "feedback pattern applicable to any expert-guided ML system."
    ),
    (
        "Implicit Rating Fallbacks",
        "Deriving ratings from behavioral signals when explicit ratings are absent: "
        "read=3.5, reading=3.0, want_to_read=2.5. A standard implicit feedback pattern "
        "that prevents cold-start failures in collaborative filtering."
    ),
    (
        "JSON-to-stdout Subprocess Contract",
        "Node.js spawns Python; Python always emits exactly one JSON line to stdout "
        "(success or error). Simple, robust inter-process contract that avoids "
        "stderr/stdout confusion and enables structured error propagation."
    ),
    (
        "CLI-as-Integration-Test",
        "user_flow_cli.js exercises the full backend + ML API without a test framework. "
        "A lightweight pattern for validating end-to-end flows during development when "
        "a full test suite isn't yet in place."
    ),
    (
        "Feedback Loop via Training Data Expansion",
        "Every book a real user rates (even if absent from the Kaggle baseline) gets "
        "appended to the XGBoost training set. The model improves as the user base grows "
        "without requiring a full dataset replacement."
    ),
]

for title, desc in patterns:
    story += h2(title)
    story.append(p(desc))

# ── Gaps ──────────────────────────────────────────────────────────────────────

story += h1("Implicit vs. Explicit Operational Context")
story.append(p(
    "The repository relies on <b>implicit operational context embedded across README, "
    "schema, CLI tooling, and ML retraining code</b> rather than centralized agent "
    "instructions. This is a deliberate engineering choice \u2014 the contracts live "
    "close to the code that enforces them rather than in a separate instruction layer "
    "that can drift. The practical consequence is that an agent working in this codebase "
    "must be explicitly directed to read the right artifacts before acting."
))

tbl = table(
    ["Context Gap", "Where the Truth Actually Lives"],
    [
        ["No centralized agent instruction file (CLAUDE.md / AGENTS.md)", "Architecture in ml/README.md; contracts in retrain.py docstring and user_flow_cli.js"],
        ["No automated test suite", "user_flow_cli.js is the manual integration driver; run it to validate the full stack"],
        ["No ESLint config for backend JS", "No static analysis gate \u2014 code review is the only enforcement layer"],
        ["No OpenAPI/Swagger spec", "Endpoint contracts in README tables + Postman collection + route handlers directly"],
        ["isbn vs isbn13 discrepancy undocumented", "schema.sql PK is 'isbn'; ML service normalizes to 'isbn13' at CSV load time in retrain.py:267"],
        ["Generate endpoints not in README", "POST /recommendations/users/:id/generate and /libraries/:id/generate visible only in user_flow_cli.js:109\u2013137"],
    ],
    col_widths=[2.4*inch, 4.0*inch],
)
story.append(tbl)

# ── Anti-Hallucination Safeguards ─────────────────────────────────────────────

story += h1("Anti-Hallucination Safeguards for Agents")
story.append(p(
    "The following facts are non-obvious and likely to be hallucinated incorrectly "
    "by an agent without this document:"
))
for item in [
    "user role value is 'user' (not 'reader') in the ENUM",
    "ML service runs on port 6000; backend on 5000 — never swap these",
    "The Kaggle CSV column is named 'isbn'; the codebase normalizes it to 'isbn13' at load time",
    "Implicit rating values are exactly 3.5 / 3.0 / 2.5 — not 4 / 3 / 2",
    "Library signal weights are exactly 3.0 (approved) and 0.5 (rejected)",
    "Rating blend is 70/30 (kaggle/user), not 50/50",
    "XGBoost skips retrain below 100 signals; SVD skips below 10 interactions",
    "The /reload endpoint reloads .pkl files in memory — it does not retrain",
    "SessionNotifier (Riverpod) is the live auth layer; AuthService is legacy dead code",
    "user_libraries is a one-to-one table (user_id is PK) — one user can only belong to one library",
]:
    story.append(b(item))

story.append(Spacer(1, 0.15 * inch))
story.append(p(
    "<i>Generated from live codebase analysis. Verify against current source before "
    "asserting any claim as authoritative — the codebase evolves.</i>"
))

# ── Build ─────────────────────────────────────────────────────────────────────

doc.build(story)
print(f"PDF written to: {OUT}")