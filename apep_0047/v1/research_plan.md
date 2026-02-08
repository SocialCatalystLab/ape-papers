# Paper 64: Initial Research Plan

**Title:** The Pence Effect: Did #MeToo Reduce Female Employment in High-Harassment Industries?

**Created:** 2026-01-21
**Status:** LOCKED (do not modify after data fetch begins)

---

## Executive Summary

This paper uses a triple-difference design to estimate whether the #MeToo movement (October 2017) differentially reduced female employment in industries with historically high sexual harassment rates. The "Pence Effect" hypothesis predicts that heightened awareness of harassment liability caused men to avoid professional interactions with women, reducing female hiring and increasing separations in high-exposure industries.

---

## Research Design

### Identification Strategy: Triple-Difference (DDD)

**First difference:** Pre vs. post October 2017 (Q4 2017)
**Second difference:** High-harassment vs. low-harassment industries
**Third difference:** Female vs. male employment outcomes

**Estimating equation:**

```
Y_isgt = α + β₁(Female_g × HighHarass_i × Post_t)
       + β₂(Female_g × HighHarass_i) + β₃(Female_g × Post_t) + β₄(HighHarass_i × Post_t)
       + γ_is + δ_st + θ_gt + ε_isgt
```

Where:
- Y = employment outcome (hires, employment level, separations)
- i = industry (NAICS 2-digit)
- s = state
- g = gender (male/female)
- t = quarter
- γ_is = industry × state fixed effects
- δ_st = state × time fixed effects
- θ_gt = gender × time fixed effects

**Coefficient of interest:** β₁ captures the differential change in female employment (relative to male) in high-harassment industries (relative to low) after #MeToo (relative to before).

### Treatment Definition: Harassment Exposure

**Primary measure:** EEOC sexual harassment charge rate by industry (2010-2016 average)
- Defined as: (Sexual harassment charges in industry i) / (Employment in industry i)
- Binary: High = above-median charge rate
- Continuous: Log(charge rate) for dose-response

**High-harassment industries (based on EEOC data):**
- Accommodation & Food Services (NAICS 72)
- Retail Trade (NAICS 44-45)
- Health Care & Social Assistance (NAICS 62)
- Arts, Entertainment & Recreation (NAICS 71)
- Administrative Services (NAICS 56)

**Low-harassment industries (control):**
- Finance & Insurance (NAICS 52)
- Professional Services (NAICS 54)
- Information (NAICS 51)
- Utilities (NAICS 22)
- Mining (NAICS 21)

**Alternative measures (robustness):**
1. Female share of industry workforce (more women = more targets)
2. Male share of management (more male managers = more perpetrators)
3. Industry-level harassment prevalence from surveys

---

## Data Plan

### 1. Quarterly Workforce Indicators (QWI)

**Source:** Census Bureau LEHD via QWI Explorer API
**Coverage:** All 50 states + DC, Q1 2010 - Q4 2023
**Variables:**
- Emp: Beginning-of-quarter employment
- HirA: All hires during quarter
- Sep: All separations during quarter
- EarnS: Average monthly earnings

All by: state × NAICS 2-digit × sex × quarter

### 2. EEOC Harassment Charge Data

**Source:** EEOC Enforcement & Litigation Statistics
**Coverage:** FY 2010-2023, by industry
**Purpose:** Construct pre-treatment harassment exposure measure

### 3. Supplementary Data

- BLS QCEW: Industry employment totals for normalization
- CPS: Monthly employment by industry-gender for robustness
- ACS: Occupation-industry data for management analysis

---

## Analysis Plan

### Stage 1: Data Preparation
1. Download QWI data (all states, industries, genders, 2010-2023)
2. Download EEOC harassment data by industry
3. Construct harassment exposure measure
4. Classify industries as high/low harassment
5. Merge all datasets

### Stage 2: Descriptive Analysis
- Figure 1: Harassment charge rates by industry (horizontal bar chart)
- Figure 2: Female employment share timeline by industry type
- Table 1: Summary statistics (pre/post × high/low harassment × gender)

### Stage 3: Main Analysis
- Figure 3: Event study (quarterly, 2014-2023)
- Table 2: Triple-difference estimates (main spec)
- Table 3: Heterogeneity by state characteristics

### Stage 4: Robustness
- Alternative harassment measures
- Placebo MeToo dates
- Different fixed effects structures
- Wild cluster bootstrap
- HonestDiD sensitivity

### Stage 5: Mechanisms
- Management representation changes
- Earnings effects
- Industry-specific deep dives

---

## Paper Structure (LaTeX Subfiles)

```
paper_64/
├── main.tex
├── sections/
│   ├── 01_abstract.tex
│   ├── 02_introduction.tex     # 4+ pages, 20+ citations
│   ├── 03_background.tex
│   ├── 04_data.tex
│   ├── 05_methods.tex
│   ├── 06_results.tex
│   ├── 07_robustness.tex
│   ├── 08_mechanisms.tex
│   ├── 09_discussion.tex
│   └── 10_conclusion.tex
└── figures/
```

---

## Quality Requirements (User-Mandated)

Before external review:
- [ ] 30+ pages polished prose
- [ ] 5+ publication-ready figures
- [ ] 5+ professionally formatted tables
- [ ] 4+ page introduction
- [ ] 20+ papers cited
- [ ] LaTeX subfiles structure
- [ ] Pre-trends clean

---

*This plan is LOCKED. Copy to research_plan.md for modifications during execution.*
