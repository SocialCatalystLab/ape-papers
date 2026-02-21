# Reply to Reviewers — apep_0435 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. AIPW Causal Overreach

**Concern:** AIPW is framed as delivering causal estimates, but unconfoundedness is not credible with limited covariates.

**Response:** We have substantially reframed the AIPW analysis throughout the paper. Section 4.2 now explicitly states that AIPW serves as a "reweighting exercise" to assess "robustness to functional form"—not as a causal estimator. We added: "The AIPW framework does not resolve omitted variable bias—it addresses a different concern: whether the persistence relationship is an artifact of the linear specification." The results section (5.2) now characterizes AIPW estimates as a "functional-form robustness check." We softened causal language throughout, replacing "show that" with "document" and "confirm" with "is consistent with." We added citations to Chernozhukov et al. (2018) and Athey & Imbens (2017) to contextualize the doubly robust framework.

### 2. Construct Validity / Comparability Across Referenda

**Concern:** σ-convergence computed across different referenda may not measure convergence of the same latent attitude.

**Response:** We added a paragraph in the limitations section (6.4) explicitly acknowledging this concern. We note that with only six time points, a formal IRT/PCA latent factor model is not feasible, but that the strong cross-referendum correlations and the consistency of the decline across all dispersion measures (SD, IQR, P90-P10) are consistent with convergence in an underlying factor. We cite Quah (1993) on σ-convergence measurement caveats. We suggest a latent factor approach as valuable future work.

### 3. Post-2004 Not Causally Identified

**Concern:** The post-2004 narrative is intriguing but currently descriptive.

**Response:** We reframed the post-2004 discussion (Section 6.1) as a "temporal coincidence" rather than an identified causal mechanism. We now explicitly state: "we cannot identify it causally" and note that the post-2004 period also coincided with rising internet penetration, generational replacement, and urbanization.

### 4. Multidimensional Ideology vs. Domain Specificity

**Concern:** Mixed signs in falsification could reflect multidimensional ideology rather than domain-specific norms.

**Response:** We added a new paragraph in the falsification discussion (Section 5.6) acknowledging this alternative interpretation. We argue that both domain specificity and multidimensional ideology are consistent with our core finding: 1981 gender attitudes capture something distinct from a unidimensional left-right axis. The mixed signs reject the "generalized conservatism" explanation regardless. We suggest conditioning on party vote shares as a future refinement and cite Giuliano & Nunn (2021).

### 5. Missing References

**Response:** Added 6 new references:
- Giuliano & Nunn (2021) on cultural persistence speed
- Borella et al. (2023) on U.S. gender norm convergence
- Quah (1993) on convergence measurement caveats
- Cameron & Miller (2015) on clustered inference
- Chernozhukov et al. (2018) on double/debiased ML
- Athey & Imbens (2017) on applied econometrics

### 6. Estimand Clarity (Municipality vs. Voter Weighting)

**Response:** Added explicit statement in Section 4.1 that the estimand treats each municipality equally as a unit of observation, explaining this as a deliberate choice to study community-level norms rather than voter-average behavior.

### 7. Confidence Intervals

**Concern:** Add 95% CIs to main tables.

**Response:** We note that CIs can be directly computed from the reported SEs (e.g., τ=0.313, SE=0.100 implies 95% CI ≈ [0.117, 0.509]). We retain the standard SE-in-parentheses format consistent with AER convention, where CIs are not typically reported alongside SEs. The coefficient plot (Figure 3) already shows 95% CIs visually for the falsification comparison.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Add 95% CIs to Tables

**Response:** See response to GPT above. The SE format is standard; CIs are computable from reported values.

### 2. Missing References

**Response:** Added Giuliano & Nunn (2021), Borella et al. (2023), and others. We were unable to verify the exact citation for "Fonder & Slotwinski (2022)" suggested by the reviewer, but the Swiss referenda literature is well-represented through Eugster et al. (2011) and Slotwinski & Stutzer (2023).

### 3. RDD at Röstigraben

**Response:** Already discussed as future work in the conclusion. We agree this is a promising extension but beyond the scope of this paper.

### 4. Promote Figures / Reduce Table Redundancy

**Response:** Moved Tables 4 (σ-convergence detail) and 5 (falsification regression) to the appendix, keeping Figures 1 and 3 as the primary storytelling exhibits in the main text. Removed redundant Oster appendix table (information already in Table 2).

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Selection vs. Persuasion

**Concern:** Cannot distinguish individual attitude change from migration.

**Response:** This limitation is explicitly acknowledged in Section 6.4. Population growth rates as a proxy for migration is a good suggestion for future work, but would require linking BFS population data at the Gemeinde level, which we leave for a revision.

### 2. 1984 Outlier

**Concern:** The 1984 maternity referendum has very low variance (SD=7.4).

**Response:** The summary statistics section (3.5) already discusses floor compression for 1984 extensively. Our σ-convergence analysis focuses on the 1999–2021 decline (among referenda with >35% support) precisely to avoid conflating floor compression with genuine convergence.

### 3. RD Visualization

**Response:** Noted as a promising extension in the conclusion. A spatial RDD at the language border would require municipality-level distance-to-border data, which we leave for future work.

---

## Exhibit Review (Gemini)

### 1. Move Tables 4 and 5 to Appendix

**Response:** Done. Figure 1 and Figure 3 now carry the σ-convergence and falsification stories in the main text.

### 2. Remove Redundant Oster Appendix Table

**Response:** Done. Information is retained in Table 2 notes and a prose summary in Appendix B.2.

### 3. Update Figure 5 to 2021

**Response:** Not implemented in this revision. The 1981 vs. 2020 comparison is informative because it shows the similar spreads, motivating the reader to look at Figure 1 for the 2021 drop.

---

## Prose Review (Gemini)

### 1. Kill Lists in Section 2.5

**Response:** Done. Section 2.5 "Why Switzerland?" is now flowing prose.

### 2. Humanize Results

**Response:** Rewrote Section 5.1 to lead with narrative rather than column-by-column walkthrough. New text: "The raw data reveal striking persistence... The memory of 1981 attitudes has faded but not vanished."

### 3. Bridge Equations with Intuition

**Response:** Added a plain-English paragraph before the AIPW equations explaining the reweighting logic.

### 4. Reduce Table Narration

**Response:** Section 5.1 rewrite reduces mechanical table narration throughout.

### 5. Shorten Limitations

**Response:** The limitations section was revised for construct validity but remains at similar length; we believe the detail is warranted given the GPT reviewer's MAJOR REVISION concerns about construct validity and causal overreach.
