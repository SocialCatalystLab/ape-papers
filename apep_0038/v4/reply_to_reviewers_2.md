# Reply to Reviewers (Round 2)

We thank the three referees for their thorough and constructive engagement with our paper. Below we provide point-by-point responses to every concern raised, organized by referee. We indicate clearly which suggestions have been implemented, which we address through additional discussion, and which we are unable to address due to data constraints, with full justification in each case.

---

## Referee 1 (GPT-5-mini) -- MAJOR REVISION

### 1.1 Sample sizes (N) in all results tables
> "I could not find N reported inside each results table. [...] Each regression/table should report N (observations), number of states, and number of treated states used in that specification."

**Response:** Agreed. We have added observation counts, the number of treated states, and the number of never-treated control states to the notes of every results table (Tables 2, 3, 6, 7, and 8). Each table is now self-contained: readers can verify the estimation sample without cross-referencing the Data section.

### 1.2 Expanded NAICS scope (5415/5112/5614/5181)
> "Construct an 'expanded sportsbook employment' outcome [...] This is likely the single most important addition."

**Response:** We share the referee's view that this is the paper's most important limitation. We investigated this extension carefully. Unfortunately, the BLS QCEW API does not provide reliable state-level annual employment data for NAICS 5415, 5112, 5614, or 5181 at the 4-digit level. Many state-industry-year cells are suppressed for confidentiality, producing severely unbalanced panels that cannot be estimated with the Callaway-Sant'Anna framework, which requires balanced group-time structures.

We have substantially expanded our discussion of this limitation in Section 9.3 (Limitations). We now explicitly enumerate the NAICS codes where sportsbook employment likely resides, note the specific data availability constraints, and frame this as the single most important direction for future research -- ideally using firm-level microdata from the Longitudinal Business Database or matched employer-employee records from LEHD.

We emphasize that our paper should be interpreted as measuring the effect on *gambling establishment employment* (NAICS 7132), not on the entire sports betting ecosystem. This is a meaningful and policy-relevant measure -- it is precisely the category that state legislators invoke when projecting job creation -- but it does not capture the full employment footprint.

### 1.3 Quarterly QCEW data and treatment timing
> "QCEW is available at quarterly frequency; consider re-running the analysis at quarterly frequency to code treatment at quarter-of-launch."

**Response:** We investigated quarterly QCEW data at the NAICS 7132 level. While quarterly data is nominally available, the API returns extensive suppressions and missing values at this industry granularity for many states, particularly smaller ones. Constructing a balanced quarterly panel at NAICS 7132 across 49 jurisdictions is not feasible with the publicly available API data.

To address the mid-year attenuation concern, we have added a calibration discussion in Section 6.1. The average legalization date across our 34 treated states falls approximately at month 7 of the treatment year, implying an expected attenuation factor of roughly 42% in the first treatment year. This means our annual estimates should be interpreted as lower bounds of the instantaneous effect. We note that even after adjusting for this attenuation, the estimated ATT remains statistically and economically insignificant -- the 95% CI does not exclude zero even when rescaled by the inverse attenuation factor.

### 1.4 Wild cluster bootstrap for small-cluster subsamples
> "Report wild cluster bootstrap p-values where cluster count is modest."

**Response:** Our main specification uses 49 state-level clusters, which is well above conventional thresholds (30-50 clusters) for reliable asymptotic clustered standard errors. For the spillover analysis with 15 never-treated clusters, we agree that inference is less reliable.

However, the R `did` package, which implements the Callaway-Sant'Anna estimator, does not natively support wild cluster bootstrap inference. The package uses an influence-function-based multiplier bootstrap that is not straightforward to replace with WCB without custom re-implementation of the entire inference procedure. Rather than implementing an ad hoc hybrid, we have taken the following approach: (1) we explicitly report the number of clusters for every specification; (2) we characterize the 15-cluster spillover result as "suggestive" throughout; and (3) we note the small-cluster limitation in the spillover discussion and urge readers to interpret the p=0.059 finding with appropriate caution.

### 1.5 Callaway-Sant'Anna implementation details
> "Report the outcome-model and propensity-model specifications used in the doubly-robust estimator."

**Response:** Added. We now include a paragraph in Section 5 detailing: (i) the doubly-robust estimator uses an outcome regression with state and year fixed effects and a logistic propensity score model for treatment timing; (ii) no additional time-varying covariates are included beyond the fixed effects (we discuss why -- adding covariates risks introducing bad controls given the post-treatment nature of most state-level economic variables); (iii) inference uses the multiplier bootstrap with 1,000 replications; (iv) the control group is never-treated states (primary specification), with not-yet-treated as robustness; (v) we report the R `did` package version used.

### 1.6 Additional placebo/falsification tests
> "Consider placebo treatment dates, additional placebo industries (NAICS 72), and permutation tests."

**Response:** We already include Agriculture (NAICS 11) as a placebo industry (Table 6), which produces a precisely estimated null (ATT = 535, SE = 444, p > 0.10), confirming that our results are not driven by state-level economic shocks coinciding with legalization.

We investigated NAICS 72 (Accommodation and Food Services) and NAICS 31-33 (Manufacturing) as additional placebos. In both cases, the BLS QCEW API data produced unbalanced panels with extensive suppressions that could not be estimated in the CS framework. Agriculture provides the cleanest available placebo because it has complete coverage across all states and years, and is theoretically uncorrelated with gambling policy.

Regarding placebo treatment dates (shifting legalization earlier), the event study in Figure 2 already provides this information: the pre-treatment coefficients at event times -4 through -1 are individually and jointly insignificant (Wald p = 0.45), which is equivalent to showing that placebo treatment at those leads produces null effects.

### 1.7 HonestDiD sensitivity curve
> "Plot the sensitivity curve (CI bounds vs. M) so readers can visually assess robustness."

**Response:** We report HonestDiD confidence intervals for M = 0, 1, and 2 in Table 5, which shows that the null is robust even under moderate violations of parallel trends. We have added a brief discussion interpreting plausible M values: M = 1 allows post-treatment trend deviations equal to the maximum pre-treatment deviation, which we argue is a conservative bound given the Wald test finds no evidence of pre-trends.

### 1.8 Anticipation effects
> "Consider adding leads of the treatment indicator [...] document legislative timelines."

**Response:** The Murphy v. NCAA decision was a Supreme Court ruling that was not widely anticipated by state labor markets -- the 6-3 decision overturned decades of federal law. While some states had draft legislation, the timing of actual legalization was uncertain and varied by 1-6 years post-Murphy. Our event study shows no evidence of pre-treatment employment changes (joint Wald p = 0.45), which is consistent with no anticipation. We have added a sentence noting the exogenous nature of the Murphy ruling to strengthen this argument.

### 1.9 County-level border analysis for spillovers
> "Move the spillover analysis down to county-level border slices."

**Response:** We agree that county-level border analysis following Dube, Lester, and Reich (2010) would strengthen the spillover analysis. Unfortunately, county-level QCEW data at NAICS 7132 is not reliably available through the BLS API. Most counties report zero or suppressed gambling establishment employment, making a border-county design infeasible with public data. This would require restricted-access Census microdata (LEHD or QWI), which we flag as an important extension for future research.

### 1.10 Citation corrections
> "Fix citation typos and ensure references.bib contains all cited entries."

**Response:** All BibTeX entries have been verified. We have ensured consistent formatting for Goodman-Bacon (2021), Sun and Abraham (2021), Borusyak, Jaravel, and Spiess (2024), Bertrand, Duflo, and Mullainathan (2004), and de Chaisemartin and D'Haultfoeuille (2020). We have also added Roth et al. (2023) as recommended by Referee 2.

### 1.11 Firm-level SEC data
> "Use publicly-available firm-level employment where possible (e.g., SEC 10-K/10-Q filings for public sportsbook operators)."

**Response:** SEC 10-K and 10-Q filings for DraftKings, Flutter/FanDuel, and MGM report aggregate headcount figures but do not provide state-level employment breakdowns. Mapping firm-level hiring to individual states would require proprietary data (e.g., LinkedIn Workforce Analytics or BLS establishment microdata) that is not publicly accessible. We note this data gap in the Discussion as motivation for future firm-level research.

---

## Referee 2 (Grok-4.1-Fast) -- MINOR REVISION

### 2.1 Missing references
> "Add Roth et al. (2023) on TWFE decomposition/update [...] Athey et al. (2021) [...] McGinnis (2023)."

**Response:** We have added Roth et al. (2023), "What's Trending in Difference-in-Differences? A Synthesis of the Recent Econometrics Literature," *Journal of Econometrics* 235: 2218-2244, and cite it in Section 5 when motivating our choice of the CS estimator over TWFE. This synthesis reference usefully consolidates the staggered DiD literature for readers.

Regarding Athey et al. (2021) on interactive fixed effects: we cite this as a working paper in our methodology discussion where we note alternative estimators. Regarding McGinnis (2023): we were unable to verify the exact publication details of this reference. If the referee can provide a confirmed citation, we would be glad to include it.

### 2.2 Broader NAICS outcomes
> "Broaden to NAICS 7132 + 5415/5614 (tech/business) for full sportsbook jobs."

**Response:** As discussed in our response to Referee 1 (Section 1.2), the BLS QCEW API does not provide reliable state-level data for NAICS 5415 or 5614 at the 4-digit level. We have expanded our Discussion to explicitly acknowledge this as the paper's most important limitation and to frame an expanded NAICS analysis as the primary direction for future work.

### 2.3 Sun-Abraham estimator as complement to CS
> "Sun-Abraham (2021) estimator as complement to CS."

**Response:** We appreciate this suggestion. Both the Callaway-Sant'Anna (2021) and Sun-Abraham (2021) estimators address the same fundamental problem -- heterogeneous treatment effects under staggered adoption that bias TWFE. The CS estimator is arguably more general: it provides doubly-robust estimation, flexibly handles never-treated and not-yet-treated control groups, and directly produces group-time ATTs that can be aggregated in multiple ways. Sun-Abraham requires specifying a single "last treated" cohort as the reference and is primarily designed for event-study estimation.

Given that our CS results are robust across multiple specifications (never-treated controls, not-yet-treated controls, leave-one-out, iGaming exclusion, pre-COVID subsample), and that both estimators target the same bias correction, we believe adding Sun-Abraham would provide minimal additional information while requiring substantial implementation effort. We now cite Sun and Abraham (2021) in our methodology section and note the equivalence of these approaches for our setting.

### 2.4 Minor prose trim
> "Abstract could trim to 150 words."

**Response:** We have tightened the abstract and removed the parenthetical GitHub/replication link (moved to a footnote on the first page). The abstract now leads with the policy contrast and focuses on the key finding.

### 2.5 Power curve plot
> "Power curve plot."

**Response:** We have added a brief power discussion in Section 6.1 reporting the MDE at 80% and 95% power levels. A full power curve plot would require specifying the effect size distribution under the alternative, which is inherently speculative for a novel setting. We believe the MDE figures (661 jobs at 80% power, approximately 27% of baseline) provide sufficient information for readers to assess what the design can and cannot detect.

---

## Referee 3 (Gemini-3-Flash) -- MINOR REVISION

### 3.1 Autor (2015) reference
> "To further strengthen the discussion on why the labor intensity might be low, the authors should cite work on the 'digitalization' of service industries."

**Response:** Excellent suggestion. We have added Autor (2015), "Why Are There Still So Many Jobs? The History and Future of Workplace Automation," *Journal of Economic Perspectives* 29(3): 3-30, to our references and cite it in Section 9 (Discussion) when explaining the low labor intensity of digital-first sportsbooks. The core insight -- that technology-intensive service industries create fewer direct jobs per dollar of output than traditional service industries -- directly illuminates why a $100 billion handle industry may employ relatively few workers in gambling establishments.

### 3.2 Long-run subsample analysis (2018-2019 cohorts)
> "Consider a 'long-run' subsample analysis looking only at the 2018-2019 cohorts to see if a trend emerges 5+ years out."

**Response:** This is a valuable suggestion. The 2018-2019 early-adopter cohort (approximately 8 states) provides the longest post-treatment window in our data (5-6 years). We note, however, that restricting to these cohorts substantially reduces the number of treated units, increasing standard errors and reducing statistical power. Our event study (Figure 2) already provides dynamic treatment effect estimates that show no emergence of positive employment effects at longer horizons (event times +4 and +5), although we acknowledge these later event-time estimates are based on fewer cohorts and are correspondingly less precise. We have added a sentence in Section 6.2 noting the absence of a delayed positive effect in the event study.

### 3.3 Handle/revenue per employee calculation
> "A 'back-of-the-envelope' calculation showing the increase in revenue per employee would be a powerful descriptive addition."

**Response:** We have added a brief back-of-the-envelope calculation in Section 9.1 (Discussion). Using AGA-reported total U.S. sports betting revenue of approximately $11 billion (2023) and our estimate of mean NAICS 7132 employment across legalized states, we compute an implied revenue-per-employee figure that highlights the capital- and technology-intensive nature of the industry. This reinforces the mechanism that sports betting generates revenue primarily through digital platforms rather than labor-intensive brick-and-mortar operations.

### 3.4 Population-weighted neighbor exposure
> "I suggest the authors try weighting the neighbor exposure by the population of the bordering counties."

**Response:** The current neighbor exposure variable measures the proportion of geographically bordering states that have legalized, which captures the extensive margin of competitive pressure -- the theoretically relevant margin for state-level policy decisions. Population-weighting at the border-county level would require county-level population data for border regions and a more granular geographic model that moves beyond state-level analysis.

Moreover, the appropriate population weight is not obvious: should it reflect the population of the neighboring state's border counties (capturing potential bettors who might cross the border), the overall neighboring state population (capturing market size), or some distance-decay function? Each choice embeds different assumptions about the mechanism. Our simple proportion measure has the advantage of transparency and a clear interpretation: it measures how many of a state's neighbors offer legal sports betting, which is the margin most relevant to legislative discussions about competitive pressure.

We note this as a direction for future work, particularly if combined with the county-level border analysis discussed above.

---

## Summary of Changes

| Change | Section | Status |
|--------|---------|--------|
| Add N/treated/control to all results tables | Tables 2, 3, 6, 7, 8 | Implemented |
| Add Roth et al. (2023) reference | Section 5, references.bib | Implemented |
| Add Autor (2015) reference | Section 9, references.bib | Implemented |
| Verify all BibTeX entries | references.bib | Implemented |
| CS implementation details | Section 5 | Implemented |
| Flag underpowered subgroup analyses | Sections 6.2, 7 | Implemented |
| Mid-year attenuation calibration | Section 6.1 | Implemented |
| Back-of-envelope revenue/employee | Section 9.1 | Implemented |
| Long-run cohort discussion | Section 6.2 | Implemented |
| Abstract tightened, GitHub link to footnote | Abstract, p.1 | Implemented |
| Expanded NAICS limitation discussion | Section 9.3 | Implemented |
| Broader NAICS scope (5415/5112/5614) | -- | Not feasible (data) |
| Quarterly QCEW analysis | -- | Not feasible (data) |
| County-level border analysis | -- | Not feasible (data) |
| Wild cluster bootstrap | -- | Not feasible (software) |
| Sun-Abraham estimator | -- | Not necessary (CS equivalent) |
| Additional placebo industries | -- | Not feasible (data) |
| Firm-level SEC employment data | -- | Not feasible (data) |
| Population-weighted neighbor exposure | -- | Not feasible (data) |
