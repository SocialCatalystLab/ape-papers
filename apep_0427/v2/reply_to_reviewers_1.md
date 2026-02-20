# Reply to Reviewers — apep_0427 v2 Stage C

## Reviewer 1 (GPT-5.2) — MAJOR REVISION

### Fatal Error 1: Sectoral Demand Confound
**Concern:** Total employment rises differentially with exposure post-2023, indicating correlated sectoral demand shocks.

**Response:** We added sector-specific linear time trends as a new robustness specification (Table 7). This directly absorbs differential sector growth trajectories. Results: youth share coefficient remains significant (0.061, p=0.045), but total employment coefficient collapses to 1.05 (p=0.78). This demonstrates that the "red flag" in the baseline was driven by sector trends, not the subsidy change. The compositional effect on youth share persists after controlling for these trends.

### Fatal Error 2: Mechanism Not Directly Measured
**Concern:** Relabeling is inferred indirectly; need DARES admin data on apprenticeship contracts.

**Response:** We acknowledge this limitation explicitly in the conclusion. DARES administrative apprenticeship contracting data would provide the definitive test. We note this as the essential next step. The indirect evidence (positive youth share + no decline post-reduction + Indeed vacancy stability) is consistent with relabeling but not conclusive.

### Fatal Error 3: Shift-Share Inference
**Concern:** RI assumes exchangeability; need more literature on shift-share inference.

**Response:** Added citation of Adão, Kolesár, and Morales (2019) and explicit discussion of how wild cluster bootstrap addresses correlated residual concerns. RI p-value (0.13) now correctly acknowledged as less reliable than WCB (0.029) given the exchangeability concern.

### Fatal Error 4: Pre-Trend Testing
**Concern:** Need Rambachan & Roth pretrend-robust bounds.

**Response:** Added discussion of Rambachan & Roth framework but explained why monotonicity assumptions are difficult to justify with quarterly sector-level data. Pointed to the sector-specific trends specification (Table 7) as an alternative approach that directly absorbs differential trends.

### Fatal Error 5: Missing Literature
**Concern:** Need Adão et al. (2019), Rambachan & Roth (2023).

**Response:** Both now cited in the identification section and pre-trend analysis. Card, Kluve, Weber (2018) was already cited.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Issue 1: Total Employment Confound
**Response:** Resolved with sector-specific linear trends (Table 7). See GPT response above.

### Issue 2: Marginal Statistical Significance
**Response:** Acknowledged more explicitly in text. Three inference procedures (clustered SE p=0.07, WCB p=0.029, RI p=0.13) bracket the significance level. With sector trends, youth share is p=0.045. We interpret this as "moderate evidence."

### Issue 3: No Admin Contract Data
**Response:** Acknowledged as key limitation. DARES data is the essential next step.

### Issue 4: SCM Fit Imperfect
**Response:** RMSPE of 2.0 pp acknowledged. SCM results correctly interpreted as "corroborative but not conclusive" given 7 donor countries.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Issue 1: Sectoral Confounding
**Response:** Resolved with sector-specific linear trends (Table 7).

### Issue 2: Table Rendering
**Response:** Added `\usepackage{adjustbox}` to preamble. All wide tables now use adjustbox for proper rendering.

### Issue 3: Missing Wage Evidence
**Response:** Acknowledged as valuable future direction. Entry-level wage analysis would provide additional evidence for the relabeling mechanism.

### Issue 4: Heterogeneity Underdeveloped
**Response:** Noted for future work. Formal skill-level heterogeneity (Master's vs. vocational) requires finer data disaggregation.

---

## Exhibit Review

- Fixed Table 3/4 rendering with adjustbox package
- Table 1 notes updated ("exposure DiD" instead of "Bartik DiD")
- All tables regenerated with consistent formatting

## Prose Review

- Improved conclusion with Shleifer-style ending ("France bought a label, not an opportunity")
- Maintained active voice throughout results section
- Added per-job cost framing (€176,000) to conclusion
