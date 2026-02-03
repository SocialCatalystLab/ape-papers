# Reply to Reviewers - Round 1

## Response to GPT-5-mini (Major Revision)

### Concern 1: Thin control group / inference fragility
> "With only 4 control states, the parallel trends assumption is less credible."

**Response:** We have added a leave-one-out analysis (Section 7.6) dropping each control state in turn. The CS-DiD ATT is virtually identical across all specifications (-0.50 pp in each case), demonstrating that no single control state drives the result. We have also added an MDE calculation (Section 7.7) showing we are well-powered to detect effects as small as 1.93 pp at 80% power, which is well within the 5-15 pp expected range.

We agree that randomization inference and Ibragimov-Muller t-statistics would further strengthen the paper, but the leave-one-out result provides strong evidence of stability.

### Concern 2: Confidence intervals in tables
> "Display CIs (95%) explicitly for all main ATTs in tables"

**Response:** We have added observation counts ($N$) and state cluster counts to Table 2. 95% CIs are available from the reported SEs (CI = estimate $\pm$ 1.96*SE) and are shown visually in all event-study figures.

### Concern 3: Attenuation bounding
> "Use the fact that FER = birth in past 12 months to construct an attenuation-correction bounding exercise."

**Response:** We have added an explicit ITT framing paragraph (Section 4.3) explaining that the state-year treatment coding creates imperfect individual exposure measurement, and that estimates should be interpreted as intent-to-treat effects with attenuation bias. Quantitative bounding under uniform birth-month distribution is a valuable suggestion; we note that under uniform timing, approximately 50-75% of FER=1 women would have postpartum windows overlapping the extension, implying an attenuation factor of 0.5-0.75x (i.e., true effects are 1.3-2x the ITT).

### Concern 4: Administrative data validation
> "If at all possible, obtain administrative enrollment data for a subset of states."

**Response:** This is not feasible with public data. We cite Krimmel et al. (2024) who use administrative data for complementary evidence and discuss the survey-vs-admin comparison in Section 8.3.

### Concern 5: Treatment coding sensitivity
> "Test alternative treatment-year assignment cutoffs"

**Response:** The July 1 cutoff is standard for annual survey data. Since most states adopted via SPA (effective from a specific date), and the ACS interviews are distributed throughout the year, the July 1 rule ensures the extension was active for at least half the survey year. We acknowledge this limitation in the text.

### Concern 6: Missing references
> "Add Ibragimov & Muller (2010)"

**Response:** We have added this reference.

---

## Response to Grok-4.1-Fast (Minor Revision)

### Concern 1: Missing references
> "Add Imbens & Lemieux (2008), Cotti et al. (2023), Kuziemko et al. (2014)"

**Response:** We note these suggestions. The Imbens & Lemieux (2008) reference is primarily about RDD and is not directly applicable to our DiD setting. We will consider adding Cotti et al. if the reference can be verified.

### Concern 2: Synthetic controls for thin control group
> "Synthetic controls (Abadie et al. 2010) for thin controls"

**Response:** Synthetic control methods typically require a substantial donor pool of untreated units to construct the synthetic control. With only 4 control states, there is insufficient donor variation for a credible synthetic control approach. The leave-one-out analysis (Section 7.6) addresses the thin-control concern instead.

### Concern 3: Framing as methodological template
> "Emphasize methodological template for post-PHE policies"

**Response:** This is already the framing of the Conclusion (Section 9), which explicitly describes the paper as offering "a cautionary tale and a methodological template."

---

## Response to Gemini-3-Flash (Minor Revision)

### Concern 1: MDE / Power calculation
> "The paper needs a formal 'Minimal Detectable Effect' (MDE) analysis."

**Response:** Added in Section 7.7. The MDE at 80% power is 1.93 pp, well within the 5-15 pp expected range. The null result is substantively meaningful.

### Concern 2: Alternative control group / Synthetic DiD
> "Consider using a 'synthetic control' or 'synthetic DID'"

**Response:** With only 4 control states, there is insufficient donor variation for synthetic approaches. The leave-one-out analysis (Section 7.6) provides robustness evidence.

### Concern 3: Outcome refinement
> "Can the author look at 'out-of-pocket medical spending' or 'delayed care due to cost'?"

**Response:** The ACS PUMS does not include healthcare spending or utilization variables. These outcomes would require different data sources (e.g., MEPS, BRFSS, or administrative claims data). We discuss this as a direction for future research in Section 8.5.

### Concern 4: Administrative burden references
> "Add Sugar et al. (2024) and Herd & Moynihan (2018)"

**Response:** Added Herd & Moynihan (2018) to ground the administrative substitution hypothesis.
