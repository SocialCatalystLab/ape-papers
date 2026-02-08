# Internal Review Round 1

## Reviewer 2 (Harsh)

### Summary
This paper examines the effect of state paid family leave on maternal employment using staggered DiD. The main finding is a null result: parallel trends fails, so no causal effect can be identified. While methodologically sound, the paper's contribution is limited since it essentially documents that a popular research design doesn't work in this context.

### Major Concerns

1. **Limited novelty.** The paper's main contribution is showing that parallel trends fails for PFL. This is a negative result with limited policy relevance. The paper doesn't advance our understanding of PFL's actual effects—it just says we can't identify them with this design.

2. **Incomplete robustness analysis.** The paper mentions HonestDiD in the robustness code but doesn't report sensitivity analysis results. Rambachan-Roth bounds could show what conclusions hold under various assumptions about parallel trends violations. This is a major omission.

3. **Missing conditional parallel trends.** The paper rejects unconditional parallel trends but doesn't seriously explore whether conditional parallel trends (controlling for covariates) might hold. Adding state-level controls for economic conditions, industry composition, or other factors could potentially restore identification.

4. **Broken table reference.** Page 10 refers to "Table ??" for the LFP results—this needs to be fixed.

5. **California missing from Figure 5.** The state-specific effects figure shows only 4 states but there are 5 treated states. Where is California?

### Minor Concerns

1. Literature review is thin—consider adding more recent PFL studies and the growing literature on DiD methodology.

2. The paper could benefit from a conceptual framework section discussing why PFL might (or might not) affect employment.

3. Triple-diff results mentioned in robustness checks but not included in the main paper.

### Verdict: MAJOR REVISION

---

## Editor (Constructive)

### Overall Assessment
This is a well-executed methodological paper that makes an important point: modern DiD methods can reveal identification failures that traditional TWFE obscures. The paper is honest about its limitations and draws appropriate conclusions. However, several improvements would strengthen the contribution.

### Suggested Revisions

1. **Add HonestDiD sensitivity analysis.** Show Rambachan-Roth bounds for what effect sizes would be consistent with the data under various assumptions about parallel trends violations. This would transform "we can't identify effects" into "effects would need to exceed X pp to be detected given the pre-trend violations."

2. **Explore conditional parallel trends.** Try adding state-level covariates (unemployment rate, industry composition, other family policies) to see if conditional parallel trends holds. Even if it doesn't, this exercise would be informative.

3. **Fix technical issues:** Table reference on p.10, California missing from Figure 5.

4. **Expand discussion of alternative designs.** The conclusion mentions eligibility cutoffs and policy reforms—could briefly discuss what these would look like and their feasibility.

5. **Include triple-diff in main text.** The triple-difference (new mothers vs. non-mothers) is mentioned in robustness but could be a valuable additional check presented in the main results.

### Verdict: MAJOR REVISION

---

## Summary Recommendation

**MAJOR REVISION**

The paper is methodologically sound and makes a valid point, but needs:
1. HonestDiD sensitivity analysis
2. Exploration of conditional parallel trends
3. Technical fixes (table reference, missing state in figure)
4. More complete presentation of robustness checks

The paper should not be rejected—negative results are valuable—but it needs more depth to merit publication.
