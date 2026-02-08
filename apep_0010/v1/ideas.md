# Research Ideas

Generated after exploration phase for DiD analysis. Assigned states: Alabama, New York, South Carolina.
Submit to `rank_ideas.py` for GPT ranking before committing to data work.

---

## Idea 1: New York Sexual Harassment Training Mandate

**Policy:** New York State became the first state to mandate comprehensive sexual harassment prevention training for ALL employers regardless of size. Effective October 9, 2018, employers had to adopt a sexual harassment prevention policy. By October 9, 2019, all employers had to provide annual interactive anti-sexual harassment training to every employee (full-time, part-time, seasonal, temporary).

**Method:** DiD

**Research Question:** Did New York's mandatory sexual harassment prevention training requirement affect female employment and retention in the state?

**Data:**
- Source: Census ACS PUMS 2016-2021
- Key variables: ST (state), SEX, ESR (employment status), WAGP (wages), COW (class of worker), NAICS (industry), PWGTP (weights)
- Sample: Working-age adults (18-64) employed in private sector
- Sample size estimate: ~500,000 NY observations, ~2M control state observations

**Hypotheses:**
- Primary: The training mandate may have improved workplace climate for women, increasing female employment and retention in NY relative to control states
- Mechanism: Training reduces tolerance for harassment, encouraging women to enter/remain in labor force; alternatively, compliance costs could reduce hiring
- Heterogeneity: Effects should be strongest in male-dominated industries where harassment is more prevalent

**Novelty:**
- Literature search: No NBER or academic papers found specifically studying employment effects of sexual harassment training mandates. Most research on sexual harassment focuses on prevalence and reporting, not policy interventions.
- Gap: No causal analysis of state-level training mandate effects on labor market outcomes
- Contribution: First causal evidence on whether mandatory harassment prevention training affects female labor force participation

---

## Idea 2: Alabama Salary History Ban

**Policy:** Alabama passed a salary history ban effective September 1, 2019. Employers may not refuse to hire, interview, promote, or employ a job applicant based on the applicant's decision not to provide pay history. Unlike stronger bans (e.g., California), Alabama's version allows employers to still ask about salary history but cannot penalize non-disclosure.

**Method:** DiD

**Research Question:** Did Alabama's salary history ban reduce the gender wage gap among job changers in the state?

**Data:**
- Source: Census ACS PUMS 2017-2022
- Key variables: ST (state), SEX, WAGP (wages), ESR (employment status), MIG (migration/job change proxy), OCCP (occupation), PWGTP (weights)
- Sample: Working-age adults (25-54) employed in private sector, with focus on recent job changers
- Sample size estimate: ~100,000 AL observations, ~500,000 control state observations

**Hypotheses:**
- Primary: The salary history ban should increase wages for women and minorities who previously had lower salaries, narrowing the gender/racial wage gap
- Mechanism: Breaking the link between past and future pay reduces perpetuation of historical discrimination
- Heterogeneity: Strongest effects among job changers, women, and workers in occupations with larger pre-existing gaps

**Novelty:**
- Literature search: Found ~5-10 papers on salary history bans. Hansen & McNichols (NBER 27054) studied early state-wide bans; Agan et al. (NBER 29460) did experimental work. Most studies focus on California, Massachusetts, or NYC.
- Gap: No study specifically examines Alabama's weaker "cannot penalize non-disclosure" variant. Southern state context also differs from coastal states.
- Contribution: First evidence on wage effects in a weak-enforcement salary history ban state; tests whether ban type matters

---

## Idea 3: South Carolina Military Spouse Licensing Reciprocity

**Policy:** South Carolina enacted the "Armed Services Members and Spouses Professional and Occupational Licensing Act" (2019-2020) requiring licensing boards to issue temporary licenses to military spouses with credentials from other states and to accept military training toward licensing requirements.

**Method:** DiD

**Research Question:** Did South Carolina's military spouse licensing reciprocity policy increase employment among military spouses?

**Data:**
- Source: Census ACS PUMS 2017-2022
- Key variables: ST (state), MIL (military service), RELSHIPP (relationship to householder), ESR (employment), OCCP (occupation), COW (class of worker), PWGTP
- Sample: Spouses in military households, working age
- Sample size estimate: ~5,000 SC military spouse observations, ~20,000 control state observations

**Hypotheses:**
- Primary: Licensing reciprocity should increase employment among military spouses in licensed occupations (nurses, teachers, etc.)
- Mechanism: Reduces time and cost barriers to employment after PCS moves
- Heterogeneity: Strongest effects in licensed professions; may vary by base proximity

**Novelty:**
- Literature search: DOD reports document the problem; no academic papers found studying state licensing reciprocity effects on military spouse employment
- Gap: Causal evidence on state policy effectiveness for military spouse employment
- Contribution: First DiD analysis of military spouse licensing reform effects

---

## Idea 4: New York Predictive Scheduling / Fair Workweek Law

**Policy:** NYC's Fair Workweek Law took effect November 26, 2017, requiring fast food and large retail employers to provide predictable schedules (14 days advance notice for fast food, 72 hours for retail), ban on-call scheduling, premium pay for schedule changes, and 11-hour rest between shifts.

**Method:** DiD

**Research Question:** Did NYC's Fair Workweek law affect employment and hours in the fast food and retail sectors?

**Data:**
- Source: Census ACS PUMS 2015-2020
- Key variables: ST (state), NAICS (industry), WKHP (hours worked), ESR (employment), WAGP (wages), PWGTP
- Sample: Fast food (NAICS 7222) and retail (NAICS 44-45) workers in NY vs control states
- Sample size estimate: ~50,000 NY retail/food service observations, ~200,000 control state observations

**Hypotheses:**
- Primary: Predictable scheduling requirements may reduce employment/hours as employers adjust to compliance costs, OR improve retention by improving job quality
- Mechanism: Reduced scheduling flexibility increases labor costs; but stable schedules may reduce turnover
- Heterogeneity: Concentrated in fast food and large retail; may affect part-time workers more

**Novelty:**
- Literature search: Some early studies on Seattle/San Francisco laws but limited causal evidence. No NBER paper found on NYC's law specifically.
- Gap: NYC's comprehensive law covers more workers and has specific clopenings ban
- Contribution: Causal evidence on employment effects of predictive scheduling in nation's largest city

---

## Exploration Notes

**States assigned:** Alabama (AL), New York (NY), South Carolina (SC)
**Method assigned:** DiD

**Search process:**
1. Searched for unique state policies in each assigned state (2017-2021)
2. Focused on labor/employment policies with clean implementation dates
3. Checked NBER and Google Scholar for existing research

**Policies considered but rejected:**
- NY Paid Family Leave (2018): Already extensively studied (NBER 28672 and others)
- NYC Salary History Ban (2017): Well-studied, and city-level creates ID issues
- Alabama Overtime Tax Exemption (2024): Too recent for PUMS data
- Alabama criminal justice/ban-the-box: No state-wide policy passed
- SC paid parental leave: Only implemented in 2022, too recent

**Top candidates ranked by promise:**
1. NY Sexual Harassment Training - Most novel, large-scale natural experiment, clear timing
2. AL Salary History Ban - Moderately novel (less studied than CA/MA), clean identification
3. SC Military Spouse Licensing - Very novel but small sample size concern
4. NYC Fair Workweek - Novel but city-level identification is challenging with state PUMS

**Recommendation:** Idea 1 (NY Sexual Harassment Training) offers the best combination of novelty, clean identification, and adequate sample size.

---

## Selection Rationale

**GPT Ranking Result:**
1. NYC Fair Workweek Law (68/100, PURSUE)
2. NY Sexual Harassment Training (63/100, CONSIDER)
3. Alabama Salary History Ban (54/100, CONSIDER)
4. SC Military Spouse Licensing (46/100, SKIP)

**Selected Idea:** NYC Fair Workweek Law (Idea 4)

**Rationale for selection:**
GPT's key insight is that this study is viable IF redesigned with PUMA-based identification to isolate NYC from the rest of New York State. The ACS PUMS includes PUMA codes that can identify NYC PUMAs, enabling:

1. **Geographic treatment identification**: NYC PUMAs (36005, 36047, 36061, 36081, 36085 boroughs) vs. non-NYC NY PUMAs vs. other large metro PUMAs
2. **Industry treatment identification**: Fast food (NAICS 7222xx) and retail (NAICS 44-45) vs. other industries
3. **Triple-difference design**: NYC × Affected Industries × Post-Nov2017

This addresses GPT's main concern about using state-level identification for a city-level policy.

**Why not the higher-novelty Idea 2?**
While NY Sexual Harassment Training is more novel, GPT correctly notes the outcomes (female employment, retention) are "far from the compliance margin" and hard to measure. The mechanism from training → employment is diffuse and subject to many confounds (#MeToo timing, other NY policies).

**Why not Ideas 2-3?**
- Alabama Salary History: MIG is poor proxy for job changes; salary history ban literature already substantial
- SC Military Spouse: Sample size constraint is binding; COVID timing overlap
