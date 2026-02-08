# Initial Research Plan

## Inherited from Parent (apep_0133)

This is a revision focused on storytelling, prose, and exhibits — not new econometrics.

## Research Question
Does sub-national climate policy experimentation generate political support for federal harmonization, or does it satisfy demand through thermostatic adjustment?

## Identification Strategy
Spatial regression discontinuity at internal Swiss canton borders, with same-language (German-German) borders as the primary specification to eliminate the Röstigraben confound.

## Expected Effects
- H1 (Positive feedback): Treated cantons vote higher on federal energy referendum
- H2 (Thermostatic): Treated cantons vote lower on federal energy referendum

## Primary Specification
Local linear RDD with triangular kernel, MSE-optimal bandwidth, comparing Gemeinden at German-German canton borders.

## Exposure Alignment
- **Who is treated:** Gemeinden in 5 cantons (AG, BE, BL, BS, GR) that adopted comprehensive MuKEn energy laws before May 2017
- **Primary estimand population:** Voters in treated-canton Gemeinden near canton borders (within MSE-optimal bandwidth ~3.2km)
- **Control population:** Voters in neighboring control-canton Gemeinden on the opposite side of the same border
- **Design:** Spatial RDD (cross-sectional) + Difference-in-Discontinuities (panel)

## Planned Robustness
- Pooled borders (all languages)
- Randomization inference (1,000 permutations)
- Difference-in-Discontinuities (panel of referendums)
- Wild cluster bootstrap (Webb weights)
- Donut RDD (excluding near-border Gemeinden)
- Bandwidth sensitivity
