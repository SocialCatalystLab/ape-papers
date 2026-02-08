# Research Ideas

## Idea 1: Sports Betting Legalization and State Employment

**Policy:** State sports betting legalization following *Murphy v. NCAA* (2018)

The Supreme Court's May 2018 decision in *Murphy v. NCAA* struck down the Professional and Amateur Sports Protection Act (PASPA), allowing states to legalize sports betting. Since then, 38 states plus DC have legalized some form of sports betting with staggered adoption:
- 2018: Delaware, New Jersey, Mississippi, West Virginia, Pennsylvania, Rhode Island
- 2019: Arkansas, Indiana, Iowa, Montana, New Hampshire, New York (retail), Oregon, Tennessee
- 2020: Colorado, Illinois, Michigan, Virginia, Washington
- 2021: Arizona, Connecticut, Louisiana, Maryland, South Dakota, Wyoming
- 2022: Kansas, Ohio
- 2023: Kentucky, Maine, Massachusetts, Nebraska, North Carolina, Vermont
- 2024: Missouri

**Outcome:** Employment in leisure and hospitality sectors, gambling services industry employment (NAICS 7132), and broader local labor market outcomes using CPS/ACS data.

**Identification:** Difference-in-differences exploiting staggered state adoption. The 2018 Supreme Court decision provides a clean exogenous shock that initiated the adoption cascade. States that never legalized (e.g., Utah, Idaho, Alaska) serve as never-treated controls.

**Why it's novel:** Existing research on sports betting legalization focuses primarily on:
- Consumer finance impacts (Baker et al. 2024 NBER WP 33108 - household debt/spending)
- Mental health effects (Humphreys 2024 WVU working paper)
- Tax revenue and fiscal impacts
- Problem gambling prevalence

The **employment effects** have not been rigorously studied despite industry claims of 200,000+ jobs created. The American Gaming Association projects $11 billion in labor income, but these are projections, not causal estimates.

**Feasibility check:**
- Variation: 38 states over 6 years (2018-2024) with clear adoption dates
- Data: CPS/ACS have state × year × industry employment; QCEW provides establishment-level counts
- Clusters: 38+ treated states, 12 never-treated → sufficient for state-clustered SEs
- Pre-periods: 4+ years of pre-treatment data (2014-2018)
- Not overstudied: Google Scholar shows <10 papers on employment effects

**Potential concerns:**
- Heterogeneous implementation (retail vs. mobile vs. both)
- Endogenous timing (states may legalize during economic booms)
- Substitution from illegal betting markets (not creating new jobs, just formalizing)

---

## Idea 2: Domestic Violence Leave Laws and Women's Employment

**Policy:** State domestic violence leave laws requiring employers to provide protected leave for victims

25 states plus DC have enacted laws allowing victims of domestic violence (and sometimes stalking, sexual assault) to take protected leave to address safety-related needs. Adoption spans from 1999 to present:
- 1999-2005: Maine (1999), Illinois (2002), Colorado (2003), Hawaii (2004)
- 2006-2010: Florida (2007), Washington (2008), Kansas (2008), California (2009), Oregon (2010)
- 2011-2015: Massachusetts (2014), New Jersey (2013), Connecticut (2014)
- 2016-2020: Nevada (2017), North Carolina (2017), New Mexico (2019), Vermont (2019)
- 2021-2026: Arizona (2021), Rhode Island (2022), Michigan (2022), additional states through 2026

**Outcome:** Women's employment rates, labor force participation, and job tenure using CPS monthly data and ACS annual data.

**Identification:** Difference-in-differences with staggered state adoption over 25+ years. The long adoption window provides extensive pre-periods and variation.

**Why it's novel:** Research on domestic violence leave focuses on:
- DV victim outcomes (employment stability for victims specifically)
- Employer compliance and awareness
- Program utilization rates

The **aggregate labor market effects** on women's employment are unstudied. Theory predicts two possible effects:
1. *Positive:* Helps victims maintain employment → higher female LFP
2. *Negative:* Employers reduce hiring of women perceived as potential leave users (mandated benefit problem)

The net effect is an empirical question that hasn't been answered.

**Feasibility check:**
- Variation: 25 states over 25 years with documented adoption dates
- Data: CPS provides state × month × demographic employment; ACS for annual
- Clusters: 25 treated states, 25 never-treated → sufficient
- Pre-periods: Multiple pre-periods for each adoption cohort
- Not overstudied: No DiD papers on aggregate employment effects found

**Potential concerns:**
- Long adoption window may have confounders (other women's labor policies)
- Small affected population (DV victims) may limit detectable effect sizes
- Data on DV status not available (intention-to-treat analysis only)

---

## Idea 3: Pay Transparency Laws and Wage Compression

**Policy:** State laws requiring employers to disclose salary ranges in job postings

A recent wave of pay transparency laws requires employers to include salary ranges in job listings:
- 2021: Colorado (Jan 1)
- 2021: Connecticut (Oct 1 - upon request), Nevada (Oct 1)
- 2023: California (Jan 1), Washington (Jan 1), Rhode Island (Jan 1)
- 2024: Hawaii (Jan 1), Illinois (Jan 1), Minnesota (Jan 1), DC (June 30)
- 2025: New Jersey, Vermont, Massachusetts

**Outcome:** Wage distributions, gender pay gaps, and starting wages using CPS Outgoing Rotation Groups (MORG) and ACS wages.

**Identification:** Difference-in-differences with staggered state adoption. Colorado serves as an early mover with 2+ years of post-treatment data.

**Why it's novel:** Research on pay transparency is nascent:
- Limited study of Colorado's law found higher labor force participation
- Theoretical predictions are ambiguous (could raise or compress wages)
- No rigorous multi-state DiD study of wage effects exists

**Feasibility check:**
- Variation: 10+ states with adoption dates spanning 2021-2025
- Data: CPS MORG provides hourly/weekly wages; ACS provides annual wages
- Clusters: Limited (10-15 states) - may require alternative inference
- Pre-periods: Colorado has 2+ pre-periods; others have 3+
- Novel: Very limited academic research exists

**Potential concerns:**
- Recent adoption limits post-treatment data
- Few treated states limits statistical power
- Compliance and enforcement varies (some laws have weak penalties)
- Spillover effects from remote work (firms may apply policies nationally)

---

## Idea 4: State Clean Slate Laws and Employment by Demographic Group

**Policy:** Automatic criminal record expungement ("clean slate") laws

12 states have enacted automatic expungement of certain criminal records:
- 2018-2019: Pennsylvania (2018), Utah (2019), California (2019)
- 2020-2021: New Jersey (2020), Michigan (2021), Connecticut (2021)
- 2022-2023: Delaware (2022), Minnesota (2022), Oklahoma (2022), Colorado (2022)
- 2024: New York (2024), Virginia (2024)

**Outcome:** Employment rates by demographic group (particularly young Black men who are disproportionately affected by criminal records) using CPS.

**Identification:** Difference-in-differences comparing employment trends in adopting vs. non-adopting states.

**Why it's less promising:** Onal (2022 SSRN) already studies this using DiD and finds **negative effects** on Black employment - consistent with statistical discrimination theory. When employers can't observe records, they may avoid hiring groups perceived as high-risk.

**Feasibility check:**
- Variation: 12 states with staggered adoption
- Data: CPS employment by race × state × year
- Clusters: 12 treated states - borderline
- Pre-periods: Available
- **Already studied:** Onal (2022) found 3.99pp decrease in Black employment

**Recommendation:** SKIP - already studied with same method and design.

---

## Recommendation

**Pursue:** Idea 1 (Sports Betting Legalization and Employment)
- Most novel contribution
- Best variation (38 states, 6 years)
- Clean natural experiment (Murphy v. NCAA)
- Sufficient power with state clusters
- Policy-relevant given ongoing legalization debates

**Consider:** Idea 2 (Domestic Violence Leave Laws)
- Novel but effect sizes may be small
- Good variation but very long adoption window

**Skip:** Idea 3 (Pay Transparency) - too few states, too recent
**Skip:** Idea 4 (Clean Slate) - already studied
