# Reply to Reviewers

## GPT-5.2 (Major Revision)

### Concern 1: Compound treatment / estimand ambiguity
> "The paper sometimes slides between 'effect of parity mandate' and 'effect of crossing threshold that bundles parity + PR.'"

**Response:** We have added a clarifying paragraph in Section 4.2 (Estimation) explicitly stating that the estimand is the effect of the entire 1,000-inhabitant electoral regime change, and explaining why we interpret it as informative about parity specifically—because the first-stage discontinuity in female representation is large, while Eggers (2015) shows other political margins exhibit smaller discontinuities. We have also tightened language throughout.

### Concern 2: Add 95% CIs to Table 2
> "For a null-result paper, the paper would be stronger if every main outcome row reports a 95% CI."

**Response:** Table 2 now includes a 95% CI column using robust bias-corrected confidence intervals from rdrobust for all outcomes.

### Concern 3: Missing RDD references
> "Imbens & Lemieux (2008), Calonico, Cattaneo & Titiunik (2014), Pande (2003)"

**Response:** All three references have been added to the bibliography and cited in the text. Calonico et al. (2014) is now cited as the underlying methodology for rdrobust. Imbens & Lemieux (2008) is cited alongside Cattaneo et al. in the Estimation section. Pande (2003) is cited in the new Treatment Intensity subsection.

### Concern 4: Treatment intensity discussion
> "Provide additional evidence... what fraction of France's female working-age population lives in communes in the local bandwidth."

**Response:** We have added a new subsection (7.5: Treatment Intensity) discussing whether the 2.7pp first stage is too small to generate detectable downstream effects, contrasting with the transformative 0-to-100% shifts in Indian reservation studies.

### Constructive suggestions not implemented (acknowledged)
- RD-IV / fuzzy RD: We acknowledge this would be valuable but the exclusion restriction is not credible given the compound treatment.
- Intermediate municipal policy outcomes: Data on childcare spending is not readily available at the commune level from public APIs.
- Difference-in-discontinuities: Would require assembling a panel across multiple census waves, which is beyond the scope of this paper but noted as a promising extension.

---

## Grok-4.1-Fast (Minor Revision)

### Concern 1: Missing references (Sun & Rokke 2023, Dargaud et al. 2022)
**Response:** These are valuable suggestions. The Sun & Rokke reference on powering null RDD results would strengthen Section 8.2. However, we could not verify the exact publication details for these references and have opted to strengthen the methodology citations with well-established papers (Imbens & Lemieux 2008, Calonico et al. 2014) instead.

### Concern 2: Panel extension / diff-in-disc
**Response:** We agree this would be a substantial upgrade. Noted as a promising direction for future work in the Discussion section.

---

## Gemini-3-Flash (Minor Revision)

### Concern 1: Compound treatment
> "Could the author use the 3,500-inhabitant threshold as a secondary check?"

**Response:** This is an excellent suggestion. We note in the pre-treatment placebo discussion that outcomes at the 3,500 threshold (where proportional voting applied longer) also show no discontinuity in employment outcomes, providing suggestive evidence that proportional representation per se is not driving the null.

### Concern 2: First-stage magnitude
> "The first stage is 2.7 pp. This is statistically significant but small in absolute terms."

**Response:** We have added a Treatment Intensity subsection (Section 7.5) addressing this directly, comparing the 2.7pp shift to the transformative changes in Indian studies.

### Concern 3: Childcare spending data
**Response:** Municipal childcare spending data at the commune level is not readily available from public APIs. This is noted as a valuable direction for future work.

---

## Exhibit Review (Gemini)

### Consolidate Figures 2 & 3 into panels
**Response:** We have kept the figures separate for clarity, as each includes detailed confidence bands and annotations that would be compressed in a panel layout. The suggestion is noted for future revisions.

### Move Table 4 to appendix
**Response:** We retain Table 4 in the main text as it complements Figure 6 by providing exact numerical values, which is important for a null-result paper where precision matters.

---

## Prose Review (Gemini)

All major prose suggestions have been implemented:
1. Opening sentence sharpened (India hook first)
2. "It is worth noting" filler removed
3. Conclusion sentence made punchier
4. Mechanisms section opening tightened
5. "Did not appear from nowhere" replaced with "was an evolution, not a shock"
