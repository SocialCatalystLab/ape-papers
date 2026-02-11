# Reply to Reviewers — apep_0219 v2

We thank all three referees for their careful reading and constructive feedback. Below we address each point raised in the v2 external reviews.

---

## Reviewer 1 (GPT-5-mini) — Major Revision

### 1.1 First-Stage Grant Data

> **Concern:** "The lack of documented first stage (county-level ARC grant disbursement data) is a substantive limitation and undermines causal claims about funding effectiveness."

**Response:** We agree this is the paper's most important limitation. We have strengthened the framing throughout: the introduction now explicitly states that "these estimates capture the reduced-form effect of the Distressed *designation*---encompassing the label, enhanced match rates, and any realized spending changes---rather than the effect of a documented increase in grant dollars." Section 5.6 (Mechanisms) distinguishes the "insufficient take-up" and "ineffective spending" hypotheses. Back-of-envelope funding calculations are now clearly labeled as illustrative. County-level ARC disbursement data would require FOIA and is flagged for future work.

### 1.2 Inference Robustness (Wild Bootstrap, Permutation)

> **Concern:** "Supplement with wild-cluster bootstrap or permutation inference."

**Response:** With 369 clusters, cluster-robust inference via rdrobust is well-powered (Cameron et al. 2008 recommend >40 clusters). The effective samples (648-901 within bandwidth) are moderate. We note that fwildclusterboot is not available for the current R version on this system, which prevents automated wild bootstrap. The year-by-year estimates (Table 10) serve as a form of cross-validation: 33 individual tests with only 1 rejection at 5% is consistent with the null. We acknowledge that formal permutation inference would further strengthen confidence and flag this for future work.

### 1.3 Explicit 95% CIs in Tables

> **Concern:** "Present explicit 95% CIs in main results table."

**Response:** Done. Table 4 (main results) now includes a row showing 95% robust bias-corrected confidence intervals for all six specifications.

### 1.4 FY2017 McCrary Rejection

> **Concern:** "FY2017 density test rejects at p=0.030. Investigate and report sensitivity."

**Response:** We added a dedicated robustness paragraph showing that excluding FY2017 produces virtually identical results (unemployment: 0.010 to 0.008, log PCMI: 0.012 to 0.011, poverty: 0.095 to 0.102). The FY2017 density anomaly does not drive the null. We also added year-by-year McCrary results as an Appendix Table, showing 10/11 years pass at 5%.

### 1.5 Imbens & Lemieux (2008) Reference

> **Concern:** "Add canonical RDD survey references."

**Response:** Added Imbens and Lemieux (2008) to the bibliography and cited in Section 4.1 alongside Hahn et al. (2001). Lee and Lemieux (2010) was already cited.

### 1.6 Lead Tests / Pre-Trends

> **Concern:** "Show RDD on lead outcomes to check for anticipatory effects."

**Response:** The covariate balance tests (Figure 3) use prior-year CIV components, which serves this purpose. Because the CIV is constructed from 3-year lagged data, outcomes at time t cannot retroactively affect the designation at time t. We discuss this institutional feature in Section 4.3. Formal lead tests would require outcomes measured entirely before the designation's fiscal year; given the multi-year lag structure, the current prior-year balance tests provide strong evidence against anticipation.

---

## Reviewer 2 (Grok-4.1-Fast) — Minor Revision

### 2.1 First-Stage Grant Data

> **Concern:** "Pursue FOIA for county-level ARC grants."

**Response:** Addressed in response to GPT 1.1 above. The first-stage limitation is acknowledged and well-framed. FOIA is flagged for future research.

### 2.2 Missing References

> **Concern:** "Add Imbens & Lemieux (2008) and Lee & Lemieux (2010)."

**Response:** Both are now cited. Imbens & Lemieux (2008) added; Lee & Lemieux (2010) was already in the bibliography.

### 2.3 Heterogeneity by Coal Dependence

> **Concern:** "Subgroup by coal-dependence."

**Response:** The Central Appalachia subsample (Section 5.3) captures the coal-dependent core (Kentucky, West Virginia, Virginia, Tennessee). The null holds in this subsample. More granular coal-dependence proxies (e.g., % mining employment) would strengthen this but require additional data merging.

### 2.4 Vary Null Phrasing

> **Concern:** "Minor repetition in null phrasing."

**Response:** We varied the language describing null results throughout the paper to avoid monotony.

---

## Reviewer 3 (Gemini-3-Flash) — Minor Revision

### 3.1 First-Stage Data

> **Concern:** "Some ARC grant data may be available via USASpending.gov or FOIA."

**Response:** We acknowledge this possibility and flag it for future work. The current paper provides the reduced-form estimate; the first-stage remains an important extension.

### 3.2 Long-Run Outcomes

> **Concern:** "Could the authors look at outcomes 5 or 10 years after first receiving the Distressed label?"

**Response:** The year-by-year estimates cover 11 fiscal years (2007-2017), and the temporal heterogeneity analysis (Figure 6, Table 10) shows no evidence of emerging effects over time. Longer-run outcomes would require extending the sample beyond 2017, which is feasible as ARC continues to publish CIV data. Flagged for future work.

### 3.3 Spillovers

> **Concern:** "Does being a Distressed county affect neighboring At-Risk counties?"

**Response:** Spatial spillovers are an excellent suggestion but would require geographic proximity data and a more complex empirical framework (e.g., spatial RDD). This is beyond the current scope but noted as a promising extension.

---

## Summary of Changes in v2

| Change | Section | Motivation |
|--------|---------|------------|
| Fixed bibliography (31 citations resolved) | All | Critical LaTeX bug |
| Added 3 non-CIV alternative outcomes | 5.4, Appendix | Outcome-assignment overlap concern |
| Added CIV distribution histogram | 5.1 | Running variable continuity |
| Added year-by-year McCrary tests | 5.1, Appendix | Year-specific density validation |
| Added FY2017 exclusion robustness | 5.5 | GPT concern about density anomaly |
| Added 95% CIs to main table | Table 4 | GPT request |
| Clarified sample counts | Abstract, Data | Advisor consistency fix |
| Added placebo results to robustness table | Table 5 Panel D | Grok completeness fix |
| Strengthened first-stage framing | Introduction, Mechanisms | All 3 reviewers |
| Added Imbens & Lemieux (2008) | Section 4.1 | GPT and Grok |
| Added revision footnote | Title | Skill requirement |
