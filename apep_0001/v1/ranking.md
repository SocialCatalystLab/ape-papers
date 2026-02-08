# Research Idea Ranking

**Generated:** 2026-01-17T01:19:01.616175
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4714

---

### Rankings

**#1: State Hair Braider Licensing Deregulation and Entrepreneurship**
- **Score: 73/100**
- **Strengths:** Extremely high novelty and clear policy lever (licensing barriers) with first-order relevance for entry/entrepreneurship, especially for Black women. PUMS can measure self-employment/class of worker and income at scale, enabling distributional and heterogeneity analysis.
- **Concerns:** The biggest risk is *treatment mismeasurement*: Census occupation codes don’t cleanly isolate “hair braiders” from broader personal appearance workers, so estimates may be heavily attenuated and/or pick up compositional shifts. Policy timing/adoption may be endogenous (states deregulate when informal markets already large), and mobility across states could further blur exposure.
- **Novelty Assessment:** Very lightly studied causally for hair braiding specifically; lots on occupational licensing generally, but this particular deregulation channel is close to “open field.”
- **Recommendation:** **PURSUE** (but only if you can build a credible policy database + show the occupation coding captures affected workers; consider a triple-diff design and strong placebo tests).

---

**#2: State Compulsory Schooling Age Increases and Educational/Labor Market Outcomes**
- **Score: 67/100**
- **Strengths:** Policy question is intrinsically important and the recent (2010s) wave is plausibly less covered than the classic early-20th-century compulsory schooling literature. Large samples in PUMS support cohort-by-state designs and subgroup analysis.
- **Concerns:** Exposure assignment is tricky: PUMS observes current state (and sometimes birth state), not state of residence at age 16—migration creates substantial measurement error in treatment, likely biasing toward zero. Identification is also vulnerable to contemporaneous education reforms and differential pre-trends; effects on “long-run” outcomes may not be fully realized for recent cohorts.
- **Novelty Assessment:** Compulsory schooling laws are heavily studied historically and via IV (e.g., Angrist-Krueger style), but the *modern US state reforms* are less systematically evaluated—moderate novelty.
- **Recommendation:** **CONSIDER** (promising if you can improve exposure measurement—e.g., restrict to low-mobility groups, use CPS/administrative education data, or validate migration sensitivity).

---

**#3: State Nurse Practitioner Full Practice Authority and Labor Supply**
- **Score: 62/100**
- **Strengths:** Clear mechanism and good outcome measurement in PUMS (hours, employment, wages, self-employment) with a reasonably identifiable occupation. Post-2020 changes (including COVID-era expansions) could add incremental value if carefully coded.
- **Concerns:** Novelty is limited because this has already attracted targeted health-econ work; your contribution risks being “update + extra outcomes.” Identification is challenged by endogeneity (states change SOP laws in response to provider shortages/political economy) and major coincident shocks (ACA dynamics, COVID demand shifts, telehealth, temporary emergency orders) that can violate parallel trends.
- **Novelty Assessment:** Already an active niche with multiple recent papers; not saturated like minimum wage, but not new.
- **Recommendation:** **CONSIDER** (only if you can (i) sharply code *full vs partial vs temporary* expansions, (ii) use modern staggered-adoption DiD methods, and (iii) show clean pre-trends/event studies).

---

**#4: State Paid Family Leave and Maternal Labor Force Participation**
- **Score: 55/100**
- **Strengths:** High policy relevance and PUMS supports large-sample analysis of employment/hours/wages around childbirth (via “birth in last 12 months”). Newer programs (WA/MA/CT) give some additional variation beyond California/NJ/RI/NY.
- **Concerns:** This topic is very heavily studied, so the bar for a contribution is high; “another DiD with ACS” will be hard to place unless it answers a genuinely new margin (e.g., specific design features, eligibility thresholds, or interactions with employer leave). Identification is also hard with few treated states, staggered timing, and concurrent policy changes; wage effects are particularly noisy in short panels around births.
- **Novelty Assessment:** Low—large existing literature; marginal novelty mainly from the newest states and post-2020 labor market context.
- **Recommendation:** **SKIP** unless you have a genuinely distinctive angle (e.g., exploiting eligibility cutoffs, admin claims data, or firm/earnings records).

---

**#5: State Automatic Voter Registration (AVR) and Civic Participation**
- **Score: 30/100**
- **Strengths:** Policymakers care, and there is abundant policy variation across states over the last decade.
- **Concerns:** As proposed, the data do not match the question: ACS/Census PUMS does not measure registration or voting, so you can’t credibly estimate AVR effects without switching to CPS Voting & Registration Supplement, voter files, or administrative DMV/voter-roll data. Even with better data, this is a fairly active literature and clean identification is nontrivial due to concurrent election administration changes.
- **Novelty Assessment:** Moderate-to-low; multiple academic and policy studies already estimate AVR impacts.
- **Recommendation:** **SKIP** (in its current PUMS-based form).

---

### Summary

This is a solid batch in the sense that two ideas (hair-braider deregulation; modern compulsory schooling age increases) target policies that are plausibly understudied relative to their importance. I would start with **Hair Braider Licensing Deregulation** because it has the highest upside on novelty—*but only if you can convincingly measure both the policy and the affected occupation*—and keep **Compulsory Schooling Age** as the main backup if you can address migration/exposure measurement.