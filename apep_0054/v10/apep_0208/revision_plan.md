# Revision Plan: apep_0206 → Prose & Exhibits Polish

## Context

**Parent:** apep_0206 (μ=22.5, σ=2.10, conservative=16.2)
**Title:** Making Wages Visible: Labor Market Dynamics Under Salary Transparency
**Focus:** Prose quality (Shleifer style) + exhibit restructuring. No new analysis or data.

The paper has strong results and a sound design, but the writing is workmanlike and the figures are cluttered. The gap to AER (μ~28) is partly a prose and presentation gap. This revision addresses that.

---

## Workstream 1: Figure Restructuring

### Key idea: Two powerful multi-panel "transparency" figures replace ~6 individual plots.

**New Figure 2: CPS Trends (2 panels, side-by-side)**
- Panel (a): Mean Hourly Wage — Treated vs Control (from `03_descriptives.R`)
- Panel (b): Gender Wage Gap — Treated vs Control (from `03_descriptives.R`)
- Combined via `patchwork`. One caption tells the story: "aggregate wages track together; the gender gap diverges."

**New Figure 3: QWI Trends (2 panels, side-by-side)**
- Panel (a): Log Quarterly Earnings — Treated vs Control (from `06b_qwi_figures.R`)
- Panel (b): Gender Earnings Gap — Treated vs Control (from `06b_qwi_figures.R`, user's favorite)
- Same layout. Story: "admin data confirms: aggregate null, gender gap diverges."

**Figures to REMOVE from main text:**
- `fig4_event_study_main.pdf` — CPS event study (ugly, noisy)
- `fig5_event_study_gender.pdf` — gender event study (replaced by panel trend figure)
- `fig_qwi_event_earns.pdf` — QWI quarterly event study (noisy sawtooth)
- `fig_qwi_event_gap.pdf` — QWI quarterly event study gap (noisy)
- `fig9_conceptual_framework.pdf` — not needed (predictions table suffices)
- `fig6_ddd_gender.pdf` — DDD coefficient plot (tables carry this)

**Figures to KEEP (renumbered):**
- Figure 1: Policy map → stays Figure 1
- Dynamism coefficient plot → Figure 4
- Industry heterogeneity → Figure 5
- LOTO forest plot → Figure 6
- Permutation distribution → Appendix

**Net: Main text goes from ~10 figures to 6.** Much tighter.

### R Script Changes
- `03_descriptives.R`: Add combined 2-panel CPS figure using `patchwork`
- `06b_qwi_figures.R`: Add combined 2-panel QWI figure using `patchwork`
- Both: Strip ggplot titles/subtitles from all figures (LaTeX captions handle this)
- `00_packages.R`: Add `patchwork` if not already loaded

---

## Workstream 2: Abstract Rewrite

**Current:** ~230 words. Target: ~150 words.

Keep: the conceptual framing ("two countervailing forces"), the three findings with numbers, the punchy ending ("equity gains at zero efficiency cost").

Cut: dataset details (N values, "state-quarter-sex-industry level"), the long inference caveat, the "pattern of results" summary.

---

## Workstream 3: Prose Overhaul (Shleifer Style)

### Rules to apply throughout:
1. Open with a hook, not throat-clearing
2. Earn every sentence — if it doesn't advance the argument, cut it
3. Active voice 80%+
4. Results tell a story, don't narrate tables
5. Transitions pull forward
6. Short sentences land points; longer ones develop nuance

### Introduction (~1100 → ~700 words)
- **Keep:** "When employers must reveal what they pay, who benefits and what breaks?" — great hook
- **Cut:** The 200-word inference caveat paragraph → move to Section 7 (Robustness)
- **Cut:** "Contribution" paragraph listing four contributions → show, don't tell
- **Cut:** Hypothesis hierarchy paragraph → move to empirical strategy
- **Tighten:** Literature review from 5 sentences to 3
- **Tighten:** Results preview — give numbers without narrating table columns

### Conceptual Framework (trim ~15%)
- Less notation, more intuition. The predictions table is the star.

### Data (trim ~20%)
- The QWI suppression paragraph (2,652 → 2,603) → one sentence
- Keep "first full quarter" footnote

### Results (major restructure)
- **Lead with the new trend figures** (Figures 2 and 3) — visual story first
- Then regression tables
- **Kill "Quarterly Event Studies" subsection** → move to appendix
- Write results prose Shleifer-style: "Transparency does not move average wages" not "Column 3 of Table X shows..."

### Discussion (trim ~10%)
- Compress limitations from laundry list to 2 tight paragraphs

### Conclusion
- Reframe, don't summarize. End with a sentence that sticks.

---

## Workstream 4: LaTeX Improvements

- Add `microtype`, `subcaption` packages
- Clean up figure references after renumbering
- Ensure no ggplot titles leak into PDF (figures should have LaTeX captions only)

---

## Execution Order

1. Create workspace `output/paper_190/`, copy parent artifacts
2. Re-run all R scripts to regenerate figures/tables fresh
3. Modify `03_descriptives.R` + `06b_qwi_figures.R` — create combined panel figures, strip ggplot titles
4. Rewrite abstract (~150 words)
5. Rewrite introduction (Shleifer style, ~700 words)
6. Restructure results section — lead with figures, kill event study subsection
7. Tighten all remaining sections
8. Renumber figures, update all cross-references
9. Compile PDF, visual QA
10. Exhibit review (Gemini) → validate panel figures look right
11. Advisor review → fix issues
12. External review → revision cycle
13. Publish with `--parent apep_0206`

---

## What Does NOT Change

- All regression results, coefficients, standard errors
- All tables (content unchanged)
- Data, code logic, identification strategy
- References (stable, maybe add 1-2)

---

## Files to Modify
- `paper.tex` — Major prose rewrite + figure restructuring
- `code/03_descriptives.R` — Combined CPS panel figure
- `code/06b_qwi_figures.R` — Combined QWI panel figure
- `code/00_packages.R` — Add patchwork if needed

## Key Source Files
- `papers/apep_0206/paper.tex` — Current paper
- `papers/apep_0206/code/03_descriptives.R` — CPS trend figures
- `papers/apep_0206/code/06b_qwi_figures.R` — QWI trend figures
- `papers/apep_0206/code/06_figures.R` — Other CPS figures

## Verification
- PDF compiles cleanly
- All 6 main-text figures render (multi-panel figures correct)
- Abstract < 200 words (target 150)
- Page count ≥ 25 (watch for over-trimming)
- Exhibit review confirms panels look good
- 3/4 advisor PASS
- 3 external reviews completed
