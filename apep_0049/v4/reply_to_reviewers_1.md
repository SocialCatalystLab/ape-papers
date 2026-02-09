# Reply to Reviewers (Round 1)

We thank the reviewers for their constructive feedback. All three reviewers recommended Minor Revision, and we have addressed all substantive points. Below we respond to each reviewer's comments.

---

## Reviewer 1 (GPT-5-mini)

**1. Discrete running variable**
> Discuss explicitly the discreteness of the running variable and cite the literature on RD with discrete running variables.

**Response:** We have added a paragraph in the Empirical Strategy section (Section 4.5) explicitly discussing the discrete nature of Census population. We note that the 3,592 unique mass points and wide bandwidths relative to population increments mitigate discreteness concerns. We also note that the local randomization inference in Section 5 does not rely on running variable continuity and yields consistent results.

**2. Present fuzzy RD/IV in a formal table**
> Include a dedicated table that reports reduced-form, first-stage, and IV estimates.

**Response:** We have added Table 7 with three panels: (A) first stage showing the $31.07 per-capita funding jump, (B) reduced-form ITT estimate, and (C) fuzzy RD TOT estimate. This table is now prominently placed in Section 5.9.

**3. Additional covariate balance checks**
> Provide balance on a richer set of pre-determined covariates.

**Response:** We acknowledge this suggestion. The current design tests income balance and reports the McCrary density test (p=0.984). The 2010 Census API provides limited pre-determined covariates at the urban area level. We note this as a limitation.

**4. Co-located policies at 50,000**
> Address possible co-located policies or thresholds that might coincide with 50k.

**Response:** To our knowledge, the 50,000 threshold is specific to the FTA Section 5307 program. While various federal programs use population thresholds, 50,000 is not a common cutoff for other major programs. We note this in the institutional background discussion of threshold validity.

---

## Reviewer 2 (Grok-4.1-Fast)

**1. NTD mechanism outcomes**
> Merge NTD data for pre/post service miles/ridership—test funding-to-service link.

**Response:** We have incorporated NTD data for heterogeneity analysis by baseline transit service presence (Section 5.6). Direct RD estimation on NTD service outcomes is limited by data availability (NTD only covers agencies that receive federal funding, creating selection). We note this as an important direction for future research.

**2. Repetition between Results and Discussion**
> Null explanations in Results/Discussion overlap slightly.

**Response:** We have trimmed Section 6.1 to reference the literature comparison already presented in Section 5.8, eliminating the redundant TransMilenio/Metro discussion.

**3. Additional references**
> Add 2-3 population-threshold and place-based policy references.

**Response:** We have added Black (1999), Dell (2010), and Cattaneo et al. (2015) to the bibliography and cited them in the Related Literature section.

---

## Reviewer 3 (Gemini-3-Flash)

**1. Fuzzy RD table**
> The Fuzzy RD (TOT) estimate should be a formal table.

**Response:** Added as Table 7 with first-stage, reduced-form, and TOT panels. See response to Reviewer 1, Point 2.

**2. Intermediate service-level outcomes**
> Adding NTD-based "First Stage: Service Provision" would strengthen the contribution.

**Response:** We agree this would be valuable. We have incorporated NTD data to identify areas with baseline transit service for heterogeneity analysis. Direct RD on service metrics faces the selection issue noted above. We highlight this in the Conclusion as a priority for future work.

---

## Additional Changes (from Exhibit and Prose Reviews)

- Added unit clarification to Table 3 notes (proportion vs. percentage points)
- Fixed near-threshold table notation (mechanical population difference)
- Removed duplicate appendix summary statistics table
- Added cost-benefit framing subsection with "used car" comparison
- Updated first-stage figure caption to reflect real FTA apportionment data
- Strengthened conclusion to emphasize informative null and cost-benefit finding
