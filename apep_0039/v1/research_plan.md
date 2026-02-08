# Initial Research Plan - Paper 56

## Research Question

Do state heat illness prevention standards reduce workplace injuries and illnesses among outdoor workers?

## Policy Background

Following California's pioneering 2005 outdoor heat illness prevention standard, several states have adopted similar workplace safety regulations:
- California: 2005 (outdoor workers), July 2024 (indoor workers)
- Minnesota: 1997 (indoor environments only)
- Oregon: June 15, 2022 (both indoor and outdoor when heat index ≥80°F)
- Colorado: 2022 (agricultural workers)
- Washington: 2023 (outdoor workers)
- Maryland: September 30, 2024

OSHA proposed a federal heat standard in August 2024, making state-level evidence immediately policy-relevant.

## Identification Strategy

**Design:** Difference-in-differences with staggered state adoption

**Treatment:** State adoption of heat illness prevention standard (binary indicator for state × year)

**Control Group:** States without heat standards (never-treated)

**Key Assumption:** Parallel trends - absent treatment, injury trends in treated states would have evolved similarly to control states

**Estimator:** Callaway-Sant'Anna (2021) for heterogeneity-robust estimates

## Data Sources

**Primary Outcome:** BLS Survey of Occupational Injuries and Illnesses (SOII)
- Unit: State × industry × year
- Measures: Total recordable cases, days away from work cases
- Years: 2010-2023
- Industries of interest: Agriculture (NAICS 11), Construction (NAICS 23)

**Alternative Outcomes:**
- CDC WONDER: Heat-related mortality by state-year
- Workers' compensation claims (if available)

**Policy Data:** Hand-collected from state occupational safety agencies and legislation

## Expected Results

**Hypothesis:** Heat standards reduce workplace injuries/illnesses in outdoor industries
- Primary effect on agriculture and construction
- Larger effects in states with higher baseline heat exposure
- Effects may take 1-2 years to materialize (employer compliance)

**Mechanisms:**
- Required water, rest, shade provisions
- Acclimatization protocols for new workers
- Worker and supervisor training
- Written heat illness prevention plans

## Potential Confounds

1. **Economic cycles:** Construction employment varies with business cycle
2. **Climate trends:** Heat events increasing over time
3. **Other safety regulations:** States adopting heat standards may be more safety-oriented generally
4. **COVID-19:** 2020-2021 disruptions

## Planned Robustness Checks

1. Event study to test parallel trends
2. Placebo tests on non-heat-related injuries
3. Sun-Abraham and TWFE as alternative estimators
4. Dropping COVID years (2020-2021)
5. Heterogeneity by state baseline temperature

## Timeline

1. Fetch and clean data
2. Run main analysis (Callaway-Sant'Anna)
3. Generate figures and tables
4. Write paper
5. Review and revise
