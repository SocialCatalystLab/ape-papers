# Research Idea Ranking

**Generated:** 2026-01-18T17:58:15.181891
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4554
**OpenAI Response ID:** resp_00bb86b3445b82a900696d11000990819398d7361338923625

---

### Rankings

**#1: Montana’s “Montana Miracle” Zoning Reform and Housing Construction**
- **Score: 74/100**
- **Strengths:** Very recent, policy-relevant statewide upzoning with a clear legal cutoff that *could* support quasi-experimental designs. If you can credibly implement an RDD (or a clean DiD with strong controls/synthetic), this would be a high-value contribution given current housing policy attention.
- **Concerns:** The proposed RDD is not automatically clean: eligibility depends on **municipal population (>5,000) *and* county population (>70,000)**, likely leaving few observations near the cutoff and raising functional-form/small-sample risks. Building Permits Survey coverage at the “place” level can be thin in small municipalities, and total permits may not capture ADU/duplex-specific uptake; the **injunction/uncertainty (Dec 2023–Mar 2025)** blurs treatment timing and may require redefining the treatment window or using an “intent-to-treat vs. effective enforcement” design.
- **Novelty Assessment:** **High.** As of now, there will be little to no peer-reviewed causal evidence specifically on Montana’s 2024 reforms; ADU reforms are studied elsewhere, but this exact policy package and institutional setting is new.
- **Recommendation:** **PURSUE** (with a feasibility check on sample size near thresholds and an explicit plan for the injunction period)

---

**#2: Rhode Island Temporary Caregiver Insurance and Labor Market Outcomes**
- **Score: 66/100**
- **Strengths:** Long pre-period and a clearly dated policy shock make **synthetic control / event-study** approaches plausible, and the “early adopter” status gives a decent donor pool pre-2018 before widespread policy diffusion. If you focus on outcomes and subgroups less covered (e.g., employment stability/job continuity, medium-run earnings paths, heterogeneity by education/industry), you can still add value.
- **Concerns:** This topic is **not new**—paid family leave has a large literature, and Rhode Island has been studied (though less than California). ACS/CPS state samples for RI can be noisy (especially for subgroup analyses), and over 2014–2026 many confounders accumulate (other state policies, business cycles, compositional change), weakening interpretability unless you tightly scope the window or exploit administrative participation data.
- **Novelty Assessment:** **Moderate-to-low.** Many papers study paid leave; some examine RI specifically. The best novelty angle is **long-run effects** and/or outcomes not well-measured previously.
- **Recommendation:** **CONSIDER** (worth doing if you can sharpen the contribution and manage small-sample precision)

---

**#3: Vermont Universal School Meals and Student Outcomes**
- **Score: 62/100**
- **Strengths:** Clear statewide rollout (SY 2022–23) and good access to chronic absenteeism measures make the question empirically tractable. Neighboring New England states are plausible comparators on observables, and the policy is directly relevant to current debates on attendance and student well-being.
- **Concerns:** Identification is the main weakness: **post-COVID attendance dynamics** and differential recovery trajectories across states make parallel trends fragile right when treatment begins. Universal meals also expanded in multiple states around this period, shrinking the clean control group; careful donor selection, robustness (synthetic DiD / SC, placebo states, pre-trend diagnostics), and possibly within-VT heterogeneity (if any intensity variation exists) will be essential.
- **Novelty Assessment:** **Moderate.** Universal free meals have been studied (including recent state expansions); Vermont-specific causal evidence may be thinner, but it’s not an untouched question.
- **Recommendation:** **CONSIDER** (promising if you can credibly address COVID-era confounding)

---

**#4: Montana Permitless Carry Law and Violent Crime**
- **Score: 45/100**
- **Strengths:** Staggered adoption across many states creates a surface-level case for modern staggered DiD/event-study designs. Data sources exist (UCR/NIBRS, WISQARS), and policymakers do care about the question.
- **Concerns:** This is heavily studied in various “right-to-carry/shall-issue/permitless carry” forms, and causal identification is notoriously contentious (policy endogeneity, heterogeneous treatment timing, spillovers, policing changes). Montana’s 2021 timing sits in the **COVID-era crime break**, and UCR/NIBRS reporting changes and missingness can materially affect results.
- **Novelty Assessment:** **Low.** There is extensive prior literature on firearm carry laws and crime; “Montana-specific” is not, by itself, a strong novelty claim.
- **Recommendation:** **SKIP** (unless you have a distinctly better design or unique microdata)

---

**#5: Vermont Automatic Voter Registration and Electoral Participation**
- **Score: 38/100**
- **Strengths:** Policy timing is clear (2017), and basic outcomes (registration/turnout) are measurable from administrative and survey sources. The question is policy-relevant and straightforward.
- **Concerns:** AVR effects have been studied extensively across early-adopting states; Vermont alone is unlikely to add much. CPS turnout is self-reported and noisy at small-state sample sizes, and administrative turnout changes are confounded by election competitiveness, mobilization, and concurrent voting reforms unless you have sharper within-state variation.
- **Novelty Assessment:** **Low.** A substantial body of work (academic and policy) evaluates AVR’s impacts.
- **Recommendation:** **SKIP** (unless you have uniquely granular administrative microdata and a novel margin, e.g., removals, list maintenance, or downstream civic outcomes)

---

### Summary
This is a solid batch in terms of policy relevance and basic feasibility, but only one idea stands out as both **high-novelty** and plausibly identifiable: the Montana zoning reforms—provided the threshold-based design has enough observations and you handle the injunction period carefully. The paid leave and universal meals ideas are workable but face either heavier prior literature (paid leave) or weaker identification due to COVID-era trend breaks (school meals).