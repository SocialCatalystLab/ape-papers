# Research Ideas: RDD + Time Use

Generated for states: California, Nebraska, Washington
User preference: Maximum novelty, "WOW factor" - time use outcomes with RDD

---

## Idea 1: The 59.5 Unlock - Do Retirement Accounts Actually Free Workers?

**Policy:** Federal tax penalty exemption for retirement account withdrawals at age 59.5. Before this age, withdrawing from 401(k)/IRA incurs a 10% penalty. At exactly 59.5, this penalty disappears - creating one of the sharpest federal discontinuities in financial incentives.

**Method:** RDD

**Research Question:** Does gaining penalty-free access to retirement savings at age 59.5 cause workers to reduce their work hours?

**Data:**
- Source: Census PUMS 2015-2023 (pooled for power)
- Key variables: AGEP (age, running variable), WKHP (usual hours worked/week), ESR (employment status), WKWN (weeks worked), PINCP (income), WAGP (wages), PWGTP (person weight)
- Sample: Ages 57-62, employed or recently employed, with positive retirement income (RETP) or investment income proxy
- Sample size estimate: ~500,000+ person-year observations

**Hypotheses:**
- Primary: Hours worked will decline discontinuously at age 59.5 as workers gain access to retirement savings
- Mechanism: Liquidity constraint release - workers who were "locked in" by penalty can now afford to cut hours
- Heterogeneity: Effect strongest for those with higher retirement account balances (proxied by high prior income), those without employer pension, and those in physically demanding occupations

**Novelty:**
- Literature search: Found NO RDD papers specifically on the 59.5 threshold. The Rule of 55 (separation from employer) gets some attention, but 59.5 is virtually unstudied.
- Gap: Complete absence of causal evidence on whether retirement account access actually changes labor supply
- Contribution: First RDD estimate of the retirement account liquidity effect on hours worked

**Why this could be "Holy Shit" material:** The 59.5 threshold is PERFECTLY SHARP (federal law, no fuzziness) and affects tens of millions of Americans with retirement accounts, yet has essentially zero causal research. If we find a significant hours reduction, it challenges the assumption that retirement savings just sit unused until 65+.

---

## Idea 2: When Grandparents Retire, Do Their Kids Work More?

**Policy:** Social Security early claiming eligibility at age 62 combined with grandparent childcare provision

**Method:** RDD

**Research Question:** When older adults reach Social Security eligibility at 62 and reduce their work hours, do their adult children (ages 25-45) increase their work hours due to newly available grandparent childcare?

**Data:**
- Source: Census PUMS 2015-2023
- Key variables for grandparents: AGEP (running variable), WKHP, ESR, SSIP (Social Security income)
- Key variables for potential parents: AGEP, WKHP, HUPARC/PARC (children in household), PWGTP
- Sample: Grandparent sample (ages 60-64), parent sample proxied by adults 25-45 with children in states with high co-residence rates
- Sample size estimate: ~300,000+ grandparent observations; spillover analysis more complex

**Hypotheses:**
- Primary: At age 62, grandparents reduce work hours; this enables adult children to increase their work hours by outsourcing childcare to newly-available grandparents
- Mechanism: Intergenerational time transfer - grandparents trade labor market time for family care time, freeing parents
- Heterogeneity: Effect strongest for families with young children (ages 0-5), in high childcare cost areas (CA), and for women

**Novelty:**
- Literature search: Spousal spillovers at 65 Medicare studied (Witman 2015 found insurance but not labor effects). Intergenerational spillovers at 62 are essentially UNSTUDIED.
- Gap: No RDD evidence on whether grandparent retirement causes labor supply changes for the next generation
- Contribution: First causal estimate of intergenerational time use spillovers from Social Security eligibility

**Why this could be "Holy Shit" material:** If grandparent retirement INCREASES labor supply for the sandwich generation, Social Security's net labor supply effect is more complex than assumed. This challenges standard models that only consider the retiring individual.

---

## Idea 3: Medicare at 65 and the Health Time Tax

**Policy:** Medicare eligibility at age 65 and its effect on time spent on healthcare-related activities

**Method:** RDD

**Research Question:** Does Medicare eligibility at 65 cause workers to spend MORE time on healthcare, thereby REDUCING work hours - not because they want to retire, but because they finally have time and coverage to address neglected health issues?

**Data:**
- Source: Census PUMS 2015-2023 (primary); American Time Use Survey as supplementary validation
- Key variables: AGEP (running variable), WKHP, WKWN, HINS3 (Medicare coverage), DIS (disability status), PWGTP
- Sample: Ages 63-67, employed or recently employed
- Sample size estimate: ~400,000+ person-year observations

**Hypotheses:**
- Primary: Work hours decline at 65 partly due to increased time spent on healthcare utilization (the "health time tax")
- Mechanism: Pre-65, workers defer healthcare due to cost/access barriers. Post-65, Medicare coverage enables catch-up care, which requires TIME away from work.
- Heterogeneity: Effect strongest for those previously uninsured (HICOV=2 before 65), those with chronic conditions, lower-income workers

**Novelty:**
- Literature search: Medicare at 65 extensively studied for insurance take-up and direct labor supply. But the MECHANISM of time reallocation (specifically time absorbed by healthcare) is understudied.
- Gap: Existing research treats retirement as voluntary leisure choice; this reframes some of it as involuntary "health time tax"
- Contribution: Decompose the Medicare labor supply effect into voluntary retirement vs. healthcare time absorption

**Why this could be "Holy Shit" material:** If a meaningful fraction of the work hour reduction at 65 is due to healthcare catch-up rather than leisure preference, it reframes the Medicare retirement literature and has policy implications for pre-65 coverage.

---

## Idea 4: The Age 21 Double-Whammy in Legal Cannabis States

**Policy:** At age 21, individuals in states with legal recreational cannabis gain legal access to BOTH alcohol AND cannabis simultaneously. This creates a unique "double liberalization" that could affect time use in unexpected ways.

**Method:** RDD (with state variation for heterogeneity)

**Research Question:** Does the combined legal access to alcohol AND cannabis at age 21 affect work hours differently in states where both are legal vs. states where only alcohol is legal?

**Data:**
- Source: Census PUMS 2018-2023 (post-legalization period for CA, WA)
- Key variables: AGEP (running variable), WKHP, ESR, ST (state), PWGTP
- Sample: Ages 19-23 in CA and WA (both legal) vs. Nebraska (alcohol only)
- Sample size estimate: ~200,000+ in legal states, ~30,000 in Nebraska

**Hypotheses:**
- Primary: The work hour reduction at 21 is LARGER in dual-legal states (CA, WA) than in alcohol-only states (NE)
- Mechanism: Cannabis + alcohol together may have synergistic effects on time allocation (more leisure time demanded, potential substitution from work)
- Heterogeneity: Effect may be concentrated among certain demographics; may differ by industry

**Novelty:**
- Literature search: MLDA at 21 and labor supply studied (Yoruk 2015 found ~1 hour reduction). Cannabis at 21 barely studied. The INTERACTION of both being legal is unstudied.
- Gap: No research examining whether simultaneous legalization creates compounded effects
- Contribution: First estimate of the "double-liberalization" effect on young adult time use

**Why this could be "Holy Shit" material:** California and Washington are perfect natural experiments - large states with legal cannabis. If we find the work hour dip at 21 is significantly LARGER in these states, it suggests cannabis legalization has real time-use consequences.

---

## Idea 5: The ACA Age 26 "Push" into Full-Time Work

**Policy:** ACA dependent coverage ends at age 26, forcing young adults off parental insurance and into the labor market for employer-sponsored coverage

**Method:** RDD

**Research Question:** At age 26, do young adults increase their work hours to gain employer-sponsored health insurance, or do they decrease hours and go uninsured?

**Data:**
- Source: Census PUMS 2012-2023 (post-ACA implementation)
- Key variables: AGEP (running variable), WKHP, ESR, HINS1 (employer insurance), HICOV (any coverage), PWGTP
- Sample: Ages 24-28, unmarried (those most likely on parental coverage)
- Sample size estimate: ~300,000+ observations

**Hypotheses:**
- Primary: At age 26, hours worked will INCREASE as workers seek employer coverage, OR decrease if workers "give up" and accept being uninsured
- Mechanism: The "push" effect - losing parent's insurance creates demand for employer coverage, which typically requires full-time hours (30+)
- Heterogeneity: Effect depends on local labor market conditions, prior insurance status, health status

**Novelty:**
- Literature search: ACA age 26 cutoff well studied (Eastern Economic Journal 2019, PMC 2015). Most focus on INSURANCE outcomes; HOURS WORKED is secondary.
- Gap: Existing RDD finds employment effects but the HOURS response is less examined
- Contribution: Clean RDD estimate of work hours response to insurance loss, with mechanism decomposition

**Why this could be "Holy Shit" material:** The direction of the effect is genuinely uncertain. Some people may work MORE (to get coverage), others LESS (giving up and going uninsured). Net effect could be surprising.

---

## Exploration Notes

**Searches conducted:**
- Medicare 65 + spousal spillover + labor supply (found Witman 2015)
- Age 59.5 + retirement account + labor supply (found financial advice, no academic RDD)
- MLDA 21 + labor supply (found Yoruk 2015)
- Social Security 62 + grandchild caregiving (found descriptive work, no RDD)
- Cannabis 21 + labor supply (found NBER working paper on employment, not hours)
- ACA 26 + hours worked (found some research, gap in hours focus)
- Commute time + retirement (descriptive only)
- American Time Use Survey + RDD (found one work-from-home paper)

**Rejected ideas:**
- Medicare 65 direct effects: Too exhaustively studied
- MLDA 21 alone: Already studied by Yoruk
- Senior transit discounts: Not sharp enough threshold, varies by system
- Driving age 16: Would need teen-specific data, PUMS age structure not ideal

**Why these 5 rose to the top:**
1. **59.5** - Genuinely novel, sharp federal threshold, large affected population
2. **Grandparent spillover** - Creative intergenerational angle, policy-relevant
3. **Health time tax** - Novel mechanism/framing for well-studied transition
4. **Cannabis double-whammy** - Perfect state comparison (CA/WA vs NE)
5. **ACA 26 hours** - Fills specific gap in existing literature

Recommendation: **Idea 1 (59.5) or Idea 2 (Grandparent spillover)** for maximum novelty and WOW potential. Idea 1 has the advantage of simplicity; Idea 2 has the advantage of a more surprising mechanism.
