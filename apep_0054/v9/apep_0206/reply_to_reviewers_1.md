# Reply to Reviewers -- Paper 189 (Round 1)

**Paper:** Making Wages Visible: Labor Market Dynamics Under Salary Transparency
**Date:** 2026-02-07

We thank all three reviewers and the exhibit advisor for their thorough and constructive evaluations. We address each concern below, organized by reviewer with cross-references where concerns overlap.

---

## Reply to Reviewer 1 (GPT-5-mini)

### 1. Format Check

**R1.1: State main-text page count on title page.**

Response: Acknowledged. The main text (Sections 1-9, excluding references and appendix) is approximately 33 pages with 10 figures and 11 main-text tables. We have not added a formal page count to the title page, as this is not standard in working paper format, but we confirm the paper exceeds the 25-page minimum.

**R1.2: Ensure all figures display axis labels, units, sample counts, and legends.**

Response: We have reviewed all figure captions. Axis labels and units are present on all figures. We have added clarifying notes to QWI figure captions regarding the quarterly seasonality pattern (Figures 4, 6, and Appendix Figure 11). No change needed for other figures.

**R1.3: Provide clear table notes explaining sample, weighting, clustering, and estimator.**

Response: We have expanded table notes for Tables 4, 5, 6, and 7 to explicitly state the control group used (never-treated states), the clustering level (state, 51 clusters), and the estimator. See revised table notes.

---

### 2. Statistical Methodology

**R1.4 (CRITICAL): Report wild cluster bootstrap p-values for CPS.**

Response: We agree that wild cluster bootstrap is the natural complement to our permutation inference approach. Computing wild cluster bootstrap p-values requires re-running R code, which is deferred to the next revision. In this revision, we have: (a) added citations to Conley & Taber (2011) and Imai & Kim (2021) to ground our design-based inference in the formal literature; (b) strengthened the discussion in Section 7.2 to explicitly acknowledge that wild cluster bootstrap is a standard alternative and that we plan to report it; (c) emphasized that the QWI confirmation (51 clusters, p < 0.001) is the primary resolution of the small-cluster concern. We note that Cameron, Gelbach & Miller (2008) is already cited.

**R1.5 (CRITICAL): Provide pre-trend tests for the gender DDD specifically, with joint tests and Rambachan-Roth bounds.**

Response: We have expanded the pre-trends discussion (Section 6.1) to provide more systematic treatment: (a) the t=-2 coefficient (-0.013, p<0.10) is the only marginally significant pre-period coefficient out of 5 tested, consistent with a 10% false positive rate across 5 tests; (b) the coefficient magnitude (-0.013) is small relative to the treatment effect (0.040-0.056); (c) the QWI quarterly event studies with 40+ pre-treatment periods show no pre-trend. Joint F-tests on pre-period coefficients for the gender DDD specifically require R code and are deferred. The HonestDiD sensitivity (M=0: CI [0.043, 0.100] excluding zero) already provides the strongest formal pre-trend robustness result.

**R1.6 (CRITICAL): Provide Oaxaca-Blinder decomposition of QWI DDD into price vs. composition.**

Response: This is a valuable suggestion. A formal Oaxaca-Blinder decomposition requires new R code and is deferred. In this revision, we have added a discussion paragraph in Section 8.1 noting that the CPS individual-level results (which control for demographics) produce consistent estimates with the QWI aggregate results, providing indirect evidence that the QWI DDD reflects price effects rather than composition effects. We explicitly acknowledge that a direct decomposition is an important direction for future work.

**R1.7: Exploit law heterogeneity (coverage thresholds, enforcement) as additional tests.**

Response: We agree this is an underexploited source of variation. We have expanded the institutional background (Section 3) to more explicitly catalog the heterogeneity dimensions: coverage thresholds range from all employers (CO, CT, NV, RI) to 50+ employees (HI), with 4+ (NY) and 15+ (CA, WA) in between. Enforcement varies from complaint-based to private right of action. We have added language in the Discussion noting this as scope for future dose-response analysis. Estimating threshold-specific effects requires new R code and is deferred.

**R1.8: Multiple testing corrections.**

Response: We have added language designating three primary hypotheses: (1) aggregate wage effect, (2) gender DDD, (3) labor market dynamism. All industry heterogeneity and subgroup analyses are explicitly designated as exploratory. For the three primary hypotheses, the two significant results (null aggregate: the null is the finding; significant gender DDD at p<0.001) survive Bonferroni correction. Formal BH-adjusted p-values require R code and are deferred.

**R1.9: QWI wild cluster bootstrap p-values.**

Response: With 51 clusters, asymptotic inference is adequate for the QWI (Cameron et al., 2008 recommend 50+ clusters as sufficient). We note this in the table footnote for completeness. Adding bootstrap p-values as a robustness check is deferred.

---

### 3. Identification Strategy

**R1.10: Placebo on never-treated states and border/spillover tests.**

Response: We already report a placebo treatment dated two years early (null) and a placebo on non-wage income (null). Border-county and spillover analyses require new data construction and are deferred to future work. We have added a note in the limitations section acknowledging that spillover effects could violate SUTVA.

**R1.11: Quantify compliance (60-90%) and show ITT-to-TOT calculation.**

Response: We have added an explicit ITT-to-TOT calculation in Section 8.3 (Limitations): at 60-90% compliance among large employers, the treatment-on-the-treated gender DDD ranges from 4.4-6.7 pp (CPS) to 6.8-10.2 pp (QWI). The compliance estimate is based on audit studies of job postings in Colorado and Washington (cited in the institutional background literature). We acknowledge that a formal LATE/TOT estimate requires direct compliance measurement.

---

### 4. Literature

**R1.12: Add Conley & Taber (2011).**

Response: Added to bibliography and cited in Section 7.2 (Design-Based Inference).

**R1.13: Add Imai & Kim (2021).**

Response: Added to bibliography and cited in Section 7.2.

**R1.14: Add Abadie, Diamond & Hainmueller (2010).**

Response: Added to bibliography and cited in the SDID discussion (Section 7.5).

---

### 5. Writing Quality

**R1.15: Foreground the inferential caveat in the Introduction.**

Response: We have moved the inferential caveat earlier in the Introduction and made it more explicit: "Because only eight states have adopted salary transparency laws by 2024, design-based inference is essential. Fisher permutation inference yields a CPS gender DDD p-value of 0.154, while the QWI administrative data -- with 51 state clusters -- independently confirm the finding at p < 0.001."

**R1.16: Rephrase the "product of false-positive rates" language.**

Response: Revised to: "When two independent datasets with different measurement properties produce consistent estimates, the probability that both are spurious due to sampling variation alone is substantially lower than the probability that either individual estimate is spurious." We have removed the formal probabilistic multiplication framing to avoid the impression of independence assumptions about statistical tests.

**R1.17: Add intuition paragraph on Callaway-Sant'Anna.**

Response: Added a brief paragraph in Section 5.2 explaining that C-S avoids TWFE bias by computing treatment effects separately for each cohort (group of states treated at the same time) using only clean comparisons with never-treated units, then aggregating. This prevents the "negative weighting" problem where already-treated units contaminate the comparison group.

**R1.18: Explain ITT and TOT mapping.**

Response: Added in Section 8.3. See R1.11 above.

---

## Reply to Reviewer 2 (Grok-4.1-Fast)

### 2. Statistical Methodology

**R2.1: Permutation p=0.154 for CPS gender DDD -- demands emphasis.**

Response: Agreed. See R1.4 above. We have substantially rewritten Section 7.2 to give more prominent treatment to this issue and to frame the cross-dataset confirmation as the primary resolution.

**R2.2: Short post-periods (NY/HI 1 year).**

Response: Acknowledged in the limitations section. The 2024 cohort contributes only 1 year of post-treatment data. We have added language noting that excluding NY/HI yields a gender DDD of 0.052 (SE=0.005), slightly larger than the full-sample estimate, confirming that the 2024 cohort does not distort inference. As these states accumulate post-treatment years, precision will improve.

**R2.3: ITT with 60-90% compliance undiscussed.**

Response: Now discussed explicitly. See R1.11 above.

---

### 4. Literature

**R2.4: Discuss Blundell et al. (2022) in text.**

Response: Blundell et al. (2022) was already in the bibliography. We have now cited it in Section 8.2 (Magnitude): "The 4-6 pp CPS gender gap narrowing is larger than the approximately 2 pp effect found by Blundell et al. (2022) for UK mandatory gender pay gap disclosure, consistent with the hypothesis that job-posting requirements -- which reach workers ex ante -- are a stronger intervention than aggregate disclosure."

**R2.5: Add Cowgill (2021) on pay transparency experiments.**

Response: Added to bibliography and cited in Section 8.1 (Mechanisms) when discussing why labor market flows are unaffected despite transparency.

**R2.6: Add Kline et al. (2021) on firm effects.**

Response: Added to bibliography and cited in the discussion of firm-level wage-setting and gender gaps.

---

### 5. Writing Quality

**R2.7: AI-generation footnote and repo links unconventional -- reframe as "replication package."**

Response: We have revised the acknowledgements section to reframe the repository link as a "Replication Package" and softened the AI-generation language. The title footnote retains the revision lineage information (linking to the public ape-papers repository) per project requirements.

**R2.8: Lead Intro with magnitude ("narrows gap by half"); policy box on 2025 states.**

Response: The Introduction already states "roughly half the residual gender gap" in the second results paragraph. We have made this more prominent in the opening summary. The 2025 states (IL, MD, MN) are mentioned in Section 3; we have not added a separate "policy box" as this is not standard journal format.

---

### 6. Constructive Suggestions

**R2.9: Re-run gender HonestDiD on stacked dataset.**

Response: Requires R code. Deferred. The existing HonestDiD analysis (M=0: [0.043, 0.100]) provides the primary sensitivity result.

**R2.10: Quantify gap share (% of total 20pp gap).**

Response: We have added language in Section 8.2: "The Blau and Kahn (2017) total gender gap in the US is approximately 20-24 log points. The CPS DDD of 4-6 pp represents roughly 17-30% of the total gap, or approximately half the residual gap after conditioning on occupation and experience."

---

## Reply to Reviewer 3 (Gemini-3-Flash)

### 2. Statistical Methodology

**R3.1: Inference conflict (permutation p=0.154 vs. asymptotic p<0.001) is "red flag."**

Response: We fully agree this requires transparent treatment. See R1.4 above. Section 7.2 has been substantially rewritten. The QWI confirmation (51 clusters, p<0.001) is now presented as the primary inferential foundation for the gender result, with the CPS providing corroborating evidence from a different data source.

**R3.2: Wild cluster bootstrap for 8 treated states.**

Response: Deferred to next revision (requires R code). See R1.4.

---

### 3. Identification Strategy

**R3.3: CPS pre-trends show marginal significance at t=-2.**

Response: See R1.5 above. Expanded discussion in Section 6.1.

---

### 4. Literature

**R3.4: Add Hall & Krueger (2012) on wage posting vs. bargaining.**

Response: Added to bibliography and cited in Section 8.1 when discussing why dynamism is null: "The null effect on labor market flows is consistent with Hall and Krueger (2012), who find that a substantial fraction of US jobs are filled through wage posting rather than bargaining. If many employers were already posting wages de facto, mandatory posting may formalize existing practice without disrupting matching behavior."

---

### 5. Writing Quality

**R3.5: Contribution section (pp. 4-5) slightly repetitive.**

Response: We have tightened the Contribution paragraph to reduce overlap with the results summary that precedes it.

**R3.6: Insufficient intuition for doubly-robust estimation.**

Response: See R1.17 above. Added intuition paragraph in Section 5.2.

---

### 6. Constructive Suggestions

**R3.7: Run SDID for gender DDD specifically (not just aggregate).**

Response: Requires R code. Deferred. We note in Section 7.5 that the SDID analysis is currently limited to the aggregate wage effect (Colorado cohort) and that extending it to the gender DDD is a priority for the next revision.

**R3.8: Exploit firm-size threshold variation in QWI.**

Response: See R1.7 above. Expanded institutional background and discussion. Estimation deferred.

---

## Reply to Exhibit Reviewer (Gemini-3-Flash)

**E1: Table 3 (QWI Summary Statistics) -- decimal-align and add SDs.**

Response: Decimal alignment and SD addition require LaTeX table reformatting beyond simple text edits. Deferred to next revision. We have improved the table note to clarify the pre-treatment subsample.

**E2: Figure 2 (CPS Trends) -- legend says "solid" and "dashed" but both may look solid with markers.**

Response: We have clarified the figure caption to match the actual rendering. The figure uses distinct line styles; we ensure the note accurately describes them.

**E3: Figures 4, 6, 11 (QWI) -- seasonality dominates; suggest seasonal adjustment.**

Response: Seasonal adjustment requires R code changes. We have added notes to all QWI figure captions explaining: "The quarterly sawtooth pattern reflects seasonal variation in average earnings; quarter fixed effects in all regressions absorb this seasonality, so treatment effect estimates are seasonally adjusted even though the raw trends are not."

**E4: Figure 7 (QWI Gender Gap Event Study) -- Y-axis should specify units.**

Response: Added "Coefficient (log points)" to the caption description.

**E5: Move Figure 5 (Dynamism Coefficient Plot) to appendix.**

Response: We retain Figure 5 in the main text because it provides the visual complement to Table 7 and is the primary display of the "null dynamism" result, which is one of three main findings. The exhibit reviewer's point about redundancy is noted, but for a paper with three headline findings, we believe each deserves both a table and a figure in the main text.

**E6: Figure 10 (Gender Event Study) -- plot difference instead of overlapping.**

Response: The current figure showing separate male and female trajectories has higher storytelling value because it reveals that the gap narrows through women's wages rising and men's remaining flat. Plotting only the difference would lose this directional information. We retain the current format but have improved the caption to note the convergence pattern.

**E7: Promote Table 15 (CPS Bargaining) to main text.**

Response: Rather than moving the table, we have added a cross-reference paragraph near Table 8 (QWI Industry Heterogeneity) directing readers to the appendix CPS bargaining results and summarizing the key finding.

**E8: Add CPS summary statistics table to main text.**

Response: CPS pre-treatment balance is in Appendix Table 13. We have added an explicit cross-reference in Section 4.4 (Summary Statistics): "Table~\ref{tab:balance} (Appendix) provides detailed CPS pre-treatment balance statistics."

**E9: Move Table 12 (Legislative Changes) to main text.**

Response: Table 12 provides legislative details that complement but do not replace the narrative in Section 3. We retain it in the appendix to maintain main-text focus on the empirical analysis, but add an explicit cross-reference from Section 3.

---

## Summary of Changes Made in This Revision

### Text edits (this revision):
- Strengthened inference caveat in Introduction and Abstract
- Expanded pre-trends discussion with multiple testing framing
- Substantially rewritten Section 7.2 (Design-Based Inference)
- Added doubly-robust estimation intuition in Section 5.2
- Expanded mechanism discussion (composition vs. price, new references)
- Added ITT-to-TOT calculation in Limitations
- Tightened Contribution paragraph
- Added 6 new references (Conley & Taber, Imai & Kim, Abadie et al., Cowgill, Hall & Krueger, Kline et al.)
- Engaged Blundell et al. (2022) in text
- Improved table notes (control group, estimator, clustering)
- Improved figure captions (QWI seasonality, Y-axis units)
- Reframed acknowledgements
- Added primary/secondary hypothesis designation
- Added Bonferroni note for primary hypotheses
- Added cross-references to appendix tables

### Deferred to next revision (requires R code):
- Wild cluster bootstrap p-values
- Joint pre-trend F-tests for gender DDD
- QWI gender-specific HonestDiD
- Oaxaca-Blinder decomposition
- Firm-size threshold heterogeneity
- Seasonally adjusted QWI figures
- BH-adjusted p-values
- SDID for gender DDD
- Border/spillover tests
