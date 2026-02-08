# Research Ideas

## Idea 1: Recreational Marijuana Legalization and Entrepreneurship: Industry-Level Evidence from Business Formation Statistics

**Policy:** State-level recreational marijuana legalization. Staggered adoption from 2012 (CO, WA) through 2023 (DE, MN, OH). 24 states plus DC have legalized as of 2023. Clear effective dates for each state.

**Outcome:** Census Bureau Business Formation Statistics (BFS) — monthly new business applications by state and NAICS sector, 2004–2025. Series include: total business applications (BA_BA), high-propensity business applications (BA_HBA), and applications with planned wages (BA_WBA). Data covers all 50 states plus DC.

**Identification:** Staggered DiD exploiting state-level variation in legalization timing. Primary specification: Callaway-Sant'Anna estimator with never-treated states as comparison group. Triple-difference (DDD): cannabis-adjacent NAICS sectors (agriculture NAICS11, retail NAICSRET, manufacturing NAICSMNF) vs. non-adjacent sectors within treated vs. control states. Pre-treatment: 2005–2011 (7+ years). Post-treatment: varies by cohort, up to 13 years for early adopters.

**Why it's novel:** Brown, Cohen & Felix (2023, KC Fed WP) examine marijuana legalization and business dynamics using Census BDS data, but cover only 12 states through 2020. This paper extends in four ways: (1) BFS data through 2025 with 24 treated states, (2) high-frequency monthly data enabling event-study dynamics, (3) NAICS sector decomposition enabling triple-difference to isolate cannabis-adjacent vs. spillover effects, (4) multiple outcome series (total, high-propensity, planned-wages) to distinguish serious vs. speculative business formation.

**Feasibility check:**
- Variation: 24 treated states, staggered 2012–2023. STRONG (≥20).
- Pre-treatment: 7+ years (2005–2011). STRONG.
- Data: BFS CSV download confirmed working. State × month × NAICS sector panels verified. 2004–2025.
- Not in APEP. KC Fed paper exists but uses different data and fewer states.
- Sample size: ~50 states × 21 years × 12 months × 20 NAICS sectors. Massive.

**DiD Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | 7+ years (STRONG) |
| Treated clusters | 24 states (STRONG) |
| Selection into treatment | Political liberalism; not obviously correlated with pre-existing business formation trends (MARGINAL+) |
| Comparison group | ~26 never-treated states (STRONG) |
| Concurrent policies | State-level economic policies vary (MARGINAL) |
| Outcome timing | BFS available through 2025 (STRONG) |
| Outcome dilution | Total BA captures all businesses, not just cannabis (some dilution; DDD addresses this) |
| Outcome-policy alignment | Direct for cannabis-adjacent sectors; indirect for total (STRONG with DDD) |

---

## Idea 2: Breaking Health Insurance Job Lock: ACA Medicaid Expansion and Adult College Enrollment

**Policy:** ACA Medicaid expansion. 38 states (plus DC) expanded, starting Jan 2014. Staggered: 25 states expanded in 2014, remainder from 2015–2023. Clear effective dates well-documented.

**Outcome:** ACS 1-year estimates of school enrollment by age, state, and year (subject table S1401 and detailed table B14004). Available via Census API, 2005–2023. Outcome: share of adults aged 25–54 currently enrolled in college (2-year or 4-year).

**Identification:** Staggered DiD comparing expansion vs. non-expansion states. CS estimator. Pre-treatment: 2005–2013 (9 years). The mechanism: Medicaid expansion breaks health insurance job lock by providing coverage to adults below 138% FPL regardless of employment, enabling them to reduce work and enroll in higher education.

**Why it's novel:** Existing literature examines (a) childhood Medicaid eligibility → adult college enrollment (De la Mata 2012; NBER WP 20178), (b) ACA Medicaid expansion → college student mental health (NBER WP 27306), (c) Medicaid expansion → college student employment intensity (AJHE 2024). The specific question — does adult Medicaid expansion increase adult enrollment in college? — is largely unstudied. The "job lock" mechanism for education (vs. labor supply) is novel.

**Feasibility check:**
- Variation: 38 treated states, concentrated in 2014 but with later adopters through 2023. STRONG.
- Pre-treatment: 9 years (2005–2013). STRONG.
- Data: ACS API tested and working. State-year enrollment data confirmed accessible.
- Not in APEP (apep_0076 uses DR for self-employment/insurance; apep_0031 is RDD for Wisconsin Medicaid).
- Sample size: ~50 states × 19 years. Adequate for state-year panel.

**DiD Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | 9 years (STRONG) |
| Treated clusters | 38 states (STRONG) |
| Selection into treatment | Political; correlated with state characteristics but well-characterized (MARGINAL) |
| Comparison group | 12 non-expansion states, mostly Southern (MARGINAL — fundamentally different) |
| Concurrent policies | ACA marketplace, dependent coverage to 26 (affect all states equally) (STRONG) |
| Outcome timing | ACS available through 2023 (STRONG) |
| Outcome dilution | Adult enrollment is a small share of population; need to focus on right age/income group (MARGINAL) |
| Outcome-policy alignment | ACS directly measures enrollment; mechanism is indirect (MARGINAL) |

**Key concern:** The comparison group of 12 non-expansion states is small and predominantly Southern. This limits the credibility of parallel trends. However, 38 treated states with different adoption timing allows within-treated-state comparisons.

---

## Idea 3: Opening the Practice: Nurse Practitioner Full Practice Authority and Primary Care Utilization

**Policy:** State laws granting Nurse Practitioners (NPs) full practice authority (FPA), allowing independent practice without physician supervision. Staggered adoption: ~10 states by 2000, ~20 by 2015, ~30 by 2023. Recent wave includes Kansas and New York (2022), Utah (2023).

**Outcome:** BRFSS data on healthcare access: "could not see doctor due to cost" (past 12 months), "have one or more personal doctor/health care provider," "last routine checkup." Available via CDC API, 2005–2023. Also: ACS data on health insurance coverage and self-reported health.

**Identification:** Staggered DiD comparing states that adopted FPA to restricted/reduced practice states. Focus on post-2010 wave of FPA adoptions (8+ states 2011–2016, more since). CS estimator with never-treated (restricted practice) states as comparison.

**Why it's novel:** Traczynski & Udalova (2018, JHE) study NP independence and healthcare utilization using earlier data. DePriest et al. (2020) study NP workforce outcomes. Bae et al. (2024) use Maryland-PA border analysis. This paper would be the first large-scale staggered DiD with modern CS estimators, covering the post-ACA acceleration of FPA adoptions. Novel for APEP entirely.

**Feasibility check:**
- Variation: ~15-20 states adopted FPA post-2010, plus ~10 earlier adopters. MARGINAL (fewer recent than desired).
- Pre-treatment: Depends on treatment definition. If using all adopters, limited pre-periods for early adopters. If post-2010 only, 5+ years pre. MARGINAL.
- Data: BRFSS likely accessible via CDC API. ACS confirmed accessible.
- Not in APEP. Some existing DiD literature but room for modern methods.
- Sample size: State-year panel with BRFSS state-level aggregates.

**DiD Screen:**
| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | 5+ if restricting to post-2010 wave (MARGINAL) |
| Treated clusters | 15-20 post-2010 adopters (MARGINAL) |
| Selection into treatment | Medical lobby strength, rural need; not clearly related to access trends (MARGINAL) |
| Comparison group | Restricted/reduced practice states (STRONG) |
| Concurrent policies | ACA expansion overlaps timing (WEAK) |
| Outcome timing | BRFSS available through 2023 (STRONG) |
| Outcome dilution | BRFSS measures population-level access (MARGINAL) |
| Outcome-policy alignment | Direct (STRONG) |

**Key concern:** The ACA Medicaid expansion (2014) overlaps temporally with many FPA adoptions, creating a major confound. States adopting FPA post-ACA may also have expanded Medicaid, making it difficult to isolate the FPA effect.
