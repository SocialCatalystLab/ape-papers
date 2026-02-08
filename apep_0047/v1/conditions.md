# Conditional Requirements

**Generated:** 2026-01-21T20:28:40.278311
**Status:** RESOLVED

---

## RESOLUTION SUMMARY

The ranking recommended **Idea 2 (MeToo Triple-Diff)** with score 74/100 as PURSUE.

The conditions listed below pertain to **Idea 1 (Training Mandates)** which was scored 52/100 as CONSIDER.

Since we are proceeding with **Idea 2** (not Idea 1), the conditions for Idea 1 are **NOT APPLICABLE** to our execution plan.

**Idea 2** avoids the cluster concerns that motivated these conditions:
- Triple-diff design uses industry × state × time variation = hundreds of clusters
- MeToo timing (October 2017) is exogenous to industry employment trends
- No state-level cluster problem since treatment is defined at industry level

---

## Idea 1 — "Sexual Harassment Training Mandates and Female Labor Market Outcomes"

**Rank:** #2 | **Recommendation:** CONSIDER (not pursuing)

### Condition 1: extending the panel to include additional adopting states post-2020 to raise treated clusters

**Status:** [X] NOT APPLICABLE

**Response:**
We are pursuing Idea 2 (MeToo Triple-Diff), not Idea 1. This condition does not apply.

---

### Condition 2: pre-registering an inference strategy robust to few clusters—e.g.

**Status:** [X] NOT APPLICABLE

**Response:**
We are pursuing Idea 2, which has hundreds of industry × state clusters. Few-cluster inference is not a concern.

---

### Condition 3: randomization inference / wild cluster bootstrap

**Status:** [X] NOT APPLICABLE

**Response:**
Idea 2 has sufficient clusters for standard asymptotic inference. We will still conduct wild cluster bootstrap as robustness.

---

### Condition 4: demonstrating treated vs control comparability via strong pre-trends

**Status:** [X] RESOLVED

**Response:**
This applies to our Idea 2 execution. We will demonstrate:
1. Event study with 15 pre-treatment quarters (Q1 2014 - Q3 2017)
2. Joint F-test for pre-period coefficients
3. Rambachan-Roth HonestDiD sensitivity bounds
4. Placebo pseudo-MeToo dates (Q4 2015, Q4 2016)

**Evidence:**
- Pre-trends analysis will be conducted in `code/02_event_study.R`
- Results will be reported in Figure 3 and Table A.1

---

### Condition 5: weighting

**Status:** [X] NOT APPLICABLE

**Response:**
For Idea 2, we will weight by employment to account for industry size differences. This is standard practice for industry-level analysis.

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: RESOLVED**
