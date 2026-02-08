# Research Ideas

**Method:** Doubly Robust (AIPW/TMLE/DML)
**Data source:** American Community Survey PUMS (Census API, no key needed)
**Risk appetite:** Novel angle on classic policy questions

---

## Idea 1: Self-Employment as Bridge Employment: Does the ACA Unlock Flexible Retirement Pathways?

**Policy:** Affordable Care Act (ACA) - signed March 2010, marketplace exchanges operational January 2014. Key provisions: individual mandate, guaranteed issue, premium subsidies for income below 400% FPL, Medicaid expansion (state-dependent). Pre-ACA: health insurance tied to employment, creating "job lock." Post-ACA: individual market viable for self-employed workers.

**Research question:** Among workers aged 55-70, does self-employment serve as a bridge to retirement (facilitating gradual withdrawal from the labor force) or does it represent precarious work (long hours, low income)? How did the ACA change this relationship?

**Outcome:** Hours worked (WKHP), conditional on employment. Secondary: income volatility, health insurance source.

**Treatment:** Self-employment (COW=6 or 7) vs. wage employment (COW=1-5).

**Identification:** Doubly robust estimation comparing self-employed vs. wage workers aged 55-70, controlling for occupation (SOCP), industry (NAICS), education (SCHL), age (AGEP), sex (SEX), race (RAC1P), disability status (DIS), state (ST), and metropolitan status. Pre/post ACA comparison adds within-design variation.

**Why DR is appropriate:** Self-employment is a choice, not randomly assigned. However:
- Rich covariates: ACS has detailed occupation, industry, demographics
- Institutional setting: We understand the decision—older workers may choose self-employment for flexibility, but health insurance constraints pre-ACA limited this option
- ACA provides natural pre/post comparison to strengthen causal claims

**Why it's novel:** 
1. Most bridge employment research examines job TYPE (e.g., part-time vs full-time), not employment STATUS (self vs wage)
2. ACA's effect on older-worker self-employment is understudied—most ACA research focuses on young adults (26 rule) or low-income (Medicaid expansion)
3. Connects two important literatures: retirement transitions and healthcare policy

**Feasibility check:**
- Data accessible: Census API, tested with 80k+ observations for CA alone, nationwide extracts feasible
- Key variables present: COW (class of worker), WKHP (hours), SOCP (occupation), DIS (disability), HICOV (insurance)
- Not in APEP list (checked 88 papers)
- Time coverage: 2005-2024 spans pre/post ACA

**Potential weaknesses:**
- Selection into self-employment on unobservables (motivation, risk preferences)
- Need strong sensitivity analysis (E-values, calibrated confounding)

---

## Idea 2: Disability, Self-Employment, and the Accommodation Hypothesis

**Policy:** Americans with Disabilities Act (ADA) - signed July 1990, amended 2008 (ADA Amendments Act). ADA requires employers to provide "reasonable accommodations" but does not apply to self-employment. Hypothesis: self-employment may serve as alternative accommodation pathway. Also relevant: SSDI/SSI work incentives (Ticket to Work 1999, ABLE Act 2014).

**Research question:** Does self-employment improve labor market outcomes (hours worked, income) for workers with disabilities compared to wage employment? Is the "self-employment premium" larger for disabled workers than non-disabled workers?

**Outcome:** Hours worked (WKHP), total income (PINCP), employment stability.

**Treatment:** Self-employment x Disability interaction.

**Identification:** Triple-difference in DR framework: 
- Self-employed vs. wage workers
- Disabled vs. non-disabled (DIS variable)
- Effect heterogeneity by disability status

**Why DR is appropriate:** Both self-employment and disability status are non-randomly assigned, but:
- Rich covariates: Education, occupation, age, industry, geography
- Disability is relatively stable for working-age adults (less selection concern than health shocks)
- Interaction design tests mechanism (flexibility accommodation)

**Why it is novel:**
1. Most disability employment research focuses on SSDI policy or ADA compliance
2. Self-employment as accommodation mechanism is theoretically motivated but empirically understudied
3. Has direct policy implications: Should entrepreneurship programs target disabled workers?

**Feasibility check:**
- Data accessible: Census PUMS, DIS variable clean
- Sample size: about 15% of working-age adults report disability in ACS
- Not in APEP list
- O*NET can provide occupation-level physical demand scores for heterogeneity analysis

**Potential weaknesses:**
- Disability may be endogenous (correlated with unobserved health affecting productivity)
- Self-selection of disabled workers into self-employment on unobservables

---

## Idea 3: Does Housing Cost Burden Increase or Decrease Labor Supply?

**Policy:** HUD 30% affordability standard - established 1981 (Brooke Amendment modified). Federal housing policy defines "cost burden" as housing costs exceeding 30% of income. State/local policies: rent control (various dates), inclusionary zoning, housing vouchers (Section 8, 1974). Housing costs have risen 2010-2024, creating natural variation in cost burden.

**Research question:** Among working-age adults, does higher housing cost burden (housing costs as share of income) lead to more or fewer hours worked? Does this differ by household structure (single vs. dual earner, with/without children)?

**Outcome:** Hours worked (WKHP), labor force participation (ESR).

**Treatment:** High housing cost burden (GRPIP or OCPIP > 30% of income) vs. low burden.

**Identification:** DR estimation comparing workers in high vs. low housing cost burden categories, controlling for metro area, occupation, industry, education, age, household composition, and income sources.

**Why DR is appropriate:**
- Housing cost burden is endogenous (function of choices about location and housing)
- But within occupation x metro cells, variation may be plausibly exogenous
- Rich covariates available: detailed geography, occupation, household structure

**Why it is novel:**
1. Classic labor supply question with understudied mechanism (housing costs)
2. Housing affordability is politically salient; labor supply implications matter for policy
3. Connects urban economics with labor economics

**Feasibility check:**
- Data accessible: ACS has GRPIP (renter), OCPIP (owner) variables
- Geographic variation: PUMA-level analysis feasible
- Not in APEP list
- Can test heterogeneity by household type (married, children, etc.)

**Potential weaknesses:**
- Reverse causality: Hours worked affects income, which affects cost burden ratio
- Need to carefully define treatment to avoid mechanical correlation
- Location choice is endogenous

---

## Idea 4: Occupational Skill Mismatch and Immigrant Earnings

**Policy:** Foreign credential recognition reforms - Arizona (2019), Florida (2020), various states 2019-2024 passing laws to recognize foreign professional credentials. Federal: Nursing Relief Act (1999), H-1B visa program (ongoing). State licensing boards historically did not recognize foreign credentials, creating "brain waste."

**Research question:** Among college-educated immigrants, does occupational-education mismatch (working in job below education level) affect earnings? Is the mismatch penalty larger or smaller than for native-born workers?

**Outcome:** Hourly wages (WAGP/WKHP) or annual earnings (PINCP).

**Treatment:** Occupation-education mismatch (college degree but in non-college occupation).

**Identification:** DR comparing matched vs. mismatched workers within education x birthplace cells.

**Why DR is appropriate:**
- Mismatch is endogenous (credential recognition, language skills, network effects)
- Rich covariates: education level, field of study (limited), occupation, industry, years in US, English proficiency

**Why it is novel:**
1. Immigrant mismatch is documented, but causal earnings penalty is less studied
2. Connects to occupational licensing reform literature
3. Policy relevant: credential recognition is active reform area

**Feasibility check:**
- Data accessible: ACS has POBP (birthplace), SCHL (education), SOCP (occupation)
- Can construct mismatch variable using occupation x education mapping
- Not in APEP list (checked immigrant-related papers)
- O*NET has education requirements by occupation for validation

**Potential weaknesses:**
- Mismatch selection is strong (language, networks, licensing barriers)
- Limited information on credential details in ACS
- Field of study (FOD1P) only available for recent graduates

---

## Summary Ranking

| Idea | Novelty | Identification | Feasibility | Policy Relevance | Overall |
|------|---------|----------------|-------------|------------------|---------|
| 1 (Self-employment bridge) | High | Medium | High | High | TOP CHOICE |
| 2 (Disability self-employment) | High | Medium | High | High | Strong backup |
| 3 (Housing cost burden) | Medium | Medium | High | High | Good backup |
| 4 (Immigrant mismatch) | Medium | Medium | Medium | Medium | Weaker |

**Recommendation:** Pursue Idea 1 (Self-Employment as Bridge Employment). It has:
- Strong novelty: connects two literatures (retirement transitions, ACA effects)
- Good identification: ACA provides temporal variation to supplement DR
- Excellent data: ACS PUMS has all required variables
- High policy relevance: retirement policy and healthcare policy intersection
