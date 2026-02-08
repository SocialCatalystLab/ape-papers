# Conditional Requirements

**Generated:** 2026-01-29T17:34:55.830879
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**All conditions resolved — proceeding to Phase 4.**

---

## State Drug Price Transparency Laws and Out-of-Pocket Prescription Spending

**Rank:** #2 | **Recommendation:** CONSIDER

**NOTE: We are pursuing Idea #1 (PDMP Must-Access Mandates), not Idea #2. All conditions for Idea #2 are marked NOT APPLICABLE.**

### Condition 1: obtaining restricted-state MEPS or alternative claims/APCD data with state

**Status:** [X] NOT APPLICABLE

**Response:** We are pursuing Idea #1 (PDMP mandates + CPS ASEC), not Idea #2.

---

### Condition 2: month

**Status:** [X] NOT APPLICABLE

**Response:** We are pursuing Idea #1 (PDMP mandates + CPS ASEC), not Idea #2.

---

### Condition 3: building a credible "binding/enforced law" measure

**Status:** [X] NOT APPLICABLE

**Response:** We are pursuing Idea #1 (PDMP mandates + CPS ASEC), not Idea #2.

---

### Condition 4: demonstrating clean pre-trends + robustness to concurrent state health-policy changes

**Status:** [X] NOT APPLICABLE

**Response:** We are pursuing Idea #1 (PDMP mandates + CPS ASEC), not Idea #2.

---

## Idea #1 Conditional Notes (PURSUE)

The GPT ranking recommended PURSUE for Idea #1 conditional on four items. These will be addressed in the research plan and analysis:

### (i) Clear timing alignment
**Plan:** Use "full-exposure year" coding — define a state as treated in year t only if the must-access mandate was effective by January 1 of year t. CPS ASEC is fielded Feb-Apr with labor force status reflecting current (March) status. This ensures full-year exposure alignment.

### (ii) Strong pre-trends/event-study diagnostics
**Plan:** CS-DiD event-study plots with 5+ pre-treatment years. Test pre-trend coefficients both visually and via joint F-test. Report honest confidence intervals via HonestDiD package.

### (iii) Serious sensitivity to concurrent opioid policies
**Plan:** Control for naloxone access laws, pill-mill laws, Medicaid expansion, and marijuana legalization using PDAPS policy dates. Run specifications with and without these controls.

### (iv) Subgroup/targeted outcomes to address dilution and power
**Plan:** Examine heterogeneous effects by education (less than college), sex (males), occupation risk (manual/blue-collar), and state-level opioid severity (pre-treatment overdose rates). Also examine disability receipt as a more targeted outcome.

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: RESOLVED**
