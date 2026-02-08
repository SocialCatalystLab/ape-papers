# Research Idea Ranking

**Generated:** 2026-01-18T01:51:47.204633
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 7075
**OpenAI Response ID:** resp_0fd1d44e21cfbec700696c2e5f32988196a51d0b7192ddc0ea

---

### Rankings

**#1: Does Legal Marijuana Access Push Workers Into Self-Employment? An RDD at Age 21 in Colorado**
- **Score:** 68/100  
- **Strengths:** Very novel mechanism (legal off-duty use + employer drug-testing risk potentially shifting workers toward self-employment), and Colorado is a clean setting with clear legal access at 21. Strong falsification menu (pre-period, other states, other ages) makes it “hardcore” if the running variable is measured finely.  
- **Concerns:** Public ACS does **not** provide age-in-months (and often not interview month in a way that delivers clean age-in-months), so the proposed RDD may be infeasible without restricted data or another survey; plus the **age-21 alcohol** discontinuity is a major confound that requires a difference-in-discontinuities design (CO vs non-recreational states) to isolate marijuana.  
- **Novelty Assessment:** I’m not aware of a large literature on *employment composition/self-employment* responses specifically at the recreational marijuana age-21 access threshold; most legalization work is on use, health, crime, and broad labor outcomes rather than this mechanism.  
- **Recommendation:** **CONSIDER** (upgrade to **PURSUE** only if you can secure month-level age and credibly net out the alcohol-at-21 discontinuity via cross-state discontinuity differences).

---

**#2: The Rule of 55 Retirement Unlock: Does Penalty-Free 401(k) Access Reduce Labor Supply?**
- **Score:** 60/100  
- **Strengths:** Genuinely underexplored compared to the heavily-studied age 59½ threshold; the policy is salient and could speak directly to retirement/older-worker labor supply debates. If you can observe separations/withdrawals, the design could be compelling.  
- **Concerns:** Treatment is **not** a true “at-55 everyone gets liquidity” shock—it’s conditional on *separating from the current employer* and having the right plan, so the first stage may be weak and the estimand hard to interpret; ACS/CPS generally won’t observe the key mechanism (withdrawal/eligibility/plan type), making this likely underpowered or mismeasured.  
- **Novelty Assessment:** Much less studied than 59½; there is a broad retirement/wealth-labor-supply literature, but “Rule of 55 as an RD at 55” is not a well-trodden template.  
- **Recommendation:** **CONSIDER** (best if redesigned around HRS/administrative retirement-plan data where eligibility and withdrawals are observable).

---

**#3: The Health Insurance Cliff and the Gig Economy: Does Losing Coverage at Age 26 Push Workers Into Platform Work?**
- **Score:** 57/100  
- **Strengths:** Identification at age 26 is a known strong design, and linking it to post-2015 work arrangements is policy-relevant (dependent coverage + gig classification debates). Data on insurance source and class of worker exist in major surveys.  
- **Concerns:** The age-26 ACA RD is **extremely** studied; novelty hinges entirely on measuring “gig/platform work,” and **unincorporated self-employment in ACS is a noisy proxy** (many gig workers are miscoded, and many “self-employed” are not platform workers). Also, age-in-months may not be available in ACS public files, weakening RD precision.  
- **Novelty Assessment:** The dependent coverage cutoff itself has a very large literature (coverage, utilization, labor supply, job lock). “Gig composition at 26” is less covered, but it’s adjacent to a saturated policy RD.  
- **Recommendation:** **CONSIDER** (only if you can obtain a sharper gig measure—e.g., CPS Contingent Worker/Alternative Work Arrangements, platform-tax 1099 data, or linked admin—and month-level age).

---

**#4: New Hampshire’s Tax Haven Effect: A Geographic RDD at the Massachusetts Border**
- **Score:** 45/100  
- **Strengths:** High policy salience (interstate tax competition) and NH is an assigned state; in principle, border designs can be persuasive when geography is fine and migration/sorting can be bounded.  
- **Concerns:** This is not close to a “sharp” RD: residential location near the border is **highly choice-based** (sorting is the treatment channel), and—critically—**NH residence does not imply no income tax** if the person works in MA (MA taxes MA-sourced income for nonresidents), so “treatment” is misclassified unless you can pin down work location and tax liability. ACS PUMS geography (PUMAs) is typically too coarse to measure distance-to-border cleanly.  
- **Novelty Assessment:** Border/tax differentials and migration are well studied; self-employment composition at this specific NH–MA border is less standard, but the broader design is not novel.  
- **Recommendation:** **SKIP** (unless you can access restricted geocodes + credible tax-liability construction; even then, sorting makes interpretation hard).

---

**#5: The FAFSA Independence Cliff: Does Financial Aid Eligibility at Age 24 Affect Non-Traditional Student Labor Supply?**
- **Score:** 42/100  
- **Strengths:** Important policy question (FAFSA rules are actively debated) and the labor-supply margin for returning students is genuinely interesting. A national design could add external validity relative to single-state administrative studies.  
- **Concerns:** The proposed RD is **misaligned with the actual rule**: FAFSA independence is determined by being 24 **by Dec 31 of the award year**, which implies a cohort/date-of-birth cutoff (around Jan 1), not a clean discontinuity at the 24th birthday; ACS also does not observe aid receipt/eligibility directly, and many are “independent” for other reasons (marriage, dependents), blurring treatment sharply.  
- **Novelty Assessment:** There is existing work on aid eligibility and outcomes (including around independence), though not necessarily on *entry/enrollment decisions + labor supply* nationally; still, the key problem here is design feasibility/validity with ACS.  
- **Recommendation:** **SKIP** (as currently framed; it would need DOB-based administrative or financial-aid microdata to be credible).

---

### Summary
This batch has one standout *idea* (Colorado age-21 marijuana access and self-employment) but multiple proposals lean on ACS in ways that likely won’t support the intended “hardcore” RDD (month-level age and/or the correct cutoff definition are missing). If you pursue anything first, pursue **Idea 1** only with redesigned identification (difference-in-discontinuities netting out alcohol-at-21) and higher-resolution age data; **Idea 5** is the next most novel but needs much better mechanism data (eligibility/withdrawals) to be publishable.