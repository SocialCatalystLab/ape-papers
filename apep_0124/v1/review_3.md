# Claude-4.5-Haiku Review

**Role:** External referee review
**Model:** anthropic/claude-haiku-4.5
**Paper:** paper.pdf
**Timestamp:** 2026-01-31T22:30:07.068269
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 25136 in / 8000 out
**Response SHA256:** 468e7fa061429546

---

# COMPREHENSIVE REVIEW

## Paper: "Do Close Referendum Losses Demobilize Voters? Evidence from Swiss Municipal Voting"

---

## 1. FORMAT CHECK

**Length**: The paper is approximately 35 pages (main text, excluding appendices). This exceeds the 25-page minimum. ✓

**References**: The bibliography is reasonably comprehensive for the RDD and winner-loser gap literatures. However, there are notable gaps (see Section 4 below).

**Prose Quality**: **MAJOR ISSUE.** The paper has substantial structural problems:
- The Introduction (pp. 1-3) is written in full paragraphs. ✓
- Section 2 (Institutional Background, pp. 4-8) is largely prose. ✓
- Section 3 (Data, pp. 9-13) **relies heavily on bullet points** in subsections 3.1-3.4. This is problematic for a top journal. The variable definitions (3.4) are presented as equations without sufficient narrative explanation of *why* these choices matter.
- Section 4 (Empirical Strategy, pp. 13-15) is mostly prose but could be clearer.
- Section 5 (Results, pp. 16-20) is **primarily tables and figures with minimal narrative**. The text is sparse and reads like a technical report rather than a compelling story.
- Section 6 (Discussion, pp. 20-24) returns to full prose. ✓

**Critical Issue**: The Results section (5.1-5.4) is only 4 pages for what should be the paper's centerpiece. Each subsection is 1-2 paragraphs followed by a table/figure. This is insufficient for a top journal. The main finding—a precise null—deserves deeper engagement: What does this mean? Why is it surprising? What are the implications? The discussion is deferred to Section 6, but results should stand on their own.

**Figures**: Figures 1-4 are publication-quality with clear axes, labels, and notes. ✓

**Tables**: All tables contain real numbers, not placeholders. ✓

**Section Depth**: 
- Introduction has ~3 substantive paragraphs. ✓
- Literature Review is embedded in Introduction (acceptable for a focused paper). Adequate depth.
- Methods section is detailed. ✓
- Results section is *too brief* (see above). ✗
- Discussion has ~4 substantive paragraphs. ✓

---

## 2. STATISTICAL METHODOLOGY (CRITICAL)

### A. Standard Errors and Inference

**PASS, with caveats.**

- Main results (Table 4) report point estimates, robust SEs, p-values, and 95% CIs. ✓
- All robustness tables (5, 6) include SEs and p-values. ✓
- Covariate balance tests (Table 3) include SEs and p-values. ✓
- Placebo tests (Table 6) are properly reported. ✓
- Bandwidth sensitivity (Table 5) shows SEs across specifications. ✓

**Issue**: The paper clusters standard errors at the canton level (26 clusters). With only 26 clusters, this is at the boundary of acceptability. The authors should:
1. Report results with alternative clustering (e.g., by municipality or no clustering) to show robustness.
2. Discuss the trade-off: canton-level clustering may be conservative (larger SEs) but appropriate given shared media environments.

The paper does not address this limitation. **Minor issue, not fatal.**

### B. RDD Validity Tests

**PASS.**

- **McCrary Density Test** (Figure 1, p. 16): p-value = 0.92, no evidence of manipulation. ✓
- **Covariate Balance** (Table 3, p. 17): Log eligible voters, focal turnout, and language region all show no discontinuity. ✓
- **Placebo Cutoffs** (Table 6, p. 20): Tests at 30%, 40%, 60%, 70% thresholds show no effects. ✓
- **Bandwidth Sensitivity** (Table 5, p. 19): Estimates stable across 0.5–1.5× optimal bandwidth. ✓

All standard RDD validity checks are present and properly executed. This is a strength.

### C. Identification Assumption

**PASS.**

The paper clearly states the identifying assumption (continuity of potential outcomes at the cutoff, p. 14). The logic is sound: municipal referendum outcomes are determined by aggregation of individual votes, making precise manipulation at 50% infeasible.

**Potential concern**: The paper does not discuss whether voters in municipalities near 50% differ systematically in *unobservable* ways. For example, do municipalities with close votes have different political engagement, education levels, or demographic composition? The covariate balance tests address *observable* covariates, but unobservable differences could still violate the identifying assumption.

**Mitigation**: The authors could argue that the RDD compares municipalities that are statistically similar on observables, and the design is robust to unobservables that vary smoothly through the threshold. This is standard RDD logic, but the paper could be more explicit.

### D. Sample and Clustering Structure

**Issue**: The analysis sample has 311,702 observations from 2,122 municipalities and 56 referendums. Observations are **not independent**: each municipality-referendum pair can contribute multiple observations (one per subsequent referendum in the same policy domain, 1–3 years after).

The paper clusters at the canton level (26 clusters), which partially addresses this dependence. However:
1. **Within-municipality dependence**: Multiple subsequent referendums per focal referendum create dependence within municipalities. Canton-level clustering may not fully account for this.
2. **Solution**: The paper should report results with standard errors clustered at the municipality level (or two-way clustering: municipality × focal referendum). This would be more conservative and appropriate.

The paper acknowledges this structure (p. 11: "Standard errors are clustered at the canton level to account for within-canton correlation and repeated observations per municipality") but does not justify why canton-level clustering is sufficient for within-municipality dependence.

**Recommendation**: Provide robustness checks with alternative clustering schemes.

### E. Outcome Variable Definition

**Potential Issue**: The outcome is turnout in subsequent referendums in the *same policy domain* occurring 1–3 years after the focal referendum. This definition assumes:
1. Voters who care about a policy area are more likely to respond to wins/losses in that area.
2. The 1–3 year window captures the relevant follow-up period.

**Questions**:
- Why 1–3 years? Why not 1–2 or 1–4?
- How many focal referendums have *any* subsequent referendums in the same domain within this window? If few, the effective sample size may be small.

The paper shows results for alternative windows (Table 12, p. C-4: 1–2 years, 1–3 years, 2–3 years). All show null effects. This is reassuring but should be in the main text, not the appendix.

**Minor issue**: The paper should clarify in the main text how many focal referendums have subsequent referendums in the same domain, and what fraction of observations come from each follow-up window.

### F. Overall Methodology Assessment

**VERDICT: PASS, with minor caveats.**

The RDD is well-executed with appropriate validity tests. Standard errors are properly reported. The main methodological concerns are:
1. Clustering at canton level may not fully address within-municipality dependence.
2. The outcome variable definition (same policy domain, 1–3 years) could be better justified.

These are not fatal, but robustness checks (alternative clustering, alternative outcome windows) should be in the main text.

---

## 3. IDENTIFICATION STRATEGY

### A. Credibility of RDD Design

**Strengths**:
- The 50% threshold is natural and not manipulable by any actor.
- Municipalities near the threshold are as-if randomly assigned to "win" vs. "lose."
- Validity tests (McCrary, covariate balance, placebo cutoffs) all pass.
- The design exploits geographic variation in outcomes for a constant national policy.

**Weaknesses**:
1. **Local vs. National Outcome Disconnect**: The paper assumes voters care about their municipality's vote share. But the policy outcome is determined nationally. Why would a voter in a municipality that voted 49% in favor of a passing measure feel "demobilized"? The paper discusses this (p. 8, "Local-national disconnect hypothesis") but doesn't fully resolve it.

   The paper argues (p. 7) that local outcomes are salient because they're reported in local media and discussed in communities. This is plausible, but the mechanism is not empirically tested. Survey data on whether voters are even aware of their municipality's vote share would strengthen this.

2. **Aggregation Masking**: The paper acknowledges (p. 21, "Aggregation masking hypothesis") that individual-level effects could be masked by municipal-level aggregation. If some voters are demobilized while others are mobilized, the net effect could be zero. This is a fundamental limitation of the design.

   **Mitigation**: The paper could use individual-level data (e.g., Swiss Household Panel) to test for heterogeneous effects. The authors mention this limitation but don't pursue it.

3. **Outcome Variable**: Restricting to subsequent referendums in the same policy domain may exclude relevant follow-up votes. A voter who loses on an environmental referendum might respond by participating (or not) in *any* subsequent referendum, not just environmental ones. The paper should report results for all subsequent referendums as a robustness check.

### B. Assumptions and Limitations

**Parallel Trends / Continuity**: The RDD assumes potential outcomes are continuous at the 50% threshold. The validity tests support this, but the assumption is inherently untestable.

**Threats to Validity**:
1. **Sorting**: Could municipalities with certain characteristics systematically land near 50%? The covariate balance tests suggest no, but unobservable sorting is possible.
2. **Manipulation**: The McCrary test shows no bunching, but sophisticated manipulation might not create visible bunching. The paper could strengthen this by showing that the density is smooth at other thresholds (e.g., 30%, 40%, 60%, 70%), which it does in Table 6. ✓

### C. Placebo Tests and Robustness

**Strengths**:
- Placebo cutoffs at 30%, 40%, 60%, 70% all show null effects. ✓
- Bandwidth sensitivity across 0.5–1.5× optimal shows stable null. ✓
- Alternative polynomial orders (linear, quadratic) show similar results. ✓
- Alternative kernels (triangular, uniform, Epanechnikov) show similar results. ✓
- Donut RDD (excluding observations within ±0.5, ±1.0, ±2.0 pp of cutoff) shows stable null. ✓

**Weaknesses**:
- No heterogeneity analysis in the main text. Language region, referendum type, policy domain, and municipality size are relegated to brief mentions (p. 21, "Heterogeneity Analysis") with results in appendix (Table 13, p. D-3). These should be in the main text if they're important.
- No analysis of whether effects differ by magnitude of loss (e.g., 49% vs. 30% yes-vote share).

### D. Conclusions Follow from Evidence?

**Yes, mostly.** The paper concludes that local referendum losses do not demobilize voters. The evidence supports this: a precise null with tight confidence intervals. However:

1. The paper could be more cautious about the interpretation. The null could reflect:
   - No true effect (voters are resilient).
   - Aggregation masking offsetting effects (some voters demobilized, others mobilized).
   - Insufficient power to detect small effects (though the CI rules out effects >1.7 pp).
   - Outcome variable misspecification (same policy domain may not capture relevant follow-up votes).

2. The paper discusses these possibilities (Section 6.1, pp. 20-23) but doesn't emphasize them enough. The main text should be more cautious.

### E. Limitations Discussed?

**Yes, adequately.** Section 6.4 (pp. 23-24) discusses:
- Local vs. extreme effects
- Turnout as the outcome
- Aggregation level
- Generalizability
- Time horizon

These are appropriate limitations. The paper could add:
- Unobservable sorting
- Outcome variable misspecification (restricting to same policy domain)
- Small number of canton clusters

---

## 4. LITERATURE REVIEW

### A. Coverage of RDD Literature

**Adequate but incomplete.** The paper cites:
- Lee (2008) on RDD in elections ✓
- Caughey & Sekhon (2011) on close elections ✓
- Imbens & Lemieux (2008) – **NOT CITED** ✗
- Calonico et al. (2014, 2020a, 2020b) on RDD inference ✓
- McCrary (2008) on density tests ✓

**Missing**: The paper should cite:
- **Imbens, G. W., & Lemieux, T. (2008).** "Regression discontinuity designs: A guide to practice." *Journal of Econometrics*, 142(2), 615-635. This is the foundational RDD review and should be cited.

```bibtex
@article{ImbensLemieux2008,
  author = {Imbens, Guido W. and Lemieux, Thomas},
  title = {Regression discontinuity designs: A guide to practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  number = {2},
  pages = {615--635}
}
```

### B. Coverage of Winner-Loser Gap Literature

**Good.** The paper cites:
- Anderson et al. (2005) ✓
- Blais & Gélineau (2017) ✓
- Marien & Kern (2018) ✓
- Bowler et al. (2022) ✓

**Missing**: 
- **Norris, P. (2011).** "Democratic Deficit: Critical Citizens Revisited." Cambridge University Press. Relevant for understanding political satisfaction and legitimacy.
- **Hibbing, J. R., & Theiss-Morse, E. (2002).** "Stealth Democracy: Americans' Beliefs about How Government Should Work." Cambridge University Press. Relevant for understanding how citizens evaluate democratic processes.

These are not essential but would strengthen the literature positioning.

### C. Coverage of Direct Democracy Literature

**Adequate.** The paper cites relevant work on Swiss referendums and direct democracy. However:

**Missing**:
- **Bowler, S., Donovan, T., & Karp, J. A. (2007).** "Enraged or Engaged? Preferences for Direct Citizen Participation in Affluent Democracies." *Political Research Quarterly*, 60(3), 351-362. Relevant for understanding participation in direct democracy.
- **Matsusaka, J. G. (2005).** "Direct Democracy Works." *Journal of Economic Literature*, 43(4), 1-34. Comprehensive review of direct democracy effects.

```bibtex
@article{Matsusaka2005,
  author = {Matsusaka, John G.},
  title = {Direct Democracy Works},
  journal = {Journal of Economic Literature},
  year = {2005},
  volume = {43},
  number = {4},
  pages = {1--34}
}
```

### D. Coverage of Policy Feedback Literature

**Adequate.** The paper cites:
- Soss (1999) ✓
- Mettler & Soss (2004) ✓

**Missing**:
- **Pierson, P. (1993).** "When Effect Becomes Cause: Policy Feedback and Political Change." *World Politics*, 45(4), 595-628. Foundational for policy feedback theory.

```bibtex
@article{Pierson1993,
  author = {Pierson, Paul},
  title = {When Effect Becomes Cause: Policy Feedback and Political Change},
  journal = {World Politics},
  year = {1993},
  volume = {45},
  number = {4},
  pages = {595--628}
}
```

### E. Coverage of Voter Turnout Literature

**Adequate.** The paper cites:
- Campbell et al. (1954) on political efficacy ✓
- Finkel (1985) on participation and efficacy ✓
- Green & Gerber (2008) on GOTV interventions ✓

**Missing**:
- **Gerber, A. S., Green, D. P., & Shachar, R. (2003).** "Voting May Be Habit-Forming: Evidence from a Randomized Field Experiment." *American Journal of Political Science*, 47(3), 540-550. Relevant for understanding habit formation in voting.

```bibtex
@article{GerberGreenShachar2003,
  author = {Gerber, Alan S. and Green, Donald P. and Shachar, Ron},
  title = {Voting May Be Habit-Forming: Evidence from a Randomized Field Experiment},
  journal = {American Journal of Political Science},
  year = {2003},
  volume = {47},
  number = {3},
  pages = {540--550}
}
```

### F. Overall Literature Assessment

**VERDICT: ADEQUATE but with notable gaps.**

The paper adequately covers the RDD, winner-loser gap, and direct democracy literatures. However, it misses some foundational papers (Imbens & Lemieux 2008, Pierson 1993, Matsusaka 2005, Gerber et al. 2003) that would strengthen the positioning.

**Recommendation**: Add citations to the papers listed above, particularly Imbens & Lemieux (2008) as the foundational RDD review.

---

## 5. WRITING QUALITY (CRITICAL)

### A. Prose vs. Bullets

**MAJOR ISSUE.**

**Section 3 (Data, pp. 9-13)**: This section relies heavily on bullet points:
- Subsection 3.1 (p. 9): Lists variables using bullet points. This is acceptable for variable definitions but should be accompanied by narrative explaining why these variables matter.
- Subsection 3.2 (p. 10): Lists Swissvotes variables using bullet points. Same issue.
- Subsection 3.4 (p. 12): Variable definitions are presented as equations with minimal narrative.

**Example (p. 12)**:
```
Running variable: The running variable for the RDD is the municipal yes-vote share centered at 50%:
X_mr = YesShare_mr - 50
```

This should be:
```
The running variable is the municipal yes-vote share centered at the 50% threshold. We define this as X_mr = YesShare_mr - 50, where positive values indicate the municipality voted in favor and negative values indicate opposition. This centering simplifies interpretation: a value of X = 0 indicates exactly 50%, the threshold separating local "winners" from "losers."
```

**Section 5 (Results, pp. 16-20)**: This is the paper's centerpiece but is written like a technical report:
- 5.1 (Density Test, p. 16): 1 paragraph + 1 figure.
- 5.2 (Covariate Balance, p. 17): 1 paragraph + 1 table.
- 5.3 (Main Results, p. 18): 1 paragraph + 1 table.
- 5.4 (Robustness, pp. 19-20): 1 paragraph per subsection + tables.

Each subsection is too brief. The main result (Table 4) deserves at least 2-3 paragraphs discussing what the estimate means, how it compares to prior expectations, and what it implies.

**Example of current text (p. 18)**:
```
Table 4 presents the main RDD results. The point estimate of the effect of local "winning" on subsequent turnout is 0.05 percentage points. The cluster-robust standard error is 0.84, yielding a t-statistic of 0.06 and a two-sided p-value of 0.95. The 95% confidence interval is [-1.60, 1.70].

The estimate is a precise null. The confidence interval rules out effects larger than approximately 1.7 percentage points in either direction. Given that baseline turnout is approximately 50%, this means we can rule out effects larger than 3.4% of baseline turnout.
```

This is only 2 paragraphs for the main result. It should be 3-4 paragraphs:
1. Present the point estimate and CI.
2. Interpret the magnitude (what does 0.05 pp mean?).
3. Compare to prior expectations and the literature.
4. Discuss what the null result implies.

**VERDICT: The Results section reads like a technical report, not a compelling narrative. This is a significant weakness for a top journal.**

### B. Narrative Flow

**Strengths**:
- Introduction (pp. 1-3) is well-structured with clear motivation, research question, and contribution.
- Institutional background (pp. 4-8) provides helpful context.
- Discussion (pp. 20-24) engages with implications and limitations.

**Weaknesses**:
- Results section (pp. 16-20) lacks narrative flow. Each subsection (density test, covariate balance, main results, robustness) feels disconnected.
- The paper doesn't tell a story: "Here's what we expected, here's what we found, here's what it means." Instead, it presents tables and figures with minimal interpretation.
- The transition from results to discussion is abrupt. The discussion should flow naturally from the results.

**Recommendation**: Rewrite the Results section to emphasize the narrative:
1. Start with a paragraph explaining what we're testing and why.
2. Present validity tests (density, covariate balance, placebo cutoffs) in a single coherent section.
3. Present main results with interpretation.
4. Discuss robustness checks as a narrative ("We tested whether results depend on bandwidth choice, polynomial order, kernel specification...").

### C. Sentence Quality

**Generally good, but uneven.**

**Strengths**:
- Introduction has varied sentence structure and clear topic sentences.
- Institutional background explains concepts clearly.

**Weaknesses**:
- Data section (pp. 9-13) has many long, complex sentences with multiple clauses. Example (p. 10):
  ```
  "The database is the authoritative scholarly source for Swiss referendum research and is updated after each voting day."
  ```
  This is clear, but many sentences in this section are denser.

- Results section has repetitive structure: "Table X presents... The point estimate is... The standard error is... The p-value is..." This becomes monotonous.

**Recommendation**: Vary sentence structure in the Results section. Use active voice more. Example:
```
Current: "Table 4 presents the main RDD results. The point estimate of the effect of local 'winning' on subsequent turnout is 0.05 percentage points."

Revised: "Local referendum losses have no detectable effect on subsequent voter turnout. The RDD estimate is 0.05 percentage points (SE = 0.84, p = 0.95), with a 95% confidence interval of [-1.60, 1.70]."
```

### D. Accessibility

**Strengths**:
- Technical terms are generally explained on first use.
- The paper provides intuition for the RDD design (pp. 13-14).
- Magnitudes are contextualized (e.g., "comparable to get-out-the-vote interventions," p. 18).

**Weaknesses**:
- The paper assumes familiarity with Swiss politics. While Section 2 provides background, a reader unfamiliar with Switzerland might struggle. The paper could briefly explain why Switzerland is a good case (high-frequency referendums, strong local identity, etc.) in the Introduction.
- Technical details (e.g., "cantonal majority," "half-cantons") are explained but could be simplified. Example (p. 5):
  ```
  "For a federal referendum to pass, it must achieve both a popular majority (more than 50% of valid votes nationwide) and, for constitutional amendments, a cantonal majority (more than half of the 26 cantons voting in favor)."
  ```
  This is clear but could be: "Federal referendums require both a national majority and (for constitutional changes) a majority of cantons."

### E. Figures and Tables

**Strengths**:
- All figures have clear titles, labeled axes, and legible fonts. ✓
- All tables have clear titles and notes explaining abbreviations. ✓
- Figures 1-4 are publication-quality. ✓

**Weaknesses**:
- Figure 3 (RDD plot, p. 18) could be larger and more prominent. It's the visual centerpiece of the paper and deserves more space.
- Table 4 (main results, p. 18) could include the 95% CI in the table rather than only in the text.

### F. Overall Writing Assessment

**VERDICT: MAJOR REVISION NEEDED.**

The paper has good structure and clear motivation, but the Results section is significantly underdeveloped. For a top journal, the main findings deserve more narrative engagement. The paper reads like a technical report in the Results section, not a compelling story.

**Specific recommendations**:
1. Expand the Results section from 4 pages to 6-8 pages.
2. Rewrite to emphasize narrative: what we expected, what we found, what it means.
3. Reduce bullet points in the Data section; integrate into prose.
4. Vary sentence structure in the Results section.
5. Add more interpretation and discussion of magnitudes.

---

## 6. CONSTRUCTIVE SUGGESTIONS

### A. Strengthen the Main Finding

The null result is interesting, but the paper could do more to explore *why* it's null. Suggestions:

1. **Heterogeneous Effects**: The paper mentions heterogeneity (p. 21) but relegates results to the appendix. The main text should include:
   - Do effects differ by language region (German vs. French-speaking)?
   - Do effects differ by referendum type (initiatives vs. mandatory referendums)?
   - Do effects differ by policy domain?
   - Do effects differ by magnitude of loss (49% vs. 30% yes-vote)?

   If effects are null across all subgroups, this strengthens the conclusion. If effects exist in some subgroups, this is more interesting.

2. **Mechanism Testing**: The paper hypothesizes three mechanisms (individual efficacy, community identity, organizational mobilization, p. 8) but doesn't test them. Suggestions:
   - Use survey data (Swiss Household Panel) to test whether voters in losing municipalities report lower efficacy beliefs.
   - Analyze whether political organizations increase mobilization efforts after near-losses (organizational records, if available).
   - Test whether effects differ by community identity (e.g., small vs. large municipalities, where community identity may be stronger).

3. **Intensity of Engagement**: The paper focuses on turnout but doesn't examine other forms of engagement. Suggestions:
   - Do losers participate less intensively (e.g., vote but don't campaign)?
   - Do losers sign fewer initiative petitions?
   - Do losers donate less to political causes?

   If turnout is stable but intensity declines, this is a more nuanced finding.

### B. Extend the Analysis

1. **Longer Time Horizon**: The paper uses a 1-3 year follow-up window. What about 3-5 years? Do effects emerge over longer periods?

2. **Cumulative Effects**: Does experiencing multiple losses have stronger effects than a single loss? The paper could test whether voters in municipalities that lose on multiple referendums show different participation patterns.

3. **Interaction with Policy Outcomes**: Do effects differ depending on whether the losing voter's preferred policy is later reversed? For example, if a voter loses on an environmental referendum but the policy is later reversed, does this restore engagement?

### C. Improve Presentation

1. **Main Text Results**: Move key robustness checks from appendix to main text. Specifically:
   - Heterogeneity analysis (Table 13, currently p. D-3)
   - Alternative outcome windows (Table 12, currently p. C-4)
   - Donut RDD (Table 11, currently p. C-3)

2. **Expand Results Section**: Rewrite to emphasize narrative. The current 4 pages should expand to 6-8 pages with more interpretation.

3. **Strengthen Discussion**: The Discussion (pp. 20-24) is good but could be more decisive. What's the single most important takeaway? The paper should lead with this.

### D. Address Limitations More Directly

1. **Outcome Variable**: The paper restricts to subsequent referendums in the same policy domain. How robust are results if we include *all* subsequent referendums? This should be in the main text.

2. **Clustering**: The paper clusters at the canton level (26 clusters). How robust are results with alternative clustering (municipality level, two-way clustering)? This should be in the main text.

3. **Individual-Level Effects**: The paper acknowledges that municipal-level aggregation may mask individual-level effects (p. 21). Can the authors use individual-level data (Swiss Household Panel) to test this? Even if sample sizes are small, this would be valuable.

---

## 7. OVERALL ASSESSMENT

### Key Strengths

1. **Novel Research Question**: The paper addresses an important question about democratic resilience that hasn't been thoroughly studied in the referendum context.

2. **Strong Identification Strategy**: The RDD design is well-executed with appropriate validity tests (McCrary, covariate balance, placebo cutoffs). The identifying assumption is credible.

3. **Comprehensive Data**: The paper uses administrative data on 2,122 municipalities and 56 federal referendums, providing substantial statistical power.

4. **Precise Null Result**: The confidence interval is tight enough to rule out economically meaningful effects, which is valuable for the literature.

5. **Good Institutional Context**: Section 2 provides helpful background on Swiss direct democracy.

### Critical Weaknesses

1. **Weak Results Section**: The main findings are presented in only 4 pages with minimal narrative interpretation. For a top journal, this is insufficient. The Results section reads like a technical report, not a compelling story.

2. **Limited Mechanism Testing**: The paper hypothesizes three mechanisms but doesn't test them. The null result would be more convincing if accompanied by evidence on *why* it's null.

3. **Aggregation Masking Not Addressed**: The paper acknowledges that individual-level effects could be masked by municipal-level aggregation but doesn't pursue this. Individual-level analysis (even with smaller samples) would strengthen the paper.

4. **Outcome Variable Restriction**: Restricting to subsequent referendums in the same policy domain may exclude relevant follow-up votes. Robustness checks with alternative outcome definitions should be in the main text.

5. **Writing Quality**: The Data section relies too heavily on bullet points, and the Results section is too brief and technical. The paper needs substantial rewriting for a top journal.

6. **Missing Literature**: Key papers (Imbens & Lemieux 2008, Matsusaka 2005, Pierson 1993) are not cited.

### Specific Issues

1. **Clustering**: Canton-level clustering (26 clusters) may not fully address within-municipality dependence. Alternative clustering schemes should be tested.

2. **Heterogeneity**: Results for different language regions, referendum types, and policy domains are relegated to the appendix. These should be in the main text.

3. **Interpretation**: The paper could be more cautious about interpreting the null. It could reflect true resilience, aggregation masking, or outcome variable misspecification.

4. **Generalizability**: The paper acknowledges that results may not generalize to other countries (p. 24) but doesn't emphasize this enough. The Swiss case is unique (high-frequency referendums, consensus culture, strong local identity), so caution is warranted.

---

## 8. DETAILED COMMENTS BY SECTION

### Introduction (pp. 1-3)

**Strengths**: Clear motivation, well-structured argument, compelling research question.

**Weaknesses**: 
- The paper could better explain *why* Switzerland is a good case. The uniqueness of Swiss direct democracy (high frequency, strong local identity) should be emphasized earlier.
- The three hypotheses (demobilization, mobilization, habituation) are introduced but not clearly labeled. A bullet-point summary would help (though bullets should be minimal elsewhere).

### Section 2: Institutional Background (pp. 4-8)

**Strengths**: Comprehensive and clear. Explains Swiss referendum procedures, municipal voting, information environment, and comparison to other systems.

**Weaknesses**:
- Section 2.5 (Comparison to Other Systems) is somewhat tangential. It could be moved to the Introduction or Discussion.
- The paper could better explain why local outcomes might matter psychologically. Section 2.4 does this but could be more prominent.

### Section 3