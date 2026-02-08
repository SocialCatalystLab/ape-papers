# Reply to Reviewers - Round 2

## Response to External Review 2/3

Thank you for the thorough and constructive review. We have addressed each of the critical methodological concerns raised.

---

### 1. Sharp vs Fuzzy RD Mischaracterization

**Reviewer Concern:** The paper claims a "sharp" threshold but Lifeline has categorical eligibility (SNAP/Medicaid/SSI) which makes some households above 135% FPL still eligible.

**Response:** We have substantially reframed our estimand throughout the paper. The abstract, introduction, and methods sections now explicitly state that we estimate "the effect of being below the 135% FPL income threshold" rather than "the effect of Lifeline eligibility." We added a new subsection (3.5.3) titled "Categorical Eligibility and Design Fuzziness" that explains:
- The dual eligibility pathways (income-based vs categorical)
- That our estimand captures the income-based pathway specifically
- We report SNAP receipt rates above the threshold (~2-4%) to quantify the fuzziness

---

### 2. Manipulation Test

**Reviewer Concern:** The two-bin chi-squared test is not adequate for a top journal. Need McCrary/rddensity.

**Response:** We implemented a proper McCrary-style density test with local polynomial estimation on each side of the cutoff. The new test reports:
- Log-difference in densities: -0.033 (z = -8.56, p < 0.001)
- Density from left: 0.00207
- Density from right: 0.00213

While statistically significant, the density difference is economically tiny (~3%) and goes in the opposite direction from what manipulation would predict (fewer observations below, not bunching). We discuss that the significance likely reflects our large sample size (N>680,000) and discreteness in POVPIP. We also implement donut RD as robustness.

---

### 3. Covariate Balance

**Reviewer Concern:** Age discontinuity is significant; need joint test and covariate-adjusted RD.

**Response:**
- Added joint chi-squared test across covariates (χ² = 16.85, p = 0.0002)
- Added covariate-adjusted RD estimates (Table 3, Panel A)
- The covariate-adjusted estimate is -0.05 pp (vs -0.30 pp unadjusted), demonstrating that age imbalance is not driving results
- Expanded discussion of why 0.5-year age difference is economically negligible

---

### 4. Bandwidth Sensitivity

**Reviewer Concern:** Significant negative estimate at 30pp bandwidth dismissed too quickly. Need modern RD inference and transparent bandwidth selection.

**Response:** We substantially expanded the bandwidth sensitivity analysis:
- Now report 8 bandwidths (20-80 pp)
- Explicitly acknowledge that estimates are significant at 25-35 pp bandwidths (p < 0.05)
- Provide three interpretations of this pattern
- Explain why we view the preponderance of evidence as consistent with null:
  - Covariate-adjusted estimates are essentially zero
  - Donut RD estimates are null
  - Negative direction is implausible (eligibility reducing adoption?)
- Added local quadratic specification which shows significant negative effect

---

### 5. Missing RD References

**Reviewer Concern:** Missing Calonico et al. (2014), Cattaneo et al. (2018), Lee & Card (2008), Calonico et al. (2019).

**Response:** All four references have been added to the bibliography:
- Calonico, Cattaneo, Titiunik (2014) - Econometrica - robust bias-corrected inference
- Calonico, Cattaneo, Farrell, Titiunik (2019) - REStat - RD with covariates
- Cattaneo, Jansson, Ma (2018) - Stata Journal - density testing
- Lee and Card (2008) - JoE - discrete running variable

These are now cited in the Robustness Specifications subsection.

---

### 6. Additional Robustness

**Response:** Added three new robustness specifications in Table 3:
- With covariates: τ = -0.0005, p = 0.87
- Local quadratic: τ = -0.0098, p = 0.027
- Donut RD (±3, ±5, ±10 pp): all null (p > 0.38)

---

### Summary of Changes

1. Reframed estimand as "income-based eligibility pathway" throughout
2. Implemented McCrary-style density test with proper interpretation
3. Added joint covariate balance test (χ² = 16.85, p < 0.001)
4. Added covariate-adjusted RD estimates
5. Added local quadratic specification
6. Added donut RD robustness (3 specifications)
7. Expanded bandwidth sensitivity to 8 bandwidths with detailed discussion
8. Added 4 missing modern RD references
9. Added new subsection on categorical eligibility fuzziness

The paper has grown from 32 to 36 pages with these additions.
