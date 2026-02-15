# Initial Research Plan — apep_0296

## Research Question

What does the geographic distribution of Medicaid provider supply look like within New York State when observed for the first time at the ZIP code level, and what does the extreme concentration of spending in personal care services reveal about the structure of the state's home- and community-based services market?

## Method

Descriptive spatial analysis. No causal claims. The paper maps the within-state geography of Medicaid provider supply using ZIP/ZCTA-level data, decomposes spending variation across regions and service types, and documents the organizational structure of NY's home care market.

## Core Empirical Facts to Document

1. **T1019 dominance**: A single procedure code (personal care aides) accounts for 51.5% of all NY Medicaid provider spending — 4.6x the national share.
2. **Spatial concentration**: Top 20 ZIPs = 45% of spending. Brooklyn neighborhoods and Queens dominate.
3. **NYC vs Upstate divide**: NYC = 54% of providers but 72% of spending. Service mix fundamentally different.
4. **Organizational concentration**: 29% of NPIs are organizations, but they control 97% of spending.
5. **Fiscal intermediary geography**: A few large billing organizations (e.g., ZIP 12110 Latham, ZIP 11232 Sunset Park) drive billions in concentrated spending.
6. **Behavioral health gap**: H-codes = 4% in NY vs 13.6% nationally.
7. **Provider dynamics**: 40.4% transient providers (<12 months), but <1% of spending.

## Key Exhibits Planned

### Maps (the visual centerpiece)
- **Figure 1**: ZCTA choropleth — total Medicaid spending per capita by ZCTA, full state
- **Figure 2**: ZCTA choropleth — provider count per 10,000 population by ZCTA
- **Figure 3**: NYC inset maps — T1019 spending concentration by ZCTA
- **Figure 4**: Upstate vs Downstate comparison panels

### Analytical Exhibits
- **Figure 5**: Lorenz curve — cumulative spending share by ZIP (Gini coefficient)
- **Figure 6**: Service mix comparison — NY vs National stacked bars
- **Figure 7**: Time series — monthly T1019 spending in NY (COVID, ARPA, unwinding)
- **Figure 8**: Provider entry/exit by region over time

### Tables
- **Table 1**: NY overview statistics (providers, spending, claims) vs national
- **Table 2**: Top 10 HCPCS codes in NY with spending, provider count, national comparison
- **Table 3**: County-level panel — spending, providers, per-capita, by service type
- **Table 4**: Market concentration (HHI by county for T1019)
- **Table 5**: NYC borough comparison — spending, providers, service mix

## Data Sources

1. **T-MSIS Medicaid Provider Spending** (already downloaded: `tmsis_full.parquet`, 4.1 GB)
2. **NPPES extract** (already downloaded: `nppes_extract.parquet`, 314 MB)
3. **Census ACS ZCTA demographics** (API: population, poverty, age by ZCTA)
4. **Census ZCTA shapefiles** (TIGER/Line download for mapping)
5. **Census ZCTA-to-county relationship file** (direct download)

## Key Caveats (from conditions.md)

1. ZIP/ZCTA geography reflects billing/practice address, not service delivery location
2. Large fiscal intermediaries create geographic concentrations at their office address
3. T-MSIS commingles FFS and managed care; no payer indicator
4. NY's behavioral health gap may reflect institutional routing, not actual spending differences
5. Managed care encounter valuations may not reflect actual provider payments

## Expected Contribution

First ZIP-level portrait of Medicaid provider supply for any state using newly released T-MSIS data. Documents the extraordinary dominance of personal care services in NY Medicaid — a fact invisible to researchers before February 2026. Provides a template for state-level analysis that other researchers can replicate. Raises policy-relevant questions about geographic access, market concentration, and the fiscal intermediary model.
