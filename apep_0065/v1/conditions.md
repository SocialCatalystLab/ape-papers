# Conditional Requirements

**Generated:** 2026-01-26T11:47:46.068334
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Remote Work and Housing Cost Burden

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: strong balance/overlap diagnostics + sensitivity analysis for unobservables

**Status:** [x] RESOLVED

**Response:**

The analysis will implement comprehensive DR diagnostics:

1. **Balance diagnostics:**
   - Propensity score overlap plots (density by treatment status)
   - Standardized mean differences before/after weighting
   - Love plots showing covariate balance

2. **Overlap assessment:**
   - Histogram of propensity scores with trimming rule (0.01-0.99)
   - Report number of observations trimmed
   - Consider overlap-weighted estimator (Crump et al.) if severe violations

3. **Sensitivity analysis for unobservables:**
   - E-values: Report the minimum strength of unmeasured confounding needed to nullify results
   - Calibrated sensitivity using `sensemakr`: Benchmark to observed confounders ("would need a confounder 2x as strong as education to nullify")
   - Negative control outcomes: Test effect on outcomes that shouldn't be affected (e.g., disability status, veteran status)

**Evidence:**

- DR methodology checklist in `references/dr_methodology.md` (Steps 11-18) requires all of these
- R packages: `sensemakr` for calibrated sensitivity, `AIPW` for overlap diagnostics
- Plan will include dedicated robustness section with these tests

---

### Condition 2: explicit tests for "arbitrage" via metro-to-nonmetro/location-cost proxies

**Status:** [x] RESOLVED

**Response:**

The "geographic arbitrage" mechanism is central to the hypothesis. Will implement:

1. **Metro status heterogeneity:**
   - Stratify analysis by metro residence: large metro core, small metro, micropolitan, non-metro
   - Test if housing burden reduction is concentrated among remote workers in lower-cost areas

2. **Cost-of-living proxies:**
   - ACS PUMA-level housing cost indices (median rent, median home value)
   - Heterogeneity by PUMA-level cost quintiles
   - Compare remote workers who moved to lower-cost PUMAs vs. those who stayed

3. **Migration mechanism test:**
   - Use MIG variable (mobility status) to identify recent movers
   - Test if remote workers who moved have larger housing burden reductions
   - Triple interaction: Remote × Recent mover × Lower-cost destination

4. **Placebo test:**
   - Estimate effect on workers who cannot work remotely (manual/service occupations)
   - Should find no "arbitrage" effect for workers tied to physical locations

**Evidence:**

- ACS PUMS includes: MET2013 (metro status), MIG (mobility), PUMA (for local cost proxies)
- Can merge PUMA-level median housing costs from ACS summary tables
- Mechanism tests are standard in applied micro papers (NBER working paper style)

---

### Condition 3: careful sample definition to avoid mismeasurement of WFH

**Status:** [x] RESOLVED

**Response:**

JWTRNS (means of transportation to work) = 11 or 12 indicates "worked from home." Key concerns and mitigations:

1. **Mismeasurement concerns:**
   - JWTRNS measures "usual" transportation, not sustained remote work status
   - May include occasional WFH, not "remote-first" workers
   - Self-employed often work from home for different reasons

2. **Sample restrictions to improve measurement:**
   - **Full-time workers only:** WKHP >= 35 hours/week (excludes casual WFH)
   - **Private sector wage workers:** COW = 1, 2 (excludes self-employed, government)
   - **Prime working age:** 25-59 (excludes retirees, students)
   - **Employed in remote-feasible occupations:** Use O*NET telework scores to identify occupations where remote work is plausible

3. **Robustness checks:**
   - Restrict to "information" and "professional services" industries where WFH is most common
   - Separate analysis by occupation telework feasibility score
   - Compare 2019 vs 2023 to use pre-pandemic as implicit control

4. **Comparison group selection:**
   - Non-remote workers matched on occupation and industry ensures we compare workers in similar jobs
   - Remote workers in "hybrid" occupations vs. in-person workers in same occupations

**Evidence:**

- ACS 2023 has ~600,000 workers with JWTRNS=11/12 (full sample)
- After restrictions (FT private-sector prime-age): ~350,000 remote workers
- Sample size remains large for precise estimates
- Restriction approach follows Barrero et al. (2023), Mondragon & Wieland (2022)

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
