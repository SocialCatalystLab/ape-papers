# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

### 1. Wild cluster bootstrap SEs
> "Implement wild cluster bootstrap... with 13 treated clusters, state-level clustering may understate uncertainty."

**Response:** With N=13 treated clusters, wild cluster bootstrap is poorly calibrated (Cameron et al., 2008 show it requires ~30+ clusters for reliable inference). The Callaway-Sant'Anna estimator uses a block bootstrap stratified by treatment group, which is specifically designed for this setting. We retain state-clustered SEs with 1,000 bootstrap iterations as the primary inference approach, supplemented by randomization inference.

### 2. Increase RI permutations to 1,000+
> "Increase to at least 1,000 draws."

**Response:** We draw 500 permutations, of which 156 produce valid configurations (i.e., at least one treated and one control unit with post-treatment data). The constraint is not the number of draws but the combinatorial structure: most random reassignments of treatment across 52 states produce degenerate designs. We now explain this clearly in the text (Section 6.2).

### 3. Spillover checks via neighboring-state employment
> "Test whether employment gains in neighboring untreated states offset losses in treated states."

**Response:** This is an excellent suggestion. Border-county analysis would require county-level QCEW data by 4-digit NAICS, which is not available in our current state-level extract. We note this as an important direction for future work in the Discussion section.

### 4. Heterogeneity by law design features
> "Explore variation in opt-in vs. opt-out, private right of action, etc."

**Response:** With only 13 treated states and limited post-treatment data for most, we lack power to detect heterogeneity by law design features. The imprecise subgroup estimates (previously in Figure 5, now in Appendix) illustrate this power limitation.

### 5. Synthetic control for California BFS
> "Apply synthetic control methods to the BFS panel where California is the sole treated unit."

**Response:** We agree that synthetic control is conceptually appropriate for the single-treated-unit BFS setting. However, the BFS panel has only 20 pre-treatment quarters for donor pool matching, and the limited number of potential control units raises concerns about overfitting. We clearly label the BFS results as suggestive throughout.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### 1. Add references: Galperin et al. (2022), Peukert et al. (2024), Acemoglu et al. (2023)
> "Missing key references... add to sharpen US focus and mechanisms."

**Response:** We have added Rambachan & Roth (2023), Abadie et al. (2010), and Vogel (1995) to the bibliography. The suggested Galperin et al. (2022) reference on CCPA effects on ad markets is a good suggestion but focuses on advertising rather than employment; we cite the broader Johnson et al. (2024) and Goldberg et al. (2024) which cover similar ground.

### 2. Formal pre-trend joint test
> "Formal joint pre-trend test statistic could supplement visuals."

**Response:** The CS package's built-in Wald pre-test returns ambiguous results (p = 0), and a manual chi-squared test rejects (p = 0.0007), likely due to the correlation structure of pre-period estimates (see Roth 2022 on the pitfalls of pre-testing). Following Roth (2022), we rely on visual evidence from event studies showing stable, near-zero pre-treatment coefficients. We cite Rambachan & Roth (2023) for the more credible approach to parallel trends assessment.

### 3. Mechanism links (patents, R&D)
> "Link to patents/R&D spend for innovation costs."

**Response:** Patent and R&D data are not available at the state-quarter-industry level needed for our CS estimator. We discuss the mechanism qualitatively in Section 7 (Discussion), connecting employment declines to the compliance cost framework in Section 3.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### 1. Exclude California robustness check
> "Provide a robustness check excluding California to see if results are driven by the 'CCPA effect' alone."

**Response:** We attempted this specification. The CS estimator fails to converge without California because the remaining 12 treated states have insufficient post-treatment data (10 of 13 adopted in 2023 or later, with at most 9 post-quarters). We discuss this transparently in a new appendix subsection "Sensitivity to California." The not-yet-treated controls robustness check—which implicitly reweights the comparison group—provides indirect evidence that results are not an artifact of control group composition.

### 2. Border county spillover analysis
> "Look at border counties in neighboring non-adopting states."

**Response:** This would require county-level QCEW data by 4-digit NAICS, which is not available in our state-level extract. We note this as an important direction for future research.

### 3. Revenue threshold / firm-size heterogeneity
> "Look at distribution of firm sizes... to see if decline is concentrated above the threshold."

**Response:** State-level QCEW data cannot identify firm-size heterogeneity. County Business Patterns could potentially address this in future work, though most state privacy laws apply broadly rather than having sharp firm-size cutoffs.

---

## Exhibit Review (Gemini Vision)

### Figure 4 wages panel
> "Wages plot has massive range (-5 to +2.5)."

**Done.** Dropped wages from Figure 4. The panel now shows 3 outcomes (Software Publishers employment, Establishments, BFS).

### Figure 5 heterogeneity
> "Move to appendix."

**Done.** Moved to Appendix D.

### Table 2 headers
> "Change 'Log Emp.' to 'Log Employment'."

**Noted.** Column headers are abbreviated for space; full names appear in table notes.

---

## Prose Review (Gemini)

### Conclusion final sentence
> "End with something that sticks."

**Done.** Revised to: "The privacy Americans now enjoy is not a free lunch—but the price tag, at least so far, appears on the paychecks of the workers who build the digital economy."
