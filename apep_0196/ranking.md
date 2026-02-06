# Research Idea Ranking

**Generated:** 2026-02-06T16:45:05.750158
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7775

---

### Rankings

**#1: Promise Programs and Community College Completion (PRIMARY)**
- **Score:** 69/100  
- **Strengths:** Good policy variation (20+ staggered adoptions) and a genuinely policy-relevant margin (completion) that is less saturated than enrollment. With 2015–2021 start dates, you finally have enough calendar time to observe 150% completion for early cohorts.  
- **Concerns:** “Completion rate” measurement is a minefield: IPEDS/Scorecard graduation rates often cover **first-time, full-time** entrants and can move mechanically via compositional change (Promise changes who enrolls). Also, Promise adoption may be bundled with other higher-ed reforms/funding shifts, complicating attribution.  
- **Novelty Assessment:** **Moderate.** There is a large literature on Promise/free-college programs (especially Tennessee Promise and place-based “Promise” scholarships) and many papers on enrollment/credits; fewer clean multi-state papers on **completion**, but it is not untouched.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (can assemble 2010+; IPEDS exists well before that).
  - **Selection into treatment:** **Marginal** (voluntary state adoption likely related to attainment goals/fiscal capacity; could correlate with trends).
  - **Comparison group:** **Marginal** (never-treated states may differ systematically; needs careful weighting/matching and state-specific trends sensitivity).
  - **Treatment clusters:** **Strong** (20+ states).
  - **Concurrent policies:** **Marginal** (possible coincident higher-ed financing changes, performance-based funding, workforce initiatives; must audit).
  - **Outcome-Policy Alignment:** **Marginal** (Promise targets recent HS grads; IPEDS graduation rates often exclude part-time/transfer-heavy pathways and can reflect composition as much as “success”).
  - **Data-Outcome Timing:** **Marginal** (Promise typically affects **fall entrants**; 150% completion is realized ~3 years later—requires correct cohort-based timing/lag structure. Using Scorecard “latest” fields would be a **fatal** mismatch; must use year-by-cohort IPEDS graduation outcomes).
  - **Outcome Dilution:** **Marginal** (community colleges serve many older/part-time students; even IPEDS FTFT cohorts include some non-eligible and omits impacted part-time students—net “treated share” is not tiny, but not close to universal).
- **Recommendation:** **PURSUE (conditional on: using cohort-based IPEDS graduation-rate panels rather than Scorecard “latest”; pre-registering a timing/lag structure that maps Promise start → entering cohort → completion at t+3; and doing a serious concurrent-policy audit + sensitivity to alternative control construction).**

---

**#2: Promise Programs and Four-Year Enrollment Diversion**
- **Score:** 57/100  
- **Strengths:** Clear policy relevance (potential crowd-out from 4-year to 2-year) and can be studied on a faster horizon than completion. Using the same staggered Promise variation keeps treatment clustering strong.  
- **Concerns:** The proposed triple-diff (state×year×institution-type) is not automatically credible because 2-year and 4-year sectors have different underlying trends and shock exposure. Data feasibility is also trickier than it looks: ACS enrollment tables are not consistently clean on **2-year vs 4-year** attendance, and Scorecard often emphasizes “latest” rather than a reliable annual panel.  
- **Novelty Assessment:** **Low-to-moderate.** Diversion/substitution is a standard question in tuition and “free CC” evaluations; there is prior work around Tennessee Promise and similar programs examining sectoral enrollment shifts. A cross-state, updated re-test could still add value, but it’s not frontier.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (2010+ feasible).
  - **Selection into treatment:** **Marginal** (same endogeneity concerns as Idea 1).
  - **Comparison group:** **Marginal** (same concerns; plus higher-ed system differences matter more here).
  - **Treatment clusters:** **Strong** (20+).
  - **Concurrent policies:** **Marginal** (other higher-ed policies can directly affect sectoral enrollment).
  - **Outcome-Policy Alignment:** **Strong/Marginal** (conceptually aligned—Promise can shift enrollment across sectors—but only if you measure **first-time**/traditional-age entry, not total headcount).
  - **Data-Outcome Timing:** **Marginal** (Promise affects fall entrants; annual enrollment measures can mix spring/fall and include continuing students unless you use IPEDS first-time fall enrollment).
  - **Outcome Dilution:** **Marginal** (sector-wide enrollment includes many students not newly eligible; dilution is avoidable if you focus on first-time, degree-seeking, traditional-age entrants).
- **Recommendation:** **CONSIDER** (best as a tightly-defined companion paper/module to Idea 1 using **IPEDS first-time fall enrollment by sector**; I would not lead with this absent very clean entry-cohort measurement).

---

**#3: FAFSA Completion Requirements and College Enrollment**
- **Score:** 45/100  
- **Strengths:** High policy relevance and genuinely timely—states are actively adopting/adjusting these mandates, and credible evidence would matter. Topic is much less studied than Promise programs.  
- **Concerns:** As proposed, the DiD is at high risk on inference and measurement: only ~12 treated states, very recent adoption, heterogeneous enforcement (opt-outs, “soft” mandates), and **ACS 18–24 enrollment is heavily diluted** relative to the affected graduating cohort. Pandemic-era overlap (2020–2022) is a major concurrent shock to enrollment and FAFSA completion.  
- **Novelty Assessment:** **High.** There is relatively little causal academic literature on statewide FAFSA-as-graduation-requirement mandates (compared to the huge FAFSA “nudges” literature).  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (can assemble many pre years).
  - **Selection into treatment:** **Marginal/Weak** (states may adopt precisely because FAFSA completion/college-going is low or falling—trend-responsive adoption is plausible).
  - **Comparison group:** **Marginal** (treated states differ politically/administratively; feasible but needs care).
  - **Treatment clusters:** **Marginal** (<20 treated clusters; inference fragile).
  - **Concurrent policies:** **Weak** (COVID-era disruptions + FAFSA redesign/timing changes + state aid changes overlap closely with adoption window).
  - **Outcome-Policy Alignment:** **Marginal** (policy targets immediate post-HS college-going; ACS enrollment is a proxy and not cohort-specific).
  - **Data-Outcome Timing:** **Weak** (mandate applies to spring graduating class → fall enrollment; ACS “year” mixes survey months and ages, making first treated year partly pre-exposure for many observations).
  - **Outcome Dilution:** **Weak** (ACS 18–24 includes many cohorts; only ~1/7 are age 18 and not all 18-year-olds are current-year graduates ⇒ treated share likely <10–15%).
- **Recommendation:** **SKIP** *in its current ACS-based form.* (It becomes promising only with a redesign using cohort-level outcomes—e.g., NSC college-going by high school or state longitudinal data systems—so the treated population is correctly measured and not diluted, and timing is cohort-accurate.)

---

**#4: Promise Programs and Geographic Retention (Brain Drain)**
- **Score:** 32/100  
- **Strengths:** Interesting long-run question and plausibly important to governors/legislatures (workforce retention is often the political selling point). Likely less studied than enrollment effects.  
- **Concerns:** Identification is very weak with the proposed outcome: ACS 1-year migration is noisy, highly cyclical, and the effect timing is mismatched (retention would plausibly change **after** degree completion/transfer, not immediately). Treated share among “young adults” is small unless you build a very specific cohort-based design; otherwise dilution dominates.  
- **Novelty Assessment:** **Moderate-to-high.** There is work on place-based scholarships and local retention, but statewide Promise-to-migration is less developed; novelty doesn’t rescue the identification problems here.  
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (ACS migration exists for long pre windows).
  - **Selection into treatment:** **Marginal** (adoption likely related to economic/demographic concerns tied directly to migration trends).
  - **Comparison group:** **Marginal** (migration trends differ structurally across regions).
  - **Treatment clusters:** **Strong** (20+).
  - **Concurrent policies:** **Marginal/Weak** (migration is affected by many simultaneous shocks—labor markets, housing, taxes—hard to rule out).
  - **Outcome-Policy Alignment:** **Weak** (Promise affects education choices; “migrated in last 12 months” for all young adults is not tightly linked to the policy mechanism without a cohort design).
  - **Data-Outcome Timing:** **Weak** (policy likely affects migration 3–8 years later; 1-year migration in early post years is mostly pre-mechanism).
  - **Outcome Dilution:** **Weak** (eligible cohorts are a small share of all young adults in ACS; even within 18–24, only some are Promise-exposed entrants).
- **Recommendation:** **SKIP** (unless completely reframed around specific cohorts/eligibility and longer-run administrative tracking; ACS 1-year migration is not a good primary outcome for this policy).

---

### Summary

This is a coherent batch centered on a real policy area with good staggered adoption variation (Promise), but most ideas risk failing on **measurement/timing alignment** and **outcome dilution** if implemented with off-the-shelf ACS/Scorecard aggregates. The only proposal that looks plausibly publishable with careful execution is **Idea 1**, provided you build a cohort-aligned IPEDS panel and take concurrent-policy confounding seriously. Ideas **3 and 4** are currently below the bar because they trigger multiple “Weak” DiD checklist items (especially timing and dilution).