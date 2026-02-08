# Research Ideas

## Idea 1: Cross-Border Minimum Wage Spillovers: Did Germany's 2015 Minimum Wage Affect Polish Labor Markets?

**Policy:** Germany's introduction of a national statutory minimum wage (€8.50/hour) on January 1, 2015 - the first national minimum wage in German history. The policy applied to ALL workers on German territory, including posted workers and cross-border commuters.

**Outcome:** Labor market outcomes (wages, employment, unemployment) in Polish NUTS2/NUTS3 regions, comparing border regions adjacent to Germany vs. interior regions far from the German border.

**Identification:** Spatial Difference-in-Differences / Synthetic Control
- **Treated units:** Polish voivodeships (NUTS2) or powiats (NUTS3) bordering Germany (Zachodniopomorskie, Lubuskie, Dolnośląskie)
- **Control units:** Polish regions in the interior, far from Germany
- **Event date:** January 1, 2015
- **Pre-treatment period:** 2010-2014
- **Post-treatment period:** 2015-2020 (before COVID)

**Why it's novel:**
The literature on Germany's 2015 minimum wage focuses almost entirely on WITHIN-Germany effects (regional wage convergence, employment effects, inequality reduction). The cross-border spillover effects are mentioned in policy debates (Poland, Czech Republic objected to Germany applying the minimum wage to posted workers) but have not been rigorously evaluated.

The 2015 controversy focused on truck drivers passing through Germany, but the broader labor market implications for Polish border regions - where workers can easily commute to Germany for higher wages - remain unstudied.

**Mechanisms (testable):**
1. **Commuter wage premium:** Polish workers commuting to Germany see wage increases → returns to cross-border commuting rise
2. **Polish labor tightness:** Workers who previously earned below €8.50 in Germany now earn more → incentive to commute increases → Polish border regions experience labor shortages → Polish wages rise
3. **Migration response:** Higher German wages → permanent migration increases → Polish border region population declines
4. **Trade competition:** German firms face higher labor costs → Polish exporters in border regions become more competitive → employment shifts to Poland

**Feasibility check:**
- ✅ Clean treatment date: January 1, 2015
- ✅ Large wage shock: About 11% of German workers were below €8.50; border regions had higher share
- ✅ Geographic variation: Clear border vs. interior regions in Poland
- ✅ Data: Eurostat EU-LFS has NUTS2 regional labor market data; some NUTS3 available for border typologies
- ✅ Pre-treatment parallel trends testable: 5 years of pre-data (2010-2014)
- ✅ Not overstudied: Google Scholar shows minimal research on this specific cross-border angle

**Data sources:**
- Eurostat Regional Statistics (reg_lmk): Employment, unemployment by NUTS2 region
- EU Labour Force Survey microdata: Individual-level employment and wage data by region
- Eurostat border regions database: NUTS3 border region typologies

---

## Idea 2: Policy Learning vs. Policy Mimicry: Do Countries Adopt Minimum Wage Increases After Observing Neighbor Success or Failure?

**Policy:** Minimum wage changes across EU member states, 2000-2023. The EU has 21 countries with statutory minimum wages that are adjusted periodically. The timing and magnitude of changes varies substantially across countries.

**Outcome:** Probability that country i increases minimum wage in year t, conditional on:
- Whether a neighboring country j increased minimum wage in year t-1 or t-2
- Whether country j experienced employment decline or increase after their minimum wage increase

**Identification:** Panel DiD / Event Study
- **Unit of analysis:** EU country-year
- **Treatment:** Neighbor country implemented minimum wage increase in recent years
- **Moderator:** Observed employment outcome in neighbor country after increase (success vs. failure)

**Why it's novel:**
The policy diffusion literature documents that policies spread across countries, but the mechanism is contested:
- **Learning:** Countries adopt policies that worked elsewhere
- **Mimicry:** Countries copy neighbors regardless of outcomes (political legitimacy, ideological similarity)
- **Counter-learning:** Countries learn from failures - either avoiding failed policies OR rushing to "do it right"

No study has explicitly tested whether OBSERVING EMPLOYMENT EFFECTS in a neighbor changes adoption probability differently than just observing adoption.

**The key test:**
If P(adopt | neighbor adopted AND employment fell) > P(adopt | neighbor adopted AND employment rose):
→ Countries are NOT learning from evidence; they're mimicking or counter-learning

If P(adopt | neighbor adopted AND employment fell) < P(adopt | neighbor adopted AND employment rose):
→ Rational learning from evidence

**Mechanisms:**
1. Pure diffusion: Adoption probability increases regardless of observed outcomes
2. Evidence-based learning: Adoption probability increases only after observed success
3. Political cover: Adoption probability increases after observed FAILURE (blame deflection)
4. Ideological contagion: Adoption probability depends on neighbor's political alignment

**Feasibility check:**
- ✅ Variation: 21 EU countries × 23 years = ~483 country-years; 100+ minimum wage changes
- ✅ Observable outcomes: Eurostat employment rates published quickly after wage changes
- ✅ Geographic neighbors: Well-defined (shared borders, economic integration)
- ✅ Data: OECD/Eurostat minimum wage database + employment rates
- ⚠️ Endogeneity concern: Minimum wage changes may be correlated with business cycle → need to control for economic conditions

**Data sources:**
- OECD Minimum Wage Database: Monthly minimum wage levels by country
- Eurostat Employment Statistics: Quarterly employment rates by country
- EU neighborhood structure: Geographic adjacency matrix

---

## Idea 3: The Announcement Effect: Did EU's 2035 ICE Vehicle Ban Change Behavior Before Implementation?

**Policy:** The EU's 2022 announcement (finalized March 2023) that new internal combustion engine (ICE) vehicle sales would be banned from 2035 as part of the European Green Deal. Note: This policy was subsequently REVERSED in December 2025.

**Outcome:** Electric vehicle (EV) adoption rates, auto industry investment, and employment in auto manufacturing across EU countries from 2019-2024.

**Identification:** Difference-in-Differences with continuous treatment intensity
- **Treatment intensity:** Share of domestic auto industry devoted to ICE manufacturing (varies by country)
- **Event:** June 2022 EU Parliament vote (announcement shock)
- **Treated:** Countries with large ICE manufacturing (Germany, Italy, France, Spain, Czech Republic)
- **Control:** Countries with minimal auto manufacturing (Denmark, Portugal, Ireland, Greece)

**Why it's novel:**
Most policy evaluation studies the effect of policy IMPLEMENTATION. But major policies often have large ANNOUNCEMENT effects - rational agents change behavior in anticipation. The 2035 ICE ban is a perfect test case because:
- Clear announcement date (June 2022)
- Implementation date 13 years away (2035)
- Heterogeneous country exposure based on auto industry composition
- Clean outcome data (vehicle sales are precisely measured)

The December 2025 REVERSAL adds another event: did the policy reversal announcement UNDO the behavioral changes?

**Mechanisms:**
1. **Consumer anticipation:** Households accelerate EV purchases expecting future value retention → EV sales spike after announcement
2. **Panic buying:** Households buy ICE vehicles while they can → ICE sales spike after announcement (opposite prediction!)
3. **Investment reallocation:** Auto manufacturers shift investment from ICE to EV R&D
4. **Labor reallocation:** Workers in ICE manufacturing invest in EV-relevant skills

**Feasibility check:**
- ✅ Clean event: June 8, 2022 EU Parliament vote
- ✅ Heterogeneous exposure: Auto manufacturing share varies from 0% to 15%+ of GDP
- ✅ Outcome data: ACEA European Automobile Manufacturers Association publishes monthly vehicle registrations by powertrain
- ✅ Country-level variation: 27 EU countries
- ⚠️ Confounds: EV subsidies, charging infrastructure, fuel prices all vary by country-time

**Data sources:**
- ACEA Vehicle Sales Statistics: Monthly new car registrations by fuel type and country
- Eurostat Structural Business Statistics: Auto industry employment and output by country
- OECD Trade Data: Auto parts imports/exports

---

## Idea 4: "The Thermostatic Employer": Does Mandating Paternity Leave Increase or Decrease Voluntary Family-Friendly Practices?

**Policy:** Spain's 2019-2021 progressive expansion of mandatory paternity leave from 5 weeks (2017) to 16 weeks (2021, equal to maternity leave). This was the most dramatic paternity leave expansion ever implemented - no other country has mandated full parity.

**Outcome:** Employer provision of VOLUNTARY family-friendly benefits (flexible hours, remote work, childcare subsidies) measured through labor force surveys.

**Identification:** Synthetic Control Method
- **Treated:** Spain
- **Donor pool:** Other EU countries that did NOT expand paternity leave similarly (France, Italy, Germany, UK)
- **Event:** Staggered reforms: 8 weeks (April 2019), 12 weeks (January 2020), 16 weeks (January 2021)
- **Outcomes:** Share of workers reporting access to flexible hours, telework, other voluntary benefits

**Why it's novel:**
The literature on paternity leave focuses on whether men TAKE the leave and whether it affects wages/employment. But there's a second-order effect that's completely unstudied:

**Crowding out hypothesis:** When governments mandate generous benefits, do employers REDUCE voluntary provision of other benefits? ("We already comply with the law, no need to do more")

**Crowding in hypothesis:** When governments signal that family-friendliness matters, do employers INCREASE voluntary benefits? ("It's now socially expected")

This is the "thermostatic employer" question - analogous to thermostatic voting where citizens reduce demand after policy is implemented.

**Mechanisms:**
1. **Compliance substitution:** Employers who previously offered 2 weeks voluntary paternity leave now offer nothing additional on top of mandated 16 weeks
2. **Signaling reinforcement:** Employers who want to attract talent must now go BEYOND the law to differentiate
3. **Budget reallocation:** Employers reallocate HR budget from paternity coverage to other benefits
4. **Norm shift:** Mandatory leave changes expectations → employees demand more → employers comply

**Feasibility check:**
- ✅ Clean treated unit: Spain's reform was uniquely dramatic
- ✅ Staggered treatment: 3 distinct increases over 2 years (useful for event study within-Spain)
- ✅ Outcome data: EU Labour Force Survey and European Working Conditions Survey include questions about voluntary benefits
- ⚠️ Synthetic control challenge: Need to construct plausible Spain counterfactual from donor countries
- ⚠️ COVID confound: Remote work increased everywhere 2020-2021 due to pandemic, not policy

**Data sources:**
- European Working Conditions Survey (Eurofound): Survey of working conditions including benefits
- EU Labour Force Survey ad hoc module on work-life balance: Periodic modules on family-friendly practices
- Eurostat Quality of Employment indicators

---

## Ranking Summary

| Idea | Novelty | Identification | Data Feasibility | Mechanism Clarity | Overall |
|------|---------|----------------|------------------|-------------------|---------|
| 1. Germany → Poland spillover | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **#1** |
| 2. Policy learning vs mimicry | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | #2 |
| 3. ICE ban announcement | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | #3 |
| 4. Thermostatic employer | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | #4 |

**Recommendation:** Proceed with **Idea 1 (Germany → Poland minimum wage spillover)** because:
1. Truly novel - this specific angle appears unstudied despite the controversy in 2015
2. Clean identification - January 1, 2015 is a sharp event; border vs. interior is clean geographic variation
3. Data is available from Eurostat at NUTS2 (definitely) and NUTS3 (likely) levels
4. Multiple testable mechanisms with clear predictions
5. Counter-intuitive angle: most minimum wage research focuses on within-country effects; this studies the "losers" of minimum wage policy (workers in neighboring countries who now face stronger competition)
