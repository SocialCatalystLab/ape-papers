# Pre-Analysis Plan

## Research Question

**Do Graduated Driver Licensing (GDL) restrictions reduce teen labor force participation by limiting mobility, and do these effects persist into early adulthood?**

Specifically: Do state-level GDL laws—particularly nighttime driving restrictions and passenger limits—reduce employment rates among teenagers (ages 16-17) relative to slightly older workers (ages 20-24) who are unaffected by the restrictions?

---

## Conceptual Framework

### Theory and Mechanism

Graduated Driver Licensing laws were adopted by states between 1996-2012 to reduce teen traffic fatalities. The laws impose three main restrictions on newly licensed drivers:

1. **Nighttime driving restrictions** (typically 10pm/11pm/midnight until 5am/6am)
2. **Passenger limits** (typically 0-1 non-family passengers)
3. **Minimum holding periods** (6-12 months with learner permit)

These restrictions may have unintended consequences for teen employment:

- **Direct effect on job access**: Many entry-level teen jobs (retail, food service, movie theaters) require evening/night work. Teens who cannot legally drive after 10pm/11pm may be unable to work these shifts.
- **Reduced job search radius**: Teens with passenger restrictions cannot carpool; those dependent on parents for rides have constrained job search.
- **Employer-side response**: Employers may prefer older workers who face no driving restrictions for evening shifts.

### Expected Sign

**Primary hypothesis**: GDL adoption is associated with a **reduction** in teen employment rates (ages 16-17).

Rationale: The restrictions directly limit teens' ability to work jobs with evening hours or distant locations. Service-sector jobs disproportionately employ teens and often require evening availability.

### Heterogeneity Predictions

Effects should be **strongest** among:
1. **Rural areas**: No public transit alternative; driving is essential for mobility
2. **States with stricter GDL** (earlier nighttime restrictions, e.g., 9pm vs. midnight)
3. **Service-sector jobs** (more likely to require evening hours)
4. **Lower-income families** (fewer cars to share, parents less available for rides)

Effects should be **weakest** among:
1. **Urban areas**: Public transit alternatives exist
2. **Teens enrolled in school full-time** (may prioritize school over work anyway)

---

## Primary Specification

### Outcome Variable

**ESR** (Employment Status Recode) from PUMS, coded as:
- `Employed = 1` if ESR ∈ {1, 2} (employed or employed but not at work)
- `Employed = 0` if ESR ∈ {3, 6} (unemployed or not in labor force)

Secondary outcomes:
- **WKHP** (usual hours worked per week) - conditional on employment
- **LFP** (labor force participation): 1 if ESR ∈ {1, 2, 3}

### Treatment Variable

**GDL_adopted_{s,t}**: Indicator = 1 if state s has GDL in year t.

Coding based on first year state adopted a three-stage GDL with nighttime restriction:
- Florida: 1996
- Georgia, Michigan, North Carolina, California: 1997
- Louisiana + 5 others: 1998
- 11 states: 1999
- 6 states: 2000
- 8 states: 2001
- 3 states: 2002
- Remaining states: 2003-2012
- North Dakota (last): 2012

**GDL_stringency_{s,t}**: Continuous measure based on IIHS ratings, capturing:
- Nighttime restriction start hour (earlier = stricter)
- Duration of restriction period
- Passenger limit stringency

### Sample

- **Years**: PUMS 2000-2019 (allows pre-period for early adopters, long post-period)
- **Ages**: 16-24
- **Treatment group**: Ages 16-17 (subject to GDL restrictions)
- **Control group**: Ages 20-24 (obtained licenses before GDL, not subject to restrictions)
- **Exclusions**: Ages 18-19 (transition group with partial exposure)
- **Geography**: All 50 states + DC

### Sample Size Estimate

- PUMS 1-year samples: ~3.5 million persons/year
- Ages 16-24: ~12% of population → ~420,000/year
- Ages 16-17 + 20-24: ~350,000/year
- 20 years × 350,000 = **~7 million observations**

### Model Equation

**Triple-Difference (DDD) Specification:**

```
Y_{i,s,t} = α + β₁(GDL_{s,t} × Teen_{i}) + β₂(GDL_{s,t}) + β₃(Teen_{i})
          + γ_{s} + δ_{t} + θ_{s,t} + X_{i}′λ + ε_{i,s,t}
```

Where:
- Y_{i,s,t} = employment indicator for individual i in state s, year t
- GDL_{s,t} = 1 if state s has GDL in year t
- Teen_{i} = 1 if age 16-17 (vs. ages 20-24)
- γ_{s} = state fixed effects
- δ_{t} = year fixed effects
- θ_{s,t} = state-specific linear trends (optional)
- X_{i} = demographics (sex, race, school enrollment)

**Coefficient of interest: β₁** = differential effect of GDL on teens vs. young adults

**Event Study Specification:**

```
Y_{i,s,t} = α + Σ_{k=-5}^{10} β_k(1{t - GDL_year_s = k} × Teen_{i})
          + γ_{s} + δ_{t} + X_{i}′λ + ε_{i,s,t}
```

This traces out the dynamic effect from 5 years before to 10 years after GDL adoption.

---

## Where Mechanism Should Operate

### Directly Affected
- **Ages 16-17**: Newly licensed drivers subject to all GDL restrictions
- **Jobs with evening hours**: Retail, food service, entertainment, recreation

### Not Directly Affected
- **Ages 20+**: Obtained licenses before GDL era (in early-adopting states) or aged out of restrictions
- **Daytime-only jobs**: Agricultural work, summer day camps, tutoring

### Falsification Tests
1. **Placebo age groups**: Effect should NOT appear for ages 20-24
2. **Placebo timing**: Effect should NOT appear in pre-GDL years within a state
3. **State-year placebo**: Effect should NOT appear in states without GDL when comparing same years

---

## Robustness Checks

### Alternative Samples
1. Exclude 2008-2010 (Great Recession) - large secular shock to teen employment
2. Restrict to states that adopted GDL between 1998-2005 (avoids Florida as outlier, avoids very late adopters)
3. Ages 16-17 vs. ages 22-24 only (wider age gap for control group)

### Alternative Specifications
1. Include state-by-year fixed effects (absorbs aggregate shocks)
2. Add state-specific linear time trends
3. Use GDL stringency index instead of binary adoption indicator
4. Callaway & Sant'Anna (2021) staggered DiD estimator for heterogeneous effects

### Alternative Outcomes
1. Labor force participation (includes unemployed seeking work)
2. Hours worked conditional on employment
3. Employment in evening-shift industries (retail, food service) vs. daytime industries

### Standard Errors
1. Cluster at state level (primary)
2. Wild cluster bootstrap (finite sample correction for 51 clusters)
3. Conley spatial HAC standard errors

---

## Validity Checks

### Pre-Trends Test
Event study should show:
- Flat coefficients in years -5 to -1 (no differential trend before GDL)
- Sharp change at year 0 (GDL adoption)
- Persistent negative coefficients in years +1 to +10

### Covariate Balance
Check whether GDL adoption timing correlates with:
- State-level teen population trends
- State unemployment rate
- Minimum wage changes
- Other teen-targeted policies (education reforms, juvenile justice)

### Placebo Tests
1. **Age placebo**: Run same specification for ages 25-30 vs. 31-35 (should be null)
2. **Timing placebo**: Assign fake adoption dates 5 years early (should be null)
3. **Outcome placebo**: Test effect on school enrollment (should be null or positive)

---

## Secondary Analyses

### Heterogeneity
1. **Urban vs. rural**: Expect larger effects in rural areas (no transit alternatives)
2. **GDL stringency**: Stricter laws (9pm restriction vs. midnight) should have larger effects
3. **Sex**: Males may have higher baseline employment and larger effects
4. **Race/ethnicity**: Lower-income groups may face larger mobility constraints
5. **School enrollment status**: Non-enrolled teens may face larger effects (more dependent on work)

### Mechanisms
1. **Industry analysis**: Effects should concentrate in evening-hour industries
2. **Commute patterns**: Teens in GDL states may have shorter commutes or use different transport modes

---

## Power Calculation

With ~7 million observations and ~40% baseline teen employment rate:
- Standard error on state-level coefficient ≈ 0.005
- Can detect effects of ~1 percentage point at 95% confidence
- Given teen employment declined from ~45% (1990s) to ~25% (2010s), detecting a 1-2pp effect of GDL is feasible

---

## What If Primary is Null?

If β₁ ≈ 0:

1. **Test heterogeneity**: Effect may exist in subgroups (rural, stricter GDL, evening-hour industries)
2. **Check mechanisms**: Maybe teens substitute to different jobs rather than not working
3. **Report honestly**: A null finding is informative - it would suggest GDL's labor market costs are minimal despite restricting teen mobility

---

## Timeline

1. Lock this pre-analysis plan
2. Collect GDL adoption dates and stringency data
3. Download PUMS data 2000-2019
4. Estimate primary DDD specification
5. Conduct event study
6. Run robustness and validity checks
7. Write paper
