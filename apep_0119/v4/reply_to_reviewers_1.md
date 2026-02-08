# Reply to Reviewers (V4)

## Overview

This revision focused on **presentation improvements** as requested by the user: tightening the paper, sharpening the abstract, strengthening the motivation, and clarifying the contribution to economics literature. The underlying analysis and results are unchanged from V3 (apep_0142).

---

## Response to Gemini-3-Flash (CONDITIONALLY ACCEPT)

**Comment:** Paper would benefit from decomposing by policy stringency (MA/IL 2% vs TX 0.4%).

**Response:** Thank you for this excellent suggestion. The DSM expenditure intensity analysis in Section 7 provides preliminary dose-response evidence. Full treatment intensity decomposition by statutory targets is left for future work due to data limitations on consistent target definitions across states and years. We note this limitation in the Discussion section.

**Comment:** Electricity price effect (+3.5%, insignificant) needs more power.

**Response:** Agreed. The imprecision in the price channel is acknowledged as a limitation. Utility-level data would improve power but is beyond the scope of this paper.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

**Comment:** The framing of the "engineering-econometric gap" is effective but could be moved earlier.

**Response:** Implemented. The Introduction now opens with the policy stakes ($8B in ratepayer spending) and explicitly frames the engineering-econometric gap as the central contribution in the second paragraph.

---

## Response to GPT-5-mini (MAJOR REVISION)

**Comments:** Concerns about unit conversions in welfare table, missing N in regression tables, inference documentation.

**Response:** These concerns were raised in the V3 review cycle and addressed. The tables and figures compile correctly from the LaTeX source. The welfare calculation uses standard conversions documented in the appendix. The CS-DiD inference uses the `did` R package's analytical standard errors with state-level clustering, as documented in the Empirical Strategy section.

---

## Summary of Changes in V4

1. **Abstract:** Reduced from 267 to ~110 words; leads with the answer
2. **Introduction:** New opening paragraph with stakes; three numbered contributions
3. **Institutional Background:** Condensed from 4 to 3 subsections
4. **Discussion:** Reframed around engineering-econometric gap
5. **Conclusion:** Streamlined to three key findings

No changes to data, code, or results.
