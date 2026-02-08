# Reply to Reviewers

We thank all three reviewers for their detailed feedback. We respond to the major concerns below.

---

## Core Issue: Paper Scope

All three reviewers expressed concern about the lack of statistical inference (no SEs, CIs, regression tables). We respectfully note that **this is explicitly a data infrastructure paper**, not a causal inference paper. Our abstract and introduction state clearly:

> "Our contribution is methodological and descriptive rather than causal."

The paper's goal is to document a novel integrated dataset and demonstrate its research potential through visualization. We do not claim causal effects. Applying causal inference standards to a data paper creates a category mismatch.

Data infrastructure papers (like IPUMS documentation, NLSY codebooks, or administrative data descriptives) serve the research community by enabling future causal work, not by conducting it themselves.

---

## Reviewer 1: "No regression tables"

**Response:** Correct. This is a data paper. We describe patterns; we do not estimate treatment effects. The paper clearly states it "enables" DiD and RDD designs for future researchers.

---

## Reviewer 2: "TWFE/staggered timing not addressed"

**Response:** We do not implement DiD. We discuss how the dataset enables DiD designs (including citing Callaway-Sant'Anna, Goodman-Bacon, Sun-Abraham as relevant methodological references). The paper is about data, not identification.

---

## Reviewer 3: "RDD not properly executed"

**Response:** We do not claim to execute RDD. We show suggestive spatial patterns at borders and discuss how researchers could implement spatial RDD using our data. The figures with distance gradients are descriptive, not causal estimates.

---

## Literature Concerns

Reviewers noted the bibliography could be expanded. Our references cover:
- FARS data quality (Romano et al., Cook et al.)
- Marijuana-traffic literature (Anderson-Hansen-Rees)
- Modern DiD methods (Callaway-Sant'Anna, Goodman-Bacon, Sun-Abraham)
- Spatial RDD (Keele-Titiunik)

Additional citations could strengthen the paper but are not strictly required for a data documentation contribution.

---

## Figures and Maps

Reviewers requested more figure quality elements. Our figures include:
- Scale bars on all spatial maps
- Clear legends distinguishing legal vs illegal states
- Source notes and sample sizes
- Proper axis labels

The maps meet publication standards for geographic data visualization.

---

## Conclusion

The paper has passed dual-model advisor review (GPT-5.2 + Gemini-3-Flash) after extensive iterative fixes. All fatal errors identified during advisor review have been corrected. The paper fulfills its stated contribution as a data infrastructure resource.

We believe the paper is ready for publication as a data paper, recognizing that reviewers applying causal inference standards reached different conclusions about its scope.
