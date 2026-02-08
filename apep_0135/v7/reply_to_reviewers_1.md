# Reply to Reviewers - Round 1

**Paper:** Technological Obsolescence and Populist Voting
**Date:** 2026-02-03

---

## Response to GPT-5-mini (MAJOR REVISION)

We thank the reviewer for their thorough and thoughtful review. We address each concern:

### On Causal Interpretation

> "The core claims... read as close to causal statements"

We respectfully note that the paper is explicit about its observational nature and carefully avoids causal claims. Our abstract states the technology-voting correlation is "consistent with geographic sorting rather than technology directly causing populist preferences." The gains test is presented as "diagnostic evidence" rather than causal proof.

### On Aggregation and Measurement

> "weight industry-level modal ages by employment shares"

We show robustness to median, 25th/75th percentile, and population-weighted specifications (Tables 7-8). The unweighted mean is our baseline because it treats all industries equally rather than privileging large employers.

### On Spatial Correlation

> "Conley SEs"

Table 9 shows two-way clustering by CBSA and state, which addresses spatial correlation at the state level. Results remain significant.

### On Data Provenance

> "the earlier data error... is alarming"

We agree this was a serious error. The appendix now documents:
1. Prof. Hassan's correspondence identifying the error
2. The correct data source (Dropbox CSV)
3. Full replication materials including the corrected data

---

## Response to Grok-4.1-Fast (MINOR REVISION)

We thank the reviewer for their positive assessment. We have addressed:

1. **Sample size consistency**: Fixed a code bug that caused misalignment in Table 1.
2. **Limitations discussion**: The paper includes a full limitations subsection (Section 6.5).

---

## Response to Gemini-3-Flash (MINOR REVISION)

We thank the reviewer for their constructive feedback. We have addressed:

1. **Temporal consistency**: Added clarifying note that the 2024 election occurred in November 2024 and this paper was prepared in early 2026.
2. **Contribution framing**: The paper's key contribution is the temporal diagnostic (effect emerges in 2016, predicts gains but not subsequent changes).

---

## Summary of Changes

1. Fixed 05_tables.R indexing bug
2. Added temporal clarification to data section
3. Expanded data provenance appendix with Prof. Hassan's correspondence
4. Updated acknowledgements

We believe the paper is now ready for publication.
