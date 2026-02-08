# Internal Review - Round 1

**Reviewer:** Claude Code (Reviewer 2 mode)
**Paper:** Must-Access PDMP Mandates and State Employment
**Date:** 2026-01-29

---

## PART 1: CRITICAL REVIEW

### Format Check
- **Length:** ~30 pages main text (excluding appendix). Passes 25-page threshold.
- **References:** Adequate coverage of DiD methodology (Callaway-Sant'Anna, Goodman-Bacon, de Chaisemartin-D'Haultfoeuille, Sun-Abraham) and opioid policy literature (Buchmueller-Carey, Dave et al., Brady et al.).
- **Prose:** All major sections in paragraph form. No bullet-point issues.
- **Figures:** 5 figures with proper axes, labels, and notes.
- **Tables:** 15 tables with real numbers, proper formatting.

### Statistical Methodology
- **Standard errors:** All coefficients have SEs in parentheses. CS uses multiplier bootstrap (1,000 iterations). TWFE uses state-clustered SEs. PASS.
- **Significance testing:** p-values reported for all main estimates. Uniform confidence bands used for event-study inference. PASS.
- **Confidence intervals:** 95% uniform CIs reported in event-study tables. Pointwise CIs available. PASS.
- **Sample sizes:** N = 833 reported throughout. PASS.
- **DiD with staggered adoption:** Uses Callaway-Sant'Anna (2021) with both not-yet-treated and never-treated comparison groups. Addresses treatment effect heterogeneity properly. PASS.

### Identification Strategy
- **Parallel trends:** Tested via event-study with uniform bands. Pre-trends clean for NYT specification. Never-treated shows violation at e=-2 (acknowledged and discussed). Adequate.
- **Robustness:** TWFE comparison, Goodman-Bacon decomposition, LOO analysis, placebo test, concurrent policy controls. Comprehensive.
- **Thin control group:** Well-acknowledged limitation. Only 4 never-treated states. The paper handles this by preferring the NYT specification.
- **Anticipation:** Handled via anticipation=1 parameter. Discussed in detail in Section 6.5.

### Concerns
1. **Power:** The paper claims an "informative null" but the 95% CI for log employment spans [-0.015, 0.019]. This means effects up to 1.9% cannot be ruled out. For context, PDMP mandates reduce opioid prescribing by 10-30% (Buchmueller & Carey 2018), and opioid-related labor force non-participation affects perhaps 1-2% of the workforce (Krueger 2017). The paper should discuss minimum detectable effects more explicitly.
2. **Outcome dilution:** State-level employment is a very coarse outcome. PDMP mandates target a specific population (opioid users/potential users). Even a meaningful effect on this subgroup would be diluted in aggregate state employment. This is discussed but could be more prominent.
3. **No individual-level data:** The paper acknowledges this limitation but doesn't attempt county-level or industry-specific analysis that might detect more targeted effects.

### Literature
- Missing: Maclean et al. (2020, NBER) on opioids and labor markets.
- Missing: Powell et al. (2020) on prescription drug monitoring and overdose deaths.
- Could cite: Grecu et al. (2019) on PDMPs and opioid abuse.

### Writing Quality
- Prose is clear and professional. Good narrative flow from motivation through results to implications.
- Introduction effectively contextualizes the opioid crisis and PDMP policy.
- Results section is well-structured with clear progression from aggregate to group-level to event-study.
- Discussion section provides thoughtful interpretation of the null finding.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Power analysis:** Add a formal MDE calculation. With 49 states and 17 years, what is the smallest effect the design can detect at 80% power?
2. **Heterogeneity by crisis severity:** States with higher opioid mortality might show larger employment effects. Consider interacting treatment with pre-mandate opioid prescribing rates.
3. **Dynamic specifications:** The event-study shows no effect, but consider whether there's a dose-response relationship (number of years since mandate).
4. **Framing:** The "informative null" framing is good but could be strengthened by explicitly calculating the implied upper bound on per-capita employment effects.

## OVERALL ASSESSMENT

**Strengths:**
- Methodologically sound: proper use of CS-DiD, uniform inference, multiple comparison groups
- Comprehensive robustness battery (TWFE, Bacon decomposition, LOO, placebo, policy controls)
- Honest engagement with limitations (thin control group, pre-trend concerns)
- Clean prose and professional presentation

**Weaknesses:**
- Aggregate employment is a coarse outcome likely to miss targeted effects
- Power concerns: cannot rule out economically meaningful effects
- Missing formal MDE/power analysis
- No attempt at sub-state or sub-population analysis

DECISION: MINOR REVISION
