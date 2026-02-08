# Internal Review #1 - Claude Code Self-Review

**Paper:** The Health Insurance Cliff: Evidence from Wisconsin's Unique Medicaid Design
**Reviewer:** Claude Code (Internal)
**Date:** January 18, 2026

---

## Summary

This paper examines Wisconsin's unique Medicaid eligibility threshold at 100% FPL using a regression discontinuity design. The main findings are: (1) a significant 7.7 pp discontinuity in Medicaid coverage at the threshold, and (2) no significant effects on labor supply outcomes.

---

## Critical Issues

### 1. Sign Direction Interpretation Error (MAJOR)

The paper reports "individuals just below the cutoff are substantially more likely to have Medicaid than those just above" with a coefficient of **-0.077**. However, a negative coefficient on the "below threshold" indicator means those BELOW have LOWER Medicaid, not higher.

**This is backwards from the expected direction** - we expect higher Medicaid below the threshold. Either:
- The sign interpretation in the text is wrong
- The coding of the treatment indicator is inverted
- The actual finding contradicts expectations (unlikely)

**Fix:** Verify the coding convention and correct the interpretation.

### 2. Missing Citation (MINOR)

Page 7: "Medicaid pregnancy thresholds (?)" - citation did not render.

### 3. Layout Issue (MINOR)

Page 2 is nearly blank due to abstract/keywords being split across pages.

### 4. Gender Covariate Imbalance Not Addressed (MODERATE)

The significant discontinuity in female proportion (p=0.010) is mentioned but not adequately addressed. Robustness checks controlling for gender are not presented.

### 5. Significant Placebo at 125% FPL (MODERATE)

The employment placebo at 125% FPL (p=0.003) is concerning and undermines the credibility of any employment effects. This is acknowledged but deserves more discussion - could indicate specification issues.

---

## Methodological Concerns

### 6. Bandwidth Selection

The paper uses ad-hoc bandwidths (10-50% FPL) rather than optimal bandwidth selection procedures (IK or CCT). While sensitivity analysis is provided, optimal bandwidth estimation would strengthen credibility.

### 7. Fuzzy RD Not Formally Estimated

The paper discusses "fuzzy RD" conceptually but estimates a sharp RD on outcomes rather than instrumenting actual Medicaid enrollment with eligibility. A formal fuzzy RD (2SLS) would provide cleaner interpretation.

### 8. Clustering

Standard errors are robust but not clustered. Given that individuals within households share the same poverty ratio, clustering at household level may be appropriate.

---

## Constructive Suggestions

### 9. Add Formal Bunching Analysis

The paper mentions bunching but doesn't estimate it formally using Chetty et al. (2011) or Kleven (2016) methods. Adding this would complement the McCrary test.

### 10. Subgroup Analysis

Consider heterogeneity by:
- Single vs. married (different household composition)
- Age groups (younger workers may be more responsive)
- Industry/occupation (sectors with more hours flexibility)

### 11. Event Study Around Policy Implementation

If data permits, show that the discontinuity emerged after 2014 when the current policy took effect, not before.

### 12. Exchange Coverage Outcome

Adding "purchased insurance" (HINS2) as an outcome would show whether those losing Medicaid above threshold successfully transition to exchange coverage.

### 13. Total Insurance Coverage

Report effects on any insurance coverage (HICOV) to assess whether the Medicaid cliff creates an uninsurance gap.

---

## Writing and Presentation

### 14. Abstract Length

At ~250 words, the abstract is slightly long. Consider trimming to ~200 words.

### 15. Theoretical Model Could Be Cleaner

The utility function presentation (Equation 1) is helpful but could note more explicitly that the "notch" creates a dominated region where no rational agent should locate.

### 16. More Context on Wisconsin Politics

A brief discussion of why Wisconsin chose this unique approach (Governor Walker's rationale) would add policy context.

---

## Overall Assessment

**Strengths:**
- Novel policy setting (unique nationally)
- Clean RD design with appropriate validation tests
- Meaningful null result on labor supply
- Good comparison with expansion states

**Weaknesses:**
- Potential sign/interpretation error (critical)
- Covariate imbalance and placebo concern not fully addressed
- Could benefit from formal fuzzy RD and bunching estimation

**Recommendation:** Revise and resubmit. Address the sign interpretation issue immediately, add robustness checks for gender imbalance, and consider adding fuzzy RD and bunching analysis.

---

## Priority Fixes for Next Revision

1. **HIGH:** Verify and correct sign interpretation
2. **HIGH:** Fix missing citation
3. **MEDIUM:** Add robustness check controlling for gender
4. **MEDIUM:** Add exchange coverage and total coverage outcomes
5. **LOW:** Fix page 2 layout
6. **LOW:** Discuss Wisconsin political context
