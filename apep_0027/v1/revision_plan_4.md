# Revision Plan 4 - Addressing Round 3 External Reviews

## Round 3 Feedback Summary

### GPT 5.2 (REJECT)
1. **TWFE not acceptable** - Need modern staggered-adoption estimators (Sun & Abraham, Borusyak et al.)
2. **16 states restriction** - "for computational manageability" not persuasive
3. **Event study non-standard** - Not a valid pre-trends diagnostic as defined
4. **Few-cluster inference** - Bootstrap p-values not in main tables
5. **Missing references** - Sun & Abraham 2021, Borusyak et al. 2021, Roth 2022, MacKinnon & Webb 2017

### Gemini 3 Pro (MAJOR REVISION)
1. **Parallel trends violation** - Figure 2 clearly shows pre-trends not flat/zero
2. **Need Synthetic Control** - Must actually implement, not just suggest
3. **Missing economics literature** - Carrell & Hoekstra 2010, Kinsler 2011, Anderson et al. 2019
4. **Identification unidentified** - "Null result" framing inappropriate when design fails

---

## Core Issue

Both reviewers agree: **The identification strategy fundamentally fails**. The early-ban states (Northeast/Hawaii) vs. never-ban states (Deep South) are on different educational trajectories independent of the policy. State and cohort fixed effects cannot solve divergent regional trends.

The counterintuitive disability "effect" (bans increasing disability) is a clear indicator of residual confounding, not a causal finding.

---

## Revision Strategy: Honest Reframing

Rather than defending a broken design, we will:

1. **Reframe the paper's contribution** - Document the identification challenge, not claim causal effects
2. **Implement Synthetic Control** - As robustness/exploratory analysis
3. **Expand to all 50 states** - Increases clusters, improves credibility
4. **Add missing references** - All suggested citations
5. **Show bootstrap inference prominently** - In main tables

---

## Specific Changes

### A. Conceptual Reframing

**Title change**: "The Long Shadow of the Paddle? Evidence from State Corporal Punishment Bans"
→ "Challenges in Evaluating Corporal Punishment Bans: A Cautionary Tale for Staggered Adoption Designs"

**Abstract reframe**:
- Current: "We find no robust evidence..."
- New: "We document that stark regional differences between early-ban (Northeast) and never-ban (Deep South) states preclude credible causal identification with standard difference-in-differences methods, highlighting the importance of careful counterfactual construction in policy evaluation."

**Contribution reframe**:
1. Comprehensive compilation of state ban dates
2. Documentation of identification challenges in staggered adoption
3. Demonstration of pre-trends diagnostic importance
4. Synthetic control exploration as alternative approach

### B. New References to Add

```bibtex
@article{SunAbraham2021,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}

@article{BorusyakJaravelSpiess2021,
  author = {Borusyak, Kirill and Jaravel, Xavier and Spiess, Jann},
  title = {Revisiting Event Study Designs: Robust and Efficient Estimation},
  journal = {Review of Economic Studies},
  year = {2024},
  volume = {91},
  pages = {3253--3285}
}

@article{Roth2022,
  author = {Roth, Jonathan},
  title = {Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends},
  journal = {American Economic Review: Insights},
  year = {2022},
  volume = {4},
  pages = {305--322}
}

@article{CarrellHoekstra2010,
  author = {Carrell, Scott E. and Hoekstra, Mark L.},
  title = {Externalities in the Classroom: How Children Exposed to Domestic Violence Affect Everyone's Kids},
  journal = {American Economic Journal: Applied Economics},
  year = {2010},
  volume = {2},
  number = {1},
  pages = {211--228}
}

@article{Kinsler2011,
  author = {Kinsler, Josh},
  title = {Understanding the Black-White Discipline Gap},
  journal = {Economics of Education Review},
  year = {2011},
  volume = {30},
  pages = {1370--1383}
}
```

### C. Synthetic Control Analysis

Implement state-level synthetic control for key early adopters:
- Massachusetts (banned 1971)
- Hawaii (banned 1973)
- New Jersey (banned 1867 - too early, may skip)

Outcome: State-level average educational attainment by birth cohort

### D. Expand to All States

Redo analysis with all 50 states to:
- Increase cluster count from 16 to 50
- Improve inference credibility
- Address "arbitrary restriction" critique

### E. Table Revisions

Add bootstrap p-values column to Table 2 and Table 3

---

## Implementation Order

1. Add new references to paper.tex
2. Rewrite abstract and introduction framing
3. Expand analysis to all 50 states
4. Implement synthetic control analysis
5. Add bootstrap p-values to tables
6. Rewrite discussion/conclusion with honest assessment
7. Recompile and visual QA
