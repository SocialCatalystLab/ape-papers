# Research Ideas: Birth Control / Reproductive Health RDD

## Idea 1: Aging Out of Parental Insurance at 26 and Fertility Decisions

**Policy:** ACA Dependent Coverage Provision (2010) - Young adults can stay on parents' health insurance until age 26, then must obtain own coverage.

**Outcome:** Birth in past 12 months (FER variable in ACS PUMS), health insurance coverage type

**Identification:** Sharp Regression Discontinuity Design at age 26
- Running variable: Age in years (AGEP in ACS)
- Cutoff: 26 years old
- Treatment: Loss of eligibility for parental insurance coverage

**Why it's novel:**
- Existing RDD studies at age 26 focus on insurance coverage and labor market outcomes (Dahlen 2015, Yörük & Xu 2018)
- Existing fertility studies of ACA use DiD comparing young adults to older adults, not the sharp age 26 discontinuity
- Gap: No RDD specifically examining fertility/birth outcomes at the age 26 threshold
- Mechanism: Loss of insurance → reduced access to contraception/prenatal care → changed fertility timing

**Data source:** Census ACS PUMS via Census API
- Has AGEP (age), FER (gave birth in past 12 months), SEX
- Has HICOV, PUBCOV, PRIVCOV (insurance coverage types)
- Has POVPIP (income-to-poverty ratio) for heterogeneity analysis
- Individual-level microdata with ~3 million observations/year

**Feasibility check:**
- ✓ Sharp cutoff exists at exactly age 26
- ✓ Data accessible via Census API (no IPUMS needed)
- ✓ Large sample sizes for precise estimates
- ✓ Outcome directly measured (gave birth in past 12 months)
- ⚠️ Age in ACS is in years, not months (coarser running variable)
- ⚠️ ACA age 26 provision well-studied for other outcomes

**RDD Feasibility Assessment:**

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Cutoff sharpness | Strong | Discrete age threshold, applies universally |
| Manipulation | Strong | Cannot manipulate birthday |
| Running variable precision | Marginal | Age in years, not months |
| Outcome relevance | Strong | FER directly measures fertility |
| Novelty | Medium | New outcome, known cutoff |

---

## Idea 2: Title X Income Threshold and Contraceptive Access

**Policy:** Title X Family Planning Program - Free contraceptive services for individuals at or below 100% FPL, sliding scale to 250% FPL

**Outcome:** Birth in past 12 months, insurance coverage

**Identification:** Fuzzy RDD at 100% FPL income threshold
- Running variable: Income-to-poverty ratio (POVPIP in ACS)
- Cutoff: 100% FPL (free services) or 250% FPL (any subsidy)
- Treatment: Eligibility for free/subsidized family planning services

**Why it's novel:**
- Title X income thresholds have not been studied using RDD
- Most Title X research uses DiD around policy changes or cross-sectional comparisons
- Mechanism: Free contraception access → reduced unintended pregnancies

**Data source:** Census ACS PUMS
- Has POVPIP (income-to-poverty ratio, 0-500+)
- Has FER (gave birth), age, demographics

**Feasibility check:**
- ✓ Cutoff defined in federal policy
- ✓ Data available via Census API
- ⚠️ Fuzzy discontinuity (not everyone eligible uses Title X)
- ⚠️ Income cutoff may be manipulable (fuzzy compliance)
- ⚠️ ACS doesn't identify Title X clinic users directly

**RDD Feasibility Assessment:**

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Cutoff sharpness | Weak | Income is continuous, self-reported |
| Manipulation | Marginal | Some income manipulation possible |
| Running variable precision | Strong | POVPIP is continuous |
| Outcome relevance | Strong | FER directly measures fertility |
| Novelty | High | Not studied with RDD |

---

## Idea 3: State IVF Insurance Mandate Age Limits

**Policy:** State IVF insurance mandates with explicit age cutoffs:
- New Jersey: Coverage until age 45 (retrieval) / 46 (transfer)
- Rhode Island: Coverage only ages 25-42

**Outcome:** IVF utilization, live births from ART

**Identification:** Sharp RDD at state-specific age cutoffs
- Running variable: Age
- Cutoff: 42 (RI), 45 (NJ)
- Treatment: Loss of insurance coverage for IVF

**Why it's novel:**
- State IVF age cutoffs have not been studied with RDD
- Could reveal intensive margin effects of insurance on fertility treatment

**Data source:** CDC NASS ART Data

**Feasibility check:**
- ✓ Sharp, legally-defined age cutoffs
- ✓ Policy variation across states
- ✗ CDC ART data is clinic-level, not individual-level
- ✗ Cannot identify individual women by exact age
- ✗ Small sample sizes in mandate states

**RDD Feasibility Assessment:**

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Cutoff sharpness | Strong | Legally defined age limits |
| Manipulation | Strong | Cannot manipulate age |
| Running variable precision | N/A | No individual-level data |
| Outcome relevance | Strong | IVF cycles directly affected |
| Novelty | High | Not studied |

**VERDICT: NOT FEASIBLE** - Insufficient individual-level data

---

## Idea 4: Medicare Eligibility at 65 and Fertility Treatment Coverage

**Policy:** Medicare eligibility begins at age 65

**Outcome:** Late-life fertility treatments, egg freezing decisions

**VERDICT: NOT FEASIBLE** - Age 65 is post-reproductive age; Medicare does not cover fertility treatments regardless.

---

## Idea 5: ACA Age 26 with State Variation in Pre-ACA Dependent Coverage Laws

**Policy:** ACA age 26 provision (2010), but some states had similar laws before 2010:
- Pre-ACA: NJ (30), PA (30), SD (30), WI (27), IL (30), UT (26), etc.
- Post-ACA: Universal age 26 cutoff

**Outcome:** Birth rates, insurance coverage

**Identification:** Difference-in-Discontinuities design
- Compare RDD slope/intercept changes before vs. after ACA
- Use pre-ACA states as controls

**Why it's novel:**
- Combines RDD with state policy variation
- Can isolate the insurance mechanism more cleanly

**Data source:** Census ACS PUMS (2008-2022)

**Feasibility check:**
- ✓ Historical ACS data available
- ✓ State of residence identified in ACS
- ⚠️ Complex design (RDD + DiD hybrid)
- ⚠️ Pre-ACA state laws varied in details (eligibility requirements)

**RDD Feasibility Assessment:**

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Cutoff sharpness | Strong | Age cutoffs well-defined |
| Manipulation | Strong | Cannot manipulate birthday |
| Running variable precision | Marginal | Age in years |
| Outcome relevance | Strong | FER directly measured |
| Novelty | High | Diff-in-disc not done for fertility |

---

## Summary Ranking

| Idea | Feasibility | Novelty | Identification | Recommended |
|------|-------------|---------|----------------|-------------|
| 1. ACA Age 26 → Fertility | High | Medium | Strong | **PURSUE** |
| 2. Title X Income Threshold | Medium | High | Weak (fuzzy) | CONSIDER |
| 3. State IVF Age Limits | Low | High | N/A (no data) | SKIP |
| 4. Medicare 65 + Fertility | N/A | N/A | N/A | SKIP |
| 5. Diff-in-Disc (ACA + state) | Medium | High | Medium | CONSIDER |

**Primary recommendation: Idea 1 (ACA Age 26 → Fertility)**

This study would examine whether the loss of parental health insurance coverage at age 26 affects fertility decisions among young women. Using ACS PUMS microdata and a sharp RDD at age 26, we can estimate the causal effect of insurance access on birth probability.

**Key research questions:**
1. Does fertility (birth probability) change discontinuously at age 26?
2. Is this effect mediated by changes in health insurance coverage?
3. Are effects larger for women in states that did not expand Medicaid?
4. Do effects differ by income, race/ethnicity, or education?
