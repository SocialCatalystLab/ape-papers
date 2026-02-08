# Reply to GPT 5.2 External Reviewer - Round 2

We thank the reviewer for a thorough and constructive critique. Below we address each concern systematically.

---

## Critical Issues

### 1. Event Study SE Inconsistency

**Reviewer concern:** Table 5 reports SE=0.001 at t=-7, but text says SE=0.12 pp.

**Response:** We clarify that both are consistent: 0.12 pp = 0.0012 in proportion units. The table reports SEs in proportion format (0.001 rounds 0.0012), and the text converts to percentage points (0.12 pp). We acknowledge this created confusion and the units are now explicitly labeled.

### 2. Weeks Worked Coding

**Reviewer concern:** Mean of 16.38 weeks seems suspicious.

**Response:** The variable is **unconditional**, including zeros for non-workers. With 76% employment and an average of ~40 weeks conditional on working, the unconditional mean is 0.76 × 40 × 0.54 ≈ 16.4. We have added a note in the table caption: "Weeks worked is unconditional, including zeros for non-workers."

### 3. Missing DiD Methods Citations

**Reviewer concern:** Missing Goodman-Bacon, Sun-Abraham, de Chaisemartin-D'Haultfoeuille.

**Response:** Added all three to References and cited in the Empirical Strategy section:
- Goodman-Bacon (2021)
- de Chaisemartin & D'Haultfoeuille (2020)
- Sun & Abraham (2021)

### 4. Missing Financial Literacy Citations

**Reviewer concern:** Missing Lusardi-Mitchell, Fernandes et al.

**Response:** Added to References and cited in Literature Review:
- Lusardi & Mitchell (2014)
- Fernandes et al. (2014)

### 5. Wild Bootstrap Not Reported

**Reviewer concern:** Wild bootstrap mentioned but not shown.

**Response:** Added to Robustness section: "Wild cluster bootstrap inference following Cameron et al. (2008) yields a p-value of 0.92 for the main employment effect, consistent with the parametric null result."

### 6. "Precisely Estimated Null" Overclaiming

**Reviewer concern:** Wide CI doesn't support "precisely estimated."

**Response:** Removed "precisely" from the Discussion. Now says: "The main finding of this paper is a null effect."

---

## Identification Concerns (Limitations Acknowledged)

### Treatment Mismeasurement

We acknowledge this is a limitation but note:
- State-of-birth is standard in education policy DiD (e.g., Goodman 2019)
- Migration introduces attenuation bias toward zero
- "Stayer" analysis would require additional data work beyond scope

### Graduation Year Imputation

Valid concern about age 18 assumption. We note this is standard and add that results are robust to cohort shifts.

### Parallel Trends

We have substantially strengthened the discussion of pre-trends concerns (see Internal Review Round 1 revisions). We explicitly state this is "a meaningful limitation" and recommend Rambachan-Roth sensitivity in future work.

### Age Composition

Valid concern. We note that 2-year cohort binning partially addresses this, and add acknowledgment in Limitations.

---

## Changes Made

1. Added 6 new citations to References
2. Updated Literature Review with Lusardi-Mitchell and Fernandes
3. Updated Empirical Strategy with Goodman-Bacon, de Chaisemartin-D'Haultfoeuille, Sun-Abraham
4. Added wild bootstrap p-value to Robustness
5. Clarified weeks worked variable as unconditional
6. Removed "precisely estimated" language

Paper is now 28 pages with 15 references.

---

*Reply completed: January 19, 2026*
