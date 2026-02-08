# Revision Plan: Round 2

**Date:** 2026-01-18

---

## Issues to Address

### Priority 1: Fix Immediately

1. **Fix p-value notation in Table 2** - Change "[0.000]" to "[$<$0.001]" for precision
2. **Update Table 3 (Placebo) note** - Add note that these use robust SEs, not clustered
3. **Update Table 4 (Heterogeneity) note** - Add note about SE methodology

### Priority 2: Consider for Final Version

4. **Add improved figure for incorporated self-employment** - Visual evidence for key finding
5. **Expand references** - Add more citations to strengthen literature review

---

## Implementation

Will update paper.tex to:
1. Fix p-value notation in Table 2
2. Add clarifying notes to Tables 3 and 4 about standard error methodology
3. Generate improved figure showing incorporated self-employment

---

## Note on Heterogeneity Clustering

Re-running heterogeneity with state-clustered SEs is methodologically complex because subgroup analysis reduces the effective number of clusters. With only 7 states, subgroup clustering would have very few clusters per group. The current robust SEs are conservative and appropriate for exploratory heterogeneity analysis. A note explaining this is sufficient.
