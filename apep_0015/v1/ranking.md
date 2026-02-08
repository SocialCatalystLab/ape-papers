# Research Idea Ranking

**Generated:** 2026-01-17T15:21:44.026832
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4251
**OpenAI Response ID:** resp_0b67b4a2f99ef7b400696b9ac818e4819482eb9afb4006481a

---

### Rankings

**#1: Pennsylvania Foster Care Education Benefits (Age 16 Threshold)**
- **Score: 69/100**
- **Strengths:** The age-16 rule is a plausibly sharp eligibility cutoff, and the population (former foster youth) plus a tuition waiver is policy-relevant and comparatively under-studied. With the *right* administrative data, an RDD could cleanly estimate impacts on enrollment and completion.
- **Concerns:** This is not feasible with standard Census PUMS (foster care history and “age at exit/permanency” are not observed), so the project lives or dies on obtaining/merging child welfare admin records with postsecondary outcomes (e.g., NSC or state higher-ed data). Manipulation/sorting around exit timing and strong age-at-exit confounding (older exit correlates with worse baseline circumstances) need careful diagnostics and covariate/balance tests.
- **Novelty Assessment:** Moderate-to-high novelty: there’s work on foster youth tuition waivers and supports, but far fewer clean quasi-experimental/RDD evaluations of specific age-cutoff eligibility rules.
- **Recommendation:** **CONSIDER** (upgrade to **PURSUE** only if you can secure linked admin data and pre-register a strong validity/balance plan)

---

**#2: Wisconsin GI Bill Dependent Education Benefits and the 30% Disability Threshold**
- **Score: 63/100**
- **Strengths:** The benefit is large (full tuition remission), and the 30% disability-rating cutoff is a natural RDD target with high policy salience for veteran families. Topic-specific evidence on *dependent* educational responses to disability-threshold benefits is relatively sparse.
- **Concerns:** The proposed data plan (PUMS) cannot support the design because it does not contain exact VA disability ratings; without the running variable you do not have an RDD. Even with VA ratings, there is meaningful risk of sorting/bunching at 30% due to appeals/re-evaluations, making this likely **fuzzy** and requiring strong McCrary/bunching checks and an admin dataset that links veteran ratings to children’s outcomes.
- **Novelty Assessment:** High novelty for this specific dependent-benefit threshold design; broader literatures exist on GI Bill effects and veteran benefits, but less on this exact cutoff.
- **Recommendation:** **CONSIDER** (only if you can access VA/state administrative rating data + dependent education outcomes)

---

**#3: Wisconsin Bucky’s Tuition Promise Income Threshold**
- **Score: 58/100**
- **Strengths:** If UW-Madison administrative financial aid data are available, the $65,000 AGI cutoff can produce a relatively clean (likely fuzzy) RDD with precise measurement and a well-defined treated population (applicants/admitted students). Policymakers and universities care about yield, retention, and completion effects of promise-style aid.
- **Concerns:** Novelty is limited (promise programs and income-threshold aid have a large literature, and you note at least one recent study on retention). The design is not credible with PUMS alone because you need applicant/admit/aid offer data and outcomes at UW-Madison specifically; plus income can be strategically reported/optimized and the package may change discretely for reasons other than the promise.
- **Novelty Assessment:** Low-to-medium: plenty on promise/threshold aid; this exact program has some existing work, reducing marginal contribution unless you study new outcomes (completion, major choice, graduate school, labor-market outcomes) or new mechanisms.
- **Recommendation:** **CONSIDER** (best if you can do something clearly beyond existing analyses and use UW administrative microdata)

---

**#4: Pennsylvania Act 101 Program and Educational Attainment**
- **Score: 44/100**
- **Strengths:** Program-level evidence on targeted academic support + aid for disadvantaged college students could be useful, and Act 101 itself is less commonly evaluated than federal need-based aid.
- **Concerns:** The proposed RDD is not credibly implemented with Census PUMS: you cannot observe Act 101 participation, the relevant risk set is *college entrants at participating institutions*, and household income in PUMS is not measured at the application/aid-determination moment (and is noisy). In practice this becomes a weak “income discontinuity” exercise on the general population with severe selection issues, not a clean policy RDD.
- **Novelty Assessment:** Medium: while Act 101 specifically is not heavily studied, “need-based eligibility thresholds and college outcomes” is extremely well-trodden, so novelty gains are mostly program-specific.
- **Recommendation:** **SKIP** (unless you can obtain institution-level admin data on eligibility/participation and outcomes)

---

**#5: Arizona Promise Program and Pell Grant Eligibility**
- **Score: 39/100**
- **Strengths:** High policy relevance—promise programs are widespread and Pell-linked “last-dollar” designs matter for state higher-ed finance.
- **Concerns:** Pell eligibility is not a clean single cutoff in income; it is a schedule based on FAFSA/SAI with many moving parts, and PUMS does not observe SAI or Pell receipt reliably enough for an RDD. Using income as a proxy makes the “threshold” too blurred for credible causal identification, and the promise-program literature is already large (limiting novelty).
- **Novelty Assessment:** Low: there are many studies of promise programs and Pell/aid interactions; this would need unusually strong data and a sharper design to add much.
- **Recommendation:** **SKIP** (unless you can get FAFSA/SAI + university admin records and design around a true Pell discontinuity/kink)

---

### Summary
The strongest concepts here are the ones with genuinely policy-driven, rule-based thresholds (**FosterED age-16** and **WI GI Bill 30%**), but both are currently undermined by major data requirements that PUMS cannot meet. If your institute can secure linked administrative data, start with **FosterED** (best novelty–ID mix); otherwise the only near-term feasible path is **Bucky’s Promise** using UW administrative records, albeit with lower novelty.