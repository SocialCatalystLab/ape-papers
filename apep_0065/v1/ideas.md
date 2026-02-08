# Research Ideas for Paper 83

**Method:** Doubly Robust (DR) Estimation
**Risk Appetite:** Novel angle (classic policy + classic data + new question/method)
**Data Era:** Modern (2022-2024)

---

## Idea 1: Remote Work and Housing Cost Burden

**Policy Context:** The COVID-19 pandemic accelerated adoption of remote work. By 2023, approximately 15-20% of full-time workers work primarily from home. This represents a massive "treatment" that affects where people live and how much they pay for housing.

**Research Question:** Does remote work reduce housing cost burden by enabling geographic arbitrage (moving to lower-cost areas while maintaining employment)?

**Treatment:** Remote work status (JWTRNS = worked from home in ACS PUMS)

**Outcome:** Housing cost burden (GRPIP = gross rent as % of income; OCPIP = owner costs as % of income)

**Identification Strategy:** DR estimation comparing remote workers to observationally similar in-person workers, controlling for occupation, industry, education, age, race, sex, state, metro status, and household composition. The key identifying assumption is selection on observables: conditional on these covariates, remote work assignment is as good as random for housing outcomes.

**Why DR Over DiD/RDD:**
- No quasi-experimental variation—remote work adoption wasn't staggered by policy
- Rich individual-level covariates available for adjustment
- Treatment is a binary choice/assignment

**Novel Angle:** Macro DiD studies (Mondragon & Wieland 2022) show remote work raised aggregate housing prices. This individual-level DR analysis asks: do *individual* remote workers pay less for housing than comparable non-remote workers? This is the first study to decompose the individual vs. aggregate effects.

**Data Source:** American Community Survey PUMS 2023 (N > 3 million working-age adults)

**Feasibility Check:**
- [x] Data accessible: Census API returns JWTRNS, GRPIP, OCPIP, and all covariates
- [x] Sample size: ~500,000 remote workers in 2023 ACS
- [x] Covariates: Occupation (SOCP), industry (INDP), education (SCHL), etc.
- [x] Novelty: No published DR study on remote work and housing burden

**Expected Findings:** Remote workers have lower housing cost burden (5-10pp) due to living in lower-cost areas, but effect is heterogeneous by income quintile (strongest for high earners who can capture full geographic arbitrage).

---

## Idea 2: Involuntary Part-Time Work and Healthcare Coverage

**Policy Context:** Approximately 4 million workers are involuntarily part-time (want full-time work but can't find it). The ACA's employer mandate threshold of 30 hours may have created incentives for some employers to limit hours, potentially affecting health insurance coverage.

**Research Question:** Do involuntary part-time workers face a health insurance coverage penalty compared to observationally similar voluntary part-time and full-time workers?

**Treatment:** Involuntary part-time status (working part-time for economic reasons)

**Outcome:** Health insurance coverage (any coverage, employer-sponsored, direct-purchase, Medicaid)

**Identification Strategy:** DR estimation comparing involuntary part-time workers to (a) voluntary part-time workers and (b) full-time workers with similar observable characteristics. Key confounders include occupation, industry, education, age, health status proxies, and state Medicaid expansion status.

**Why DR Over DiD/RDD:**
- Involuntary PT status is not randomly assigned or determined by policy threshold
- No quasi-experimental variation in involuntary PT incidence
- Rich covariates available in CPS and ACS

**Novel Angle:** Prior research shows associations between part-time work and worse health outcomes but doesn't distinguish voluntary vs. involuntary. By using DR to isolate the involuntary component, we can estimate the causal health insurance penalty of being unable to find full-time work.

**Data Source:** American Community Survey PUMS 2023 (N > 3 million) with WKW (weeks worked) and WKHP (hours per week)

**Feasibility Check:**
- [x] Data accessible: ACS PUMS via Census API
- [x] Treatment variable: Can identify part-time workers (WKHP < 35) but need to proxy "involuntary" status
- [ ] Challenge: ACS doesn't directly distinguish voluntary vs. involuntary PT—CPS does but less accessible
- [x] Covariates: Rich demographic and labor market controls

**Expected Findings:** Involuntary PT workers have 8-12pp lower employer-sponsored coverage than comparable FT workers, partially offset by higher Medicaid enrollment in expansion states.

**RISK:** May need to pivot to CPS data if ACS can't adequately identify involuntary PT status.

---

## Idea 3: Gig/Self-Employment and Retirement Account Access

**Policy Context:** Approximately 10% of workers are self-employed, including growing numbers of gig/platform workers. Unlike traditional employees, these workers lack automatic enrollment in employer retirement plans (401k/403b), potentially creating a retirement savings gap.

**Research Question:** Do self-employed workers have lower retirement account coverage than observationally similar wage workers, and how does this gap vary by income and access to state auto-IRA programs?

**Treatment:** Self-employment status (COW = self-employed in ACS)

**Outcome:** Retirement income/assets (limited in ACS; INTP includes interest income as proxy for savings)

**Identification Strategy:** DR estimation comparing self-employed to wage workers conditional on occupation, industry, education, age, income level, household composition, and state. ATT estimand to capture effect on the self-employed population.

**Why DR Over DiD/RDD:**
- Self-employment is a choice, not quasi-randomly assigned
- No policy discontinuity creates sharp variation
- State auto-IRA mandates apply to employers, not self-employed

**Novel Angle:** APEP-0076 studied self-employment and health insurance. This extends to retirement security, a complementary dimension of the self-employment benefits gap. We can also test whether state auto-IRA mandates (which apply only to W-2 workers) have widened the self-employment retirement gap.

**Data Source:** American Community Survey PUMS 2023

**Feasibility Check:**
- [x] Data accessible: COW identifies self-employed; RETINC provides retirement income
- [x] Sample size: ~350,000 self-employed workers in ACS
- [ ] Limitation: ACS doesn't directly measure retirement account ownership—only retirement income
- [x] Novelty: No published DR study on self-employment and retirement coverage

**Expected Findings:** Self-employed workers have 15-20pp lower retirement income receipt than comparable wage workers, with the gap largest in states with auto-IRA mandates (because these help wage workers but not self-employed).

**RISK:** ACS retirement income variables may be too noisy. May need Survey of Consumer Finances.

---

## Idea 4: Immigrant Self-Employment as Economic Integration Pathway

**Policy Context:** Immigrants are substantially more likely to be self-employed than native-born workers (~12% vs ~10%). Self-employment may represent either a pathway to economic integration (entrepreneurial success) or a necessity (labor market barriers).

**Research Question:** Does immigrant self-employment lead to better economic outcomes (income, poverty, homeownership) than immigrant wage employment, conditional on observables?

**Treatment:** Self-employment among immigrants

**Outcome:** Personal income (PINCP), poverty status (POVPIP), homeownership (TEN)

**Identification Strategy:** DR estimation comparing self-employed immigrants to wage-employed immigrants with similar characteristics: years in US, education, English proficiency, country of origin, occupation, state. ATT estimand.

**Why DR Over DiD/RDD:**
- No policy creates quasi-random variation in immigrant self-employment
- Selection into self-employment is endogenous
- Rich covariates available in ACS

**Novel Angle:** Most self-employment research focuses on the general population. By isolating immigrants, we can test whether self-employment serves as an integration pathway or reflects labor market exclusion. Heterogeneity by years in US and English proficiency will help distinguish these mechanisms.

**Data Source:** American Community Survey PUMS 2023 (foreign-born sample: N > 500,000)

**Feasibility Check:**
- [x] Data accessible: NATIVITY, YOEP (year of entry), ENG (English ability), COW
- [x] Sample size: ~50,000 self-employed immigrants
- [x] Covariates: Rich immigrant-specific controls
- [x] Novelty: Limited DR research on immigrant self-employment outcomes

**Expected Findings:** Self-employed immigrants have higher incomes than wage-employed immigrants with similar characteristics (+$5,000-10,000), but this premium varies by years in US (larger for longer-term residents, suggesting integration pathway rather than necessity).

---

## Idea 5: Union Membership and Non-Wage Compensation

**Policy Context:** Union membership has declined to ~10% of workers, but unions negotiate for benefits beyond wages—health insurance, retirement plans, paid leave. The "union wage premium" is well-studied, but the union benefit premium is less quantified.

**Research Question:** What is the causal effect of union membership on non-wage compensation (employer health insurance, retirement plans)?

**Treatment:** Union membership (in CPS; limited in ACS)

**Outcome:** Employer-sponsored health insurance, retirement plan coverage

**Identification Strategy:** DR estimation comparing union members to non-members conditional on occupation, industry, firm size, education, tenure, state right-to-work status.

**Why DR Over DiD/RDD:**
- Union membership is not randomly assigned
- No policy creates sharp discontinuity in membership
- Rich controls needed to address selection

**Novel Angle:** The union wage premium is estimated at 10-20%. What's the union *benefit* premium? This decomposition matters for understanding total compensation and for policy debates about labor market institutions.

**Data Source:** CPS MORG (monthly outgoing rotation groups) via IPUMS—has union membership, ESI, pension

**Feasibility Check:**
- [x] Data accessible: CPS MORG via IPUMS (requires IPUMS API key—we don't have)
- [ ] Challenge: ACS lacks union membership variable
- [x] Novelty: Limited recent DR estimates of union benefit premium

**Expected Findings:** Union members have 10-15pp higher employer health insurance coverage and 15-20pp higher retirement plan coverage than comparable non-union workers.

**RISK:** CPS requires IPUMS API key which we don't have. Would need to download microdata files directly.

---

## Recommendation: Pursue Idea 1 (Remote Work and Housing Cost Burden)

**Rationale:**
1. **Data accessibility:** All variables readily available via Census API
2. **Policy relevance:** Remote work is a defining labor market change of the 2020s
3. **Novelty:** Complements macro studies with individual-level causal estimates
4. **Method fit:** Perfect DR use case—observational treatment, rich covariates, no quasi-experimental variation
5. **Clear mechanisms:** Geographic arbitrage is testable with metro/non-metro variation
6. **Timely:** First DR study on this question

**Second choice:** Idea 4 (Immigrant Self-Employment) if housing data proves problematic—also has excellent data accessibility and clear policy relevance.

---

## DR Feasibility Assessment Summary

| Idea | Data Access | Treatment Clarity | Covariate Richness | Positivity | Recommendation |
|------|-------------|-------------------|-------------------|------------|----------------|
| 1. Remote Work & Housing | Excellent | Clear (JWTRNS) | Excellent | Good (15% treated) | **PURSUE** |
| 2. Involuntary PT & Insurance | Moderate | Proxy needed | Good | Good (~3% treated) | CONSIDER |
| 3. Self-Employment & Retirement | Limited | Clear | Good | Good (10% treated) | RISKY |
| 4. Immigrant Self-Employment | Excellent | Clear | Excellent | Good (12% treated) | **CONSIDER** |
| 5. Union & Benefits | Limited (need CPS) | Clear | Good | Good (10% treated) | SKIP |
