# Research Ideas — Paper 59

## Idea 1: Universal Free School Meals and Household Food Security

**Policy:** State universal free school meals programs adopted 2022-2024

| State | Effective Date | Program Details |
|-------|----------------|-----------------|
| California | Fall 2022 | K-12, breakfast + lunch |
| Maine | Fall 2022 | K-12, breakfast + lunch |
| Vermont | Fall 2022 | K-12, breakfast + lunch (1-year initially) |
| Colorado | Fall 2023 | K-12, optional for districts |
| Massachusetts | Fall 2023 | K-12, funded by millionaire tax |
| Michigan | Fall 2023 | K-12, $160M state appropriation |
| Minnesota | Fall 2023 | K-12, breakfast + lunch |
| New Mexico | Fall 2024 | K-12, breakfast + lunch |

**Outcome:** Household food insufficiency measured via the Census Household Pulse Survey (HPS) which has state-level data from April 2020-present. The HPS specifically asks about food sufficiency in households with children.

**Identification:** Staggered DiD exploiting differential state adoption timing. States without universal programs (≈42 states) serve as comparison group.

**Why it's novel:**
- USDA ERS published ONE descriptive report (2024) showing correlation with reduced food insufficiency
- NO causal DiD analysis with proper heterogeneity-robust estimators has been published
- No event study plots showing pre-trends have been presented

### DiD Early Feasibility Assessment

| Criterion | Assessment | Justification |
|-----------|------------|---------------|
| Pre-treatment periods | **Strong** | HPS data available from April 2020 (2+ years before first adoptions) |
| Selection into treatment | **Marginal** | Democratic-leaning states more likely to adopt; not responding to food insecurity trends specifically |
| Comparison group | **Strong** | 42+ never-treated states with similar demographics available |
| Treatment clusters | **Strong** | 8 treated states, 42+ control states = 50 clusters |
| Concurrent policies | **Marginal** | COVID relief (ARP, SNAP emergency allotments) ended ~2023; need to control |

**Feasibility check:**
- ✅ Variation exists: 8 treated states, staggered 2022-2024
- ✅ Data accessible: HPS data available via Census API (tested)
- ✅ Not overstudied: Only 1 USDA descriptive report, no causal DiD
- ⚠️ Concurrent policies: SNAP emergency allotments ended Feb 2023; ARP school meal waivers ended June 2022. Timeline actually helps—clean separation from COVID programs.

---

## Idea 2: Clean Slate Laws and Employment Among Formerly Incarcerated Individuals

**Policy:** State automatic criminal record expungement ("Clean Slate") laws adopted 2018-2024

| State | Enacted | Effective/Operational |
|-------|---------|----------------------|
| Pennsylvania | 2018 | 2018 |
| Utah | 2019 | 2019 |
| New Jersey | 2019 | ~2020 |
| Michigan | 2020 | 2023 (implementation delayed) |
| Connecticut | 2021 | 2023 |
| Delaware | 2022 | 2024 |
| Oklahoma | 2022 | 2025 |
| Colorado | 2022 | Phased |
| Virginia | 2022 | 2025 |
| California | 2023 | 2023-2024 |
| New York | 2023 | Nov 2024 |
| Minnesota | 2024 | 2025 |

**Outcome:** Employment rates and labor force participation among individuals with criminal records, measured via CPS ASEC. Challenge: CPS doesn't directly identify criminal history, but we can use demographic proxies (young Black males historically most affected by criminal records).

**Identification:** Staggered DiD with Callaway-Sant'Anna estimator. Never-treated states (38+) as control.

**Why it's novel:**
- Existing literature focuses on "ban the box" (APEP list shows overlap concerns)
- Clean Slate is AUTOMATIC expungement (stronger treatment than petition-based)
- No published causal DiD using nationally representative data

### DiD Early Feasibility Assessment

| Criterion | Assessment | Justification |
|-----------|------------|---------------|
| Pre-treatment periods | **Strong** | CPS data available 2010-present; 8 years before PA first adoption |
| Selection into treatment | **Marginal** | Blue states more likely to adopt; may correlate with labor markets |
| Comparison group | **Strong** | 38+ never-treated states |
| Treatment clusters | **Strong** | 12+ treated states, 38+ controls = 50 clusters |
| Concurrent policies | **Marginal** | Ban-the-box laws overlap in some states; need to control |

**Feasibility check:**
- ✅ Variation exists: 12 treated states, staggered 2018-2025
- ⚠️ Data limitation: CPS doesn't identify criminal records directly; need demographic proxy approach
- ✅ Not overstudied: Clean Slate specifically (vs. ban-the-box) is understudied
- ⚠️ Implementation lags: Some laws passed but not yet operational (e.g., NY, MN)

---

## Idea 3: State Insulin Price Caps and Diabetes Management Outcomes

**Policy:** State laws capping monthly out-of-pocket insulin costs (typically $25-$100/month), adopted 2019-2024

| State | Effective Date | Cap Amount |
|-------|----------------|------------|
| Colorado | 2020 | $100 → $50 (lowered 2024) |
| Illinois | 2020 | $100 |
| New Mexico | 2020 | $25 |
| New York | 2020 | $100 |
| Maine | 2020 | $35 |
| Utah | 2020 | $30 |
| Washington | 2021 | $100 |
| Texas | Sept 2021 | $25 |
| Connecticut | 2022 | $25 |
| Delaware | 2022 | $100 |
| New Hampshire | 2022 | $30 |
| West Virginia | 2022 | $35 |
| California | 2023 | $35 |
| + ~10 more states | 2023-2024 | Various |

**Outcome:** Diabetes-related emergency department visits and hospitalizations from state-level hospital discharge data (HCUP SID) or CDC BRFSS measures of diabetes management.

**Identification:** Staggered DiD with 20+ treated states, never-treated as control.

**Why it's novel:**
- Texas A&M study (2024) found 40% reduction in out-of-pocket costs using commercial claims
- NO study has examined health outcomes (ED visits, hospitalizations, A1C control)
- Policy-relevant: informing federal debate on extending caps to commercial insurance

### DiD Early Feasibility Assessment

| Criterion | Assessment | Justification |
|-----------|------------|---------------|
| Pre-treatment periods | **Strong** | BRFSS/HCUP data available 2010-present |
| Selection into treatment | **Marginal** | Both red and blue states adopted (TX, UT, CO, CA, NY) |
| Comparison group | **Strong** | ~25 never-treated states |
| Treatment clusters | **Strong** | 25+ treated states, 25+ controls = 50 clusters |
| Concurrent policies | **Marginal** | Federal Medicare $35 cap (IRA 2023); manufacturer voluntary caps (2024) |

**Feasibility check:**
- ✅ Variation exists: 25+ treated states, staggered 2019-2024
- ⚠️ Data access: HCUP SID requires purchase; BRFSS is free but less granular
- ✅ Not overstudied: Health outcomes specifically are unstudied (only cost studies exist)
- ⚠️ Concurrent policies: Federal Medicare cap (2023) and manufacturer voluntary caps (2024) complicate late-period identification

---

## Idea 4: State Paid Family Leave and Maternal Labor Force Participation

**Policy:** State paid family and medical leave (PFML) programs, staggered implementation 2004-2024

| State | Contributions Start | Benefits Available |
|-------|--------------------|--------------------|
| California | 2004 | 2004 |
| New Jersey | 2009 | 2009 |
| Rhode Island | 2014 | 2014 |
| New York | 2018 | 2018 |
| Washington | 2019 | 2020 |
| Massachusetts | 2019 | 2021 |
| Connecticut | 2021 | 2022 |
| Oregon | 2022 | 2023 |
| Colorado | 2023 | 2024 |
| Maryland | 2024 | 2026 |
| Delaware | 2025 | 2026 |

**Outcome:** Maternal labor force participation (mothers of children <1 year old) from CPS ASEC. Secondary outcomes: return-to-work timing, employer attachment, wage growth.

**Identification:** Staggered DiD with modern heterogeneity-robust estimators. 36+ never-treated states as comparison.

**Why it's novel:**
- Existing literature focuses on California/NJ (early adopters)
- Wave of 2018-2024 adoptions provides new quasi-experimental variation
- APEP paper 0002 studied paid SICK leave (different policy); this is FAMILY leave

### DiD Early Feasibility Assessment

| Criterion | Assessment | Justification |
|-----------|------------|---------------|
| Pre-treatment periods | **Strong** | CPS data available 1990-present; many pre-periods for recent adopters |
| Selection into treatment | **Marginal** | Blue states more likely; but CA was early (2004) before polarization |
| Comparison group | **Strong** | 36+ never-treated states |
| Treatment clusters | **Strong** | 14 treated, 36+ controls = 50 clusters |
| Concurrent policies | **Marginal** | FMLA (federal, unpaid) already exists; ACA maternity coverage |

**Feasibility check:**
- ✅ Variation exists: 14 treated states, long stagger from 2004-2024
- ✅ Data accessible: CPS ASEC via IPUMS (key available)
- ⚠️ Heavily studied: California/NJ programs well-documented; contribution is NEW adopters (2018-2024)
- ✅ Distinct from APEP list: Paper 0002 is sick leave, not family leave

---

## Idea 5: State Data Privacy Laws and Tech Sector Employment

**Policy:** Comprehensive state consumer data privacy laws (CCPA-style), adopted 2020-2024

| State | Effective Date | Key Provisions |
|-------|----------------|----------------|
| California (CCPA) | Jan 2020 | Consumer data rights, $2,500-7,500 penalties |
| Virginia | Jan 2023 | Consumer rights, opt-out |
| Colorado | July 2023 | Consumer rights, opt-out |
| Connecticut | July 2023 | Consumer rights, opt-out |
| Utah | Dec 2023 | Business-friendly version |
| Texas | July 2024 | Broad applicability |
| Oregon | July 2024 | Including biometric data |
| Montana | Oct 2024 | Consumer rights |
| New Hampshire | Jan 2025 | Consumer rights |
| New Jersey | Jan 2025 | Consumer rights |
| + 8 more | 2024-2025 | Various |

**Outcome:** Tech sector employment (NAICS 51, 54) from QCEW or BLS-OES. Secondary: data-intensive job postings, wages in compliance roles.

**Identification:** Staggered DiD. California provides early treatment (2020); wave of 2023-2025 adoptions provides fresh variation.

**Why it's novel:**
- Privacy law effects on EMPLOYMENT are completely unstudied
- Literature focuses on consumer behavior, firm compliance costs
- Policy-relevant: federal privacy legislation debate ongoing

### DiD Early Feasibility Assessment

| Criterion | Assessment | Justification |
|-----------|------------|---------------|
| Pre-treatment periods | **Strong** | QCEW quarterly data available 2000-present |
| Selection into treatment | **Marginal** | Tech-heavy states (CA, CO) early adopters |
| Comparison group | **Marginal** | ~30 never-treated states, but tech employment concentrated in treated states |
| Treatment clusters | **Strong** | 19+ treated states (by 2025), 30+ controls |
| Concurrent policies | **Weak** | COVID-19 shock (2020) coincides with California CCPA |

**Feasibility check:**
- ✅ Variation exists: 19+ treated states by 2025
- ✅ Data accessible: QCEW is public, no API key needed
- ✅ Novel angle: Employment effects unstudied
- ⚠️ Confounded: COVID shock exactly coincides with California's effective date (Jan 2020)

---

## Summary and Recommendation

| Idea | Novelty | Identification | Data | Overall |
|------|---------|----------------|------|---------|
| 1. Universal Free School Meals | **High** | Strong | Good (HPS) | **PURSUE** |
| 2. Clean Slate Laws | Medium | Strong | Limited (proxy) | CONSIDER |
| 3. Insulin Price Caps | **High** | Strong | Moderate (BRFSS) | **PURSUE** |
| 4. Paid Family Leave | Low | Strong | Good (CPS) | CONSIDER (crowded) |
| 5. Data Privacy Laws | **High** | Weak (COVID) | Good (QCEW) | SKIP (confounded) |

**Top Recommendations:**
1. **Universal Free School Meals** — Novel policy, clean timing, direct outcome measure
2. **Insulin Price Caps** — Novel outcome angle (health, not cost), policy-relevant
