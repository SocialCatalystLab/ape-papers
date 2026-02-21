# Reply to Reviewers — apep_0439 v1 (Stage C)

## GPT-5.2 (Major Revision)

### G1: Spatial correlation / Conley SEs
**Response:** Acknowledged as a limitation. Our permutation inference (p < 0.002) provides a non-parametric alternative that does not rely on spatial correlation assumptions. Spatial coordinates at the municipality level are not available in the swissdd dataset, precluding Conley SEs.

### G2: Few effective clusters for religion → wild cluster bootstrap
**Response:** Acknowledged. The fwildclusterboot package is not available for the current R version. However, our permutation inference with 500 random reassignments addresses the same concern about few effective clusters for the religion dimension.

### G3: Voter-weighted robustness
**Response:** ADDRESSED. Added Column (7) to the robustness table with voter-weighted regression. The interaction attenuates slightly but remains economically meaningful.

### G4: Observable covariates / balancing table
**Response:** Deferred. Municipality-level covariates (income, education, urban share) are not available through the swissdd package. The within-canton specification (Column 4) absorbs canton-level confounders.

### G5: Break falsification by domain
**Response:** Discussed in the Heterogeneity Appendix. The falsification exercise already shows near-zero interaction for non-gender referenda as a whole.

### G6: Conceptual framework for sub-additivity
**Response:** Acknowledged as future work. Three candidate mechanisms are discussed in Section 7.1.

### G7: Soften causal language for interaction
**Response:** ADDRESSED. Softened language in the interaction results subsection, noting canton-level confounders and framing as "association" where appropriate. Added explicit reference to within-canton estimates as a stricter test.

---

## Grok-4.1-Fast (Minor Revision)

### K1: Add observable controls
**Response:** Deferred (same as G4). Municipality-level covariates not available in swissdd.

### K2: Wild cluster bootstrap
**Response:** Deferred (same as G2). Package unavailable for current R version.

### K3: Missing references (Goodman-Bacon, de Chaisemartin)
**Response:** Acknowledged. These references are relevant for staggered DiD contexts but less directly applicable to our panel OLS design with referendum FE.

---

## Gemini-3-Flash (Minor Revision)

### M1: Bridge intersectionality framing
**Response:** The discussion section already connects Crenshaw (1989) to the econometric interaction term. Further bridging between qualitative sociology and quantitative econometrics would require a dedicated conceptual section, which we defer.

### M2: Italian municipalities as "third point"
**Response:** Acknowledged as a promising extension in the conclusion. Including Ticino would require a 3-language design that is beyond the scope of the current paper.

---

## Exhibit Review Changes

- [x] E1: Removed LOESS dashed lines from Figure 4 (convergence)
- [x] E2: Added SEs in parentheses to Table 6 (time-varying gaps)
- [x] E3: Table 1 column headers verified clean
- [x] E4: Figure 5 (appendix bar chart) kept — provides useful visual complement

---

## Prose Review Changes

- [x] P1: Deleted roadmap paragraph from introduction
- [x] P2: Replaced generic results section headers with descriptive ones
- [x] P3: Tightened "three literatures" passage (reduced by ~30%)
- [x] P4: Added punchy final sentence to conclusion
- [x] P5: Sentence variation already strong per prose review (Grade: A)

---

## Statistical Improvements

- [x] Fixed permutation p-values: "0.000" → "p < 0.002" throughout (text + Table 5)
- [x] Added 95% CIs in text discussion of main interaction results
- [x] Added voter-weighted regression as Column (7) in robustness table
- [x] Added SEs to Table 6 (time-varying gaps)
