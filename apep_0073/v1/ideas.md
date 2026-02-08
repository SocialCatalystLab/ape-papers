# Research Ideas

## Idea 1: SNAP Work Requirement Reinstatement and Employment Outcomes (SELECTED)

**Policy:** SNAP ABAWD (Able-Bodied Adults Without Dependents) work requirements reinstatement. Under federal law, ABAWDs (ages 18-49, no dependents, able to work) can only receive SNAP for 3 months in any 36-month period unless working 80+ hours/month. However, states can request waivers during high unemployment. After the 2008 recession, nearly all states had waivers. As unemployment fell, states lost eligibility and work requirements were reinstated at different times (2013-2019), creating staggered adoption.

**Outcome:** Employment status (employed, unemployed, NILF) for ABAWD-eligible adults, from Census ACS PUMS.

**Identification:** Staggered difference-in-differences. Treatment = state loses ABAWD waiver (work requirement reinstated). Compare employment outcomes for 18-49 year olds without dependents before/after reinstatement, using states still under waiver as control. Use Callaway-Sant'Anna (2021) estimator to handle staggered adoption and heterogeneous treatment effects.

**Why it's novel:** While SNAP work requirements have been studied for participation effects (Bauer et al. 2019 find 600k lost benefits), less attention has been paid to employment outcomes using individual-level microdata and modern staggered DiD methods. The existing literature largely uses state-level aggregates; ACS PUMS allows individual-level analysis with proper controls for demographics.

**Feasibility check:**
- ✓ Variation exists: USDA FNS publishes waiver status by state-year (FY 2010-2024)
- ✓ Data accessible: Census ACS PUMS API (2010-2022) provides individual-level employment, SNAP receipt, age, state
- ✓ Not overstudied: Most papers focus on SNAP participation, not employment outcomes
- ✓ Sample size: Millions of observations per year in ACS

**DiD Feasibility Screen:**
- Pre-treatment periods: 5+ years (2010-2014 for most states)
- Selection into treatment: Based on unemployment rate falling below threshold - partially endogenous but predictable from macro conditions
- Comparison group: States still under waiver (slower economic recovery)
- Treatment clusters: 40+ states eventually reinstated requirements
- Concurrent policies: Need to control for Medicaid expansion (correlated timing)
- Data-outcome timing: Employment measured continuously, waiver changes at fiscal year boundaries

---

## Idea 2: SNAP Work Requirements and Labor Force Participation by Age Group

**Policy:** Same as Idea 1 - SNAP ABAWD waiver reinstatement

**Outcome:** Labor force participation rate, separately for ages 18-24, 25-34, 35-49

**Identification:** Same DiD framework with age-group heterogeneity analysis

**Why it's novel:** Age heterogeneity in response to work requirements has policy implications for targeting employment services

**Feasibility check:**
- ✓ Same data sources work
- ✓ Sufficient sample within each age band

---

## Idea 3: SNAP Work Requirements and Self-Employment

**Policy:** Same as Idea 1

**Outcome:** Self-employment rate among ABAWD-eligible adults (class of worker variable in ACS)

**Identification:** Same DiD framework

**Why it's novel:** Work requirements specify 80 hours/month of work OR job training. Does this push people into gig/self-employment to meet requirements?

**Feasibility check:**
- ✓ ACS has class of worker (COW) variable
- ⚠ Self-employment is relatively rare - may lack power

---

## Ranking

**Idea 1 is strongest:**
- Clearest policy question with largest literature gap
- Most direct test of work requirement effectiveness
- Largest sample size for primary outcome
- Employment is the key policy-relevant outcome (the stated goal of work requirements)

