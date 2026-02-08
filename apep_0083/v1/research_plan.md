# Research Plan

## Revision of APEP-0103: Geocoded Atlas of Western US Traffic Fatalities

### Research Question

Construct a comprehensive geocoded atlas of Western US traffic fatalities (2001-2019) that:
1. Integrates FARS crash data with OpenStreetMap road network attributes
2. Links marijuana legalization policy timing by state
3. Documents drug and alcohol testing patterns and results

### Identification Strategy

This is a **descriptive data paper**, not a causal study. The contribution is data infrastructure that enables future causal research using:
- Spatial RDD at state borders
- Staggered DiD around legalization dates
- Event study designs for pre/post analysis

### Revision Progress

#### Completed

1. **Fixed FARS data fetch:** Successfully downloaded all years 2001-2019
   - Total crashes: 139,601 (up from ~70,000)
   - Geocoding rate: 96%
   - All 19 years now present

2. **Merged policy data:** Added marijuana legalization timing
   - rec_effective_date, retail_open_date
   - Border distance calculations
   - Event time variables for event studies

3. **Regenerated all figures:**
   - National overview maps (Figures 1-9)
   - Zoom maps at borders (Figures 10-17)
   - Substance involvement figures (Figures 18-23)
   - Border analysis figures (Figures 24-29)

4. **Updated paper.tex:**
   - Revision footnote added
   - Abstract updated with new crash counts
   - Introduction rewritten for continuous coverage
   - Section 8.2 (DiD) rewritten to reflect capabilities
   - Table 2 panel ordering fixed

5. **Added literature references:**
   - Goodman-Bacon (2021) TWFE decomposition
   - Roth (2022) pre-trends testing
   - Calonico, Cattaneo, Titiunik (2014) robust RDD
   - de Chaisemartin & D'Haultfoeuille (2020)

6. **Generated all tables:**
   - Policy timeline (Table 1)
   - Summary statistics by state and year
   - THC rates before/after legalization
   - Border region comparisons

### Remaining Steps

1. Run external reviews (advisor, parallel 3, final)
2. Address any review feedback
3. Publish with revise_and_publish.py

### Key Metrics

| Metric | Parent (APEP-0103) | Revision |
|--------|-------------------|----------|
| Total crashes | ~70,000 | 139,601 |
| Year coverage | 2001-2005, 2016-2019 | 2001-2019 (continuous) |
| Geocoding rate | ~90% | 96% |
| Event study | Not possible | Enabled |
