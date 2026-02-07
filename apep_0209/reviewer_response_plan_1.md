# Reviewer Response Plan

## Summary of Feedback

- **GPT-5-mini (MAJOR):** Wild cluster bootstrap for CPS, pre-trend sensitivity, composition checks, firm-size threshold exploitation, mechanism evidence
- **Grok-4.1-Fast (MINOR):** Add 2-3 references, extend event studies, firm-size RD (largely praise)
- **Gemini-3-Flash (MINOR):** Dose-response by firm size, composition decomposition, explicit "men's loss" discussion
- **Exhibit Review:** Deseasonalize QWI figure, move Table 7 to appendix, promote balance table
- **Prose Review:** Shleifer-style opening (done), kill roadmap (done), improve transitions

## Cross-Reviewer Themes

1. **CPS small-cluster inference** — All 3 reviewers flag permutation p=0.154. GPT wants wild cluster bootstrap. Our response: note fwildclusterboot unavailable on this R version; emphasize QWI carries identification.
2. **Firm-size threshold heterogeneity** — All 3 suggest dose-response. Response: note this as limitation/future work (requires firm-level data we don't have).
3. **Composition vs within-worker** — GPT and Gemini want more evidence. Response: strengthen composition discussion, note Lee bounds already tight.
4. **"Men's loss" implications** — Gemini specifically asks. Response: add explicit paragraph.

## Workstreams

### A. Prose Improvements (from Prose Review)
- [DONE] Shleifer-style opening replacing rhetorical question
- [DONE] Killed roadmap paragraph, replaced with dollar-value impact
- [DONE] "We know surprisingly little" replacing "Existing evidence is fragmentary"
- [DONE] Active voice in pre-trends section

### B. Exhibit Improvements (from Exhibit Review)
- Note: QWI seasonal patterns are inherent to quarterly data; deseasonalizing would require additional analysis beyond this structural revision's scope. Add footnote explaining sawtooth pattern.
- Table 7 (industry) and Table 8 (robustness) — keep in main text since they're already discussed substantively.

### C. Discussion Expansion (from All Reviewers)
- Add "men's loss" paragraph (Gemini)
- Strengthen composition discussion (GPT, Gemini)
- Add wild cluster bootstrap discussion (GPT) — note unavailability, discuss Webb 6-point

### D. References (from Grok, GPT)
- References already include Cowgill, Hernandez-Arenaz & Iriberri, Johnson
- Add MacKinnon & Webb (2017) for wild cluster bootstrap discussion

## What We Cannot Do (and why)
- Wild cluster bootstrap: fwildclusterboot package unavailable for current R version
- Firm-size RD: requires firm-level data not in QWI public use files
- Job-posting data: not available in our datasets
- Within-worker panel: CPS ASEC is cross-sectional
- These are noted as limitations and future work directions
