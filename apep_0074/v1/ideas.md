# Research Ideas

## Idea 1: Extreme Risk Protection Orders (Red Flag Laws) and Firearm Suicide

**Policy:** Extreme Risk Protection Orders (ERPOs), also known as "red flag" laws, allow courts to temporarily remove firearms from individuals deemed at risk. Connecticut (1999) and Indiana (2005) were early adopters. A major wave occurred after the 2018 Parkland shooting: Florida (2018), Vermont (2018), Maryland (2018), Rhode Island (2018), New Jersey (2018), Delaware (2018), Massachusetts (2018), Illinois (2019), Colorado (2019), Nevada (2019), Hawaii (2019), New York (2019), and others. By 2019, 17 states had ERPOs.

**Outcome:** State-year firearm suicide rates from CDC WONDER mortality data. Firearm suicides account for approximately 50% of all gun deaths and the mechanism (temporary gun removal during crisis) directly targets suicide prevention.

**Identification:** Difference-in-differences exploiting staggered adoption across states 2014-2019. The 2018-2019 wave provides sharp variation with many states adopting in response to Parkland (plausibly exogenous to state-level suicide trends). Use Callaway-Sant'Anna estimator.

**Why it's novel:** Prior research focuses mainly on Connecticut and Indiana case studies (Swanson 2016, 2024). Limited causal evidence on the post-2018 wave. Novel angle: heterogeneity by age group (youth vs elderly suicide) and by enforcement intensity (law enforcement vs family petitions).

**Feasibility check:** CDC WONDER provides state-year mortality data by cause (firearm suicide). PDAPS provides state adoption dates. ~17 treated states (2014-2019), ~20+ control states. Strong mechanism: the acute suicidal crisis window is often minutes/hours, and ERPO removes the lethal means.


## Idea 2: State Generic Drug Substitution Laws and Medication Adherence

**Policy:** States vary in whether pharmacists must, may, or cannot substitute generic drugs for brand-name prescriptions. Some states have "mandatory substitution" (must substitute unless prohibited), others have "permissive substitution" (may substitute with consent), and some require patient consent. Several states have updated these laws over 2010-2020.

**Outcome:** Medication adherence rates from MEPS (Medical Expenditure Panel Survey) or prescription fill rates.

**Identification:** DiD exploiting law changes across states. Challenge: variation may be limited to specific provisions rather than major on/off changes.

**Why it's novel:** Most research uses cross-sectional variation. Novel angle: focus on adherence for chronic conditions (diabetes, hypertension) where cost-related non-adherence is well-documented.

**Feasibility check:** MEPS microdata available but may require complex data construction. Law variation is nuanced (not simple binary). Medium feasibility - data construction is challenging.


## Idea 3: State Medicaid Work Requirements and Health Insurance Coverage

**Policy:** Several states implemented Medicaid work requirements in 2018-2019 (Arkansas, Kentucky, Indiana, New Hampshire). Arkansas fully implemented; others were blocked by courts. Arkansas's requirement was in effect Jan 2018 - Mar 2019 before being enjoined.

**Outcome:** Health insurance coverage rates from ACS or CPS.

**Identification:** DiD using Arkansas (and briefly other states) as treatment, with never-implementing states as controls.

**Why it's novel:** Short implementation window creates a unique natural experiment. Can study both implementation AND removal effects.

**Feasibility check:** ACS/CPS data available. Challenge: only Arkansas had sustained implementation before court blocked; very limited treatment variation (essentially N=1 state). Low feasibility for staggered DiD.


## Idea 4: State Tobacco-21 Laws and Youth Smoking Initiation

**Policy:** States raised minimum tobacco purchase age to 21 before federal law (2019). Hawaii (2016), California (2016), New Jersey (2017), Oregon (2017), Maine (2018), Massachusetts (2018), Virginia (2019), and several others.

**Outcome:** Youth smoking rates from YRBSS (Youth Risk Behavior Surveillance System) or BRFSS for young adults 18-20.

**Identification:** DiD exploiting staggered state adoption 2016-2019, before federal Tobacco-21 law (Dec 2019) created uniform policy.

**Why it's novel:** Federal law now makes state variation irrelevant going forward; the 2016-2019 window captures the last period of state policy variation. Can study age-specific effects (18-20 directly affected vs 15-17 spillovers).

**Feasibility check:** YRBSS provides state-year data on youth tobacco use but is biennial (odd years only). BRFSS has annual data but limited for under-18. ~10 states treated before federal law. Moderate feasibility.


## Idea 5: State Extreme Risk Protection Orders and Firearm Homicide (Alternative to Idea 1)

**Policy:** Same as Idea 1 - ERPO/Red Flag laws.

**Outcome:** Firearm homicide rates instead of suicide.

**Identification:** Same staggered DiD.

**Why it's novel:** Most ERPO research focuses on suicide. Mass shooting prevention is a stated goal but harder to measure (rare events). Firearm homicide is more common and may capture interpersonal threat cases where ERPOs are used.

**Feasibility check:** CDC WONDER data available. Challenge: mechanism is weaker (most homicides not preceded by reportable threats to authorities). Prior research finds no clear effect on homicide. Lower expected effect size than suicide.
