# Advisor Review - GPT-5.2

**Role:** Academic advisor checking for fatal errors
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T15:32:08.326794
**Route:** OpenRouter + LaTeX
**Tokens:** 19479 in / 1157 out
**Response SHA256:** a6ba1f55ea7e84a7

---

FATAL ERROR 1: Data–Design Alignment (Nightlights DiD control group is not “never-treated”)
  Location: Section “Callaway-Sant’Anna Estimator for Nightlights” (Empirical Strategy), and Results → “Main Results: Nightlights”
  Error: The paper states “I designate Phase III districts as the ‘never-treated’ control group,” but Phase III districts are treated starting April 2008. That means there is, in fact, no never-treated group in your data. As written, the Callaway–Sant’Anna setup (and especially the reported “overall ATT across all treated groups and post-treatment periods”) is not internally consistent with the treatment timing: post-2008 comparisons cannot use Phase III as an untreated control. This is a design–data mismatch in the DiD construction, not just a “caveat.”
  How to fix:
  - Re-estimate the CS DID using an appropriate comparison set:
    - Option A (cleanest): Restrict the ATT aggregation to post-treatment years that still have not-yet-treated controls (i.e., use only years t < 2008 so Phase III is genuinely untreated), and clearly report that the nightlight effects are identified only through 2006–2007 (and part of 2007 depending on how you code April timing).
    - Option B: Use the “not-yet-treated” comparison group approach implemented in the `did` package (do not label Phase III as never-treated; define controls as districts untreated at t). Then only interpret ATTs where such controls exist, or be explicit that after 2008 you are no longer estimating causal effects relative to untreated units.
    - Option C: If you keep post-2008 estimates, you must redefine estimands as comparisons to “later-treated” (not “never-treated”) and avoid reporting/aggregating them as a single overall causal “ATT” as currently framed.

FATAL ERROR 2: Internal Consistency (Outcome/share denominators contradict across sections/tables)
  Location: Table 1 (Summary Statistics by MGNREGA Phase), tablenotes; and Data section “Village-Level Census Data”
  Error: You define worker shares in the Data section as ratios over “total main workers” (e.g., non-farm share = (HH industry + other workers)/total main workers). But Table 1’s notes say: “Worker shares are computed as the share of main workers in each occupational category out of total workers.” Those are different denominators (total workers vs total main workers), and they will generally produce different levels and changes. This is a hard internal inconsistency because Table 1 is used to motivate baseline differences and trends that feed directly into the regression design.
  How to fix:
  - Make the denominator definition consistent everywhere (recommended: total main workers, since your outcomes/regressions are long differences in main-worker shares).
  - Update Table 1 notes (and anywhere else) to match the actual construction used in the code.
  - Double-check that the reported means/changes in Table 1 are indeed computed using the same denominator as the regression dependent variables (d_nonfarm_share etc.). If Table 1 was computed using “total workers” while regressions use “main workers,” recompute Table 1.

ADVISOR VERDICT: FAIL