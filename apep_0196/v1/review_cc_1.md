# Internal Review - Round 1

**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** Do State College Promise Programs Increase Enrollment? Evidence from Staggered Adoption
**Timestamp:** 2026-02-06

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

**Length:** The main text runs approximately 17 pages (pages 1-17, through Acknowledgements), excluding references (pages 18-19) and appendices (pages 20-27). **This is below the 25-page minimum requirement.** The paper needs substantial expansion.

**References:** Adequate coverage of DiD methodology (Callaway & Sant'Anna 2021, Goodman-Bacon 2021, Sun & Abraham 2021) and Promise program literature (Carruthers & Fox 2020, Bartik et al. 2019).

**Prose:** Excellent. Full paragraphs throughout; no bullet-point-heavy sections in Introduction, Results, or Discussion.

**Section depth:** Each major section has 3+ substantive paragraphs.

**Figures/Tables:** Publication-quality with proper labels, axes, and notes. No placeholders.

### 2. STATISTICAL METHODOLOGY

**Standard Errors:** ✓ PASS. All coefficients have SEs in parentheses (Table 2: ATT SE = 0.0102; TWFE SE = 0.0142).

**Significance Testing:** ✓ PASS. 95% CIs reported; p-values discussed.

**Sample Sizes:** ✓ PASS. N = 676 reported in Table 2; state counts in Table 1.

**DiD with Staggered Adoption:** ✓ PASS. Uses Callaway-Sant'Anna estimator with never-treated controls (not problematic TWFE). TWFE shown only for comparison. Doubly robust estimation implemented.

**Inference Robustness:** ✓ Wild cluster bootstrap, randomization inference, and Conley SEs all conducted.

### 3. IDENTIFICATION STRATEGY

**Parallel Trends:** Event study (Figure 1, page 13) shows no significant pre-treatment coefficients. F-test for joint pre-trends: F = 0.87, p = 0.51. This is supportive evidence.

**Placebo Tests:** Pseudo-treatment 3 years prior yields null effect (-0.003, SE = 0.011). Graduate enrollment placebo shows no effect. Good.

**CRITICAL CONCERN - Severe Power Limitations:**

The MDE of 29% (page 15) is the paper's fatal weakness. This means:
- The study can only detect effects >29%
- Prior literature finds 5-15% effects (Carruthers & Fox 2020)
- **The null finding is essentially uninformative**

The confidence interval [-3.4%, +0.6%] cannot rule out the 5-15% effects found elsewhere. The paper honestly acknowledges this (Section 6.5), but this raises a fundamental question: *what is the scientific contribution of a study that cannot detect realistic effect sizes?*

### 4. LITERATURE GAPS

The literature review is adequate but missing key recent papers:

**Missing citations:**
```bibtex
@article{Denning2017,
  author = {Denning, Jeffrey T.},
  title = {College on the Cheap: Consequences of Community College Tuition Reductions},
  journal = {American Economic Journal: Economic Policy},
  year = {2017},
  volume = {9},
  number = {2},
  pages = {155--188}
}

@article{Andrews2020,
  author = {Andrews, Rodney J. and Imberman, Scott A. and Lovenheim, Michael F.},
  title = {Recruiting and Supporting Low-Income, High-Achieving Students at Flagship Universities},
  journal = {Economics of Education Review},
  year = {2020},
  volume = {74}
}
```

### 5. WRITING QUALITY

**Prose:** Strong throughout. Clear narrative arc from motivation to findings to implications.

**Accessibility:** Technical terms explained; magnitudes contextualized (e.g., "approximately -1.4%").

**Figures:** Publication-quality. Event study (Figure 1) is clear with proper confidence bands.

**One improvement:** The Introduction could open with a more compelling hook—perhaps the dollar magnitude of Promise spending ($2B annually) before policy spread statistics.

---

## CRITICAL WEAKNESSES (Reviewer 2 Mode)

### Issue 1: Outcome Measure Mismatch (Major)

Promise programs target **first-time community college enrollment among recent high school graduates**. The paper uses **total undergraduate enrollment** from the ACS, which includes:
- Continuing students (majority of enrollment in any year)
- Students at 4-year institutions
- Returning adults and non-traditional students

This dilution is acknowledged (Section E.1) but understated. If Promise increases first-time CC enrollment by 10%, the effect on total enrollment would be ~2-3% given the stock-flow dynamics. The paper is measuring the wrong outcome.

**Fix:** Use IPEDS first-time, full-time enrollment at community colleges as the outcome variable.

### Issue 2: Treatment Heterogeneity (Major)

Promise programs differ substantially:
- **Funding:** Last-dollar (most states) vs. first-dollar (New Mexico)
- **Scope:** Community college only (most) vs. includes 4-year (NY Excelsior)
- **Requirements:** Mentorship/community service (TN) vs. none

Pooling these heterogeneous programs and finding a null is unsurprising. The cohort-specific estimates (Table 3) hint at this—the 2021 cohort (Michigan Reconnect, which targets adults) shows a significant *negative* effect (-5.6%, p<0.05).

**Fix:** Code program features systematically and test for heterogeneous effects by program design.

### Issue 3: Missouri Inclusion (Moderate)

Missouri's A+ Scholarship (coded as treated from 2010) differs fundamentally from modern Promise programs:
- Predates the "free college" movement by decades (A+ started in 1997)
- Different eligibility criteria and funding structure
- No media attention or "Promise" branding

Including it as "always-treated" may contaminate the treatment effect estimate. The paper notes Missouri is excluded from event studies but included in overall ATT.

**Fix:** Conduct sensitivity analysis excluding Missouri entirely. Report results with and without.

### Issue 4: COVID-19 Period (Moderate)

The sample includes 2020-2023, during which:
- Enrollment dropped dramatically nationwide (not Promise-specific)
- 2020/2021 cohorts (4 states) have only COVID-affected post-treatment data
- COVID response policies varied by state, potentially correlated with Promise adoption

The paper notes excluding 2020-2021 produces similar results (Section C.3), but this deserves more attention given 4 of 20 treated states adopted during COVID.

### Issue 5: No Balance Tests (Moderate)

The paper does not present balance tests comparing treated and control states on pre-treatment characteristics. Are Promise-adopting states systematically different in:
- Baseline enrollment rates?
- Population demographics?
- Political orientation?
- Higher education funding levels?

Propensity score analysis or covariate balance tables would strengthen the parallel trends argument.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Suggestion 1: Triple-Difference Design

Use age-based variation within states. Promise programs typically require recent high school graduation (within 2 years). Compare:
- Recent graduates (eligible) vs. older students (ineligible)
- In Promise vs. non-Promise states
- Before vs. after adoption

This differences out state-specific shocks and provides a more credible counterfactual.

### Suggestion 2: Institution-Level Analysis

Use IPEDS institution-level data to directly test the crowd-out hypothesis:
- Does CC enrollment increase while 4-year enrollment decreases?
- Is the compositional shift zero-sum at the state level?

This would transform the null finding into a positive contribution about compositional effects.

### Suggestion 3: Synthetic Control for Early Adopters

Tennessee (2015) has 8 years of post-treatment data. Use synthetic control methods to create a counterfactual Tennessee from donor pool of never-treated states. This provides a complementary identification strategy and avoids the pooling-heterogeneous-treatments problem.

### Suggestion 4: Bounding Analysis

Given power limitations, provide bounds on the treatment effect under various assumptions:
- What effect size can be ruled out with 95% confidence?
- Under what assumptions about treatment heterogeneity is the null finding informative?

### Suggestion 5: Mechanism Analysis

Even if aggregate effects are null, mechanisms could be explored:
- FAFSA completion rates (available from Federal Student Aid data)
- High school graduation rates (could show anticipation effects)
- Community college vs. 4-year enrollment shares

---

## OVERALL ASSESSMENT

### Strengths
1. Correct use of modern heterogeneity-robust DiD methodology (Callaway-Sant'Anna)
2. Honest and thorough acknowledgment of power limitations
3. Comprehensive robustness checks (wild bootstrap, randomization inference, Conley SEs)
4. Well-written prose with clear narrative flow
5. Valuable null finding that challenges prevailing narratives

### Critical Weaknesses
1. **MDE of 29% renders the null finding largely uninformative** - cannot detect realistic effect sizes
2. **Outcome measure (total enrollment) poorly aligned with treatment** - Promise targets first-time CC enrollment
3. **Main text below 25-page requirement** (~17 pages)
4. Treatment heterogeneity not systematically addressed

### Recommendation

The paper has a sound methodological foundation but faces fundamental power limitations that undermine its scientific contribution. The null finding is honest but uninformative—it cannot distinguish "no effect" from "effect too small to detect with these data."

To be publishable, the paper needs:
1. Better-aligned outcome data (IPEDS first-time enrollment) OR
2. Reframing as a methodological/power demonstration OR
3. Substantial expansion of heterogeneity analysis and mechanisms

---

**DECISION: MAJOR REVISION**
