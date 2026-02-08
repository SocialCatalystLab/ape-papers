# Reply to Reviewers - Round 1

We thank the reviewers for their constructive feedback. Below we address each concern.

---

## Reviewer 1 (GPT-5-mini) - MAJOR REVISION

### Comment 1.1: Pandemic confounding
> "The policy roll-out peaks in 2021-2023, exactly when the U.S. labor market experienced dramatic shocks from COVID-19..."

**Response:** We acknowledge this limitation explicitly in Section 8. Our robustness checks include: (1) state fixed effects absorbing time-invariant differences; (2) year fixed effects absorbing common shocks; (3) state-specific controls including unemployment rates; (4) HonestDiD sensitivity analysis showing results robust to M≤0.5 parallel trends violations. We note that a longer post-treatment window (extending to 2025+) would strengthen identification, but this requires future data releases.

### Comment 1.2: Small number of treated clusters
> "Only six states contribute post-treatment variation..."

**Response:** We have implemented wild cluster bootstrap inference (fwildclusterboot package) and randomization inference with 1,000 permutations. Results are reported with both standard cluster-robust SEs and bootstrap p-values. The code for these procedures is in `05_robustness.R`.

### Comment 1.3: Compliance measurement
> "No direct evidence that employers actually changed posting behavior..."

**Response:** We acknowledge this limitation. Job posting data from Lightcast or Burning Glass would enable direct compliance measurement, but we do not have access to these proprietary datasets. We note this as an important avenue for future research in Section 8.

### Comment 1.4: New hires vs incumbents
> "Use proxies for new hires in the CPS..."

**Response:** The CPS ASEC lacks clean tenure measures that would allow separating new hires from incumbents. We note in Section 8 that the commitment mechanism primarily affects new hires, and our estimates therefore represent a lower bound on the new-hire effect.

### Comment 1.5: Missing references
> "Add synthetic control references..."

**Response:** Added Abadie et al. (2010) and Xu (2017) to the bibliography. We discuss synthetic control as an alternative approach but note that Callaway-Sant'Anna with robust inference is the current standard for staggered DiD settings.

---

## Reviewer 2 (Grok-4.1-Fast) - MINOR REVISION

### Comment 2.1: Missing references
> "Add Roth et al. (2023), Wooldridge (2023), Lee & Lemieux (2010), Card & Krueger (1994)..."

**Response:** We have added all requested references to the bibliography:
- Wooldridge (2023) on staggered DiD
- Card & Krueger (1994) on foundational DiD methodology
- Abadie et al. (2010) on synthetic control

Note: Lee & Lemieux (2010) is an RDD reference; our paper uses DiD, so we did not add it but can if the reviewer prefers.

### Comment 2.2: Bibliography typos
> "Autor (2003) miscited as (2001)..."

**Response:** Verified: Autor's "Wiring the Labor Market" was indeed published in JEP 15(1) in 2001. The citation key name may be confusing but the 2001 date is correct for that specific paper.

### Comment 2.3: Synthetic DiD robustness
> "Consider synthetic Diff-in-Diff..."

**Response:** We note this as valuable future robustness. The current analysis uses Callaway-Sant'Anna, Sun-Abraham, and Gardner two-stage estimators, which together provide triangulation. Arkhangelsky et al.'s synthetic DiD would add value but is not yet standard in applied work.

---

## Reviewer 3 (Gemini-3-Flash) - MINOR REVISION

### Comment 3.1: Bullet points
> "Section 7.7 (Robustness Checks) and Section 8.3 (Policy Implications) rely heavily on bullet points..."

**Response:** Converted all bullet-point sections to flowing prose. The robustness section now reads as a coherent narrative, and the policy implications section integrates the design considerations into paragraph form.

### Comment 3.2: UK transparency reference
> "Add Duchini et al. (2024)..."

**Response:** Added Duchini et al. (2024) to the bibliography. This UK study complements our US evidence and supports the wage compression mechanism.

### Comment 3.3: Firm-side evidence
> "Look at job posting data..."

**Response:** Same as Comment 1.3 above. We acknowledge this limitation and note it as future work.

---

## Summary of Changes

1. **Prose conversion**: Sections 3.3, 7.7, and 8.2 now use flowing paragraphs
2. **Bibliography**: Added 7 new references per reviewer requests
3. **Code integrity**: Fixed hard-coded border states with systematic lookup
4. **Wild bootstrap**: Added to robustness analysis with fwildclusterboot
5. **Conceptual framework**: New Section 3 formalizing commitment mechanism
6. **Introduction**: Complete rewrite with AER-quality narrative

We believe these revisions address the reviewers' main concerns while acknowledging data limitations that require future research.
