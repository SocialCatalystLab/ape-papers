# Research Ideas: Paper 29

Generated for states: Montana, Hawaii, Maryland
Method: Difference-in-Differences (DiD)
Date: January 2026

---

## Idea 1: Montana HELP-Link Workforce Program and Labor Force Participation

**Policy:** Montana's Medicaid expansion (HELP Act, 2015) included a unique workforce development component called HELP-Link, administered by the Department of Labor & Industry starting in 2016. Unlike other Medicaid expansion states, Montana explicitly integrated career planning, job training, and employment services into its Medicaid program. This creates a natural experiment comparing Montana to other Medicaid expansion states that adopted coverage-only models.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Montana's combined Medicaid expansion + workforce program (HELP-Link) produce larger employment gains than Medicaid expansion alone in comparable states?

**Data:**
- Source: Census PUMS 2013-2020 (1-year samples)
- Treatment: Montana (expansion + workforce program, effective 2016)
- Control states: Other Mountain West Medicaid expansion states without integrated workforce programs (Colorado 2014, Nevada 2014, New Mexico 2014)
- Key variables: ESR (employment status), WKHP (hours worked), WAGP (wages), HICOV/HINS4 (insurance coverage), PINCP (income), AGEP (age), ST (state), PWGTP (weight)
- Sample: Adults 19-64 with income <138% FPL (Medicaid eligible population)
- Sample size estimate: ~50,000-80,000 per state over the study period

**Hypotheses:**
- Primary: Montana experienced 3-6 percentage point larger employment gains than control expansion states for the Medicaid-eligible population
- Mechanism: HELP-Link's individualized career planning and job training accelerated employment transitions that health coverage alone cannot produce
- Heterogeneity: Effects strongest for (1) prime-age adults 25-54, (2) those with prior work history, (3) non-disabled adults

**Novelty:**
- Literature search: Bureau of Business and Economic Research at U of Montana reported descriptive gains (6-9pp LFP increase). No rigorous DiD comparing Montana's integrated model to coverage-only states.
- Gap: Existing Medicaid expansion literature focuses on coverage effects; workforce integration is unstudied
- Contribution: First causal estimate of whether bundling workforce programs with Medicaid expansion enhances employment outcomes

**Why This Could Work:** Clear timing (2016), distinct policy bundle (workforce + coverage vs. coverage-only), comparable control states in Mountain West, relevant variables all in PUMS.

---

## Idea 2: Maryland Healthy Working Families Act (2018) and Employment Stability

**Policy:** The Maryland Healthy Working Families Act took effect February 11, 2018, requiring employers with 15+ employees to provide paid sick leave (1 hour per 30 hours worked, up to 40 hours/year). Smaller employers must provide unpaid leave. Maryland was the 9th state to pass such a law, providing policy variation for DiD against neighboring states without mandates.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Maryland's paid sick leave mandate increase employment stability and reduce job separations for low-wage workers?

**Data:**
- Source: Census PUMS 2015-2021 (1-year samples)
- Treatment: Maryland (effective Feb 2018)
- Control states: Pennsylvania and Virginia (no paid sick leave mandates during period)
- Key variables: ESR (employment status), WKW (weeks worked last year), WKHP (hours per week), WAGP (wages), OCCP (occupation), COW (class of worker), AGEP (age), ST (state), PWGTP (weight)
- Sample: Workers 18-64 in service sector occupations (retail, food service, healthcare support) most affected by sick leave policies
- Sample size estimate: ~150,000 service workers per state-year

**Hypotheses:**
- Primary: Maryland workers in service occupations experienced 2-4 percentage point increase in full-year employment (WKW=52) relative to control states
- Mechanism: Paid sick leave reduces job loss from illness-related absences and reduces presenteeism that leads to termination
- Heterogeneity: Effects strongest for (1) workers in firms with 15+ employees (covered), (2) low-wage workers, (3) women with children (caregiving needs)

**Novelty:**
- Literature search: Existing research is mixed. Slopen (2024) finds positive effects on women's employment; Pichler & Ziebarth (2020) find null effects. No study focuses specifically on Maryland using individual-level PUMS data with employment stability outcomes.
- Gap: Maryland-specific effects unstudied with rigorous individual-level data
- Contribution: First PUMS-based DiD evaluation of Maryland's law with employment stability outcomes

**Why This Could Work:** Clean timing (Feb 2018), neighbor-state controls, service sector workers identifiable in PUMS, employment stability measurable through weeks worked variable.

---

## Idea 3: Hawaii's Minimum Wage Acceleration (2022) and Part-Time Employment Composition

**Policy:** Hawaii's Act 114 (2022) raised the minimum wage from $10.10 to $12.00 effective October 1, 2022, with scheduled increases to $18.00 by 2028 (highest in nation). This large increase interacts with Hawaii's unique Prepaid Health Care Act, which requires employer health insurance for employees working 20+ hours/week. Theory predicts employers may shift workers below 20 hours to avoid both higher wages AND health insurance costs.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Hawaii's 2022 minimum wage increase cause a shift from covered (20+ hours) to uncovered (<20 hours) part-time employment to avoid the combined cost of higher wages plus mandatory health insurance?

**Data:**
- Source: Census PUMS 2019-2024 (1-year samples)
- Treatment: Hawaii (minimum wage jump Oct 2022)
- Control states: Similar island/tourism-dependent economies without combined wage+insurance mandates - potentially Alaska (tourism economy) and coastal resort areas
- Key variables: WKHP (usual hours worked per week), ESR (employment status), WAGP (wages), OCCP (occupation), INDP (industry - focus on tourism, retail, food service), ST (state), PWGTP (weight)
- Sample: Low-wage workers (bottom quartile wages) in industries affected by both minimum wage and health care mandates
- Sample size estimate: ~30,000-40,000 low-wage workers in Hawaii per year

**Hypotheses:**
- Primary: Hawaii saw relative increase in employment at 15-19 hours/week (just below 20-hour health insurance threshold) post-2022
- Mechanism: Combined cost pressure (wage + health insurance) creates stronger incentive to keep workers below 20-hour threshold than wage increases alone
- Heterogeneity: Effects strongest in industries with high part-time incidence (retail, food service, tourism)

**Novelty:**
- Literature search: Buchmueller et al. (2011, AEJ:EP) studied Hawaii's Prepaid Health Care Act effects through 2005, finding increased part-time employment. No research on interaction with recent minimum wage increases.
- Gap: 15+ years since last rigorous study; no research on minimum wage x health insurance mandate interaction
- Contribution: First study of policy interaction effects between minimum wage and employer health insurance mandate

**Why This Could Work:** Unique policy combination (only Hawaii has both), clearly identifiable threshold (20 hours), recent timing (2022), hours worked directly observable in PUMS.

---

## Idea 4: Montana's Cannabis Worker Protection Law (2022) and Employment Outcomes

**Policy:** Montana not only legalized recreational marijuana in 2020 (I-190), but uniquely in 2021 (HB 701, effective January 1, 2022) amended its lawful off-duty conduct statute to protect workers who use marijuana off-premises during non-work hours. Employers cannot refuse to hire or discriminate based on lawful off-duty marijuana use. This creates a natural experiment comparing Montana to other legalization states without worker protections.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Montana's marijuana worker protection law increase employment and reduce unemployment duration for workers in occupations with historically high rates of drug testing?

**Data:**
- Source: Census PUMS 2019-2024 (1-year samples)
- Treatment: Montana (worker protections effective Jan 2022)
- Control states: Other states that legalized recreational marijuana without employment protections (Arizona 2020, New Jersey 2021, New Mexico 2021)
- Key variables: ESR (employment status), WKHP (hours), WAGP (wages), OCCP (occupation), INDP (industry), ST (state), PWGTP (weight)
- Sample: Workers 18-64 in occupations with high drug testing prevalence (transportation, warehousing, manufacturing, construction)
- Sample size estimate: ~80,000 workers in target occupations across study states

**Hypotheses:**
- Primary: Montana saw relative employment gains of 1-3 percentage points in high-drug-testing occupations compared to legalization-only states
- Mechanism: Worker protections reduce barriers to employment for marijuana users who would otherwise fail pre-employment or random drug tests
- Heterogeneity: Effects strongest in (1) occupations with mandatory drug testing (transportation), (2) blue-collar industries, (3) younger workers with higher cannabis use rates

**Novelty:**
- Literature search: Cannabis legalization employment effects studied (NBER working papers), but worker protection provisions largely ignored
- Gap: No research on employment effects of marijuana worker protection laws specifically
- Contribution: First causal estimate of whether cannabis worker protections (vs. legalization alone) improve employment outcomes

**Why This Could Work:** Clear policy variation (protection vs. no protection), identifiable high-drug-testing occupations in PUMS, recent timing for DiD, Montana vs. similar legalization states.

---

## Idea 5: Maryland's Staggered Minimum Wage ($15 by 2025) and Youth Employment

**Policy:** Maryland's Fight for $15 legislation (2019) created a staggered pathway to $15/hour, with large employers reaching $15 in January 2024 and small employers by 2026. The trajectory: $11.75 (2021) → $12.50 (2022) → $13.25 (2023) → $14.00 (2024, large) → $15.00 (2025). This staggered, firm-size-differentiated approach creates variation for analyzing employment effects.

**Method:** DiD (Difference-in-Differences)

**Research Question:** Did Maryland's staggered minimum wage increases disproportionately reduce youth employment (ages 16-24) compared to neighboring states with lower or no minimum wage increases?

**Data:**
- Source: Census PUMS 2018-2024 (1-year samples)
- Treatment: Maryland (staggered increases 2019-2025)
- Control states: Pennsylvania ($7.25 federal minimum, no state increase), Virginia (delayed $12 in 2023)
- Key variables: ESR (employment status), WKHP (hours), WAGP (wages), AGEP (age), SCHL (education/in-school status), ST (state), PWGTP (weight)
- Sample: Young workers ages 16-24, especially those without college degrees
- Sample size estimate: ~100,000 young workers per state-year

**Hypotheses:**
- Primary: Maryland youth employment fell 2-5 percentage points relative to Pennsylvania as minimum wage rose
- Mechanism: Youth workers are most price-sensitive to minimum wage increases due to lower productivity and substitutability with automated systems
- Heterogeneity: Effects strongest for (1) teens 16-19 vs. young adults 20-24, (2) those not enrolled in school, (3) workers without high school diploma

**Novelty:**
- Literature search: One study (ResearchGate 2024) examined Maryland's 2022 increase in fast-food only, finding negative effects. No comprehensive analysis of youth employment across all industries using individual-level data.
- Gap: Maryland-specific youth employment effects understudied despite being a leading $15 state
- Contribution: First comprehensive PUMS-based analysis of Maryland's Fight for $15 impact on youth employment

**Why This Could Work:** Clear staggered timing, neighboring state without increases (PA) as control, youth identifiable by age in PUMS, employment and hours directly observable.

---

## Summary Table

| Idea | Policy | Treatment State | Control States | Primary Outcome | Novelty Level |
|------|--------|-----------------|----------------|-----------------|---------------|
| 1 | HELP-Link Workforce + Medicaid | Montana | CO, NV, NM | Employment | Very High |
| 2 | Paid Sick Leave (2018) | Maryland | PA, VA | Employment stability | High |
| 3 | Min Wage + Health Insurance | Hawaii | AK, tourism areas | Hours distribution | Very High |
| 4 | Cannabis Worker Protections | Montana | AZ, NJ, NM | Employment in tested occupations | Very High |
| 5 | Fight for $15 Youth Effects | Maryland | PA, VA | Youth employment | Medium-High |

---

## Recommendation

**Idea 1 (Montana HELP-Link Workforce Program)** offers the strongest combination of:

1. **High novelty**: Completely unstudied policy bundle (workforce + Medicaid vs. Medicaid alone)
2. **Clean identification**: Clear timing (2016), comparable Mountain West control states
3. **Policy relevance**: Ongoing debates about work requirements vs. work supports in Medicaid
4. **Data quality**: Employment, wages, and health insurance all measurable in PUMS
5. **Sample size**: Large enough Medicaid-eligible population for statistical power

**Backup**: Idea 3 (Hawaii minimum wage + health insurance interaction) is highly novel but Hawaii's small population may limit statistical power.

---

## Selection for Execution

**Proceeding with Idea 1: Montana HELP-Link Workforce Program and Labor Force Participation**

This study will evaluate whether Montana's innovative approach of bundling workforce services with Medicaid expansion produced superior employment outcomes compared to coverage-only expansion in neighboring states.
