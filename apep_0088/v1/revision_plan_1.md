# Revision Plan for Paper 111

**Date:** 2026-01-30
**Decisions:** Minor (1), Major (2)

## Summary of Reviewer Concerns

### All Three Reviewers:
1. **Literature review too thin** - Need to add foundational RDD citations (Dell 2010, Keele & Titiunik 2015) and policy papers
2. **McCrary density test failure** - Significant imbalance (p=0.001) dismissed too easily
3. **Positive point estimate discussion** - 9.2 pp estimate is economically large; need to discuss complementarity possibility

### Specific Issues:
- **R1:** Small cluster problem in distance analysis (7 states); needs Wild Cluster Bootstrap
- **R2 & R3:** Need power analysis / minimum detectable effect calculation
- **R2:** Bullet points in some sections (Data, Cost components)
- **R2:** Conclusion too fragmented

## Planned Revisions

### 1. Expand Literature Review
Add citations:
- Dell (2010) - seminal spatial RDD
- Keele & Titiunik (2015) - geographic RDD theory
- Imbens & Lemieux (2008) - RDD guide
- Miller & Seo (2021) or similar - cannabis policy

### 2. Address Density Imbalance More Rigorously
- Add discussion that density imbalance reflects population differences (CA more populous)
- Note that sorting into crash locations is implausible (can't choose where to have a fatal crash)
- Add robustness check excluding California-border crashes

### 3. Discuss Complementarity Hypothesis
- Add paragraph in Results section discussing the positive point estimate
- Frame the positive estimate (9.2 pp, ~32% of mean) as potentially consistent with complementarity
- Note that imprecision prevents definitive conclusions

### 4. Add Power Analysis
- Calculate minimum detectable effect given sample size and variance
- Discuss what size of effect can be ruled out at 80% power

### 5. Address Small Cluster Problem
- Add note that distance analysis should be interpreted cautiously due to few clusters
- Consider mentioning Wild Cluster Bootstrap would be appropriate with more clusters

### 6. Polish Prose
- Convert any remaining bullet points in main text to paragraphs
- Consolidate Conclusion subsections

## Implementation Order
1. Add literature citations to bibliography and text
2. Expand density discussion
3. Add complementarity discussion
4. Add power analysis paragraph
5. Polish prose
6. Recompile and re-run advisor review
