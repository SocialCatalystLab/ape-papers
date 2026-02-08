# Research Ideas

Generated after exploration phase focusing on assigned states: NH, AR, NE.
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: Arkansas Minimum Wage Stair-Step Increases (2019-2021)

**Policy:** Arkansas Issue 5 (2018) mandated minimum wage increases from $8.50 to $11.00 over three years: $9.25 (Jan 1, 2019), $10.00 (Jan 1, 2020), $11.00 (Jan 1, 2021). The measure passed with 68.5% voter approval. No exemptions for small employers or teens were added despite legislative attempts.

**Method:** DiD

**Research Question:** Did Arkansas's stair-step minimum wage increase from $8.50 to $11.00 (2019-2021) affect employment and wages of low-wage workers compared to neighboring states without similar increases?

**Data:**
- Source: Census PUMS 2017-2022 (pre/post periods)
- Key variables: WAGP (wages), ESR (employment status), WKHP (hours), ST (state), AGEP (age), SCHL (education), PWGTP (weight)
- Sample: Working-age adults (18-64) in Arkansas (ST=05) vs neighboring states (OK=40, MS=28, LA=22, MO=29, TN=47)
- Sample size estimate: ~15,000 Arkansas workers/year, ~100,000 control state workers/year

**Hypotheses:**
- Primary: Minimum wage increase raised wages for workers at the bottom of the distribution with minimal employment effects
- Mechanism: Arkansas's increase to 74% of median wage (unusually high ratio) may produce larger effects than typical increases (37-59% of median)
- Heterogeneity: Strongest effects for young workers, workers without college degrees, service sector workers

**Novelty:**
- Literature search: Extensive minimum wage literature exists (Cengiz et al. 2019, Dube 2019), but no NBER or major causal study found specifically on Arkansas's 2018-2021 increase. Most studies examine federal or coastal state increases.
- Gap: Arkansas's increase is unusually large relative to median wage (74% vs typical 37-59%), making it a unique natural experiment. Southern state minimum wage increases are understudied.
- Contribution: First causal evaluation of Arkansas's 2018-2021 minimum wage increase; tests whether employment effects differ when increase is large relative to local wages.

---

## Idea 2: Arkansas Fair Chance Licensing Reform (Act 990, 2019)

**Policy:** Arkansas Act 990 (effective July 24, 2019) reformed occupational licensing for people with criminal records: (1) prohibited use of "moral turpitude" and "good character" criteria, (2) established 5-year limit on considering felony convictions, (3) allowed pre-application petition to determine if criminal history would be disqualifying.

**Method:** DiD

**Research Question:** Did Arkansas's 2019 fair chance licensing reform increase employment in licensed occupations relative to unlicensed occupations?

**Data:**
- Source: Census PUMS 2017-2022
- Key variables: ESR (employment), OCCP (occupation code), WAGP (wages), ST (state), AGEP (age), PWGTP (weight)
- Sample: Working-age adults (18-64) in Arkansas vs control states without similar reforms (compare licensed vs unlicensed occupations)
- Sample size estimate: ~5,000 Arkansas workers in licensed occupations/year

**Hypotheses:**
- Primary: Employment in licensed occupations increased in Arkansas post-2019 relative to unlicensed occupations
- Mechanism: Removing criminal record barriers allows more people to enter licensed professions
- Heterogeneity: Strongest effects in occupations with historically high criminal record restrictions (healthcare, education)

**Novelty:**
- Literature search: Illinois 2017 reform studied by researchers (published 2024) using DiD. Arkansas's reform is different (5-year rule, pre-petition process). Nine states enacted similar reforms in 2019.
- Gap: No causal evaluation of Arkansas's specific reform. Multi-state comparison possible but not yet done.
- Contribution: Extends fair chance licensing literature to Southern state; tests whether 5-year rule and pre-petition process design matters.

**Note:** Main limitation is PUMS doesn't directly identify individuals with criminal records. Would need to use licensed vs. unlicensed occupation comparison or proxy using demographic characteristics associated with criminal justice involvement.

---

## Idea 3: Nebraska Occupational Board Reform Act (LB299, 2018)

**Policy:** Nebraska's Occupational Board Reform Act (LB299, signed April 23, 2018) required: (1) 5-year cycle of legislative license review, (2) "least restrictive" standard for new regulations, (3) criminal record pre-petition process allowing applicants to determine disqualifying status before completing training. Nebraska became 4th state with comprehensive licensing reform.

**Method:** DiD

**Research Question:** Did Nebraska's 2018 Occupational Board Reform Act increase employment or wages in licensed occupations compared to neighboring states?

**Data:**
- Source: Census PUMS 2016-2022
- Key variables: ESR (employment), OCCP (occupation code), WAGP (wages), ST (state), PWGTP (weight)
- Sample: Working-age adults (18-64) in Nebraska (ST=31) vs neighbors (IA=19, KS=20, SD=46, WY=56, CO=08, MO=29)
- Sample size estimate: ~3,000 Nebraska workers in licensed occupations/year

**Hypotheses:**
- Primary: Employment in licensed occupations increased in Nebraska post-2018 relative to control states
- Mechanism: Reduced barriers to entry through ongoing license review and criminal record reforms
- Heterogeneity: Effects should be largest in occupations that underwent legislative review and had requirements reduced

**Novelty:**
- Literature search: No quantitative studies found on Nebraska LB299's employment effects. Platte Institute published policy analysis but no causal evaluation.
- Gap: First evaluation of comprehensive licensing reform (vs. targeted reforms like fair chance licensing)
- Contribution: Tests whether systemic licensing review produces measurable employment effects.

**Note:** Challenge is identifying which specific licenses were modified through the review process. May need supplementary data from Nebraska legislative records.

---

## Idea 4: Universal License Recognition and Interstate Migration

**Policy:** Arizona pioneered universal license recognition (ULR) in 2019, allowing workers with valid out-of-state licenses to work without re-licensing. New Hampshire adopted ULR in 2019 (with "substantially similar" requirement) and strengthened it in 2023. By 2024, 20+ states have some form of ULR.

**Method:** DiD

**Research Question:** Did adoption of universal license recognition increase interstate migration of licensed workers to adopting states?

**Data:**
- Source: Census PUMS 2017-2023
- Key variables: MIGSP (migration state 1 year ago), ST (current state), OCCP (occupation), ESR (employment), PWGTP (weight)
- Sample: Working-age adults (25-60) with recent interstate moves (MIGSP != ST), focusing on licensed occupations
- Sample size estimate: ~500,000 interstate movers/year nationally, ~50,000 in licensed occupations

**Hypotheses:**
- Primary: ULR adoption increased in-migration of licensed workers by reducing mobility barriers
- Mechanism: License portability reduces costs of interstate moves for affected workers
- Heterogeneity: Strongest effects for occupations with largest pre-ULR licensing barriers; stronger for states without "substantially similar" requirements (IA, MO, ID, UT)

**Novelty:**
- Literature search: Bae & Timmons (Archbridge Institute) found ~50% increase in in-migration and 1 percentage point employment gain. Published in Economics Letters (2022).
- Gap: Existing research uses administrative licensing data. PUMS-based analysis could capture broader labor market effects and compare across states with different ULR designs.
- Contribution: First PUMS-based evaluation; comparison of "substantially similar" vs. universal recognition designs.

**Note:** Some research already exists but used different data sources. Novelty depends on adding state design variation comparison.

---

## Idea 5: New Hampshire Day of Rest Requirement (Historical RDD)

**Policy:** New Hampshire requires that employees working on Sundays must receive a 24-hour consecutive rest period within the following 6 days. This is a unique labor protection not common in other states.

**Method:** RDD (potential)

**Research Question:** Does New Hampshire's mandatory rest period requirement affect worker outcomes at the state border compared to neighboring states?

**Data:**
- Source: Census PUMS 2017-2023
- Key variables: WKHP (hours), WAGP (wages), ESR (employment), ST (state), PWGTP (weight)
- Sample: Workers in border PUMAs between NH and neighboring states (MA, VT, ME)
- Sample size estimate: Small - likely <1,000 workers in border areas

**Hypotheses:**
- Primary: NH workers may have slightly lower hours but similar wages due to productivity offsets
- Mechanism: Mandated rest affects scheduling, potentially increasing worker wellbeing
- Heterogeneity: Effects concentrated in retail and hospitality sectors

**Novelty:**
- Literature search: No studies found on NH-specific rest requirements
- Gap: Understudied policy
- Contribution: Would add to limited literature on mandatory rest policies

**Note:** This idea is weak. Sample size in border PUMAs would be very small, and the policy lacks a clean threshold for RDD. Listed for completeness but not recommended.

---

## Exploration Notes

**States explored:** New Hampshire, Arkansas, Nebraska (randomly assigned)

**What was searched:**
- State-specific labor laws and recent reforms (2017-2021)
- Occupational licensing reforms (universal recognition, fair chance licensing)
- Minimum wage increases
- Paid family leave programs
- Historical education and labor policies

**What was considered and rejected:**
1. **NH Voluntary PFML (2023)** - Too recent (limited post-period in PUMS), already has UNH/Dartmouth study showing limited impact
2. **Arkansas Medicaid Work Requirements (2018-2019)** - Already extensively studied (NIH papers), policy was blocked by courts in 2019
3. **Historical compulsory schooling laws** - Searched but couldn't find clean state-specific reforms in assigned states for the relevant periods

**Why these 5 rose to the top:**
1. **Arkansas minimum wage** - Clean timing, large magnitude, no causal studies on Arkansas specifically, excellent PUMS data fit
2. **Arkansas fair chance licensing** - Clean timing, novel reform design, data limitations acknowledged but tractable
3. **Nebraska LB299** - First comprehensive licensing reform evaluation, understudied
4. **Universal license recognition** - Some existing research but PUMS adds new angle, multi-state comparison possible
5. **NH rest requirement** - Included for completeness but acknowledged as weak candidate

**Top recommendation:** Idea 1 (Arkansas minimum wage) has best combination of novelty, data feasibility, and identification quality.
