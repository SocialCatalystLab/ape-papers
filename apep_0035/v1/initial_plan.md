# Initial Research Plan: Paper 47

**Title:** The Ballot and the Paycheck: Women's Suffrage and Female Labor Force Participation, 1880-1920

**Created:** 2026-01-19
**Status:** LOCKED (do not modify after data fetch begins)

---

## Research Question

Did state-level women's suffrage laws (1893-1918) increase female labor force participation?

---

## Identification Strategy

### Method: Callaway-Sant'Anna DiD with Staggered Adoption

**Treatment:** State-level women's suffrage laws enacted before the 19th Amendment (1920)

**Treatment timing:**
| State | Year | Pre-Censuses Available |
|-------|------|------------------------|
| WY | 1869 | None (too early) |
| UT | 1870 | None (too early) |
| CO | 1893 | 1880 |
| ID | 1896 | 1880 |
| WA | 1910 | 1880, 1900 |
| CA | 1911 | 1880, 1900, 1910 |
| OR | 1912 | 1880, 1900, 1910 |
| KS | 1912 | 1880, 1900, 1910 |
| AZ | 1912 | 1880, 1900, 1910 |
| MT | 1914 | 1880, 1900, 1910 |
| NV | 1914 | 1880, 1900, 1910 |
| NY | 1917 | 1880, 1900, 1910 |
| MI | 1918 | 1880, 1900, 1910 |
| OK | 1918 | 1900, 1910 |
| SD | 1918 | 1880, 1900, 1910 |

**Control group:** 33 states without suffrage before 19th Amendment (1920)

### Sample
- **Unit:** Women ages 18-64 linked across censuses via HISTID
- **Censuses:** 1880, 1900, 1910, 1920
- **Sample size:** Expect ~10-50 million women-census observations

### Outcome
- Primary: Labor force participation (LABFORCE = 2 in IPUMS)
- Secondary: Self-employment, occupational status (OCC1950)

### Identification Assumptions
1. Parallel trends in female LFP between treated and never-treated states (pre-1893)
2. No anticipation effects
3. No spillovers across state lines

---

## Analysis Plan

### Step 1: Data Extraction (IPUMS API)
Variables: HISTID, YEAR, STATEFIP, AGE, SEX, MARST, RACE, LABFORCE, OCC1950, SCHOOL, BPL, NCHILD
Samples: us1880e, us1900m, us1910m, us1920c (Full Count)

### Step 2: Sample Construction
1. Restrict to women (SEX = 2)
2. Ages 18-64
3. Merge with state-level suffrage dates
4. Create treatment timing variable (gname for C-S)

### Step 3: Descriptive Statistics
- Sample sizes by state × census
- Mean LFP by treatment cohort × year
- Balance tables: treated vs. never-treated pre-treatment

### Step 4: Main Analysis (Callaway-Sant'Anna)
```r
library(did)

cs_out <- att_gt(
  yname = "labforce",
  tname = "year",
  idname = "histid",
  gname = "treat_year",
  data = df,
  control_group = "nevertreated",
  clustervars = "statefip"
)

# Aggregate to event study
es <- aggte(cs_out, type = "dynamic")

# Aggregate to overall ATT
overall <- aggte(cs_out, type = "simple")
```

### Step 5: Robustness Checks
1. Region × year fixed effects (address western differential trends)
2. Exclude early adopters (WY, UT, CO, ID) with limited pre-data
3. Placebo: Male LFP (should show no effect)
4. Restrict to 1910-1918 adoption wave only
5. Alternative control groups (not-yet-treated)
6. HonestDiD sensitivity analysis for pre-trend violations

### Step 6: Heterogeneity
- By age group (young vs. older women)
- By marital status (married vs. unmarried)
- By race (white vs. non-white)
- By urban/rural

---

## Figures

1. **Map:** Suffrage adoption timing across states (choropleth)
2. **Parallel trends:** Mean female LFP by treatment cohort × year
3. **Event study:** C-S estimates with 95% CI
4. **Heterogeneity:** Subgroup effects
5. **Placebo:** Male LFP event study

---

## Tables

1. Summary statistics (overall and by treatment status)
2. Balance table (pre-treatment characteristics)
3. Main results: Overall ATT and by cohort
4. Robustness checks
5. Heterogeneity analysis

---

## Expected Contribution

1. **Novel outcome:** First study of suffrage → female LFP (existing lit focuses on public spending)
2. **MLP advantage:** Individual-level panel via HISTID enables FE within-person comparisons
3. **Modern methods:** Callaway-Sant'Anna addresses heterogeneous treatment effects
4. **Policy relevance:** Speaks to political empowerment → economic outcomes

---

## Risks and Mitigation

| Risk | Mitigation |
|------|------------|
| Pre-trends failure | Restrict to 1910-1918 wave; HonestDiD |
| Selection into treatment | Region × year FE; robustness without West |
| Low LFP rates | Focus on extensive margin; large samples |
| HISTID linkage bias | Compare linked vs. full sample |
| WWI confound | Placebo with male outcomes |

---

## Timeline Targets

This plan is locked once data extraction begins.
