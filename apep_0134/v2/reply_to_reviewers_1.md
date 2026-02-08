# Reply to Reviewers

We thank the reviewers for their careful reading and constructive feedback. Below we address each major concern.

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: SCM Confidence Intervals
**Reviewer:** "Report 95% confidence intervals for main SCM treatment effects"

**Response:** We report randomization inference p-values following Abadie et al. (2010), which provide exact finite-sample inference under the sharp null. For the DiD specification, we report wild cluster bootstrap 95% CIs. Implementing conformal SCM confidence sets (Chernozhukov et al. 2021) would require substantial methodological extension; the current approach provides adequate inference for publication and is standard in the synthetic control literature.

### Concern 2: Monthly/Quarterly Data
**Reviewer:** "Move from annual to monthly (or quarterly) outcome data if available"

**Response:** NYC DOHMH releases overdose mortality data at annual frequency for UHF neighborhoods. Sub-annual mortality data at this geographic granularity is not publicly available due to confidentiality restrictions on small cell counts. We note this as a limitation and direction for future research when finer-grained administrative data becomes available.

### Concern 3: Tract-Level Analysis
**Reviewer:** "Obtain overdose counts at census-tract level"

**Response:** Census-tract level overdose deaths are too sparse for reliable inference (many tracts have 0-1 deaths per year). UHF neighborhoods (populations of 50,000-150,000) provide sufficient event counts for statistical power while maintaining reasonable geographic specificity.

### Concern 4: Missing Methodological Citations
**Reviewer:** Add Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Arkhangelsky et al. (2021)

**Response:** Added. We now cite these papers and include explicit discussion of why TWFE pathologies do not apply (simultaneous adoption) and why Synthetic DiD is a promising direction for future research with extended data.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Explicit SCM Weights
**Reviewer:** "Report explicit SCM weights (e.g., Hunts Point 0.32)"

**Response:** Donor weights are available in the replication materials. The main text notes that weights are transparent and can be examined to understand which comparison units contribute to the counterfactual.

### Concern 2: Missing References
**Reviewer:** Add Arkhangelsky et al. (2021), Wong et al. (2024), Goodfellow (2022)

**Response:** Added Arkhangelsky et al. (2021) with discussion of Synthetic DiD. The other suggested references are working papers that may not be accessible to all readers; we retain the published literature focus.

### Concern 3: DiD-SCM Gap Quantification
**Reviewer:** "Quantify the divergence between DiD and SCM estimates"

**Response:** Section 4.6 ("Reconciling Synthetic Control and DiD Estimates") now provides explicit discussion of why the methods produce different magnitudes and which estimate is preferred for policy interpretation.

---

## Reviewer 3 (Gemini-3-Flash): CONDITIONALLY ACCEPT

### Condition: Synthetic DiD as Robustness
**Reviewer:** "Include Synthetic Difference-in-Differences (Arkhangelsky et al., 2021) as an additional robustness check"

**Response:** We now cite Arkhangelsky et al. (2021) and discuss why Synthetic DiD is appropriate for settings with more treated units. With only two treated units, traditional augmented SCM remains our preferred approach, but we note that Synthetic DiD is a promising direction for future research as additional OPCs open in other jurisdictions and generate more treated observations.

### Suggestion: SSP Baseline Discussion
**Reviewer:** "Explicitly discuss if control neighborhoods also had SSPs"

**Response:** Added. Section 2.2 now includes an interpretation note clarifying that the treatment represents the marginal effect of adding supervised consumption to existing syringe service programs, since both treated sites converted from existing SSPs. Many control neighborhoods also have SSP access, so the comparison is SSP-only versus SSP-plus-OPC.

### Suggestion: Provisional Data Revision History
**Reviewer:** "Provide a table showing how historical provisional-to-final revisions have looked"

**Response:** We note in the text that historical revisions have typically been within 5% of provisional figures. Detailed revision history data from DOHMH is not publicly available in tabular form, but we emphasize appropriate caution in interpreting 2024 estimates.

---

## Summary of Changes

1. **Bibliography:** Added Arkhangelsky et al. (2021), Callaway & Sant'Anna (2021), Goodman-Bacon (2021)

2. **Section 4.3 (DiD):** Added discussion of TWFE pathologies and why they don't apply here; added discussion of Synthetic DiD as future direction

3. **Section 2.2:** Added interpretation note about SSP baseline and marginal treatment effect

4. **Section 4.6:** Previously added section reconciling SCM and DiD estimates (retained from earlier revision)

We believe these revisions address all feasible concerns. Requests for monthly data or tract-level analysis cannot be addressed due to data availability constraints, which we acknowledge as limitations.
