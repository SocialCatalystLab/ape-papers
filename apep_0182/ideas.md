# Research Ideas

## Idea 1: The MVPF of Unconditional Cash Transfers in a Developing Country: Evidence from Kenya's GiveDirectly Program

**Policy:** GiveDirectly's unconditional cash transfer program in rural Kenya (2011-2018), providing one-time transfers of $1,000 USD to poor households via M-Pesa mobile money.

**Outcome:** Household-level earnings, consumption, assets, employment; aggregate fiscal multiplier effects.

**Identification:** Randomized controlled trial with village-level and household-level randomization. Published in Econometrica (Egger et al. 2022) and QJE (Haushofer & Shapiro 2016). Treatment = receipt of unconditional cash transfer. Control = no transfer.

**Why it's novel:**
1. **First MVPF calculation for a developing country UCT program.** The entire Hendren-Sprung-Keyser MVPF library (208 policies) is almost exclusively US-focused. This extends the framework to a fundamentally different context.
2. **Incorporates general equilibrium effects.** The Egger et al. study uniquely estimates a fiscal multiplier of 2.5-2.7, capturing spillovers to non-recipients—something no prior MVPF study has done.
3. **Policy-relevant for global development.** UCTs are now used in 50+ countries; knowing their MVPF helps allocate scarce development resources.
4. **Conceptually interesting:** Though GiveDirectly funded the program, we answer the counterfactual: "If the Kenyan government funded this, what would the MVPF be?"

**MVPF Calculation Approach:**
- **Numerator (WTP):** Consumption gains = $293 PPP increase (12% of baseline) × 1.5 years persistence = ~$440 PPP. Asset gains = $174 PPP (24% increase). Total direct WTP ≈ $614 PPP per recipient.
- **Spillover WTP:** Non-recipients gained 13% consumption increase; with fiscal multiplier of 2.5, total WTP including GE effects could be 2.5× direct WTP.
- **Denominator (Net Cost):** $1,000 transfer - fiscal externalities.
- **Fiscal externalities:** Earnings gains × marginal tax rate. Kenya's effective tax rate is ~18.5% in formal sector, but rural informal sector faces ~0% income tax. Main fiscal channel: increased VAT (16%) on consumption gains + reduced future transfer dependency.

**Feasibility check:**
- **Variation exists:** RCT design with clear identification (CONFIRMED)
- **Data accessible:** Replication data publicly available on Harvard Dataverse (doi:10.7910/DVN/M2GAZN) and Econometrica supplementary materials (CONFIRMED)
- **Not overstudied:** No MVPF calculation exists for GiveDirectly or any developing country UCT (CONFIRMED via search)
- **Sample size:** 10,500 treated households + controls, 653 villages (CONFIRMED)

---

## Idea 2: The MVPF of Finland's Universal Basic Income Experiment

**Policy:** Finland's 2017-2018 Universal Basic Income experiment providing €560/month unconditionally to 2,000 unemployed persons randomly selected from unemployment benefit recipients.

**Outcome:** Employment, earnings, wellbeing, government expenditure savings.

**Identification:** RCT—random selection among unemployment benefit recipients aged 25-58.

**Why it's novel:**
1. First MVPF for a UBI program in a developed country
2. Rich Nordic register data enables precise fiscal externality calculation
3. Policy-relevant for UBI debates worldwide

**MVPF Calculation Approach:**
- **Numerator (WTP):** €560×24 months = €13,440 direct transfer + wellbeing gains (life satisfaction, reduced stress)
- **Denominator (Net Cost):** €13,440 - fiscal externalities from employment gains
- **Fiscal externalities:** Finland's marginal tax rate (~45% for average earner) × employment/earnings changes (6 additional days employed)

**Feasibility check:**
- **Variation exists:** RCT design (CONFIRMED)
- **Data accessible:** Results published by Finnish government, but individual-level register data requires institutional access through Statistics Finland (PARTIAL - REQUIRES INSTITUTIONAL ACCESS)
- **Not overstudied:** No published MVPF for Finland UBI (CONFIRMED)
- **Sample size:** 2,000 treatment + control (SMALLER THAN IDEAL)

**CONCERN:** Register data access requires Finnish institutional affiliation. Employment effects were small and imprecisely estimated.

---

## Idea 3: The MVPF of Denmark's "Start Aid" Refugee Integration Policy

**Policy:** Denmark's "Start Aid" policy (July 2002) cut welfare transfers to newly-arrived refugees by ~40%, from ~DKK 10,000 to ~DKK 6,000/month.

**Outcome:** Employment, earnings, welfare receipt, children's long-run outcomes.

**Identification:** Sharp regression discontinuity at the policy implementation date—refugees granted residency just before vs. just after July 2002 are otherwise identical.

**Why it's novel:**
1. First MVPF for refugee integration policy
2. Unique identification: policy cut creates clean RD variation
3. Long-run follow-up data on children's outcomes (education, crime, employment)

**MVPF Calculation Approach:**
- **Numerator (WTP):** Negative (welfare cut). But policy intended to promote self-sufficiency.
- **Denominator (Net Cost):** Government savings from 40% transfer cut - costs from adverse child outcomes
- **Fiscal externalities:** Short-run employment doubled, but long-run showed adverse effects on children (education, crime). Children's reduced lifetime earnings reduce future tax revenue.

**Feasibility check:**
- **Variation exists:** Clean RD at policy cutoff (CONFIRMED per Andersen et al.)
- **Data accessible:** Danish register data requires institutional access (REQUIRES INSTITUTIONAL ACCESS)
- **Not overstudied:** No published MVPF (CONFIRMED)
- **Sample size:** All refugees pre/post July 2002 (ADEQUATE)

**CONCERN:** Register data access requires Danish institutional affiliation. MVPF may be negative (costs exceed benefits) due to adverse child effects.

---

## Idea 4: The MVPF of Nurse-Family Partnership in the United States

**Policy:** Nurse-Family Partnership (NFP) providing nurse home visits to low-income first-time mothers from pregnancy through child's age 2, costing ~$11,000-$15,000 per family.

**Outcome:** Maternal employment/earnings, child health, educational attainment, crime reduction.

**Identification:** Multiple RCTs in Elmira NY (1977), Memphis TN (1990), Denver CO (1994) with long-run follow-up (15+ years).

**Why it's novel:**
1. NFP is NOT in the Policy Impacts MVPF library (confirmed via search)
2. Exceptionally long-term outcome data available (children tracked into adulthood)
3. Rich fiscal externality data: government savings from reduced Medicaid, TANF, food stamps, criminal justice

**MVPF Calculation Approach:**
- **Numerator (WTP):** Maternal earnings increase (exceeded program cost per sensitivity analysis) + children's lifetime earnings gains + wellbeing improvements
- **Denominator (Net Cost):** ~$12,000 program cost - fiscal externalities
- **Fiscal externalities:** 8.5% reduction in child Medicaid spending (birth-18), 5.6% reduction in TANF (12 years), 9.6% reduction in food stamps (12 years), reduced criminal justice costs

**Feasibility check:**
- **Variation exists:** Multiple RCTs (CONFIRMED)
- **Data accessible:** Original study data access may be restricted. Published effect estimates available. (PARTIAL)
- **Not in MVPF library:** CONFIRMED (no results on policyimpacts.org)
- **Sample size:** Elmira: 400; Memphis: 1,139; Denver: 735 (ADEQUATE)

**CONCERN:** Original microdata access uncertain. But published estimates may suffice for MVPF calculation.

---

## Ranking Summary

| Idea | Novelty | Identification | Data Access | Sample Size | Recommendation |
|------|---------|----------------|-------------|-------------|----------------|
| 1. Kenya UCT | Very High | RCT (Gold Standard) | **PUBLIC** | 10,500+ | **PURSUE** |
| 2. Finland UBI | High | RCT | Restricted | 2,000 | SKIP (access) |
| 3. Denmark Refugees | High | RD | Restricted | Adequate | SKIP (access) |
| 4. NFP USA | High | RCT | Partial | ~2,000 | CONSIDER |

**Primary recommendation: IDEA 1 (Kenya GiveDirectly UCT)**

This represents the sweet spot:
- Methodologically rigorous (RCT with GE effects published in Econometrica)
- Data publicly available (Harvard Dataverse)
- Conceptually novel (first developing country MVPF)
- Policy-relevant (UCTs now global)
- Can calculate MVPF using published effect estimates + Kenya fiscal data
