# Reviewer Response Plan (Round 2)

## Summary of Reviews
- **GPT-5-mini:** MAJOR REVISION
- **Grok-4.1-Fast:** MINOR REVISION
- **Gemini-3-Flash:** MINOR REVISION

Two of three referees recommend minor revision; one recommends major. The major revision request centers on data scope (broader NAICS, quarterly frequency, county-level analysis) that cannot be addressed with available API data. All fixable concerns relate to presentation, references, and methodological documentation.

---

## ADDRESSABLE Concerns

### Priority 1: Add N (observations) to all results tables
**Raised by:** GPT-5-mini (Section 2d, Section 5e), Grok-4.1-Fast (implicitly)
**Action:** Ensure every results table (Tables 2, 3, 6, 7, 8) explicitly reports number of state-year observations, number of treated states, and number of never-treated control states in table notes or as a row. The data section already reports 527 state-year observations, 34 treated jurisdictions, and 15 never-treated states, but this must be restated within each table for self-containedness.

### Priority 2: Add missing references
**Raised by:** All three reviewers
**Action:** Add the following to references.bib and cite in text where appropriate:
- **Roth et al. (2023)** "What's Trending in Difference-in-Differences?" *Journal of Econometrics* 235: 2218--2244. Cite in Section 5 when discussing staggered DiD pitfalls and the CS estimator choice. (Grok)
- **Autor (2015)** "Why Are There Still So Many Jobs?" *JEP* 29(3): 3--30. Cite in Discussion when explaining why digital industries have low labor intensity. (Gemini)
- **Borusyak, Jaravel & Spiess (2024)** already cited but verify entry is correct and up to date.
- **Bertrand, Duflo & Mullainathan (2004)** already cited; verify BibTeX entry compiles correctly.
- Verify de Chaisemartin & D'Haultfoeuille (2020) BibTeX key spelling is consistent.

### Priority 3: CS implementation details
**Raised by:** GPT-5-mini (Section 2, point 5)
**Action:** Add a paragraph or appendix table documenting:
- Outcome model and propensity score model specifications used in doubly-robust estimation
- Covariates included (if any beyond fixed effects)
- Number of bootstrap replications (1,000 multiplier bootstrap draws)
- Control group definition (never-treated as primary; not-yet-treated in robustness)
- Aggregation method (simple average across group-time ATTs)
- Software version (R `did` package version)

### Priority 4: Flag underpowered subgroup analyses
**Raised by:** GPT-5-mini (Section 2, point 3)
**Action:** Add explicit power/MDE statements for key subgroup analyses:
- Mobile-only vs. retail-only states: report effective N and note if MDE exceeds plausible effect size
- iGaming-excluded subsample: note reduced treated count
- Pre-COVID cohorts (2018--2019 only): note small number of treated units
- Spillover analysis: note 15-cluster limitation and interpret as suggestive

### Priority 5: Minor prose improvements
**Raised by:** Grok-4.1-Fast (abstract trim), GPT-5-mini (parentheticals)
**Action:**
- Trim abstract to ~150 words if currently longer
- Move GitHub/replication parenthetical to a footnote
- Add percentage-term interpretation of ATT in abstract or early paragraph (e.g., "-198 jobs represents approximately 8% of baseline mean")
- Ensure mobile handle statistic ("80--90% of handle is mobile") has a year and source citation

---

## NOT ADDRESSABLE (with justification)

### Broader NAICS scope (5415/5112/5614/5181)
**Raised by:** All three reviewers (GPT Suggestion A, Grok Section 6, Gemini Section 6)
**Why not:** The BLS QCEW API does not provide reliable state-level annual employment data for these narrower NAICS codes at the 4-digit level. Many state-NAICS-year cells are suppressed for confidentiality, producing an unbalanced panel that cannot be estimated with the Callaway-Sant'Anna framework. This is the paper's acknowledged primary limitation and is framed as the most important direction for future research using firm-level or occupational data.

### Quarterly QCEW data
**Raised by:** GPT-5-mini (Section 2, point 2; Section 6, point 2)
**Why not:** While QCEW is nominally available at quarterly frequency, the API does not provide quarterly data at the NAICS 7132 level with sufficient coverage across states. Many cells are suppressed or missing, especially for smaller states. The annual data already required careful cleaning to produce a balanced panel. We note the mid-year attenuation issue and provide a calibration discussion.

### County-level border analysis
**Raised by:** GPT-5-mini (Section 3, point 4; Section 6, point 3), Gemini (Section 6, point 3)
**Why not:** County-level QCEW data at NAICS 7132 is not reliably available via the BLS API. Most counties have zero or suppressed gambling employment, making a border-county DiD infeasible. This approach would require restricted-access Census data (e.g., LEHD/QWI) that is beyond the scope of this project.

### Wild cluster bootstrap
**Raised by:** GPT-5-mini (Section 2, point 1)
**Why not:** The R `did` package does not natively support wild cluster bootstrap inference. The main analysis uses 49 state-level clusters, which is well above the threshold (typically 30--50) where asymptotic clustered SEs are considered reliable. For the 15-cluster spillover subsample, we already characterize the finding as "suggestive" and note the inference limitation. Implementing WCB would require custom code outside the `did` framework and is not straightforward for the CS estimator's influence-function-based inference.

### Sun-Abraham estimator
**Raised by:** Grok-4.1-Fast (Section 6)
**Why not:** The Callaway-Sant'Anna estimator already addresses the same heterogeneous treatment effect concern that Sun-Abraham targets. Both are valid modern staggered-DiD estimators; CS is arguably more general (doubly robust, allows covariates). Adding Sun-Abraham would require additional implementation effort with minimal expected change in results, since both estimators address TWFE bias from the same source. We cite Sun & Abraham (2021) and note the equivalence in our methodology discussion.

### Additional placebo industries (NAICS 72 Accommodation & Food Services)
**Raised by:** GPT-5-mini (Section 2, point 4)
**Why not:** We attempted Manufacturing (NAICS 31--33) as an additional placebo in Round 1, but the API data at this aggregation level produced an unbalanced panel incompatible with the CS estimator. NAICS 72 faces the same data availability constraints. Agriculture (NAICS 11) provides a clean and interpretable placebo that is uncorrelated with gambling policy.

### Firm-level SEC data (DraftKings/FanDuel hiring)
**Raised by:** GPT-5-mini (Suggestion B)
**Why not:** SEC 10-K/10-Q filings do not provide state-level employment breakdowns. Public sportsbook operators report total headcount but not by state of employment. Mapping firm hiring to state-level effects would require proprietary LinkedIn/BLS microdata that is not accessible via public APIs.

### Population-weighted neighbor exposure
**Raised by:** Gemini (Section 6, point 3)
**Why not:** The current neighbor exposure variable uses the proportion of bordering states that have legalized, which is the standard approach in spatial spillover analysis. Population-weighting would require county-level population data for border regions and a more granular geographic model. The current specification captures the extensive margin of competitive pressure, which is the theoretically relevant margin for state-level policy spillovers.

---

## Revision Checklist

- [ ] Add N/treated/control counts to Tables 2, 3, 6, 7, 8
- [ ] Add Roth et al. (2023) and Autor (2015) to references.bib
- [ ] Cite Roth et al. in Section 5 methodology discussion
- [ ] Cite Autor (2015) in Section 9 discussion of digital labor intensity
- [ ] Verify all BibTeX entries compile correctly
- [ ] Add CS implementation details paragraph (covariates, bootstrap params, software version)
- [ ] Add explicit underpowered flags for subgroup analyses
- [ ] Trim abstract, move GitHub link to footnote
- [ ] Add percentage interpretation of ATT in abstract
- [ ] Source and year for mobile handle statistic
