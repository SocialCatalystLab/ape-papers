# Research Idea Ranking

**Generated:** 2026-01-17T21:45:23.887870
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6300
**OpenAI Response ID:** resp_0baeb5d1bcf1dc3600696bf4a471c88190a4ba9f4bb857db4a

---

### Rankings

**#1: Montana HELP-Link Workforce Program and Labor Force Participation (Idea 1)**
- **Score: 68/100**
- **Strengths:** Genuinely distinctive policy bundle (Medicaid expansion + embedded workforce services) with high policy salience given ongoing debates about “work supports” vs. “work requirements.” Outcomes (employment, hours, wages, insurance) are measurable in microdata, and the timing (2016 rollout) is reasonably clear.
- **Concerns:** The proposed DiD is not very clean because the control states expanded Medicaid earlier (2014), so you’re effectively comparing “post-expansion steady state” elsewhere to “newly expanded + HELP-Link” in Montana—parallel trends is a major worry. PUMS won’t observe actual HELP-Link participation, so estimates are an ITT for “living in Montana post-2016,” and other Montana-specific shocks/policies could be doing work.
- **Novelty Assessment:** **Moderately high**. Medicaid expansion and labor outcomes are heavily studied, but the *integrated workforce-service design* is much less studied; I’m not aware of a well-known causal paper isolating HELP-Link specifically.
- **Recommendation:** **PURSUE** (but redesign: add a **triple-difference** using Medicaid-eligible vs. near-eligible within each state; consider event-study and/or synthetic control; validate with administrative participation data if possible).

---

**#2: Hawaii’s Minimum Wage Acceleration (2022) and Part-Time Employment Composition (Idea 3)**
- **Score: 62/100**
- **Strengths:** Very strong novelty from the interaction of a large minimum-wage hike with Hawaii’s unique 20-hour health insurance mandate—this is a sharp, theory-driven mechanism (hours bunching just below 20). If the effect exists, it’s directly relevant to “hidden margins” of adjustment and benefit mandates.
- **Concerns:** Identification is fragile with a **single treated state** and hard-to-justify controls (“tourism-dependent” is not a research design). Data feasibility is also a concern: ACS/PUMS is annual and the hike is **Oct 2022**, so “post” measurement is noisy; Hawaii sample sizes for narrow low-wage industry cells may be thin; hours measures in ACS are self-reported and coarse for detecting subtle bunching.
- **Novelty Assessment:** **High**. The Prepaid Health Care Act has an older literature, but the *interaction with modern minimum-wage acceleration* is largely uncharted.
- **Recommendation:** **CONSIDER** (strong idea, but likely needs a different design/data: CPS monthly, administrative UI/QCEW, or a within-Hawaii distributional/bunching approach rather than state-comparison DiD).

---

**#3: Maryland Healthy Working Families Act (2018) and Employment Stability (Idea 2)**
- **Score: 55/100**
- **Strengths:** Clear policy question that policymakers care about; plausible margins (job separations, weeks worked) and a natural set of nearby comparison states. Service-sector targeting is sensible given coverage.
- **Concerns:** Novelty is limited because paid sick leave mandates have a sizable literature, and a Maryland-only contribution may be incremental. The biggest practical issue is measurement: ACS “weeks worked last year” and annual employment status blur timing (law effective Feb 2018), and you can’t observe firm size (15+) cleanly in PUMS—so coverage vs. non-coverage heterogeneity will be weak.
- **Novelty Assessment:** **Medium-low**. Many state/city paid sick leave DiD/event studies exist; Maryland-specific evidence is thinner but not a major frontier.
- **Recommendation:** **CONSIDER** (would be stronger with higher-frequency labor market data, clear event-study pre-trends, and a better way to approximate covered workers).

---

**#4: Montana’s Cannabis Worker Protection Law (2022) and Employment Outcomes (Idea 4)**
- **Score: 50/100**
- **Strengths:** The worker-protection angle is genuinely novel relative to the broader legalization literature, and the occupational focus (drug-testing-heavy jobs) is well-motivated.
- **Concerns:** The identification problem is severe: Montana’s recreational market effectively began in **Jan 2022**, coinciding with the worker-protection effective date—so any employment changes could be legalization-market demand shocks, not worker protections. Additionally, for the highest-testing sectors (e.g., DOT-regulated transportation), **federal rules often dominate**, potentially muting treatment intensity precisely where you expect effects.
- **Novelty Assessment:** **High** on the legal provision, but novelty alone doesn’t rescue weak separability from concurrent shocks.
- **Recommendation:** **SKIP** unless you can (i) separate worker protections from market opening/timing, and (ii) document enforceability/coverage and employer testing practices with better data.

---

**#5: Maryland’s Staggered Minimum Wage ($15 by 2025) and Youth Employment (Idea 5)**
- **Score: 44/100**
- **Strengths:** High policy relevance and clear target population; neighboring controls (PA, VA) are intuitive; outcomes are standard and measurable.
- **Concerns:** This sits in an extremely crowded literature (minimum wage and youth employment), and Maryland’s staggered, multi-step schedule plus COVID-era shocks make credible DiD identification difficult without very careful event-study work and robustness. The incremental value of another state-specific DiD using ACS/PUMS is likely low.
- **Novelty Assessment:** **Low**. Minimum wage effects on youth employment are among the most studied questions in applied labor.
- **Recommendation:** **SKIP** (unless you have a genuinely new identification angle—e.g., border discontinuities with granular administrative data, or employer-size-specific exposure with strong measurement).

---

### Summary
This is a mixed batch: two ideas are meaningfully novel (HELP-Link; Hawaii wage–health mandate interaction), but several rely on annual ACS/PUMS timing and state-level DiD comparisons that are often too weak for credible causal inference. I would prioritize **Idea 1** (with a stronger DDD/synthetic-control redesign) and keep **Idea 3** as a high-upside “consider” project if you can secure better, higher-frequency data and a more defensible control strategy.