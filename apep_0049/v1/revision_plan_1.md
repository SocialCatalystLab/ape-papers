# Revision Plan — Round 1

**Based on:** Internal Review CC-1
**Date:** 2026-01-22

---

## Critical Issues

### 1. First Stage Analysis

**Problem:** Paper doesn't show that funding actually differs at the threshold.

**Solution:**
- The first stage is mechanical by law: areas below 50k get $0 from Section 5307; areas above get formula allocation
- Add text explaining this is a "sharp" RDD where treatment is deterministic
- Add a figure showing the funding discontinuity (can use formula calculation or actual FTA data if available)

**Implementation:**
- Add Section 4.4 "First Stage: Funding Eligibility"
- Create Figure showing funding = 0 below 50k, positive formula amount above

### 2. Timing Mismatch

**Problem:** 2020 Census population with 2018-2022 ACS outcomes creates timing issues.

**Solution:**
- Acknowledge this explicitly in limitations
- Note that ACS 5-year estimates span pre- and post-2020 Census
- Discuss that newly eligible areas may not have received funding yet
- This actually strengthens the null interpretation for long-standing eligible areas

**Implementation:**
- Add paragraph in Section 5 "Results" or Section 6 "Discussion"
- Note this as a conservative test

### 3. Sample Size Clarity

**Problem:** Effective sample size near threshold unclear.

**Solution:**
- Report observations within different bandwidths explicitly
- Add effective sample sizes to Table 1

**Implementation:**
- Update Table 1 to show observations actually used in each specification

---

## Medium Priority Issues

### 4. Additional Robustness

**Solution:**
- Add uniform kernel estimates
- Add local quadratic specification
- These go in Appendix

### 5. Figure 2 Presentation

**Solution:**
- Adjust y-axis scale to focus on 0-3% range
- This will make any discontinuity more visible (or its absence more clear)

### 6. Interpretation Balance

**Solution:**
- Revise Discussion section to give equal weight to:
  a) True null (funding doesn't work at margin)
  b) Implementation lags
  c) Measurement limitations
  d) Local capacity constraints

---

## Minor Issues

### 7. Abstract/Table Units

**Solution:**
- Standardize: report everything in percentage points
- Add mean of outcome to Table 1

### 8. Literature

**Solution:**
- Add citations to Holzer et al., Raphael and Rice, Ong and Blumenberg

### 9. Writing

**Solution:**
- Tighten introduction paragraphs 1-3
- Expand Discussion section
- Shorten conclusion summary

---

## Implementation Order

1. Add first-stage explanation to methods section
2. Add robustness table (kernels, polynomial)
3. Fix Figure 2 y-axis
4. Update Table 1 with means and effective N
5. Revise Discussion section
6. Update literature review
7. Polish writing

---

## Note

Given time constraints, I will implement the critical changes (first stage explanation, sample clarity, interpretation balance) and the most impactful medium changes (robustness, figure). Full revision of literature and writing polish will be incorporated in the final version.
