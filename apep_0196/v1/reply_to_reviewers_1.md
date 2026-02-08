# Reply to Reviewers (Round 1)

## Summary of Changes

This revision substantially expands the paper from 17 to 35 pages and addresses key concerns raised by all three reviewers. The main changes include:

1. **Expanded Data Section:** Added balance table comparing treated/control states, detailed data limitations discussion
2. **Expanded Empirical Strategy:** Added alternative specifications, inference methods, and threats to validity subsections
3. **Substantially Expanded Discussion:** Added policy implications, comparison to prior literature, limitations, and future research directions
4. **Added missing references:** Roth et al. (2023), Mountjoy (2022), Conley (1999)
5. **Softened language:** Removed "precisely estimated null" framing, emphasized power limitations
6. **Added bootstrap CI to Table 2**
7. **Added exposure alignment documentation to research plan**

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Power calculation unclear, need IPEDS data

**Response:** The MDE calculation is now more clearly explained in Section 6.5, explicitly showing the formula from Bloom (1995), the standard deviation value (1.065), and the resulting 29% MDE. I acknowledge this is a fundamental limitation and discuss it extensively in the new Discussion section (Interpretation 3 and Limitations subsection).

Regarding IPEDS data: This would require a complete data rebuild and represents a future research direction rather than something addressable in this revision. The paper now explicitly discusses IPEDS as the preferred data source for future work (Section 7.5, Future Research Directions).

### Concern 2: Wild bootstrap in main text

**Response:** Added bootstrap confidence intervals directly to Table 2. The Callaway-Sant'Anna estimate now reports both asymptotic CI ([-0.0337, 0.0064]) and bootstrap CI ([-0.036, 0.008]) in the main results table.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Missing references

**Response:** Added all suggested references:
- **Roth et al. (2023):** Cited in Section 5.2 discussing modern DiD methodology
- **Mountjoy (2022):** Cited in Section 6.8 discussing compositional effects and welfare implications
- **Conley (1999):** Cited in Appendix D discussing spatial correlation robustness

### Concern 2: IPEDS extension

**Response:** Acknowledged as the primary direction for future research. The new Section 7.5 (Future Research Directions) includes detailed discussion of how IPEDS institution-level data would address the study's limitations.

### Concern 3: Methodology praised

**Response:** Thank you. The paper maintains the rigorous Callaway-Sant'Anna approach with doubly robust estimation, wild cluster bootstrap, and randomization inference.

---

## Reviewer 3 (Gemini-3-Flash): REJECT AND RESUBMIT

### Concern 1: MDE too high (29%)

**Response:** This is honestly acknowledged as a fundamental limitation throughout the revised paper. The Discussion section now devotes substantial attention to power limitations (Interpretation 3, Limitations subsection). The paper frames this as a methodological contribution: demonstrating that state-level aggregate analysis cannot detect plausible effect sizes is valuable information for future research design.

### Concern 2: ACS data too noisy

**Response:** Acknowledged. The new Data Limitations subsection explicitly discusses the measurement issues with ACS total enrollment. The paper notes that IPEDS first-time enrollment would be preferable and discusses this as a future research direction.

### Concern 3: Need composition tests

**Response:** ACS does not provide 2-year vs. 4-year enrollment breakdown by state, so direct composition tests are not possible with current data. The paper now:
- Discusses the composition/diversion hypothesis extensively (Discussion, Interpretation 2)
- Cites Mountjoy (2022) for supporting evidence on diversion
- Explicitly acknowledges this as a limitation
- Identifies institution-level decomposition as a priority for future research

---

## Summary of All Changes Made

| Section | Change |
|---------|--------|
| Abstract | Softened language ("cannot detect" vs "precisely null") |
| Section 4 (Data) | Added balance table, expanded data limitations (2 pages) |
| Section 5 (Empirical Strategy) | Added alternative specifications, inference methods (3 pages) |
| Section 5 | Added detailed threats to validity discussion |
| Section 6 (Results) | Added bootstrap CI to Table 2 |
| Section 7 (Discussion) | Completely rewritten with 6 subsections (6+ pages) |
| Section 7 | Added policy implications, future research directions |
| References | Added 3 new references |
| Research Plan | Added exposure alignment section |

---

## Items Not Addressed

These concerns require new data collection and are noted as future research directions:

1. **IPEDS data integration** - Would require complete data rebuild
2. **Institution-level decomposition** - Not available in ACS
3. **First-time enrollment analysis** - ACS provides total enrollment only
4. **Synthetic control comparison** - Would require substantial new analysis

The paper honestly acknowledges these limitations while making a contribution with existing data: demonstrating the power constraints of state-level aggregate analysis for Promise program evaluation.
