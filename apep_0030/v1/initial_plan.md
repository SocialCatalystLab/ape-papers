# Initial Research Plan — Paper 37

**Title:** Decriminalize, Then Recriminalize: The Effects of Colorado's Fentanyl Policy Reversal on Overdose Mortality

**Created:** 2026-01-18
**Status:** LOCKED (do not modify after creation — use research_plan.md for updates)

---

## Research Question

Did Colorado's 2019 decriminalization of fentanyl possession (HB 19-1263) increase overdose deaths, and did the 2022 partial recriminalization (HB 22-1326) reverse this trend?

---

## Policy Background

### Historical Context
The United States is experiencing an unprecedented fentanyl crisis. Synthetic opioids, primarily illicitly manufactured fentanyl, are now the leading cause of drug overdose deaths nationwide. States have experimented with different policy responses, ranging from decriminalization to enhanced criminal penalties.

### Colorado's Policy Experiment

**Phase 1: Decriminalization (2019)**
House Bill 19-1263, enacted in 2019, reduced possession of less than 4 grams of most controlled substances—including fentanyl—from a felony to a misdemeanor. Supporters argued this would treat drug use as a public health issue rather than a criminal justice matter. The law applied to Schedule I and II substances, with exceptions for "date-rape drugs."

**Phase 2: Partial Recriminalization (2022)**
Following a surge in fentanyl deaths (520 in 2020 → 803 in 2021), law enforcement and prosecutors pressured legislators to reverse course. House Bill 22-1326, signed May 25, 2022, made possession of more than 1 gram of fentanyl a Level 4 drug felony (punishable by up to 180 days in jail and 2 years probation). Possession of 1 gram or less remained a misdemeanor.

Key provisions of HB 22-1326:
- Created a felony for possessing >1 gram of fentanyl
- Allowed felony to be downgraded if defendant completes treatment
- Included "mistake of fact" defense if defendant didn't know substance contained fentanyl
- Allocated $30 million for harm reduction, Narcan distribution, and treatment

### Why This Matters
This is one of the only examples of a U.S. state decriminalizing drug possession and then partially reversing course. Most policy changes are unidirectional. Colorado's "policy reversal" creates a unique natural experiment to evaluate the effects of decriminalization vs. recriminalization on drug outcomes.

---

## Identification Strategy

### Primary Method: Difference-in-Differences with Synthetic Control

**Treatment Group:** Colorado
**Control Group:** Synthetic control constructed from donor pool of states without major drug policy changes in 2019-2022

**Pre-Treatment Period:** 2015-2018
**Treatment Period 1:** 2019-2021 (post-decriminalization)
**Treatment Period 2:** 2022-2024 (post-recriminalization)

### Key Identifying Assumptions

1. **Parallel Trends:** Absent policy changes, Colorado's overdose trends would have evolved similarly to the synthetic control
2. **No Anticipation:** Drug users and dealers did not change behavior in anticipation of the policy
3. **SUTVA:** No spillovers from Colorado's policy to other states

### Threats to Identification

1. **National Fentanyl Supply Shock:** Fentanyl flooded the U.S. drug supply during 2019-2022, affecting all states
2. **COVID-19 Pandemic:** Disrupted treatment access, social support, and may have increased drug use
3. **Oregon Measure 110:** Oregon decriminalized all drugs in 2020, providing a potential confounder for national trends

### Addressing Confounders

1. **Drug-Specific Analysis:** Compare fentanyl deaths to non-fentanyl opioid deaths, stimulant deaths
2. **Border County Analysis:** Compare Colorado border counties to neighboring state border counties
3. **Enforcement Intensity:** Use arrest/prosecution data to measure actual policy implementation
4. **Placebo Tests:** Test for effects in periods before policy changes
5. **Synthetic Control Weights:** Report donor state weights and conduct leave-one-out sensitivity

---

## Data Sources

### Primary Outcome Data

1. **Colorado Department of Public Health and Environment (CDPHE)**
   - State Unintentional Drug Overdose Reporting System (SUDORS)
   - Annual and monthly overdose deaths by county, 2015-2024
   - Drug type breakdown (any opioid, synthetic opioid, heroin, stimulants)
   - URL: cdphe.colorado.gov

2. **CDC WONDER Multiple Cause of Death**
   - State-level overdose mortality, all 50 states, 2015-2024
   - ICD-10 codes: X40-X44, X60-X64, X85, Y10-Y14 (drug overdose)
   - T40.4 (synthetic opioids other than methadone)
   - For synthetic control construction

### Secondary Outcome Data

3. **Colorado Division of Criminal Justice**
   - Quarterly jail population data (HB 19-1297)
   - Arrests by charge type
   - URL: ors.colorado.gov

4. **Drug Enforcement Administration (DEA)**
   - Fentanyl seizures by state (proxy for supply)

### Control Variables

5. **Census Bureau / ACS**
   - State demographics, poverty rates, health insurance coverage
   - County-level population for per-capita calculations

---

## Empirical Approach

### Step 1: Descriptive Analysis
- Plot Colorado vs. national overdose trends, 2015-2024
- Decompose by drug type (synthetic opioids, heroin, stimulants, all opioids)
- Show raw trends around policy change dates (2019, May 2022)

### Step 2: Synthetic Control Method
- Construct synthetic Colorado from donor pool (exclude Oregon, states with major policy changes)
- Match on pre-2019 overdose trends, demographics, economic indicators
- Report pre-treatment fit (RMSPE)
- Conduct placebo tests (apply method to all donor states)

### Step 3: Event Study
- Estimate dynamic treatment effects by year relative to policy change
- Test for pre-trends
- Show separate event studies for 2019 decriminalization and 2022 recriminalization

### Step 4: Robustness Checks
- Drug-specific analysis (fentanyl vs. other opioids vs. stimulants)
- Border county analysis
- Alternative donor pools
- Leave-one-out sensitivity
- Different outcome specifications (levels, logs, per capita)

---

## Expected Findings

### Hypothesis 1: Decriminalization Effect (2019)
The 2019 decriminalization may have had limited direct effect on overdose deaths, as:
- Supply-side factors (fentanyl flooding the market) likely dominate
- Possession penalties may not significantly affect user behavior
- Treatment diversion was already available under prior law

### Hypothesis 2: Recriminalization Effect (2022)
The 2022 recriminalization is unlikely to have substantially reduced overdose deaths because:
- Jail time (up to 180 days) is too short to affect long-term outcomes
- Treatment diversion provisions mean many avoid felony conviction
- Supply-side factors still dominant

### Alternative Hypothesis
If we observe differential effects (large increase after decriminalization, decline after recriminalization), this would provide evidence that criminal penalties do affect drug use behavior—a contested claim in the harm reduction literature.

---

## Paper Structure

1. **Introduction** (2-3 pages)
   - Policy context and national fentanyl crisis
   - Colorado's unique policy experiment
   - Contribution to literature

2. **Background** (3-4 pages)
   - Fentanyl crisis overview
   - Colorado's 2019 and 2022 legislation in detail
   - Related literature on drug decriminalization

3. **Data** (3-4 pages)
   - Data sources and construction
   - Summary statistics
   - Trends in overdose deaths

4. **Empirical Strategy** (4-5 pages)
   - Synthetic control method
   - Event study design
   - Identification assumptions and threats

5. **Results** (5-6 pages)
   - Main estimates
   - Drug-specific heterogeneity
   - Robustness checks

6. **Discussion** (2-3 pages)
   - Interpretation of findings
   - Policy implications
   - Limitations

7. **Conclusion** (1-2 pages)

**Target Length:** 25-30 pages (excluding appendix)

---

## Timeline

1. Data collection: Fetch CDPHE, CDC WONDER, arrest data
2. Descriptive analysis: Trends, summary statistics
3. Synthetic control construction and estimation
4. Event study estimation
5. Robustness checks
6. Writing and revision
7. Internal review (3-5 rounds)
8. External review (3-5 rounds)
9. Publish

---

## Risks and Contingencies

| Risk | Mitigation |
|------|------------|
| Pre-trends violated | Use drug-specific analysis; if fentanyl shows pre-trends, focus on mechanism |
| Synthetic control poor fit | Report honestly; use multiple estimation approaches |
| COVID confounding | Control for COVID-era indicators; acknowledge limitation |
| Data unavailable | Pivot to publicly available CDC WONDER only |
| Null results | Report honestly; null is informative for policy debate |

---

## Accountability Checkpoints

- [ ] initial_plan.md committed before data fetch
- [ ] Code committed before running
- [ ] All estimates reproducible from raw data
- [ ] Figures generated from code, not manually edited
