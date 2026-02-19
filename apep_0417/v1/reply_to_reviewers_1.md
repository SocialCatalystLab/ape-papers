# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. T-MSIS Suppression and Measurement
**Concern:** Suppression creates non-classical measurement error that could mechanically generate a null.

**Response:** We have expanded Section 3.4 to clarify that T-MSIS suppression operates at the billing×servicing×HCPCS×month cell level. At the provider-quarter level, a provider appears if they have *any* non-suppressed cell, substantially mitigating the concern. We acknowledge this as a limitation and note that suppression-driven attenuation would bias toward zero, making our null consistent with (but not solely explained by) measurement limitations. We add explicit discussion of this in the limitations section.

### 2. Missing DiD References
**Concern:** Need Goodman-Bacon (2021), Callaway & Sant'Anna (2021), de Chaisemartin & D'Haultfoeuille (2020), Roth et al. (2023), Cameron et al. (2008).

**Response:** All five references added to bibliography and cited in Section 5 (Empirical Strategy). We contextualize our Sun-Abraham estimator within this literature and note the concordance between TWFE and SA estimates as evidence against heterogeneous treatment effect bias.

### 3. MDE Calculation
**Concern:** Need formal minimum detectable effect for a null result paper.

**Response:** We add an MDE calculation in Section 6.1. With our pooled SE of 0.2376 and 51 clusters, the MDE at 80% power is approximately 0.47 log points (~60% change), confirming that while we can rule out large effects, our power for detecting small effects is limited. We present MDE for pooled and by-specialty estimates.

### 4. 95% CIs in Tables
**Concern:** Only pooled CI reported in text; need CIs in tables.

**Response:** We add 95% CI columns to the by-specialty regression table (Table 4).

### 5. Temper Reimbursement Language
**Concern:** Claiming "reimbursement is the binding constraint" is stronger than the evidence supports.

**Response:** We revise the discussion and conclusion to frame the reimbursement hypothesis as *consistent with* our findings rather than *proven by* them. We replace definitive language with suggestive phrasing.

### 6. Billing vs. Servicing NPI
**Concern:** Billing NPIs conflate organizations and clinicians.

**Response:** We acknowledge this limitation in Section 3.4 and note that Type 1 (individual) NPIs represent the vast majority of our sample, reducing but not eliminating this concern.

### Not Addressed:
- **Border-county design:** Beyond scope of current revision; noted as promising extension
- **Wild cluster bootstrap:** R package fwildclusterboot unavailable; permutation inference (500 draws) provides similar non-parametric validity
- **State-specific trends:** Could absorb treatment; noted as sensitivity worth exploring in future work

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Missing DiD References
**Response:** Added Goodman-Bacon (2021), Callaway & Sant'Anna (2021), de Chaisemartin & D'Haultfoeuille (2020). Integrated into Section 5.

### 2. Table Notes
**Concern:** Some tables have incomplete or empty notes.

**Response:** All table notes reviewed and completed.

### 3. Reimbursement Heterogeneity
**Concern:** Interact unwinding with state Medicaid reimbursement rates.

**Response:** We note this as a promising extension. Current T-MSIS extract does not include fee schedule data, and Medicaid-to-Medicare fee ratios vary by service type and year, making clean integration non-trivial. We add discussion of this as a natural next step.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Literature: Clemens & Gottlieb (2014), Finkelstein (2007)
**Response:** Both references added and cited in the discussion of supply-side price elasticities (Section 8).

### 2. Composition of Remaining Enrollees
**Concern:** Show complexity/chronic conditions of remaining pool changed.

**Response:** We note this as an important extension requiring beneficiary-level T-MSIS data, which is outside our current provider-level extract.

### 3. Border-County Design
**Response:** Noted as promising future work in the Discussion section. Would require additional geocoding and border-pair matching infrastructure.
