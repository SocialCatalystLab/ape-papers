# Research Idea Ranking

**Generated:** 2026-01-21T17:44:09.465934
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 9910
**OpenAI Response ID:** resp_080e99dad299309e00697101d97ca48195bc4a34d03b386626

---

### Rankings

**#1: State Auto-IRA Mandates and Retirement Savings**
- **Score:** 68/100
- **Strengths:** Strong policy relevance and a clear mechanism (auto-enrollment) with a meaningful staggered rollout across many states. With modern staggered DiD (e.g., Callaway–Sant’Anna) you can estimate dynamic effects and heterogeneity (by income/coverage status).
- **Concerns:** Key risk is **outcome measurement**: CPS ASEC measures employer pension coverage/participation more cleanly than IRA ownership/contributions; auto-IRA participation may be misreported or not well captured. “Treatment” is also phased in by employer size/implementation dates, so a simple state×year indicator may attenuate effects unless you model intensity.
- **Novelty Assessment:** **Moderately novel**. There are program-specific evaluations and lots of work on auto-enrollment generally, but a credible pooled multi-state estimate for state auto-IRAs is not yet heavily saturated in top journals.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** *if you use CPS ASEC back to at least 2012* (your stated 2015 start would be **Weak** for Oregon-2017).
  - **Selection into treatment:** **Marginal** (politically selected adopters; less clear it responds to short-run savings trends, but must test).
  - **Comparison group:** **Marginal** (never-treated states differ systematically; consider region/political controls, reweighting, or matched controls).
  - **Treatment clusters:** **Marginal** (≈13 treated states; better than many, but below the ≥20 “very safe” zone for clustered inference).
  - **Concurrent policies:** **Marginal** (federal SECURE Act affects all states; main concern is differential interactions + other state retirement/benefit initiatives).
- **Recommendation:** **PURSUE** (conditional on: extend pre-periods; improve treatment coding with phased rollout/intensity; validate that CPS ASEC measures the relevant margin for auto-IRAs).

---

**#2: Salary History Bans and the Gender Wage Gap**
- **Score:** 60/100
- **Strengths:** Potentially better identification than a plain DiD if you implement a credible **triple-diff** (job changers vs. stayers) and focus on groups most exposed to the ban. Large CPS ORG sample supports subgroup/event-study work.
- **Concerns:** High risk of **policy bundling** (pay equity packages, pay transparency, minimum wage changes) and political endogeneity; the triple-diff assumption (parallel trends in changers vs. stayers across states) is nontrivial and must be stress-tested. Effects may also operate through hiring/offers, which CPS wages may observe only noisily.
- **Novelty Assessment:** **Moderately studied**. There are existing papers on early adopters and related pay-transparency policies; a comprehensive multi-state design is still publishable but not “wide open.”
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (CPS ORG allows many pre-years; don’t start at 2017 only).
  - **Selection into treatment:** **Marginal** (likely correlated with attitudes/levels; may or may not be driven by worsening trends—must show pre-trends).
  - **Comparison group:** **Marginal** (controls differ; mitigate with region-by-year shocks, reweighting, or restricting to more comparable states).
  - **Treatment clusters:** **Strong** (22+ treated states).
  - **Concurrent policies:** **Marginal** (serious but potentially manageable by (i) limiting to an adoption window before widespread pay-transparency laws, and (ii) explicitly controlling for overlapping labor policies).
- **Recommendation:** **CONSIDER** (worth doing if you pre-register a tight policy-bundling strategy and validate the triple-diff pre-trends aggressively).

---

**#3: State Clean Energy Standards and Electricity Prices**
- **Score:** 48/100
- **Strengths:** Excellent data quality (EIA state×year price series, long panels) and high policy salience. Many pre-periods enable rich event studies and robustness checks.
- **Concerns:** **Dealbreaker under your DiD checklist**: too few treated states (≈7) for reliable clustered inference in a DiD framing, and near-term price effects may be small because mandates target 2040–2050 (policy “announcement” vs. binding compliance timing becomes central).
- **Novelty Assessment:** **Low-to-moderate**. RPS impacts are heavily studied; “100% CES” is newer but still conceptually adjacent to a very crowded literature.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Marginal**
  - **Comparison group:** **Marginal**
  - **Treatment clusters:** **Weak** (<10)
  - **Concurrent policies:** **Marginal** (federal subsidies/fuel prices affect all states, but differential exposure remains)
- **Recommendation:** **SKIP** *as currently designed*. (Could become viable if redesigned as state-specific synthetic control(s) with transparent inference, or moved to utility-level outcomes to increase clusters—though that becomes a different project.)

---

**#4: Automatic Voter Registration and Voter Turnout**
- **Score:** 45/100
- **Strengths:** Large number of adopting states (good cluster count) and clear policy importance. In principle, long pre-periods exist because CPS Voting Supplement goes back decades (even if biennial).
- **Concerns:** **Two DiD dealbreakers**: strong political selection/endogeneity and extensive concurrent election-law changes (ID laws, early voting, registration rules, felon reenfranchisement) that directly affect the same outcomes and vary precisely in the same places/times. CPS turnout is also self-reported (systematic misreporting may vary by state/polarization).
- **Novelty Assessment:** **Moderately studied** (political science/econ have multiple AVR papers; multi-state work exists, and the confounding policy environment is well known).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (if you use long history; biennial alone isn’t fatal)
  - **Selection into treatment:** **Weak**
  - **Comparison group:** **Marginal**
  - **Treatment clusters:** **Strong**
  - **Concurrent policies:** **Weak**
- **Recommendation:** **SKIP** (unless you can move to a design leveraging plausibly exogenous implementation shocks or detailed administrative election-policy controls + a much more credible comparison strategy than “non-AVR states”).

---

**#5: State Pay Transparency Laws and Wage Dispersion**
- **Score:** 35/100
- **Strengths:** Very high novelty (recent laws) and strong policy interest. If you had the right data (job postings, employer-level pay bands, vacancy wages), this could be impactful.
- **Concerns:** As proposed, **data do not match the outcome**: CPS ORG cannot measure *within-firm* dispersion (no firm identifiers), and state-level dispersion measures will be noisy and slow-moving relative to a 2021+ policy window. Identification is also undermined by few treated states and heavy overlap with other wage-setting policies.
- **Novelty Assessment:** **High** (new policy area), but novelty cannot compensate for weak identification/data mismatch.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak**
  - **Selection into treatment:** **Weak**
  - **Comparison group:** **Marginal**
  - **Treatment clusters:** **Weak** (<10 so far)
  - **Concurrent policies:** **Weak**
- **Recommendation:** **SKIP** (unless redesigned around job-posting microdata and an exposure-based strategy that increases effective treated “clusters,” e.g., employer/occupation/posting-level analysis).

---

### Summary

Only **Idea 1 (Auto-IRA mandates)** looks like a strong “first project,” provided you (i) extend the pre-period and (ii) verify CPS ASEC captures the relevant retirement participation margin (and ideally model phased rollout intensity). **Idea 2 (Salary history bans)** is the best runner-up but needs a disciplined plan to handle overlapping policies and to validate the triple-diff assumptions. The remaining ideas have **DiD dealbreakers** (especially concurrent policies and/or too few treated clusters) in their current form.