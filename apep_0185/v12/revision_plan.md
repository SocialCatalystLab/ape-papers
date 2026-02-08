# Revision Plan: apep_0202 → paper_186

## Context
**Parent:** apep_0202 "Friends in High Places: How Social Networks Transmit Minimum Wage Shocks"
**Parent of parent:** apep_0201
**Rating:** 31.9 (σ=3.87), conservative=20.3
**Integrity:** SUSPICIOUS (4 HIGH issues)
**Reviews:** GPT=MAJOR REVISION, Grok=MINOR REVISION, Gemini=MINOR REVISION

## User Directives (5 items)
1. Fix code review issues
2. Address useful external reviewer comments
3. Reframe: core economics/labor markets, NOT "information volume"
4. 35-40 page main text + proper appendix (content declaration, numbered sections)
5. Drop event study entirely

---

## Workstream 1: Code Integrity Fixes (Priority #1)

### 1a. Fix population weight construction (02b_add_pop_weights.R:34-38)
**Issue:** Uses `mean(emp)` over full panel instead of pre-treatment 2012-2013 average
**Fix:** Filter to `year %in% c(2012, 2013)` before computing `pop_proxy`
**Impact:** Results will change — weights become genuinely predetermined per Borusyak et al.

### 1b. Fix QWI fetch provenance (01_fetch_data.R:442-443)
**Issue:** Comment says "subset for demonstration" — misleading. Silent failure on API errors.
**Fix:** Remove misleading comment. Add completeness check after fetch loop (count successes, report missing state×year×quarter cells, stop with error if coverage < 95%).

### 1c. Fix QWI error handling (01_fetch_data.R:425-439)
**Issue:** `return(NULL)` swallows all errors silently
**Fix:** Add `message()` logging on failures. After loop, report total success/fail counts and which state-year-quarters are missing. Warn if any are missing.

---

## Workstream 2: Reframe Paper — Core Economics, Not "Information Volume"

This is the biggest structural change. The user finds the "information volume" framing distracting. The core economics question is better framed as: **Do social network connections to high-wage labor markets improve local labor market outcomes?**

### 2a. New framing: Social Networks and Labor Market Spillovers
- **Title change:** "Friends in High Places: Social Network Connections and Local Labor Market Outcomes" (drop "information volume" / "transmit minimum wage shocks")
- **Abstract rewrite:** Lead with the labor economics question. The pop-weight vs prob-weight comparison remains as a specification test, not as the central narrative
- **Theory section:** Simplify. Cut the formal information diffusion model (Section 2.4 extreme value theory). Keep the economic intuition: workers connected to high-wage areas have better outside options, update reservation wages, search more actively. The pop vs prob distinction becomes "extensive margin of network connections" rather than "information volume"
- **Drop "volume" language throughout:** Replace "information volume" with "breadth of network connections" or "scale of exposure" or just describe what pop-weighting does mechanically

### 2b. Tighten Introduction
- Cut from ~4 pages to ~2.5 pages
- Lead with economic question, not measurement innovation
- State results concisely, save detailed numbers for Results section
- Drop the 5-contribution list — synthesize into 2-3 sentences

### 2c. Simplify Theory (Section 2)
- Keep channels (information, migration option value, employer response) — these are good economics
- Keep formal definitions of the two exposure measures
- Cut the extreme value theory formal model (Section 2.4) — move to appendix if desired
- Cut "Unit of Analysis" subsection (2.5) — integrate key point into Results interpretation
- Cut "Testable Predictions" enumerated list — weave into narrative

---

## Workstream 3: Drop Event Study

Per user instruction, remove the event study analysis entirely.

### What to remove:
- Section 8.1 (Event-Study Specification) and Figure 5
- Section 8.7 (Reduced-Form Event Study and Distance-Credibility) — but KEEP the distance-credibility table/figure as standalone robustness
- Figure 9 (dual event study)
- References to pre-trend p=0.008 throughout
- The structural vs reduced-form event study distinction narrative

### What to keep:
- Distance-restricted instruments (Table 8) — this is valuable robustness independent of event studies
- Distance-credibility analysis (Table 9, Figure 10) — reframe as "distance robustness" without RF event study column
- Balance tests (Table 6)
- All other robustness (permutation, AR CIs, leave-one-out, placebos)

### Reframe identification narrative:
- Without the event study, lean on: (1) strong first stage, (2) distance-restricted instruments improving balance, (3) placebo shocks, (4) leave-one-out stability, (5) Anderson-Rubin CIs, (6) permutation inference
- Be honest that we don't have a pre-trends test — acknowledge this as a limitation of the shift-share IV design, note that it's fundamentally different from DiD

---

## Workstream 4: Restructure — 35-40 Page Main + Proper Appendix

### Main text target: ~37 pages
1. Introduction (~2.5 pp)
2. Institutional Background (~2 pp) — merge with literature into "Background"
3. Theoretical Framework (~3 pp, streamlined)
4. Data (~2 pp)
5. Construction of Exposure Measures (~1.5 pp)
6. Identification Strategy (~3 pp)
7. Main Results (~4 pp) — employment, earnings, USD specs, prob-weight mechanism test
8. Robustness (~4 pp) — distance, balance, leave-one-out, placebos, inference, county trends, Sun-Abraham
9. Mechanisms: Job Flows and Migration (~3 pp) — merge current Sections 10+11
10. Heterogeneity (~2 pp)
11. Discussion (~3 pp) — magnitudes, LATE, policy implications, limitations
12. Conclusion (~1.5 pp)
References (~4 pp)

### Move to Appendix:
- Formal information diffusion model (current Section 2.4)
- Probability-weighted exposure map (already in appendix)
- Exposure gap map (already in appendix)
- Full shock contribution diagnostics table (currently Table 8)
- LATE/Complier characterization table (currently Table 10)
- Sun and Abraham detailed results
- County-specific linear trends results
- Joint state exclusion results
- Rambachan-Roth sensitivity details
- Industry heterogeneity details
- Urban-rural heterogeneity details

### Appendix structure:
First page: **Content Declaration**
```
Appendix Contents
A. Theoretical Model Details
B. Additional Robustness Checks
C. Heterogeneity Analysis Details
D. Data Construction Details
```

---

## Workstream 5: Address Reviewer Comments

### From GPT (MAJOR REVISION):
- [x via WS1] Fix code integrity
- [x via WS4] Move sensitivity analyses to appendix with full tables
- [x via WS3] Pre-trend discussion simplified by dropping event study
- Add: Rambachan & Roth full sensitivity curves in appendix
- Add: Wild cluster bootstrap results
- Add: More explicit LATE discussion in main text
- Add: Kline & Moretti (2014) citation for magnitude comparison

### From Grok (MINOR REVISION):
- Add: Jardim et al. (2024) citation on interstate MW spillovers
- Add: Schmutte (2015) citation per Gemini suggestion
- [x via WS4] Prose-ify testable predictions list

### From Gemini (MINOR REVISION):
- Add: Industry-specific job flow analysis (high-bite sectors)
- Note: Housing price channel mentioned but we don't have Zillow county data in our pipeline — acknowledge as future work

---

## Execution Order

1. **Create workspace** `output/paper_186/` — copy parent artifacts
2. **Fix code** (WS1: 02b_add_pop_weights.R, 01_fetch_data.R)
3. **Re-run all R scripts** to regenerate results with fixed weights
4. **Rewrite paper.tex** (WS2 reframe + WS3 drop event study + WS4 restructure + WS5 reviewer fixes)
5. **Regenerate figures** (drop event study figures, keep others)
6. **Compile PDF, visual QA**
7. **Advisor review → fix → External review → fix**
8. **Publish** with `--parent apep_0202`

---

## Verification
- After fixing `02b_add_pop_weights.R`, confirm weights use only 2012-2013 data
- After re-running analysis, verify main coefficients are reasonable (they may shift)
- Check compiled PDF is 35-40 main text pages
- Check appendix has content declaration on first page
- Check no event study figures/tables remain in main text
- Check "information volume" language is replaced throughout
- Run `python3 scripts/workflow_status.py output/paper_186/`
