# Research Ideas

## Idea 1: France's Apprenticeship Subsidy Boom: Net Job Creation or Relabeling?

**Policy:** France's "aide exceptionnelle à l'embauche d'alternants" — a massive apprenticeship hiring subsidy introduced in July 2020 (€5K for minors, €8K for adults), reduced to €6K flat in January 2023, then cut to €5K/<250 employees and €2K/≥250 employees in February 2025. The policy tripled new apprenticeship contracts from 306K (2017) to 879K (2024) at a cost of €15B/year. The firm-size threshold at 250 employees creates additional within-policy variation.

**Outcome:** Multiple complementary data sources:
1. Eurostat `lfsi_emp_q` — Quarterly youth (15-24) employment rates by country (2015Q1-2025Q3)
2. Eurostat `lfsi_neet_q` — Quarterly NEET rates by country
3. Indeed Hiring Lab job postings index — Daily by country and sector (France, Germany, Spain, Italy, Netherlands, UK) from Feb 2020
4. Eurostat `lfsq_etpga` — Temporary vs permanent employment by age group (quarterly)
5. DARES annual apprenticeship contract statistics (context/descriptive)

**Identification:** Triple-Difference (DDD): France × Youth (15-24) × Post-subsidy-change. Cross-country DiD uses Belgium, Netherlands, Spain, Italy, and Portugal as controls (similar labor market structures, no equivalent subsidy programs). Within-France age DiD compares youth (15-24) to prime-age (25-54) workers. Symmetric test: estimate both the 2020 introduction (positive shock) and 2023 reduction (negative shock) to verify the subsidy drives the effect.

**Why it's novel:**
- First causal evaluation of France's post-COVID apprenticeship subsidy (no academic papers exist on this €15B/year policy)
- Combines administrative enrollment data with high-frequency vacancy data from Indeed
- Tests the "relabeling" hypothesis: did firms create net new entry-level positions or just convert existing junior hires to subsidized apprenticeships?
- The 2023 reduction provides a symmetric natural experiment — rare in subsidy evaluation

**Feasibility check:**
- Eurostat R package (`eurostat`) provides direct API access to all quarterly LFS datasets ✓
- Indeed Hiring Lab data freely available on GitHub (CC BY 4.0), covers France with daily sector-level indices ✓
- Pre-treatment period: 2015Q1-2020Q2 = 22 quarters of pre-trends ✓
- Treatment variation across 6 EU countries × 2 age groups × multiple time periods ✓
- Not in APEP list, zero academic papers evaluating this specific French policy ✓

---

## Idea 2: UK Apprenticeship Levy and Firm Hiring Composition

**Policy:** UK's 2017 Apprenticeship Levy — 0.5% payroll tax on employers with >£3M annual pay bill, with smaller firms receiving co-investment support. The levy created a sharp incentive break at the £3M threshold and dramatically shifted employer behavior (apprenticeship starts fell 25% initially as firms adjusted).

**Outcome:** UK Labour Force Survey data via Eurostat, UK government apprenticeship statistics (explore-education-statistics.service.gov.uk), Indeed UK job postings.

**Identification:** RDD at the £3M payroll threshold (firms just above vs just below). Combined with DiD around the April 2017 introduction date.

**Why it's novel:** Most UK levy studies focus on learner outcomes, not firm hiring composition. Could study whether firms above the threshold substitute apprentices for junior employees.

**Feasibility check:**
- UK apprenticeship data available from DfE (annual, by sector, age, level) ✓
- No firm-level payroll data available via public APIs — threshold RDD would require firm registry data ✗
- Eurostat has UK data through 2020 only (post-Brexit data gaps) ✗
- **PARTIAL FEASIBILITY — firm-level data constraint makes RDD impractical**

---

## Idea 3: Australia's Boosting Apprenticeship Commencements (BAC) Expiration

**Policy:** Australia's BAC program (Oct 2020-June 2024) offered 50% wage subsidy for new apprentices. The sharp start/stop creates clean pre/post variation. The program went through multiple extensions and modifications.

**Outcome:** ABS Labour Force Survey (quarterly), Indeed Australia job postings, NCVER apprenticeship data.

**Identification:** DiD: Australia vs New Zealand (similar labor market, no equivalent subsidy). Pre/post BAC introduction and expiration.

**Why it's novel:** Under-studied outside of policy reports. Sharp temporal boundaries useful for event-study designs.

**Feasibility check:**
- ABS data requires manual download (no API for detailed age breakdowns) ✗
- NCVER data may not be freely downloadable ✗
- Indeed Australia data available on GitHub ✓
- New Zealand comparator viable but questionable parallel trends ✓
- **PARTIAL FEASIBILITY — data access constraints**

---

## Idea 4: Pan-European Comparison of Post-COVID Training Subsidies and Youth Labor Markets

**Policy:** Multiple EU countries introduced temporary training/apprenticeship subsidies during COVID. Key variation: France (generous, extended), Spain (moderate SEPE subsidies), Italy (existing incentivi apprendistato, expanded), Germany (Bundesprogramm Ausbildungsplätze, targeted). Cross-country variation in subsidy generosity, duration, and phase-out timing.

**Outcome:** Eurostat quarterly data for all EU-27 countries + Indeed job postings for 6 covered countries.

**Identification:** Continuous treatment DiD using subsidy generosity (€/apprentice) × policy duration as treatment intensity. Countries with no/minimal subsidies (Netherlands, Belgium) as controls.

**Why it's novel:** Comparative evaluation of pandemic-era training subsidies across multiple countries with harmonized outcome data.

**Feasibility check:**
- Eurostat data covers all countries with harmonized methodology ✓
- Indeed covers 6 countries (France, Germany, Spain, Italy, Netherlands, UK) ✓
- Subsidy generosity data would need to be compiled from government sources (feasible but labor-intensive) ✓
- Risk: heterogeneous labor market institutions make cross-country comparison noisy ⚠
- **FEASIBLE but potentially underpowered for causal claims**
