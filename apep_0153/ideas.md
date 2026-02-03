# Research Ideas

## Idea 1: Paid Sick Leave Mandates and Preventive Healthcare Utilization
**Policy:** State paid sick leave (PSL) mandates, staggered adoption 2012-2024. 21+ treated states: CT (2012), CA (2015), MA (2015), OR (2016), AZ (2017), VT (2017), WA (2018), MD (2018), RI (2018), NJ (2018), MI (2019), NV (2020), NY (2020), CO (2021), ME (2021), NM (2022), MN (2024), IL (2024).
**Outcome:** BRFSS pre-aggregated state-level data on preventive care utilization: flu vaccination (65+), routine checkups, cholesterol screening, mammography, dental visits. Data from CDC Socrata API, 2011-2024, broken out by income group, age, race/ethnicity.
**Identification:** Staggered DiD using Callaway & Sant'Anna (2021). Treatment = state PSL mandate effective date. Control = never-treated states. Triple-diff: low-income vs. high-income households within treated states (low-income workers disproportionately lacked PSL pre-mandate).
**Why it's novel:** APEP-0001 studied PSL effects on work hours. The 2025 Lancet paper used insurance claims data. This paper uses population-based BRFSS survey data to study preventive care (a different outcome), enabling analysis of uninsured populations and broader demographic breakdowns unavailable in claims data. Novel contribution: population-level preventive healthcare externalities of labor regulation.
**Feasibility check:** Confirmed: 21+ treated states with staggered adoption 2012-2024. BRFSS Socrata API returns state×year×income data for flu shots, checkups, cholesterol screening, dental visits. 13 years of panel data with 5+ pre-treatment years. Not in APEP list (APEP-0001 is employment, not health).

## Idea 2: State E-Cigarette Indoor Air Laws and Youth Vaping Prevalence
**Policy:** State laws restricting e-cigarette use in indoor public places. Staggered adoption across states from 2013-2023. ~20 states have comprehensive e-cigarette smokefree indoor air laws.
**Outcome:** Youth Risk Behavior Surveillance System (YRBSS) or BRFSS e-cigarette use prevalence by state and year.
**Identification:** Staggered DiD. Treatment = state e-cigarette indoor restriction effective date. Placebo: cigarette smoking (should not be affected by e-cigarette-specific restriction).
**Why it's novel:** Most e-cigarette research focuses on taxation or flavor bans. Indoor use restrictions are understudied with causal methods. The substitution/complementarity between policy tools (tax vs. use restrictions) is an open question.
**Feasibility check:** Uncertain. Need to verify exact state adoption dates and whether BRFSS e-cigarette data has sufficient pre-treatment years (e-cigarette questions only added to BRFSS in 2016-2017). Limited pre-treatment data is a concern.

## Idea 3: State Medicaid Postpartum Coverage Extensions and Maternal Health
**Policy:** States extending Medicaid postpartum coverage from 60 days to 12 months. Staggered adoption via Section 1115 waivers and the ARPA option (2021+). ~38 states have extended as of 2024.
**Outcome:** BRFSS maternal health indicators, CDC WONDER maternal mortality data, ACS health insurance coverage for women of childbearing age.
**Identification:** Staggered DiD. Treatment = state postpartum extension effective date. Large number of treated states provides power.
**Why it's novel:** This is a recent, rapidly-spreading policy. Some working papers exist but no definitive causal study using staggered DiD with modern estimators. The policy directly addresses the maternal mortality crisis.
**Feasibility check:** Partially confirmed. 38+ treated states is excellent. Adoption dates are verifiable through CMS records. The concern is measurement: BRFSS lacks granular postpartum health measures, and CDC WONDER maternal mortality has small counts in many states creating noise. Would need to identify the right outcome variable.

## Idea 4: State Minimum Wage Increases and Preventive Healthcare Utilization
**Policy:** State minimum wage increases, continuous variation across states and years.
**Outcome:** BRFSS preventive care data (same as Idea 1).
**Identification:** Staggered DiD using minimum wage increase events. Treatment = state raises minimum wage above federal floor. Rich variation across 30+ states.
**Why it's novel:** The minimum wage-employment link is saturated. The minimum wage-health link is less studied with rigorous causal methods. Income channel: higher wages → more healthcare? Or time channel: reduced hours → less time for healthcare?
**Feasibility check:** Confirmed data availability. Concern: many confounders (states that raise minimum wage may also expand healthcare). The identification is weaker than Idea 1 because minimum wage changes correlate with many other progressive policies.

## Idea 5: State Paid Sick Leave Mandates and Influenza Mortality
**Policy:** Same PSL mandates as Idea 1.
**Outcome:** CDC WONDER influenza and pneumonia mortality data by state and year. Publicly available, annual, all states.
**Identification:** Staggered DiD. Mechanism: PSL allows sick workers to stay home → reduced workplace transmission → lower flu mortality.
**Why it's novel:** The public health externality of paid sick leave (contagion reduction) has been theorized but not rigorously tested with causal methods at scale. Prior work uses cross-sectional or national-level time series.
**Feasibility check:** Confirmed. CDC WONDER has ICD-10 J09-J18 (influenza and pneumonia) mortality counts by state and year, 1999-2023. Concern: flu mortality is volatile year-to-year due to strain variation, creating noise. COVID-19 period (2020-2021) is a major confounder. Would need to exclude or carefully model the pandemic period.
