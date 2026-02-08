# Revision Plan - Round 3 (External Review Round 2 Response)

## GPT 5.2 Verdict: REJECT AND RESUBMIT

## Critical Issues to Address

### 1. Table cross-reference error (Critical)
- Table 4 note says "Column 1 replicates Table 2 Column 1" but Table 2 is summary stats
- Fix: Change to "replicates Table 3 Column 1"

### 2. Main text length (~24 pages, need 25+)
- Currently slightly under threshold
- Add more substantive content to reach threshold

### 3. Bullets in Conceptual Framework
- Section 4 uses bullet lists instead of prose
- Convert to narrative paragraphs

### 4. Confidence intervals missing
- Tables report SEs but not 95% CIs
- Add CIs to main results table

### 5. Few-cluster inference not implemented
- Discussed but not implemented
- Note: With 5 treated states, even wild bootstrap has limitations
- Add note on bootstrap SEs in Callaway-Sant'Anna implementation

### 6. Missing literature
- Synthetic control foundational papers (Abadie et al. 2010, 2015)
- Freyaldenhoven, Hansen & Shapiro (2019)
- Ferman & Pinto (2019)

### 7. California/Washington issues
- Already acknowledged in paper
- Add additional sensitivity analysis note excluding CA and WA

## Implementation Priority

Given the fundamental limitations of the research design, focus on:
1. Fix table cross-reference (critical error)
2. Add CIs to tables
3. Convert bullets to prose
4. Add missing literature
5. Expand text slightly to hit page threshold
6. Add note about inference implementation

## Note

The reviewer's core criticism is that the paper delivers no credible causal estimate and no novel methodological contribution. This is inherent to the research design and findings - the parallel trends failure is the main result. The paper is framed as a cautionary tale, which the reviewer acknowledges is "honest and potentially useful" but may not meet top-journal standards without a new identification strategy.
