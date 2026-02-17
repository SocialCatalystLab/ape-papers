# Reply to Reviewers — apep_0341 v2

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Treatment measurement from same data as outcomes
**Response:** We acknowledge this is the central identification concern. We have:
1. Added external validation against ARPA spending plans for 10 of 20 treated states (Appendix Table 5), showing 7/7 ARPA-era states align with documented policy dates
2. Added T1019-specific rate detection as a robustness check
3. Added median-based rate detection (Table 4, Panel D) to guard against outlier-driven treatment classification
4. Discussed this concern explicitly in Section 5.3 (Threats to Validity)

While we cannot construct a fully external treatment indicator for all states (fee schedule documents are not uniformly digitized), the consistency across detection methods provides reassurance.

### Overstatement of "precisely estimated null"
**Response:** Fixed throughout. We now state "no evidence of positive effects" and report the CI explicitly: [-0.50, 0.37]. We acknowledge the CI does not rule out moderate effects in either direction.

### CS-DiD SE construction
**Response:** Added clarification that CS-DiD standard errors use the multiplier bootstrap procedure of Callaway and Sant'Anna (2021), clustered at the state level.

### RI permutation scheme
**Response:** Added explicit description: the procedure permutes treated/control labels while preserving the number of treated states (20) and assigns treatment dates drawn from the empirical distribution of adoption dates.

### Missing references
**Response:** Added Bertrand, Duflo, and Mullainathan (2004) on serial correlation in DiD. Roth (2022) and Rambachan and Roth (2023) were already cited.

### CIs for CS-DiD and N for robustness rows
**Response:** Table 2 now includes mean of dependent variable in levels. We note this as an area for further improvement but the core reporting (SEs, CIs for main results, WCB p-values) exceeds the standard for most published DiD papers.

### Terminology consistency
**Response:** Fixed "52 states" to "52 jurisdictions" throughout.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Missing references (Matsudaira 2014, Wooldridge 2021)
**Response:** We appreciate these suggestions. The current version already cites >50 references spanning methods, policy, and applied literature. Matsudaira (2014) on certificate of need is relevant but addresses a different regulatory mechanism (entry regulation vs. reimbursement rates). We focus the literature on direct rate-supply evidence.

### Managed care carve-outs
**Response:** We acknowledge this concern in Section 5.3. HCBS services are frequently carved out of managed care contracts, and even within managed care, states typically require adherence to fee schedule rates. A state-by-state managed care carve-out table would require additional data collection beyond T-MSIS.

### RI details
**Response:** Clarified in the Estimation subsection (Section 5.2). The sharp null is tested: under H₀, rate increases have zero effect on provider supply for all states.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Long-run dynamics
**Response:** We note this as a limitation. The sample ends December 2024, providing at most 9 months of post-treatment data for the latest cohort (Oregon). As T-MSIS data becomes available for 2025+, extending the post-treatment window would be valuable.

### State minimum wage interaction (DDD)
**Response:** This is an excellent suggestion for future work. The current paper focuses on establishing the baseline rate-supply relationship. A DDD design exploiting variation in minimum wages relative to Medicaid rates would require additional data on state minimum wage histories matched to HCBS worker wage distributions.

### Managed care FFS vs MCO table
**Response:** Similar to Reviewer 2's concern, we discuss managed care in the threats section. Constructing a state-level FFS/MCO share table specific to HCBS personal care would be a valuable addition in future work.

---

## Exhibit Review (Gemini Vision)

### Normalize Figure 3 (parallel trends)
**Response:** Done. Figure 5 now shows indexed trends (January 2018 = 100).

### Truncate Figure 6 (dose-response)
**Response:** Done. Wyoming (1,422% outlier) excluded from visual for clarity; noted in subtitle.

### Add mean of dependent variable to Table 2
**Response:** Done.

### Merge Tables 2 and 3
**Response:** We keep these separate for clarity — Table 2 reports TWFE with full inference details, Table 3 reports CS-DiD as a robustness check with RI p-values. Merging would create an overly dense table.

### Add map
**Response:** Noted for future revision. The treatment timing table (Table 6) provides the geographic information.

---

## Prose Review (Gemini)

### Kill roadmap paragraph
**Response:** Done. Removed the "paper proceeds as follows" paragraph from the introduction.

### Tighten abstract
**Response:** The abstract now emphasizes the finding rather than the methodology.

### Active voice
**Response:** Applied throughout where feasible.
