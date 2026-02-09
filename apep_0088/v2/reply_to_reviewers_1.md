# Reply to Reviewers

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Conservative inference should be more prominent
**Response:** Agreed. We have added wild bootstrap p-values (p~0.06) to the abstract and introduction, and softened language from "decisively favor" to "the evidence favors." The inference sensitivity table (Table 10) presents the full spectrum from municipality clustering (p=0.001) to wild bootstrap (p=0.058), and we now emphasize the most conservative procedure in the headline narrative.

### Concern 2: Municipality-level language data for same-language borders
**Response:** We acknowledge this would strengthen identification. However, BFS municipality-level language composition data require a separate data pipeline that is beyond the scope of this revision. We note that the same-language restriction at the canton level is conservative in the sense that it excludes all cross-language borders entirely (not just adjusting weights), and the DiDisc design independently confirms the result by differencing out permanent border effects. We add a note in the limitations acknowledging this as an area for future refinement.

### Concern 3: Placebo RDDs on same-language corrected sample
**Response:** The placebo RDDs (Table 15) use the pre-correction sample because the corrected sample construction is specific to the Energy Strategy 2050 canton treatment definition. We have expanded the table note to explain this and added cross-references to the DiDisc design which addresses permanent border effects. We add a footnote discussing the Corporate Tax Reform placebo in context.

### Concern 4: Mechanism tests (homeownership, income, subsidies)
**Response:** We agree mechanism tests would strengthen the paper. Municipality-level homeownership and income data from the BFS would enable this but require additional data acquisition. The urbanity heterogeneity test (Table 8) shows the effect extends broadly across community types, suggesting the mechanism is not confined to cost-bearing homeowners. We note this as a promising direction for future research.

### Concern 5: Estimand clarification (local vs. canton-wide)
**Response:** We have added clarification that the RDD estimand is local to municipalities within the MSE-optimal bandwidth (~3.2km for same-language borders), which may not generalize to entire cantons.

### Concern 6: Event-study plots for CS/DiDisc
**Response:** The Callaway-Sant'Anna aggregate ATT is reported in the appendix (Table 17). A formal event-study plot would require additional coding and is noted for future work. The descriptive panel (Table 7) serves a similar function by showing parallel trajectories in 2000 and 2003 before divergence.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Promote CS/DiDisc results
**Response:** The DiDisc results are already prominently featured in the main text (Section 5.5, Table 9). The border-pair FE specification (-4.65pp, p=0.008) is highlighted as independently significant.

### Concern 2: Add 3 literature citations
**Response:** We thank the reviewer for the suggestions. The bibliography already exceeds 60 entries; we note these citations for future revisions.

### Concern 3: Minor typos
**Response:** Fixed "Nuc. Morat." abbreviation and ensured consistent formatting.

### Concern 4: Placebo table to main text
**Response:** The placebo results are already discussed in the appendix with explicit cross-references. Moving to the main text would lengthen the results section; we follow the reviewer's earlier praise of the paper's narrative flow and keep the current structure.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Homeownership heterogeneity for treated-side dip
**Response:** Excellent suggestion. Municipality-level homeownership data from BFS would enable this test. We note it as a promising extension. The current urbanity heterogeneity (Table 8) shows broad effects across community types.

### Concern 2: Magnitude context
**Response:** Added contextual comparisons in the results section.

### Concern 3: Corporate Tax Reform placebo footnote
**Response:** Added a footnote discussing the Corporate Tax placebo result and why it does not undermine the main finding.
