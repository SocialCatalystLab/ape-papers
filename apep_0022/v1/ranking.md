# Research Idea Ranking

**Generated:** 2026-01-17T19:03:23.878778
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6561
**OpenAI Response ID:** resp_0209c0a5da18833900696bcea18b5c81949dbe25163ab37169

---

### Rankings

**#1: Does Social Security Eligibility at Age 62 Reduce Living Alone Among Older Adults? (Idea 1)**  
- **Score:** 69/100  
- **Strengths:** High policy salience and a clear, nationally uniform eligibility threshold; very large samples in ACS/PUMS make small effects detectable. The “living alone” outcome is cleanly measured and plausibly linked to isolation.  
- **Concerns:** In ACS PUMS, **AGEP is integer age**, so the RDD is inherently **discrete/coarse** (not age-in-months), weakening continuity-based claims. Eligibility at 62 is also **fuzzy** (not everyone claims immediately), and living arrangements may adjust slowly—so a sharp discontinuity may be small or absent.  
- **Novelty Assessment:** **Moderately novel.** There is an enormous SS literature (especially on labor supply/claiming), but comparatively fewer credible designs on **household composition/living alone** right at 62; still, it is not untouched.  
- **Recommendation:** **PURSUE** (but only if you add a clear first-stage check using SS income receipt and handle discrete-RD carefully).

---

**#2: Does Medicare Eligibility Reduce Employment-Based Social Connection? (Idea 2)**  
- **Score:** 67/100  
- **Strengths:** Age-65 Medicare eligibility is a classic, strong policy discontinuity, and ACS has good measures of employment and insurance. Extending the question to a loneliness proxy is a meaningful twist that policymakers could care about (retirement transitions and social isolation).  
- **Concerns:** This is the **most heavily studied threshold in US applied micro**; novelty comes mainly from the outcome, not the design/policy. Also, “living alone” is a **slow-moving stock variable**; even if employment drops at 65, household structure may not jump, so the key reduced-form may be weak. Integer age in PUMS again makes the RD less clean than in surveys with month-of-birth.  
- **Novelty Assessment:** **Low-to-moderate novelty.** Medicare-at-65 RDDs are everywhere; the loneliness-proxy angle is less studied but still an incremental extension of a saturated design.  
- **Recommendation:** **CONSIDER** (good as a secondary project, or if you can show compelling first-stage insurance/employment shifts in this exact data).

---

**#3: Does Reaching Age 60 Senior Services Eligibility Reduce Living Alone? (Idea 4)**  
- **Score:** 59/100  
- **Strengths:** Substantively aligned with loneliness (OAA services are explicitly social-connection oriented), and genuinely understudied relative to SS/Medicare. If a real discontinuity in access exists, the policy interpretation would be very direct.  
- **Concerns:** Identification is the core problem: OAA “eligibility” at 60 is often **not a sharply enforced cutoff** (programs vary locally; access can be informal; some services serve under-60 disabled). Without **utilization/participation data** to verify a first-stage jump at 60, the RDD risks being a “threshold in name only.” Integer age further blurs any discontinuity.  
- **Novelty Assessment:** **High novelty.** Credible causal work on OAA eligibility effects on social outcomes is sparse.  
- **Recommendation:** **CONSIDER** (only if you can document a first-stage discontinuity via external admin/AAA utilization data or strong institutional evidence; otherwise it will likely be unpublishable as RD).

---

**#4: Do Medicaid Expansion States See Reduced Institutionalization and Living Alone Among Low-Income Elderly? (Idea 3)**  
- **Score:** 57/100  
- **Strengths:** High policy relevance and a natural DiD/event-study structure with clear timing (2014 expansions). Outcomes (institutional group quarters; living alone) are observable in ACS, so this is feasible in principle.  
- **Concerns:** ACA Medicaid expansion has **a vast DiD literature**, so novelty is limited; adding “loneliness proxies” helps but may still look like a marginal outcome extension. Identification will be contested (state-specific trends; compositional changes; concurrent policies), and the “institutionalization” margin for ages 55–64 in ACS can be **small/noisy** (and group quarters includes non–nursing home institutions unless carefully restricted). Massachusetts/Wisconsin add further ambiguity because MA pre-expanded and WI’s status is atypical.  
- **Novelty Assessment:** **Medium to low.** The policy has been studied extensively; your specific outcomes are less common, but not enough to fully escape “another Medicaid expansion DiD.”  
- **Recommendation:** **CONSIDER** (stronger if you broaden beyond the three states, implement modern DiD methods, and tightly define nursing-home-type group quarters).

---

**#5: Does Wisconsin’s IRIS Self-Directed Care Program Reduce Institutionalization? (Idea 5)**  
- **Score:** 53/100  
- **Strengths:** Potentially meaningful and relatively distinctive policy variation (self-direction, paying family caregivers), with clear conceptual links to community living and social connection. If identified, it could inform HCBS waiver design.  
- **Concerns:** With **PUMS only**, you cannot observe IRIS enrollment or even true Medicaid/waiver eligibility—so treatment is badly mismeasured (you’re effectively doing an “intent-to-treat” on a very noisy proxy population). Wisconsin had **multiple long-term-care reforms** around the same era (and neighboring states had their own HCBS changes), making clean comparison and parallel trends hard to defend; institutionalization in ACS is also a thin outcome.  
- **Novelty Assessment:** **Moderate.** Program-specific evaluations exist (often administrative/case-study); population-level DiD on institutionalization is less common, but the design challenges dominate.  
- **Recommendation:** **SKIP** under the stated data constraint (worth revisiting only with linked admin HCBS/Medicaid data or a clearly validated enrollment shock).

---

### Summary

The best ideas here are the **age-threshold RDDs (SS at 62; Medicare at 65)** because they offer clearer timing and very feasible measurement in PUMS—though **integer age** and **slow-moving household outcomes** are major threats to identification. If you pursue one first, I’d start with **Social Security at 62**, but only after demonstrating a strong first-stage (e.g., discontinuity in SS income receipt) and using a discrete-RD design that is honest about the limitations of PUMS age measurement.