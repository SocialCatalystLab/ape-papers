# Reply to Reviewers

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

### SCI Timing / Pre-determinacy of Shares
**Concern:** SCI measured in 2018 lies within the 2012-2022 sample window, raising endogeneity concerns.

**Response:** We have added a dedicated discussion paragraph (Section 11.4) addressing this concern through four arguments: (1) Facebook's documentation shows SCI correlation >0.99 across vintages, confirming temporal stability; (2) Bailey et al. (2020) validate SCI against decennial census migration patterns spanning decades, demonstrating that SCI reflects deep historical patterns rather than recent changes; (3) our population weights use pre-treatment 2012-2013 employment (predetermined per Borusyak et al. 2022), not SCI-derived weights; (4) distance-restricted instruments show STRONGER effects when restricted to distant connections, the opposite of what SCI endogeneity would predict (endogenous SCI would bias toward local connections).

### Exclusion Restriction / Event Study
**Concern:** Request for dynamic event study with leads and lags.

**Response:** We deliberately omit event-study specifications from this revision. Our shift-share IV design is fundamentally different from a DiD design: the "treatment" is a continuous, time-varying weighted average of 50 state-level policy changes, not a binary on/off switch. Imposing event-study dynamics on a continuous shift-share exposure is methodologically inappropriate (Borusyak et al. 2022). Instead, we provide: (1) distance-restricted instruments with improving balance, (2) two placebo shock tests confirming null effects for GDP and employment, (3) Anderson-Rubin confidence sets excluding zero, (4) permutation inference, (5) leave-one-state-out stability. We have softened causal language throughout to reflect maintained assumptions.

### Job Flows vs Employment Reconciliation
**Concern:** Positive employment but net job creation ≈ 0; how to reconcile?

**Response:** Added a dedicated paragraph in Section 9. The reconciliation operates through two channels: (1) QWI job flow variables suffer from much heavier confidentiality suppression (25% of county-quarters missing) than employment (1% missing), creating different effective samples; (2) increased churn is consistent with rising employment if the hiring rate slightly exceeds the separation rate, which our point estimates suggest (hire rate coefficient 0.058* vs separation rate 0.044).

### Additional Suggestions
- Causal language softened throughout (Section 1, Section 6)
- Added Monras (2020) and Dustmann et al. (2022) to bibliography

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Pre-trend Evidence
**Concern:** Event-study pre-trends would further reassure.

**Response:** Figure 8 shows roughly parallel pre-2014 trends across IV quartiles. We have corrected the figure caption to accurately describe the quartile ordering. As noted above, formal event-study specifications are inappropriate for continuous shift-share exposure.

### Missing References
**Concern:** Add Goldsmith-Pinkham & Sorkin (2023), Roth & Sant'Anna (2023), Athey et al. (2018).

**Response:** We focus on the most directly relevant methodological references (Borusyak et al. 2022, Goldsmith-Pinkham et al. 2020, Adão et al. 2019) which cover our specific shift-share design. Added Monras (2020) and Dustmann et al. (2022) which are most relevant to our labor market mechanisms.

---

## Reviewer 3 (Gemini-3-Flash) — MAJOR REVISION

### Magnitude Concern
**Concern:** 9% employment from $1 network MW seems implausibly large.

**Response:** Added a dedicated discussion paragraph (Section 11). The 9% is not comparable to direct minimum wage elasticities for several reasons: (1) it is the LATE for high-compliance counties with the strongest cross-state network ties; (2) a $1 change in network average MW represents a large policy shock aggregated across dozens of state-level changes; (3) Kline & Moretti (2014) find spatial multipliers of comparable magnitude (1.5-2.0x) for place-based policies; (4) using the economically relevant one-SD variation, the implied effect is ~8.6%, within the range of spatial multiplier estimates.

### Commuting Zone Analysis
**Concern:** Show results at CZ level to rule out cross-county commuting.

**Response:** This is an excellent suggestion that we note as future work. Our county fixed effects and state-by-time fixed effects absorb much cross-county commuting variation within states. The distance-restricted instruments further address this by showing effects strengthen with distance, inconsistent with commuting-driven artifacts.

### Mechanism Deep-Dive
**Concern:** Move more job flow analysis to main body.

**Response:** The job flow results (Table 9) are already in the main text body (Section 9). We have added a reconciliation paragraph addressing the employment-churn relationship.
