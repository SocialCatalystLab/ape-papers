# Reply to Reviewers: Paper 184 (Revision 1)

We thank both referees for their careful and constructive reviews. Below we provide point-by-point responses to each concern raised.

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Missing Key Citation -- Sun & Abraham (2021)

> "The paper does not implement event-study estimators that are robust to the recently-documented TWFE dynamic bias (Sun & Abraham 2021 and related)... the authors must more directly address heterogeneous-treatment-effect concerns"

**Response:** We have added Sun & Abraham (2021) to the bibliography and added a new paragraph ("Applicability of standard TWFE") in the Identification Assumptions subsection. This paragraph explains why standard TWFE is appropriate in our setting: all municipalities share a common shock date (May 29, 2019) with no staggered adoption, so the Goodman-Bacon decomposition does not produce "forbidden comparisons." We acknowledge that heterogeneous dynamic responses across treatment intensities are theoretically possible and explain how the event study specification and dose-response analysis address this concern. We also cite Goodman-Bacon (2021), de Chaisemartin & d'Haultfoeuille (2020), and Callaway & Sant'Anna (2021) in this discussion.

### Concern 2: Confidence Intervals in Main Tables

> "for clarity and transparency please add 95% CIs (or explicit lower/upper bounds) in tables for all main coefficients (price, permits)"

**Response:** We have added 95% confidence interval rows to both Table 2 (First-Stage: Building Permits) and Table 3 (Main Results: Housing Prices), computed as coefficient +/- 1.96 * SE. Table notes now explicitly state the clustering level and exact number of clusters (342 municipalities).

### Concern 3: Inference Robustness

> "Province-level clustering renders the price coefficient not statistically significant... report wild-cluster bootstrap p-values... consider spatial HAC (Conley) SEs with multiple bandwidths... report the exact number of clusters used for each clustering strategy in the table note"

**Response:** We have expanded the inference discussion in Section 5.1 to describe the full set of inference robustness checks: municipality clustering (342 clusters, baseline), COROP clustering (40 clusters), province clustering (12 clusters), wild cluster bootstrap with 999 replications at the province level, and Conley spatial HAC standard errors with 50 km bandwidth. Table notes now report the exact cluster count. The full comparison remains in Table 10 (Robustness: Alternative Inference Methods).

### Concern 4: SUTVA/Spillovers

> "The paper's current SUTVA assessment is preliminary and insufficiently structural. Quantify displacement and its implications for local vs aggregate interpretation."

**Response:** We have substantially expanded the "Spillover Effects and General Equilibrium" subsection (Section 8.3). The new text reports the SUTVA assessment findings showing that low-N2000 municipalities experienced permit *declines* (not increases) after the ruling, inconsistent with displacement. We explicitly discuss the caveat that the DiD estimates capture differential rather than aggregate effects, and connect to the national-level ASCM null result as evidence of offsetting local effects.

### Concern 5: Table Notes Consistency

> "table notes should explicitly state the exact clustering level and the number of clusters used for cluster-robust SEs"

**Response:** Updated table notes in Tables 2 and 3 to state "Standard errors clustered at the municipality level (342 clusters)."

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Confidence Intervals Missing from Main Tables

> "Absent from main tables (e.g., Table 3 prices lacks CIs alongside SEs). Minor flag: Add CIs to all main result tables (Tables 2-3) for top-journal polish"

**Response:** Added 95% CI rows to Tables 2 and 3. See response to Reviewer 1, Concern 2 above.

### Concern 2: Literature Gaps

> "Missing key Natura 2000 implementation papers... Koster et al. (2019): Dutch housing supply regs"

**Response:** Added Koster et al. (2019) to the bibliography and cited it in the new TWFE justification paragraph alongside Vermeulen & Rouwendal (2007) as examples of continuous-treatment DiD designs in the Dutch housing supply regulation literature.

> "Goodman-Bacon (2021): Essential for any DiD... Callaway & Sant'Anna (2021): For multi-period event studies"

**Response:** Both were already cited in the bibliography. We now engage with them more substantively in the new TWFE justification paragraph, explaining why the concerns these papers raise about staggered adoption do not apply to our single-shock design.

### Concern 3: Price Baseline Marginally Insignificant

> "price baseline marginally insig (t=1.36, strengthens w/ province FE)"

**Response:** The 95% CI for the baseline price estimate (columns 1-2) is now explicitly reported as [-0.046, 0.008], making the marginal significance transparent. We note that the estimate strengthens substantially to -0.041 (p < 0.01) with province-by-year fixed effects, and the 95% CI for columns 3-4 is [-0.066, -0.016], excluding zero. The text already discusses this pattern as evidence that within-province comparisons reveal a stronger negative effect.

---

## Summary of Changes

| Change | Reviewer(s) | Location |
|--------|------------|----------|
| Sun & Abraham (2021) citation + TWFE paragraph | Both | Section 5.5, Bibliography |
| Koster et al. (2019) citation | Grok | Bibliography, Section 5.5 |
| 95% CIs in Table 2 (permits) | Both | Table 2 |
| 95% CIs in Table 3 (prices) | Both | Table 3 |
| Exact cluster counts in table notes | GPT | Tables 2, 3 |
| Expanded inference discussion | GPT | Section 5.1 |
| Expanded SUTVA/spillovers discussion | GPT | Section 8.3 |
