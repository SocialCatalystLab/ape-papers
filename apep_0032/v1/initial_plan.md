# Paper 42: Initial Research Plan

**Title:** Compulsory Schooling Laws and Mother's Labor Supply: Testing the Permanent Income Hypothesis in Historical Context

**Created:** 2026-01-19
**Status:** Locked (do not modify after creation)

---

## Research Question

How did mothers respond to the loss of child labor earnings when compulsory schooling laws were enacted? Did this response reflect transitory income smoothing (consistent with PIH) or permanent labor market adjustment?

## Theoretical Framework

**Permanent Income Hypothesis (Friedman, 1957):** Consumption depends on permanent (expected lifetime) income, not current income. Transitory income shocks are smoothed through savings/borrowing or temporary labor supply adjustments.

**Application:** Compulsory schooling laws removed children from the labor force, reducing household income. If households viewed this as:
- **Transitory shock:** Mothers would temporarily increase labor supply until children aged out of schooling requirements
- **Permanent shock:** Mothers would permanently increase labor supply to compensate for the structural change in child labor expectations

The **duration and persistence** of mother's labor supply response tests which interpretation households applied.

## Hypothesis

**H1:** Compulsory schooling laws increased mother's labor force participation in treated households.

**H2 (PIH Test):** The labor supply response was initially larger for mothers with younger children (longer expected income loss) than for mothers with older children (shorter exposure).

**H3 (Heterogeneity):** Single mothers responded more than married mothers (less income insurance from spouse).

---

## Policy: Compulsory Schooling Laws (1852-1918)

### State Adoption Timeline

| Year | States |
|------|--------|
| 1852 | Massachusetts |
| 1864 | District of Columbia |
| 1867 | Vermont |
| 1871 | Michigan, New Hampshire, Washington |
| 1872 | Connecticut, New Mexico |
| 1873 | Nevada |
| 1874 | California, Kansas, New York |
| 1875 | Maine, New Jersey |
| 1876 | Wyoming |
| 1877 | Ohio |
| 1879 | Wisconsin |
| 1883 | Illinois, Montana, N. Dakota, S. Dakota, Rhode Island |
| 1885 | Minnesota |
| 1887 | Nebraska, Idaho |
| 1889 | Colorado, Oregon |
| 1890 | Utah |
| 1895 | Pennsylvania |
| 1896 | Hawaii, Kentucky |
| 1897 | Indiana, West Virginia |
| 1899 | Arizona |
| 1902 | Iowa, Maryland |
| 1905 | Missouri, Tennessee |
| 1907 | Delaware, North Carolina, Oklahoma |
| 1908 | Virginia |
| 1909 | Arkansas |
| 1910 | Louisiana |
| 1915 | Alabama, Florida, South Carolina, Texas |
| 1916 | Georgia |
| 1918 | Mississippi |

**Total states:** 48 (plus DC)
**Period:** 66 years of staggered adoption

---

## Data

### Primary Source: IPUMS Full Count Census

**Years:** 1880, 1900, 1910, 1920, 1930

**Sample Construction:**
1. Identify all women aged 18-55 with at least one child aged 6-16 in household
2. Link mothers to children using household structure (RELATE, MOMLOC)
3. Determine child ages and exposure to compulsory schooling

**Key Variables:**

| Variable | Description | Availability |
|----------|-------------|--------------|
| OCC1950 | Occupation code (1950 basis) | All years |
| LABFORCE | In labor force indicator | Derived from OCC |
| OCCSCORE | Occupation income score | All years |
| MARST | Marital status | All years |
| AGE | Age | All years |
| SEX | Sex | All years |
| NCHILD | Number of children | All years |
| RELATE | Relationship to household head | All years |
| MOMLOC | Mother's location in household | All years |
| STATEFIP | State FIPS code | All years |
| RACE | Race | All years |
| LIT | Literacy | All years |

### Sample Size Estimates

- Full count 1900: ~76 million persons
- Married women with children: ~8-10 million
- Multiple census years: 30+ million mother-year observations

---

## Identification Strategy

### Staggered Difference-in-Differences

**Treatment:** State adopted compulsory schooling law before census year
**Treated group:** Mothers with children aged below compulsory schooling maximum
**Control group:**
1. Mothers in states without (yet) compulsory schooling
2. Mothers with children above compulsory schooling age

### Regression Specification

$$LFP_{isc,t} = \alpha + \beta_1 \cdot Post_{s,t} + \beta_2 \cdot HasSchoolAgeChild_i + \beta_3 \cdot (Post_{s,t} \times HasSchoolAgeChild_i) + X_i'\gamma + \delta_s + \tau_t + \epsilon_{isc,t}$$

Where:
- $LFP_{isc,t}$: Labor force participation for mother $i$ in state $s$, county $c$, year $t$
- $Post_{s,t}$: Indicator for state $s$ having compulsory schooling in year $t$
- $HasSchoolAgeChild_i$: Indicator for having child aged 8-14 (typical compulsory ages)
- $X_i$: Individual controls (age, race, marital status, number of children)
- $\delta_s$: State fixed effects
- $\tau_t$: Year fixed effects

**Main coefficient of interest:** $\beta_3$ (effect of compulsory schooling on mothers with school-age children)

### Event Study

For states with sufficient pre- and post-treatment observations:

$$LFP_{isc,t} = \alpha + \sum_{k=-20}^{+20} \beta_k \cdot \mathbb{1}[t - t^*_s = k] \times HasSchoolAgeChild_i + X_i'\gamma + \delta_s + \tau_t + \epsilon_{isc,t}$$

Where $t^*_s$ is the year state $s$ adopted compulsory schooling.

### Identification Assumptions

1. **Parallel trends:** Absent compulsory schooling, mother's LFP would have evolved similarly in treated and control states
2. **No anticipation:** Mothers did not change labor supply in anticipation of law passage
3. **SUTVA:** No spillovers across states

### Robustness Checks

1. Placebo test: Effect on mothers with only children above school age
2. Placebo test: Effect on childless women
3. Border-county analysis: Compare adjacent counties across state borders
4. Stacked DiD (Cengiz et al.) to address heterogeneous treatment timing issues
5. Triple-difference: Add gender placebo (fathers vs. mothers)

---

## PIH-Specific Tests

### Test 1: Duration of Child Exposure

If mothers view child labor loss as tied to schooling duration:
- Mothers with younger children (e.g., age 8) face longer income loss
- Mothers with older children (e.g., age 13) face shorter income loss

**Prediction:** Larger LFP response for mothers with younger school-age children

### Test 2: Persistence of Response

If mothers treat the shock as permanent:
- LFP should remain elevated even after children age out of schooling
- No "reversal" when youngest child turns 14

If mothers treat the shock as transitory:
- LFP should decline after children age out
- "Reversal" toward pre-treatment levels

### Test 3: Married vs. Single Mothers

Married mothers have income insurance from spouse:
- May not need to increase LFP as much
- Can smooth consumption through husband's income

Single mothers lack this insurance:
- Must self-insure through own labor supply
- Larger LFP response expected

---

## Potential Concerns

### 1. Underreporting of Women's Occupation

**Issue:** Historical census significantly undercounted married women's work, especially in farm households where "keeping house" was recorded instead of actual work.

**Mitigation:**
- Use Goldin's corrected occupation classifications where available
- Acknowledge this as measurement error that biases toward null
- Focus on non-farm households as robustness check

### 2. Endogenous Law Adoption

**Issue:** States may have adopted compulsory schooling when women's LFP was already changing.

**Mitigation:**
- Event study to check pre-trends
- Control for state-level economic conditions (industrialization, urbanization)
- Placebo tests on childless women

### 3. Contemporaneous Reforms

**Issue:** Child labor laws and factory regulations often coincided with compulsory schooling.

**Mitigation:**
- Use Aizer (2004) coding of child labor laws
- Include child labor law controls
- Test whether effects are larger in states that only passed compulsory schooling (vs. both)

### 4. Migration

**Issue:** Families may have migrated in response to laws.

**Mitigation:**
- Check for changes in state-level child/mother ratios
- Use birthplace to identify long-term residents
- Analyze separately by migration status

---

## Analysis Plan

### Step 1: Data Construction
1. Request IPUMS full count extract for 1880, 1900, 1910, 1920
2. Construct mother-child links using household structure
3. Merge with state compulsory schooling adoption dates
4. Create treatment indicators and child age variables

### Step 2: Descriptive Statistics
1. Summary statistics by treatment status
2. Trends in mother's LFP by state and year
3. Balance tests on observable characteristics

### Step 3: Main Results
1. DiD regression on LFP
2. Event study for timing of effects
3. Heterogeneity by child age (PIH Test 1)

### Step 4: PIH-Specific Tests
1. Persistence analysis (PIH Test 2)
2. Single vs. married mothers (PIH Test 3)
3. Occupation upgrading (intensive margin)

### Step 5: Robustness
1. Placebo: Childless women, fathers, above-age children
2. Border county analysis
3. Stacked DiD for staggered treatment
4. Correcting for occupation underreporting

---

## Expected Contribution

1. **Methodological:** First test of PIH using mother's labor supply response to household income shock in historical context

2. **Substantive:** New evidence on how historical households adjusted to major policy-induced income changes

3. **Policy:** Informs understanding of how mandated schooling affected household economic behavior

---

## Timeline and Milestones

| Phase | Task | Output |
|-------|------|--------|
| Data | IPUMS extract request | Raw data files |
| Data | Construct analysis sample | analysis_sample.csv |
| Analysis | Summary statistics | descriptive_stats.tex |
| Analysis | Main DiD results | main_results.tex |
| Analysis | Event study | event_study.png |
| Analysis | PIH tests | pih_tests.tex |
| Writing | Draft paper | paper.tex |
| Review | Internal rounds | Revised paper |
| Review | External rounds | Final paper |

---

## Sources

- Friedman, Milton. 1957. *A Theory of the Consumption Function*. Princeton University Press.
- Aizer, Anna. 2004. "Were Compulsory Attendance and Child Labor Laws Effective?" *Journal of Law and Economics* 47(2): 755-786.
- Goldin, Claudia. 1990. *Understanding the Gender Gap*. Oxford University Press.
- IPUMS USA Full Count Census. https://usa.ipums.org/usa/full_count.shtml
- PMC8871595: Going Places: Effects of Early U.S. Compulsory Schooling Laws on Internal Migration
