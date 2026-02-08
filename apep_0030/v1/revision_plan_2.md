# Revision Plan — Round 2

**Date:** 2026-01-18
**Review Source:** GPT 5.2 External Review
**Decision:** REJECT AND RESUBMIT

---

## Summary of Critical Issues

The GPT 5.2 review identified five publication-blocking weaknesses:

1. **Invalid inference**: HC3 SEs inappropriate for DiD with serial correlation and 8 states
2. **Fragile identification**: Heterogeneous fentanyl supply shocks threaten parallel trends
3. **Outcome/timing issues**: Annual aggregation, unclear effective dates, counts vs rates
4. **Incomplete literature**: Missing core DiD and opioid-policy citations
5. **Below-norm presentation**: Short length, bullet-heavy sections, overstated conclusions

---

## Revision Strategy

### Priority 1: Fix Inference (Non-negotiable)

**Problem:** HC3 standard errors do not address within-state serial correlation. With 8 states, cluster-robust SEs are also unreliable.

**Solution:**
- Implement **wild cluster bootstrap** (Cameron, Gelbach & Miller 2008) for all main specifications
- Implement **permutation/randomization inference** with placebo treatment assignments
- Report bootstrap p-values prominently in Table 2
- Cite Bertrand, Duflo & Mullainathan (2004) on serial correlation in DiD
- Cite Conley & Taber (2011) on inference with few treated units
- Cite Cameron & Miller (2015) practitioner guide

### Priority 2: Strengthen Design with Synthetic Control

**Problem:** With one treated state, simple DiD vs neighbors is fragile.

**Solution:**
- Implement formal **synthetic control method** (Abadie et al. 2010) with full donor pool
- Show pre-treatment fit, donor weights, and placebo gaps
- Consider **synthetic DiD** (Arkhangelsky et al. 2021) as robustness
- Report SCM as complementary main specification

### Priority 3: Improve Outcome Measurement

**Problem:** Using log(count+1) ignores population changes; no per-capita rates.

**Solution:**
- Add **death rates per 100,000** as primary outcome
- Fetch state population data
- Report Poisson pseudo-MLE with population exposure offset as robustness
- Calculate minimum detectable effect (MDE) for power analysis

### Priority 4: Expand Literature Review

**Required additions:**

**DiD/Inference:**
- Bertrand, Duflo & Mullainathan (2004) - Serial correlation in DiD
- Conley & Taber (2011) - Inference with few policy changes  
- Cameron & Miller (2015) - Cluster-robust inference guide
- Cameron, Gelbach & Miller (2008) - Wild bootstrap
- Callaway & Sant'Anna (2021) - Modern DiD
- Goodman-Bacon (2021) - DiD with variation in treatment timing
- Rambachan & Roth (2023) - Sensitivity for parallel trends

**Synthetic Control:**
- Abadie, Diamond & Hainmueller (2010) - SCM
- Arkhangelsky et al. (2021) - Synthetic DiD

**Opioid Policy:**
- Alpert, Powell & Pacula (2018) - Supply-side drug policy
- Rees et al. (2019) - Naloxone access and Good Samaritan laws

### Priority 5: Revise Presentation

- Convert bullet lists to paragraph prose
- Reframe "precise null" to "imprecise and inconclusive"
- Add exact policy effective dates
- Expand to 25+ pages
- Improve figure formatting

### Priority 6: Address COVID Confounding

- Show sensitivity to excluding 2020-2021 data
- Discuss pandemic × drug market interaction

---

## Implementation Order

1. Fetch population data (for per-capita rates)
2. Implement wild cluster bootstrap
3. Enhance synthetic control with placebo inference
4. Run all new analyses
5. Update LaTeX paper
6. Compile and visual QA
7. Write reply to reviewers
