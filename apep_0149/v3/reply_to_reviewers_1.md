# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Permutation inference methodology inconsistency
> The main text says TWFE for permutation but the appendix says CS-DiD.

**Response:** Fixed in advisor round. Both the main text and appendix now consistently state that the permutation test uses the TWFE estimator for computational tractability, with explicit justification and comparison to the CS-DiD ATT.

### Concern 2: Missing tables/figures
> External files (\input{tables/...}) not included in submission.

**Response:** This is an artifact of the LaTeX-only review route. The compiled PDF includes all 5 tables and 10 figures, fully populated with real regression results. All tables include N, number of clusters, SEs, and inference notes.

### Concern 3: Format/length
> Ensure 25+ pages main text.

**Response:** The compiled PDF is 44 pages total, with main text through Section 9 (approximately 30 pages excluding bibliography and appendix).

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Convert bullet lists to prose
> Testable Predictions in Section 3 uses enumerate; rephrase to prose.

**Response:** Converted the enumerated list in Section 3.4 to a flowing paragraph.

### Concern 2: Missing references
> Add Sommers et al. (2024), Miller et al. (2024), Eliason et al. (2023).

**Response:** Added Sommers et al. (2024) on unwinding heterogeneity, cited in Section 2.3. Miller et al. (2024) and Eliason et al. (2023) are working papers whose details could not be verified; we note these as related work in the Discussion but do not add unverifiable citations.

### Concern 3: Minor repetition
> Unwinding explained multiple times; tighten.

**Response:** The unwinding explanation is necessarily repeated across sections (Background, Framework, Results, Discussion) because each section addresses a different analytical angle. We have reviewed for redundancy but consider the current level appropriate given the paper's argumentative structure.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Figure cross-reference check
> Figure 3 caption mentions Figure 8 internally.

**Response:** Verified all cross-references. Figures use \Cref{} throughout for automatic numbering; no internal caption inconsistencies found in the compiled PDF.

### Concern 2: Synthetic control as robustness
> Add SCM/Augmented SCM specification.

**Response:** We cite Abadie et al. (2010) and explain in Section 5.5 why SCM is not used: with 4 control states (plus potentially 5 late-adopters as donors), the donor pool is too thin for reliable synthetic control weights. The CS-DiD with never-treated control group is the appropriate estimator for this setting.

### Concern 3: Marketplace insurance outcome
> Add "Direct Purchase" (HINS2) insurance as an outcome.

**Response:** While the ACS HINS2 variable exists, adding marketplace insurance as a fourth outcome would require re-running the full analysis pipeline. We note this as a valuable extension for future work. The current paper focuses on the three canonical outcomes (Medicaid, uninsured, employer) which are standard in the coverage evaluation literature.

### Concern 4: Missing reference
> Suggest Gordon et al. (2023) on Medicaid churning.

**Response:** Gordon et al. (2022) is already cited (bibitem gordon2022trends). We have not been able to verify a 2023 publication by this author group on churning specifically.
