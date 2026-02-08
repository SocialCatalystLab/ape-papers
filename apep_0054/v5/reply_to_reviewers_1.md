# Reply to Reviewers - Round 1

We thank the reviewers for their constructive feedback. This paper is a polishing revision of apep_0155 addressing the previous round's concerns. Below we respond to each reviewer.

---

## Reviewer 1 (GPT-5-mini) - MAJOR REVISION

### Comment 1.1: Small cluster inference
> "With only 6 treated states contributing post-treatment variation, standard cluster-robust inference may be unreliable..."

**Response:** We acknowledge this fundamental design limitation. The paper now reports wild cluster bootstrap p-values in all main tables (Tables 2, 3, and 4). The bootstrap p-values support the same conclusions as standard inference. Additionally, randomization inference results are discussed in Section 7.7.

### Comment 1.2: Goodman-Bacon decomposition
> "Show the full decomposition in the Appendix..."

**Response:** We use Callaway-Sant'Anna specifically to avoid TWFE bias issues that the Goodman-Bacon decomposition diagnoses. The C-S estimator does not use already-treated units as controls, so the negative weight problem does not apply. We note this as an additional diagnostic that could be added but is not essential given our estimator choice.

### Comment 1.3: Job posting data
> "Bring in job posting data to measure compliance..."

**Response:** We acknowledge this limitation. Proprietary data from Lightcast/Burning Glass would enable direct compliance measurement but is not available. This remains an important avenue for future research.

### Comment 1.4: Synthetic control robustness
> "Add synthetic control as a robustness check..."

**Response:** Noted as valuable future robustness. The current analysis uses three modern staggered DiD estimators (C-S, Sun-Abraham, did2s) which together provide triangulation. Synthetic control methods are not yet standard requirements for staggered adoption settings.

---

## Reviewer 2 (Grok-4.1-Fast) - MINOR REVISION

### Comment 2.1: Paper reads like "QJE lead paper"
**Response:** Thank you for this assessment.

### Comment 2.2: Additional references
**Response:** We have added Roth et al. (2023) "What's Trending in DiD" and Bertrand et al. (2004) on cluster inference.

### Comment 2.3: Consolidate appendix tables
**Response:** The appendix structure has been maintained for completeness but we have ensured no redundancy with main text tables.

---

## Reviewer 3 (Gemini-3-Flash) - CONDITIONALLY ACCEPT

### Comment 3.1: Minor literature additions
**Response:** Added Bessen et al. (2020) on salary history bans and strengthened the discussion of concurrent policies that may confound estimates.

### Comment 3.2: Firm-size data clarification
**Response:** The CPS does not directly measure employer size. We exploit variation in state-level employer thresholds as a proxy, noting this limitation in Section 7.6.

---

## Summary of Changes

This revision addresses:
1. Gemini advisor FAIL issues (2024 cohort labeling, R² explanation, table formatting)
2. Wild bootstrap p-values added to all main tables
3. Trimmed repetition in Introduction
4. Added 3 new references
5. Strengthened concurrent policy discussion

The paper is 39 pages, has passed all 4 advisors, and has 3 complete external reviews. Per workflow guidelines, we are proceeding to publication as this represents revision 3 of the paper lineage.
