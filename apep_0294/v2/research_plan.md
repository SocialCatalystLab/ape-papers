# Research Plan: T-MSIS Medicaid Provider Spending Dataset Overview

## Research Question

What does the Medicaid provider landscape look like when observed at the provider level for the first time? What research opportunities does this new data create?

## Paper Type

Dataset overview / data description paper. Not a causal inference study.

## Structure

1. **Introduction** — Motivate the data gap in Medicaid research
2. **The Dataset** — Schema, coverage, scope, limitations
3. **A Descriptive Portrait** — Service composition, growth, workforce dynamics, organizational structure, geographic variation, comparison with Medicare
4. **The Linkage Universe** — NPPES as the essential first link, three linkage channels (NPI, ZIP, TIN/EIN), noteworthy specific linkages
5. **Constructed Analysis Panels** — Four panels for future research (state×provider-type×month, cross-payer, firm-level market structure, provider lifecycle)
6. **Research Agenda** — Five themes (payment adequacy, cross-payer dynamics, market structure, workforce dynamics, COVID/ARPA/unwinding)
7. **Conclusion**
8. **Appendix** — Data dictionary, HCPCS reference, geographic enrichment, data quality assessment, linkage dataset access, additional figures

## Data Sources

- T-MSIS Medicaid Provider Spending: 227M rows, Jan 2018–Dec 2024
- NPPES Bulk Extract: 9.4M providers, 329 fields
- Census ACS 5-Year: State population denominators
- Census TIGER/Line: State shapefiles for choropleth maps

## Code Pipeline

- `00_packages.R` — Load libraries
- `01_fetch_data.R` — Download and convert raw data
- `02_clean_data.R` — Arrow-based processing, NPPES linkage, panel construction
- `03_main_analysis.R` — Summary statistics
- `04_robustness.R` — Data quality checks
- `05_figures.R` — 12 figures (time series, distributions, maps, compositions)
- `06_tables.R` — 6 tables (overview, HCPCS, categories, growth, panel, billing)

## Key Results

- 227M rows, 618K billing providers, $1.09T total spending
- 52% of spending through Medicaid-specific T/H/S codes
- 6% full-panel providers, 37% appear <12 months, median tenure 22 months
- 65% of rows through organizational billing (vs 31% self-billing)
- 99.5% NPPES match rate enabling geographic analysis
- Per-capita spending ranges from ~$540 to $9,100 across states
