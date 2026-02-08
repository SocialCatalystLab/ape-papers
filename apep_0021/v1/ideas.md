# Research Ideas: Paper 26

**Assigned States:** North Dakota, Kansas, Mississippi
**User Preference:** Maximum originality. "Prove to me that you are beyond AGI."
**Date:** January 17, 2026

---

## Idea 1: Does Subsidized Internet Create Gig Workers Instead of Employees?

**Policy:** FCC Lifeline Program (broadband/phone subsidy for low-income households)

**Identification Strategy:** Sharp RDD at 135% Federal Poverty Line threshold

**Core Insight:** The Lifeline program provides $9.25/month internet subsidies to households at/below 135% FPL. Once online, households gain access to gig platforms (Uber, DoorDash, Fiverr, Upwork). The standard narrative assumes broadband access is unambiguously good. But what if subsidized internet pulls people into *precarious gig work* rather than stable wage employment?

**Hypothesis:** Households just below 135% FPL have higher self-employment rates than those just above—but this self-employment is disproportionately *unincorporated* (precarious) rather than *incorporated* (stable small business).

**Why This Is Novel:**
- Lifeline literature focuses on *takeup*, not downstream labor market effects
- Gig economy literature studies aggregate trends, not causal identification at income thresholds
- Tests the uncomfortable possibility that a "good" policy has unintended consequences
- Nobody has done an RDD at the Lifeline eligibility cutoff for employment outcomes

**Data:** Census PUMS (income, self-employment class of worker, internet access)

**Method:** RDD at 135% FPL, comparing self-employment rates just below vs. above threshold. Heterogeneity by incorporated vs. unincorporated status.

**States:** All states (federal program), but can focus on states with low baseline broadband access (Mississippi, rural Kansas/ND) where the subsidy has most bite.

---

## Idea 2: The Age 40 Threshold—When Discrimination Protection Enables Risk-Taking

**Policy:** Age Discrimination in Employment Act (ADEA) protections begin at exactly age 40

**Identification Strategy:** Sharp RDD at age 40

**Core Insight:** At precisely age 40, workers gain federal protection against age discrimination. The conventional view: this protects older workers from job loss. The unconventional hypothesis: *protection enables risk-taking*. When you know you can't be easily fired for your age, you might be MORE willing to quit and start a business.

**Hypothesis:** Self-employment rates *increase* discontinuously at age 40, particularly for high-skill workers who now have a "safety net" if their venture fails and they need to return to wage work.

**Why This Is Novel:**
- ADEA literature focuses on effects *on* the protected class (employment rates of 50+, 60+)
- Nobody examines behavioral changes *at the exact threshold* of protection
- Tests a counterintuitive mechanism: protection → increased risk-taking
- Creative use of an age discontinuity for entrepreneurship, not just labor supply

**Data:** Census PUMS (age, class of worker, industry, education)

**Method:** RDD at age 40, comparing self-employment entry just before vs. after 40th birthday. Heterogeneity by education, occupation, gender.

**States:** All states (federal law), but interesting to compare strong vs. weak state-level age discrimination enforcement.

---

## Idea 3: Kansas's 3.2% Beer Shock—When Deregulation Kills Small Business

**Policy:** Kansas allowed only 3.2% ABV beer in grocery stores until April 1, 2019, when full-strength beer sales were legalized

**Identification Strategy:** Difference-in-Differences using April 2019 cutoff

**Core Insight:** For decades, Kansas was one of two states restricting grocery stores to "near beer" (3.2% ABV). Liquor stores had a protected monopoly on real beer. On April 1, 2019, Kansas allowed full-strength beer in grocery stores. This should have *destroyed* small liquor stores that depended on beer sales.

**Hypothesis:** The 2019 deregulation led to a sharp decline in liquor store employment and self-employment, with displaced workers either exiting the labor force or moving to grocery retail.

**Why This Is Novel:**
- Almost no academic literature on the 3.2% beer laws
- Tests the "small business protection" rationale for alcohol regulation
- Natural experiment with clean treatment date
- Captures the general phenomenon of deregulation destroying protected incumbents

**Data:** Census PUMS (industry code, employment status, self-employment)

**Method:** DiD comparing Kansas to neighboring states (Nebraska, Missouri, Oklahoma, Colorado) around April 2019. Focus on retail trade industries (NAICS 445: food and beverage stores vs. NAICS 4453: beer/wine/liquor stores).

**States:** Kansas (treatment), Nebraska/Missouri/Oklahoma/Colorado (control)

---

## Idea 4: The Entrepreneurship Lock at 138% FPL—Does Medicaid Free the Founders?

**Policy:** ACA Medicaid Expansion eligibility threshold at 138% Federal Poverty Line

**Identification Strategy:** Sharp RDD at 138% FPL in expansion states

**Core Insight:** The "entrepreneurship lock" hypothesis suggests people stay in wage jobs primarily for health insurance. Medicaid expansion at 138% FPL provides free health coverage, potentially unlocking entrepreneurship for those who would otherwise fear losing insurance.

**Hypothesis:** In Medicaid expansion states, self-employment rates are higher just below 138% FPL than just above. This effect is stronger for people with health conditions or dependents.

**Why This Is Novel:**
- Entrepreneurship lock papers usually use state-level variation, not RDD at the income threshold
- Tests the mechanism directly rather than comparing expansion vs. non-expansion states
- Can separate the insurance effect (below 138%) from the subsidy cliff effect (above 138%)

**Data:** Census PUMS (income, self-employment, health insurance type, disability status)

**Method:** RDD at 138% FPL in expansion states (excluding Kansas, Mississippi which didn't expand; including states that later expanded). Compare to 138% threshold in non-expansion states as placebo.

**States:** Expansion states for treatment, non-expansion states (including Mississippi, Kansas) for placebo.

---

## Idea 5: North Dakota's Oil Boom Reversal—The End of the Bakken

**Policy:** The Bakken oil price collapse (2014-2016) and subsequent bust

**Identification Strategy:** Difference-in-Differences comparing Bakken-region PUMAs to non-oil PUMAs

**Core Insight:** North Dakota's Bakken oil boom (2008-2014) brought massive in-migration and wage growth. When oil prices collapsed in 2014-2016, the boom reversed. But what happened to the workers? Did they leave? Become self-employed in non-oil sectors? Drop out of the labor force?

**Hypothesis:** The oil bust led to increased self-employment as displaced oil workers pivoted to other sectors, but also increased labor force exit among those who couldn't adapt.

**Why This Is Novel:**
- Most Bakken research focuses on the boom, not the bust
- Tests resilience and adaptation after a commodity shock
- Examines self-employment as a "coping mechanism" for job loss

**Data:** Census PUMS (PUMA geography, industry, employment status, year)

**Method:** DiD comparing Bakken-region PUMAs (Williams, McKenzie, Mountrail counties) to non-oil ND PUMAs, pre/post 2015.

**States:** North Dakota

---

## Ranking Criteria

For GPT ranking, evaluate each idea on:
1. **Novelty:** Has this specific RDD/DiD been done before?
2. **Identification Quality:** How sharp is the discontinuity/timing?
3. **Data Feasibility:** Can PUMS capture the relevant variation?
4. **Policy Relevance:** Does this speak to current debates?
5. **"Wow Factor":** Would this make someone say "Holy shit, AI did this?"

## Recommendation

**Lead with Idea 1 (Broadband/Gig Work)** if feasible. It has:
- A sharp, clean threshold (135% FPL)
- A counterintuitive hypothesis
- High policy relevance (ACP just ended in 2024)
- The perfect "AI discovers uncomfortable truth" narrative

If Idea 1 has data issues, **fall back to Idea 2 (Age 40 ADEA)** which has an even sharper discontinuity (exact birthdate) and tests a genuinely novel mechanism.
