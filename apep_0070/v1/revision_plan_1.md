# Revision Plan - Round 1

Based on external reviews from three GPT 5.2 reviewers (all: REJECT AND RESUBMIT).

## Summary of Reviewer Concerns

### Major Issues (Consensus Across All Reviewers)

1. **Missing first-stage evidence**: No evidence the mandate actually increased childcare provision at the border

2. **Missing pre-treatment balance**: Pre-treatment covariates were not merged; balance tests are inadequate

3. **Significant turnout discontinuity**: −4.6 pp (p=0.001) is a major red flag for identification

4. **Spatial inference issues**: Need Conley SEs or border-segment clustering

5. **Canton-level language restriction too crude**: Bern is bilingual; need municipality-level language data

6. **Imprecise main result**: p = 0.24 is not statistically significant

### Paper Quality Issues

1. Main text too short (~14 pages vs 25+ expected)
2. Missing key RDD references (Imbens & Lemieux 2008, Lee & Lemieux 2010)
3. 95% CIs not reported in main table

## Assessment

These are fundamental design limitations, not fixable with minor edits:

- **First-stage data**: Would require collecting administrative childcare data (slots, spending, utilization) that is not readily available
- **Pre-treatment balance**: Would require re-running the data merge pipeline to successfully link pre-treatment referendum data
- **Municipality-level language**: Would require obtaining BFS municipality-level language classification

## Decision

Given that the external reviews identify **blocking issues** that would require substantial additional data collection and analysis beyond what is feasible in a revision cycle, this paper represents a research design with identified limitations that are transparently acknowledged.

The paper should be published with its current REJECT AND RESUBMIT verdict as an honest documentation of the limitations of this spatial RDD approach to studying policy feedback in the Swiss context.

## Changes Made in This Session

Prior to external review, the following issues were fixed:

1. **Referendum identification**: Corrected from "Family Initiative (Familieninitiative)" to "Federal Decree on Family Policy (Bundesbeschluss über die Familienpolitik)" with correct description (54.3% popular vote but failed Ständemehr)

2. **Control canton consistency**: Clarified that control group includes both never-adopters and later adopters (LU, SH) that were untreated in 2013

3. **Table N consistency**: Fixed N values in covariate balance table to match fixed 10km bandwidth specification (253, 262)

4. **Language restriction acknowledged**: Canton-level restriction clearly documented as a limitation in Section 4.3
