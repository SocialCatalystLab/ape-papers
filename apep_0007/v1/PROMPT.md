# Research Prompt: Wyoming Universal License Recognition

## Research Question

Did Wyoming's 2021 Universal License Recognition law (SF 0018) increase in-migration of licensed workers relative to comparison states?

## Policy Background

Wyoming's SF 0018, signed in February 2021, requires state licensing boards to universally recognize occupational licenses obtained in other states. Workers who move to Wyoming with a valid out-of-state license can now practice immediately rather than repeating training or certification requirements. The law excludes attorneys and professions with prescriptive drug authority.

Arizona became the first state to enact universal license recognition in 2019, followed by Montana (2021), Wyoming (2021), and others. By 2023, approximately 20 states had enacted some form of universal license recognition.

## Method

Difference-in-Differences (DiD)

- **Treatment group:** Wyoming (FIPS 56) after February 2021
- **Control group:** States without universal license recognition laws
- **Pre-period:** 2018-2020
- **Post-period:** 2021-2023

## Identification Strategy

Compare changes in in-migration rates for licensed workers in Wyoming before vs. after SF 0018 implementation, relative to changes in comparable states that did not enact similar laws. The identifying assumption is that, absent the policy, trends in licensed worker in-migration to Wyoming would have been parallel to trends in control states.

## Novel Contribution

The existing NBER paper (Oh & Kleiner 2025, w34030) studies universal license recognition effects on healthcare access and physician migration, finding increased healthcare utilization but no change in physician interstate migration. This paper focuses on non-healthcare licensed occupations (cosmetology, barbers, real estate, etc.) where licensing requirements are often more burdensome relative to earnings, and labor markets are less geographically elastic.

## Key PUMS Variables

- ST: State FIPS code (Wyoming = 56)
- MIG: Migration status (1=Same house, 2-3=Moved within state, 4+=Moved from different state)
- MIGSP: State of residence 1 year ago
- OCCP: Occupation code (to identify licensed occupations)
- ESR: Employment status
- PWGTP: Person weight
- AGEP: Age
- SEX: Sex
- SCHL: Educational attainment
- WAGP: Wage income
