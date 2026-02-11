# Reviewer Response Plan

## Summary of Reviews
- GPT-5-mini: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Grouped Concerns and Actions

### 1. Power/MDE Analysis (GPT — critical)
**Action:** Add MDE calculation to paper. With SE=236 and pre-treatment mean employment of ~2,414:
- MDE (80% power, two-sided 5%): ~2.8 * SE = ~661 jobs = ~27% of baseline
- MDE (95% power): ~3.5 * SE = ~826 jobs = ~34% of baseline
- We can rule out effects larger than ~661 jobs (27% of baseline employment)
- Add to Section 6.1 and Discussion

### 2. Broader NAICS Scope (All three reviewers)
**Action:** Acknowledge limitation more explicitly. Note that QCEW API does not provide reliable state-level data for NAICS 5415/5112 at the granularity needed. Add a paragraph in Discussion discussing this as the main caveat and framing it as a clear direction for future research.

### 3. Small-Cluster Inference (GPT)
**Action:** Add note about wild cluster bootstrap for the 15-cluster spillover subsample. Our main analysis has 49 clusters, which is sufficient.

### 4. Missing References (All three)
**Action:** Add Holmes (1998) for border analysis, and acknowledge the Humphreys et al. (2023) and Philander (2014) references if real.

### 5. Exhibit Improvements (from exhibit review)
**Action:** Already addressed key issues (Table 1 dates, Table 7 stars, HonestDiD text-table alignment).

### 6. Prose Improvements (from prose review)
**Action:** Already improved opening hook, results narration, transitions, and conclusion.

### Items NOT addressed (with justification)
- Quarterly QCEW analysis: Data not available at needed NAICS granularity via API
- County-level border analysis: Requires county-level QCEW data (not in scope for this revision)
- Firm-level DraftKings/FanDuel analysis: SEC filings not available via API
- Goodman-Bacon decomposition: Would require additional implementation time
- Additional placebo industries (NAICS 72): Manufacturing data already failed; NAICS 72 likely similar issues
