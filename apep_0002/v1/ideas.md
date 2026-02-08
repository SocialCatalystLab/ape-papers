# Research Ideas

Generated after exploration phase. Assigned states: **Maine (ME)**, **Texas (TX)**, **Iowa (IA)**.
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Maine Earned Paid Leave and Employment Effects

**Policy:** Maine's Earned Paid Leave Law (LD 369), effective January 1, 2021. First state to mandate paid leave for "any reason" (not restricted to sick/family leave). Employers with 10+ employees must provide 1 hour of paid leave per 40 hours worked, up to 40 hours annually. Employees can use leave for any purpose after 120 days of employment.

**Method:** DiD

**Research Question:** Did Maine's first-in-nation earned paid leave mandate affect employment, labor force participation, and hours worked among workers at firms near the 10-employee threshold?

**Data:**
- Source: Census PUMS 2019-2023 (ACS 1-year)
- Key variables: ESR (employment status), WKHP (hours worked), WAGP (wages), COW (class of worker), ST (state), PWGTP (weights)
- Sample: Workers aged 18-64 in Maine vs. comparison states (NH, VT) without universal paid leave mandates
- Sample size estimate: ~5,000-8,000 Maine workers per year; ~30,000+ across treatment and control

**Hypotheses:**
- Primary: Positive effect on labor force participation, particularly among women and workers with caregiving responsibilities, as access to flexible paid leave reduces barriers to employment
- Mechanism: Workers who previously faced tension between caregiving/personal needs and employment can now maintain employment while addressing personal obligations
- Heterogeneity: Effects should be strongest among women, workers aged 25-45 (prime caregiving years), and lower-wage workers who previously lacked paid leave benefits

**Novelty:**
- Literature search: Found no causal studies specifically on Maine's 2021 law. Paid sick leave literature exists (San Francisco, CT, etc.) but Maine's "any reason" leave is unique.
- Gap: No research on employment effects of universal "any reason" paid leave mandates
- Contribution: First causal estimate of labor market effects from unrestricted paid leave policy, providing evidence for states considering similar legislation

---

## Idea 2: Iowa Universal Occupational License Recognition and Interstate Migration

**Policy:** Iowa HF 2627, effective June 2020. Iowa became the 7th state to adopt universal license recognition, allowing workers licensed in any other state to practice in Iowa without re-licensure. One of the broadest implementations (no "substantially similar" requirement, few exemptions).

**Method:** DiD

**Research Question:** Did Iowa's universal occupational license recognition increase interstate migration of licensed workers and overall employment in licensed occupations?

**Data:**
- Source: Census PUMS 2018-2023 (ACS 1-year)
- Key variables: MIG (migration), MIGSP (migration state), OCCP (occupation), ESR (employment), WAGP (wages), ST (state), PWGTP (weights)
- Sample: Workers in licensed occupations (healthcare, legal, education, skilled trades) aged 25-64 who moved to Iowa vs. comparison states without universal recognition
- Sample size estimate: ~3,000-5,000 migrants per year to Iowa; ~50,000+ licensed occupation workers in Iowa

**Hypotheses:**
- Primary: Increased in-migration of licensed workers to Iowa, particularly in occupations with high licensing burdens
- Mechanism: Reduced barriers to cross-state mobility increase labor supply from workers who previously couldn't transfer credentials
- Heterogeneity: Effects should be largest for occupations with most burdensome licensing (healthcare, cosmetology, skilled trades) and among workers from neighboring states

**Novelty:**
- Literature search: Found NBER working paper 34030 (Oh & Kleiner) on universal license recognition and healthcare utilization, finding positive effects on healthcare access. Deyo & Plemmons (2022) examine mobility effects in Economics Letters.
- Gap: Existing research focuses on healthcare utilization or physician-specific mobility. No comprehensive study of labor supply and migration effects across all licensed occupations using individual-level microdata.
- Contribution: First comprehensive assessment of universal license recognition's effects on cross-state migration and employment across all licensed occupations using PUMS microdata

---

## Idea 3: Texas Nurse Mandatory Overtime Ban and Labor Supply

**Policy:** Texas Health and Safety Code Chapter 258 (S.B. 476), effective September 1, 2009. Prohibits hospitals from requiring nurses (RNs and LVNs) to work mandatory overtime except in declared disasters or emergencies. Provides job protection for nurses who refuse mandatory overtime.

**Method:** DiD

**Research Question:** Did Texas's nurse mandatory overtime ban affect nurse labor supply, hours worked, and employment in nursing occupations?

**Data:**
- Source: Census PUMS 2007-2012 (ACS 1-year)
- Key variables: OCCP (occupation - RN/LVN codes), WKHP (usual hours worked), ESR (employment), WAGP (wages), ST (state), PWGTP (weights)
- Sample: Registered nurses and licensed vocational nurses aged 21-64 in Texas vs. comparison states without overtime bans
- Sample size estimate: ~15,000-20,000 nurses per year in Texas; ~60,000+ across treatment and control states

**Hypotheses:**
- Primary: Reduction in average hours worked among nurses, with potential increase in nurse employment (extensive margin) as hospitals hire more nurses to cover shifts
- Mechanism: Without mandatory overtime, hospitals must either hire additional nurses or rely on voluntary overtime (with higher compensation), shifting labor from intensive to extensive margin
- Heterogeneity: Effects should be strongest in hospital settings (vs. outpatient), among nurses with caregiving responsibilities, and in areas with nurse shortages

**Novelty:**
- Literature search: Found PMC article (Bae et al. 2014) examining multiple state nurse overtime laws broadly, but no specific causal study of the 2009 Texas law's effects on nurse labor supply using individual-level data.
- Gap: No rigorous causal analysis of Texas's 2009 law using microdata. Existing literature focuses on patient outcomes and general trends, not individual-level labor supply responses.
- Contribution: First individual-level causal estimate of nurse overtime regulation effects on labor supply, informing ongoing policy debates about nurse working conditions

---

## Idea 4: Maine Cost-of-Living Indexed Minimum Wage Effects

**Policy:** Maine Question 4 (2016), effective January 7, 2017. Raised minimum wage from $7.50 to $9/hour in 2017, with annual increases reaching $12/hour by 2020, then annual CPI indexing. Maine is one of few states with automatic cost-of-living adjustments, providing continuous "treatment" over time.

**Method:** DiD

**Research Question:** Did Maine's minimum wage increase and subsequent CPI indexing affect employment, hours, and wages among low-wage workers compared to New Hampshire (no state minimum wage)?

**Data:**
- Source: Census PUMS 2015-2023 (ACS 1-year)
- Key variables: WAGP (wages), WKHP (hours), ESR (employment), SCHL (education), AGEP (age), ST (state), PUMA (geography), PWGTP (weights)
- Sample: Workers aged 16-64 earning below $15/hour (pre-treatment) in Maine vs. New Hampshire
- Sample size estimate: ~20,000-30,000 low-wage workers per year across both states

**Hypotheses:**
- Primary: Wage increase for affected workers with minimal negative employment effects, consistent with recent minimum wage literature
- Mechanism: Monopsony power in low-wage labor markets allows wage increases without proportional job losses; employer adjustments through reduced turnover, productivity gains, and price increases
- Heterogeneity: Effects concentrated among workers in retail, food service, and accommodation; largest wage effects for workers near old minimum, smallest employment effects in tight labor markets

**Novelty:**
- Literature search: Found MECEP descriptive analyses showing wage gains without job losses, but no peer-reviewed causal study specifically on Maine's 2017 reform and CPI indexing mechanism.
- Gap: No rigorous DiD study comparing Maine's indexed minimum wage to control states. The CPI indexing feature is understudied.
- Contribution: First causal estimate of Maine's minimum wage reform using PUMS microdata, with particular attention to the novel automatic indexing mechanism that other states are considering

---

## Exploration Notes

**Assigned States:** Maine (ME), Texas (TX), Iowa (IA)

**What I Searched:**
- State-specific labor and employment laws in all three states
- NCSL occupational licensing database for Texas
- Recent policy reforms (2018-2023) in each state
- Academic literature on each policy via NBER, Google Scholar

**What I Considered and Rejected:**
- **Iowa Child Labor Law (SF542, 2023):** Too recent for effects to appear in PUMS data; conflicts with federal law creating compliance uncertainty
- **Texas Permitless Carry (HB1927, 2021):** Cannot measure relevant outcomes (crime, gun ownership) with PUMS
- **Iowa Education Funding (SSA):** No clear threshold or timing; affects school districts not individuals measurable in PUMS
- **Texas Property Tax Homestead Exemption (Age 65):** Medicare at 65 RDD is exhausted; this is essentially the same threshold

**Why These 4 Rose to Top:**
1. **Maine Paid Leave:** True policy novelty (first "any reason" mandate), clean January 2021 implementation, measurable outcomes in PUMS, no causal research found
2. **Iowa License Recognition:** Some existing research but focused on healthcare/physicians; opportunity to study broader labor market effects across all occupations
3. **Texas Nurse Overtime:** Specific occupation with clear PUMS coding, older policy (2009) with long post-period, understudied in individual-level data
4. **Maine Minimum Wage:** Well-identified with NH as control, CPI indexing feature is novel policy mechanism worth studying
