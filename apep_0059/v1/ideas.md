# Research Ideas

## Idea 1: Self-Employment and Health Insurance Coverage: A Doubly Robust Analysis

**Policy:** Self-employment as a labor market choice
**Outcome:** Health insurance coverage type and rates (PUMS: HICOV, HINS1-7, PRIVCOV, PUBCOV)
**Treatment:** Self-employment status (COW = 6 or 7: self-employed incorporated/unincorporated)
**Control group:** Wage and salary workers (COW = 1-5)
**Data source:** Census ACS PUMS 2018-2022 (post-ACA stabilization period)

**Identification:** Doubly Robust estimation comparing self-employed vs wage workers, controlling for:
- Demographics: age, sex, race, education, marital status
- Location: state, urban/rural (PUMA)
- Industry (INDP) and occupation (OCCP) at detailed levels
- Household composition: presence of spouse, number of children
- Prior employment history proxied by current hours/weeks worked

**Why DR is appropriate:** Self-employment is not randomly assigned, but selection is largely based on observable characteristics. No clean quasi-experimental variation exists (no staggered policy adoption or sharp cutoffs). The ACA Marketplaces in theory equalized access to individual insurance, but selection into self-employment may still affect coverage through mechanisms like employer-sponsored insurance access.

**Estimand:** ATT - effect of self-employment on health insurance coverage among those who chose self-employment

**Why it's novel:**
- Existing literature (e.g., Fairlie et al. 2011) used pre-ACA data
- Modern DR methods with ML-based nuisance estimation not applied
- Post-ACA landscape fundamentally changed insurance access
- Can examine heterogeneity by ACA Marketplace status

**Feasibility check:**
- ✓ Data accessible: Census PUMS API returns 1M+ observations for workers 25-60
- ✓ Treatment prevalence: ~10% of workers are self-employed
- ✓ Rich covariates available: detailed occupation, industry, demographics
- ✓ Not overstudied with modern DR methods post-ACA

**Policy relevance:** Understanding whether self-employment still carries health insurance penalties post-ACA informs gig economy policy, portable benefits debates, and Marketplace effectiveness.

---

## Idea 2: English Proficiency and Earnings Among Immigrants: A Doubly Robust Approach

**Policy:** English language proficiency as human capital
**Outcome:** Annual wages (WAGP), hourly wages (WAGP/WKHP), employment (ESR)
**Treatment:** Limited English proficiency (ENG = 3 or 4: "Not well" or "Not at all")
**Control group:** English proficient immigrants (ENG = 1 or 2)
**Data source:** Census ACS PUMS 2022, restricted to foreign-born (NATIVITY=2)

**Identification:** Doubly Robust estimation within the foreign-born population, controlling for:
- Demographics: age, sex, education (including foreign degrees)
- Origin country (POBP) and years in US (YOEP)
- Occupation and industry at detailed levels
- Geographic location (state, metro area)
- Family structure: marital status, children

**Why DR is appropriate:** English proficiency is acquired, not randomly assigned. However, conditional on country of origin, education, and years in US, remaining selection is likely on observables. No quasi-experiment available for English acquisition.

**Why it's novel:**
- Classic question (Chiswick 1978, etc.) but not examined with modern DR/ML methods
- Recent immigration patterns differ from historical waves
- Can provide sensitivity analysis with calibrated bounds (sensemakr)

**Feasibility check:**
- ✓ Data accessible: PUMS has ~5M foreign-born observations across 5-year file
- ✓ Treatment prevalence: ~20% of immigrants report limited English
- ✓ Rich controls available including country of origin
- ✗ Concern: May be too well-studied; novelty limited

**Policy relevance:** Informs English language instruction funding, immigration policy, workforce integration programs.

---

## Idea 3: For-Profit College Attendance and Early Career Earnings

**Policy:** For-profit vs non-profit college sector choice
**Outcome:** Median earnings 10 years post-entry, employment rates
**Treatment:** Attended for-profit institution
**Control group:** Attended public or private non-profit institution
**Data source:** College Scorecard institution-level data merged with characteristics

**Identification:** Doubly Robust at institution level, controlling for:
- Student body composition (Pell share, demographics)
- Admission selectivity (if available)
- Program mix (share in various fields)
- Geographic market characteristics
- Institutional characteristics (size, urbanicity)

**Why DR is appropriate:** Students self-select into for-profit colleges. No clean quasi-experiment. Selection likely based on academic preparation, geographic access, field of study interest - largely observable in aggregate.

**Why it's novel:**
- Cellini & Chaudhary (2012) used individual FE; DR approach is different
- College Scorecard provides newer, richer data
- Can examine field-of-study heterogeneity

**Feasibility check:**
- ✓ Data accessible: College Scorecard API working
- ✓ Institution-level data with earnings outcomes
- ✗ Concern: Aggregated data limits individual-level inference
- ✗ Concern: Selection at student level, but data at institution level

**Policy relevance:** Informs gainful employment regulations, student loan forgiveness debates, career college oversight.

---

## Idea 4: Recent Childbirth and Labor Force Participation: Doubly Robust Estimates

**Policy:** Childbirth as a life event affecting labor supply
**Outcome:** Employment (ESR), hours worked (WKHP), wages (WAGP)
**Treatment:** Gave birth in past 12 months (FER=1)
**Control group:** Women who did not give birth (FER=2)
**Data source:** Census ACS PUMS 2022, restricted to women 20-45

**Identification:** Doubly Robust comparing recent mothers to non-mothers, controlling for:
- Demographics: age, race, education, marital status
- Spouse characteristics if married (HUSBORD link)
- Prior labor market attachment (occupation, industry, hours)
- Household structure: other children, extended family
- Geographic factors: state, urban/rural

**Why DR is appropriate:** Childbirth timing is a choice, but conditional on observables (age, education, marriage), remaining selection may be limited. No quasi-experiment for childbirth itself.

**Estimand:** ATT - effect of recent birth on labor outcomes among those who gave birth

**Why it's novel:**
- Classic motherhood penalty literature uses OLS or simple matching
- Modern DR with ML-based propensity scores not widely applied
- Can provide E-values for sensitivity to unmeasured confounding

**Feasibility check:**
- ✓ Data accessible: PUMS has FER variable for women 15-50
- ✓ Treatment prevalence: ~6% of women 20-45 gave birth in past year
- ✓ Rich controls available
- ✗ Concern: Unconfoundedness harder to defend (fertility timing is complex)

**Policy relevance:** Informs paid family leave design, childcare subsidies, workplace flexibility mandates.

---

## Summary and Ranking

| Idea | Novelty | Identification | Feasibility | Policy Relevance | Overall |
|------|---------|----------------|-------------|------------------|---------|
| 1. Self-employment + insurance | High | Medium | High | High | **Best** |
| 2. English + earnings | Medium | Medium | High | Medium | Good |
| 3. For-profit + earnings | Medium | Low | Medium | High | Marginal |
| 4. Childbirth + labor | Low | Low | High | High | Marginal |

**Recommended:** Idea 1 (Self-Employment and Health Insurance Coverage) offers the best combination of novelty, feasibility, and policy relevance. The post-ACA setting provides a natural update to the literature, and DR methods are well-suited to this observational question.
