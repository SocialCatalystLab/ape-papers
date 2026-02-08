# Research Ideas

## Idea 1: Medicare Eligibility and Labor Force Exit: Heterogeneous Effects by Automation Exposure

**Research Question:** Does Medicare eligibility at age 65 have a larger effect on labor force exit for workers in high-automation-exposure occupations compared to low-automation-exposure occupations?

**Policy:** Medicare eligibility at age 65 (federal, universal since 1965). Medicare provides health insurance outside of employer sponsorship, potentially reducing "job lock."

**Data:**
- **Labor outcomes:** IPUMS CPS (2005-2023), individual-level data with age, employment status, hours, occupation (OCC2010)
- **Automation exposure:** Frey & Osborne (2017) automation probabilities or Felten et al. AIOE index, crosswalked from SOC to OCC2010

**Identification (Doubly Robust):**
- Treatment: Work in high-automation occupation (above median automation probability)
- Outcome: Labor force participation
- Heterogeneity: Estimate treatment effect separately for ages 55-64 vs 65-75
- Unconfoundedness: Control for education, gender, race, state, year, industry, wages, health insurance status
- Sensitivity: E-values, calibrated sensitivity analysis (benchmark to observed confounders)

**Mechanism:**
1. Workers in high-automation occupations face greater displacement risk
2. Employer-sponsored health insurance creates "job lock"
3. At age 65, Medicare eligibility removes this lock
4. High-automation workers, with less bargaining power and job security, may be more responsive to Medicare eligibility

**Why it's novel:**
- Existing literature studies: (a) Medicare → retirement (Rust & Phelan 1997, Blau & Gilleskie 2006), (b) Automation → retirement (Frey & Osborne 2017, Work, Aging and Retirement 2024)
- **No paper examines the interaction**: Does Medicare eligibility differentially affect high vs low automation workers?
- This fills a gap at the intersection of health insurance, retirement, and technological displacement

**Feasibility check:**
- ✓ Data accessible: IPUMS CPS (API key configured), Frey-Osborne probabilities (published data)
- ✓ Sample size: CPS has ~100K observations/year, ages 55-75 = sufficient power
- ✓ Variation: Continuous age × continuous automation exposure
- ✓ Not in APEP list (checked: apep_0027, apep_0032 study age thresholds but not automation heterogeneity)
- ✓ Confounders: CPS has rich demographics, education, industry for unconfoundedness

---

## Idea 2: ACA Medicaid Expansion and Employment Transitions by Automation Risk

**Research Question:** Did ACA Medicaid expansion (2014+) differentially affect employment and job transitions for workers in high vs low automation-exposure occupations?

**Policy:** ACA Medicaid expansion. Staggered state adoption starting 2014. Currently 40 states + DC have expanded.

**Data:**
- **Labor outcomes:** IPUMS CPS (2010-2023), employment, hours, occupation transitions
- **Automation exposure:** Frey-Osborne or AIOE index
- **Treatment timing:** State expansion dates (Kaiser Family Foundation)

**Identification:** DiD with heterogeneous effects by automation exposure. Compare employment outcomes for high-auto vs low-auto workers in expansion vs non-expansion states, before vs after expansion.

**Why it's novel:**
- Medicaid expansion labor effects studied extensively (Duggan et al. 2019, Moriya et al. 2016)
- But heterogeneity by automation exposure not examined
- Important policy question: Does health insurance expansion help workers in automation-threatened occupations?

**Feasibility check:**
- ✓ Data accessible
- ✓ Clear state × time variation
- ⚠️ Would require DiD method (not DR as assigned)
- ⚠️ Potentially crowded literature on Medicaid expansion

---

## Idea 3: Social Security Early Retirement (Age 62) and Labor Supply by Automation Exposure

**Research Question:** Do workers in high-automation occupations claim Social Security earlier (at age 62) than low-automation workers?

**Policy:** Social Security early retirement eligibility at age 62 (reduced benefits available). Federal, universal.

**Data:**
- **Labor outcomes:** IPUMS CPS, labor force participation by age
- **Social Security claiming:** Health and Retirement Study (HRS) has detailed claiming data
- **Automation exposure:** Crosswalked indices

**Identification (DR):**
- Treatment: High automation exposure
- Outcome: Probability of claiming SS at age 62 (vs waiting until FRA or later)
- Controls: Education, health, wealth, industry, state

**Why it's novel:**
- Automation → retirement literature exists (Work, Aging & Retirement 2024)
- But specific focus on SS claiming age choice by automation exposure is novel
- Policy relevance: If high-auto workers claim early, they face permanent benefit reductions

**Feasibility check:**
- ✓ Data: HRS has detailed SS claiming and occupation data
- ⚠️ Requires HRS access (sensitive data)
- ⚠️ Similar to apep_0027, apep_0032 but different angle

---

## Idea 4: AI Chatbot Release (ChatGPT, Nov 2022) and Labor Market Outcomes

**Research Question:** Did the release of ChatGPT affect employment and wages for workers in AI-exposed occupations?

**Policy/Event:** ChatGPT release November 30, 2022. Sudden, unexpected shock to AI capabilities.

**Data:**
- **Labor outcomes:** CPS, employment, wages, hours
- **AI exposure:** Felten et al. AIOE or Eloundou et al. (2023) GPT exposure scores

**Identification:** Event study around Nov 2022. Compare outcomes for high vs low AI-exposed occupations before/after release.

**Challenges:**
- ⚠️ No geographic variation - all US exposed simultaneously
- ⚠️ Other confounders: post-COVID recovery, Fed rate hikes, tech layoffs
- ⚠️ Too soon to see labor market effects (skills adaptation, displacement takes time)

**Feasibility check:**
- Data accessible
- ✗ Weak identification without geographic/policy variation
- ✗ Confounded time period
- Not recommended

---

## Recommendation

**Pursue Idea 1 (Medicare × Automation)** as the primary candidate:
- Strongest identification for DR method
- Clear novel contribution
- All data accessible
- Rich covariates for unconfoundedness
- Natural sensitivity analysis opportunities
