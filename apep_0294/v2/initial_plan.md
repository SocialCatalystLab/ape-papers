# Initial Plan: T-MSIS Medicaid Provider Spending Dataset Overview

## Research Question

What does the Medicaid provider landscape look like when observed at the provider level for the first time? What research opportunities does this new data create?

## Paper Type

Dataset overview / data description paper. Not a causal inference study.

## Approach

1. Download and process the complete T-MSIS dataset (227M rows)
2. Link to NPPES for geographic and provider enrichment (99.5% match rate)
3. Produce descriptive statistics, visualizations, and maps
4. Map the linkage universe (30+ joinable external datasets)
5. Construct and describe four analysis panels for future research
6. Outline a five-theme research agenda

## Key Findings (Pre-Registered Expectations)

- Medicaid spending is dominated by HCBS-specific codes (T/H/S prefixes) invisible to Medicare data
- The provider panel is highly dynamic with substantial entry/exit
- Geographic variation is substantial across states
- The NPI linkage architecture enables dozens of research designs

## Data Sources

- T-MSIS Medicaid Provider Spending (HHS Open Data, Feb 2026)
- NPPES Bulk Extract (CMS)
- Census ACS 5-Year (for population denominators)
- Census TIGER/Line (for shapefiles)

## Note on Causal Methods Discussed

The paper's research agenda section discusses future DiD and other causal designs as potential applications of the dataset. These are proposed directions, not executed analyses. No treatment, exposure, or identification strategy is implemented in this paper. The affected population for future studies is described conceptually in the research agenda.

## Analysis

All analysis in R using data.table and Arrow for memory-efficient processing of 227M rows.
