# Reply to Reviewers (Round 1)

**Paper:** Does Coverage Create Capacity? Medicaid Postpartum Extensions and the Supply of Maternal Health Providers
**Paper ID:** apep_0356 v1
**Date:** 2026-02-18

We thank all three referees for their careful and constructive reviews. The reviews converge on several key points: the data and question are novel and policy-relevant, the methods are appropriate, but the balanced-panel result raises a fundamental data validity concern that must be addressed head-on. We agree. Below we respond to each referee's major points and describe the changes made.

---

## Referee 1 (GPT-5.2) -- MAJOR REVISION

### Major Concern 1: Balanced panel collapse and data/reporting confounding

> "The paper itself identifies the key problem: Balanced panel restriction... produces an attenuated estimate of 0.0028... much of the variation comes from states with intermittent T-MSIS reporting. This is not a minor limitation; it threatens the core claim that the policy caused the observed increase."

> "Elevate data quality to a core identification problem and resolve it with diagnostics and redesigned outcomes."

**Response:** We agree that this is the paper's most important limitation and that it was insufficiently prominent in the original draft. We have made the following changes:

1. **New subsection "Data Validity and Reporting Artifacts" (Section 6.7).** This subsection now explicitly characterizes the 17 balanced-panel states versus the remaining 34 states, discusses the zero-to-positive reporting transition pattern, and frames the balanced-panel estimate (ATT = 0.0028) as a plausible lower bound on the true effect alongside the full-sample estimate (0.2834) as an upper bound that includes both real effects and reporting artifacts.

2. **Revised abstract and conclusion.** We no longer present the 33% claims increase as an unqualified finding. The abstract now notes that the effect is "sensitive to sample composition, with balanced-panel estimates near zero," and the conclusion frames the result as a bounded range rather than a point estimate.

3. **Revised Discussion (Section 7.1).** We add a paragraph acknowledging that the 33% figure should be interpreted as an upper bound, with the true effect likely lying between approximately 0% and 33%.

4. **Antepartum placebo as partial reassurance.** We note in the new subsection that if the effect were purely driven by general T-MSIS reporting improvements, we would expect antepartum claims to rise as well. The postpartum-specific pattern is more consistent with either a real policy effect or postpartum-code-specific reporting changes, but cannot fully resolve the ambiguity.

We defer the referee's suggestion to construct payment ($) outcomes, broader code baskets, and rates (postpartum claims per delivery) to a future revision, as these require re-aggregating the T-MSIS microdata with different code selections. We note these as important extensions in the Discussion.

---

### Major Concern 2: RI p-value (0.21) vs. conventional p-value (0.027) discrepancy

> "Why is the conventional p-value 0.027 while RI says 0.21? This discrepancy is a red flag unless clearly explained."

**Response:** We have added an explicit paragraph in the robustness section explaining this discrepancy. The key points are:

- The conventional p-value tests H0: ATT = 0 using the asymptotic distribution of the CS-DiD estimator with block-bootstrap standard errors. With 51 clusters (47 treated, 4 never-treated), the bootstrap may overstate precision because the effective comparison group is small.
- The RI p-value tests the sharp null that treatment assignment is independent of outcomes. With only 4 never-treated states and 47 treated, most permuted treatment assignments look similar to the observed one, limiting the variation in the permutation distribution and making rejection inherently difficult. This is a finite-sample power issue, not necessarily evidence against the effect.
- We have increased RI permutations from 200 to 1,000 per the referee's (and Referee 2's) recommendation, and report the updated p-value.
- We recommend interpreting the evidence as "suggestive" rather than "definitive," consistent with the paper's existing cautious language.

---

### Major Concern 3: Bootstrap scheme underspecified

> "You should specify whether you use state-level block bootstrap (resample states) vs. naive observation-level bootstrap."

**Response:** We have added a clarifying sentence in Section 5.1 and in the table notes specifying that all CS-DiD confidence intervals use state-level block bootstrap (resampling entire state time series), which preserves within-state serial correlation. This is the default in the `did` R package when clustering is specified at the state level.

---

### Major Concern 4: TWFE as "robustness check"

> "You should be clearer that TWFE is not a valid robustness check unless you show that the identifying assumptions imply TWFE is approximately unbiased."

**Response:** We have revised the discussion of TWFE results in Section 6.2 to clarify that the TWFE estimates are presented as a benchmark for comparison with the prior literature, not as a robustness test of equal standing. We note that TWFE attenuation under staggered adoption is expected (per Goodman-Bacon 2021) and that the CS-DiD estimator is the preferred specification. The TWFE results are useful primarily for documenting the magnitude and direction of attenuation bias in this setting.

---

### Minor Concern 5: 95% CIs for main outcomes

> "Main tables do not report 95% CIs, only SEs and stars."

**Response:** We have added 95% confidence intervals in brackets below the standard errors for the primary outcomes in Table 2, Panel A. Event-study figures already display 95% CIs via shaded regions.

---

### Minor Concern 6: Provider "supply" operationalization

> "'Provider supply' = 'distinct NPIs billing 59430.' That is closer to billing participation for one code than capacity."

**Response:** We have added a clarifying paragraph in Section 4.2 and in the Discussion noting that our measure captures "billing participation" (distinct NPIs billing a specific postpartum code) rather than provider capacity or physical supply. We acknowledge this distinction and note that the OB/GYN provider measure (Column 4 of Table 2, which captures all-code billing by OB/GYN-taxonomy providers) shows no significant change, suggesting the effect operates through existing providers adding postpartum billing rather than new providers entering the market. We flag the decomposition of individual vs. organizational NPIs as a valuable extension for future work.

---

### Literature additions

> "Consider adding Sun & Abraham (2021), Borusyak, Jaravel & Spiess (2021), de Chaisemartin & D'Haultfoeuille (2020)."

**Response:** We have added citations to Sun & Abraham (2021) and de Chaisemartin & D'Haultfoeuille (2020) in the Empirical Strategy section, and Borusyak, Jaravel & Spiess (2024) in a footnote. These are cited alongside Goodman-Bacon (2021) when discussing the limitations of TWFE under heterogeneous treatment effects and the motivation for using the CS-DiD estimator.

---

## Referee 2 (Grok-4.1-Fast) -- MINOR REVISION

### Concern 1: RI permutations too low (200)

> "Randomization inference uses only 200 permutations (low for precision); suggest 1000+."

**Response:** We have increased RI permutations to 1,000 and report the updated p-value. We agree that 200 permutations provided insufficient precision for the RI p-value. The updated value is reported in Table 3 and discussed in the text.

---

### Concern 2: Balanced-panel attenuation

> "Balanced panel near-zero is a red flag (p.28); probe T-MSIS reporting changes."

**Response:** As described in our response to Referee 1, we have added a new "Data Validity and Reporting Artifacts" subsection that directly addresses this concern. We characterize which states contribute to the full-sample effect, discuss the zero-to-positive reporting pattern, and frame the result as a bounded range. We acknowledge that we cannot fully separate reporting artifacts from behavioral responses with the available data, and flag reporting diagnostics as a priority for future work.

---

### Concern 3: Literature gaps

> "Add 3-4 cites for completeness: MACPAC on T-MSIS quality, Aaronson et al. (2023), Finkelstein et al. (2022), Sun et al. (2021)."

**Response:** We have added Sun & Abraham (2021) in the Empirical Strategy section, de Chaisemartin & D'Haultfoeuille (2020) alongside the TWFE discussion, and Borusyak, Jaravel & Spiess (2024) in a footnote. We have also expanded the MACPAC (2022) citation in the Data Validity subsection to emphasize T-MSIS data quality concerns. We appreciate the suggestion of Aaronson et al. (2023) and Finkelstein et al. (2022); we have added a brief citation to each in the Introduction and Literature positioning.

---

### Concern 4: County heterogeneity and mechanisms

> "County-level DiD (NPPES ZIPs) for rural gaps. LARC heterogeneity: state-level LARC policies?"

**Response:** We agree this is a valuable extension. The NPPES data do contain practice ZIP codes that could enable county-level analysis, and state variation in LARC access policies could interact with the coverage extension. However, constructing county-level panels from the T-MSIS provider-level data and merging rural/urban classifications requires substantial additional data processing that we defer to a future revision. We have added a sentence in the Discussion (Section 7.4) flagging rural/urban heterogeneity and LARC policy interactions as priority extensions.

---

### Concern 5: Harmonize ATT aggregation schemes

> "Harmonize ATT aggregations (simple vs. group-weighted, p.38)."

**Response:** We have revised the Appendix Section D to clarify the distinction between the simple calendar-time ATT (0.2834, reported in Table 2) and the group-weighted ATT (0.288). We now explicitly state which aggregation scheme is used in each table and explain that the difference is small because the large April 2022 cohort dominates both weighting schemes.

---

## Referee 3 (Gemini-3-Flash) -- MAJOR REVISION

### Major Concern 1: The "zero-to-positive" reporting problem

> "The fact that the result dies in the balanced panel is a major concern. To salvage this, the author should conduct a 'Leads' test specifically for the appearance of data. If the T-MSIS reporting for a state starts exactly when the policy starts, it is likely a reporting change."

**Response:** We have addressed this in the new "Data Validity and Reporting Artifacts" subsection (Section 6.7). We discuss the pattern of data appearance relative to policy adoption timing and acknowledge that contemporaneous onset of reporting and policy adoption would make the two effects inseparable. We frame the full-sample and balanced-panel estimates as upper and lower bounds, respectively. A formal "leads test" for reporting onset (examining whether the first non-zero month for each state systematically precedes, coincides with, or follows the adoption date) is a valuable suggestion that we describe in the text but note requires careful definition of "first report" given cell suppression. We flag this as a priority diagnostic for future work.

---

### Major Concern 2: HCPCS code bundling (59430 vs. global codes)

> "Postpartum care (59430) is often bundled into global maternity codes (59400). The author should discuss if the 33% increase is a shift in how doctors bill (unbundling) rather than a shift in care provided."

**Response:** We have added a new paragraph in Section 4.2 discussing the relationship between the standalone postpartum code (59430) and global obstetric codes (59400 for vaginal delivery with postpartum care, 59510 for cesarean delivery with postpartum care). We note that:

- Under global codes, postpartum care is bundled into a single payment covering antepartum, delivery, and postpartum services. When global codes are used, the postpartum component is not separately billable as 59430.
- The extension could incentivize unbundling: providers may bill delivery globally but add separate 59430 claims for follow-up visits in months 3-12 that are now covered. This would represent genuine new billing activity (and plausibly new visits) but could overstate the "new care" interpretation.
- The delivery code placebo provides partial reassurance: delivery claims (which include global codes 59400 and 59510) show no significant change (ATT = 0.0452, p = 0.863), suggesting that global code billing patterns remain stable. If systematic unbundling were occurring, we would expect some shift in the composition of delivery-related codes.
- We cannot empirically separate unbundling from new visits with the available data, and flag this as a limitation.

---

### Minor Concern 3: State-level reimbursement rate interaction

> "The paper would be much stronger if the author merged in state-level Medicaid-to-Medicare fee ratios. Does the 'duration effect' only exist in states with higher baseline fees?"

**Response:** We agree this would substantially strengthen the paper's contribution to the coverage-vs-rates debate. Merging state-level Medicaid-to-Medicare fee ratios (available from the Urban Institute or Kaiser Family Foundation) would allow us to test whether the duration effect is complementary to or substitutable with rate levels. This requires external data not currently in the analysis pipeline. We have added a paragraph in the Discussion (Section 7.2) explicitly posing this interaction as the key open question and flagging it for future work.

---

## Exhibit Review (Gemini-3-Flash) -- Selected Responses

> "Move Figure 5 (Contraceptive event study) and Figure 7 (RI histogram) to appendix."

**Response:** We have moved both figures to the Appendix to tighten the main text narrative. The contraceptive event study is imprecisely estimated and is better suited as supporting evidence. The RI distribution is a diagnostic that does not need main-text prominence.

> "Add a Post-PHE marker to Figure 1."

**Response:** We have added a second vertical marker in Figure 1 (and Figure 2) indicating the end of the PHE (April 2023), since the paper emphasizes this date as the point at which extensions become binding.

> "Consider log-transforming the y-axis for Figure 4 (Raw Trends)."

**Response:** We have revised Figure 4 to use a log-scaled y-axis so that the trends in smaller states and the never-treated group are visible and comparable to the large-state trends.

---

## Prose Review (Gemini-3-Flash) -- Selected Responses

> "Eliminate 'Importantly' on page 5."

**Response:** Revised to remove the meta-comment. The sentence now reads: "The adoption decision was made at the state level..."

> "Sharpen Section 6.2 opening."

**Response:** Revised the opening of Section 6.2 from "Table 2 presents the aggregate treatment effects" to leading with the substantive finding.

> "Vary sentence length in conclusion."

**Response:** Revised the opening paragraph of the Conclusion for more varied rhythm.

---

## Summary of Changes

| Change | Section(s) Affected | Addresses |
|--------|---------------------|-----------|
| New "Data Validity and Reporting Artifacts" subsection | 6.7 (new) | All 3 referees |
| Revised abstract, introduction, conclusion framing | Abstract, 1, 7, 8 | All 3 referees |
| RI vs. conventional p-value explanation | 6.6 | Referee 1 |
| Increased RI permutations to 1,000 | Code, 6.6, Table 3 | Referees 1 & 2 |
| Bootstrap scheme clarification | 5.1, Table notes | Referee 1 |
| TWFE framing as benchmark, not robustness | 6.2 | Referee 1 |
| 95% CIs added to Table 2 | Table 2 | Referee 1 |
| Provider "billing participation" clarification | 4.2, 7 | Referee 1 |
| Added 4+ literature citations | 1, 5, 7, References | Referees 1 & 2 |
| HCPCS code bundling discussion | 4.2, 7.3 | Referee 3 |
| Reimbursement rate interaction flagged | 7.2 | Referee 3 |
| Figures 5, 7 moved to appendix | Main text, Appendix | Exhibit review |
| Post-PHE marker added to Figures 1-2 | Figures 1, 2 | Exhibit review |
| Figure 4 log-scaled y-axis | Figure 4 | Exhibit review |
| Prose polish (meta-comments, sentence variety) | Throughout | Prose review |
