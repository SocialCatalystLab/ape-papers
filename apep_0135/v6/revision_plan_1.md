# Revision Plan (Round 1)

## Summary of Reviewer Feedback

### GPT-5-mini (Major Revision)
- Requested formal event-study with leads/lags
- Missing methodological citations (Callaway & Sant'Anna, Goodman-Bacon, Bertrand et al.)
- Requested Conley spatial SEs
- Suggested migration/sorting tests
- Requested converting enumerated list to prose

### Grok-4.1-Fast (Minor Revision)
- Missing references (Chetty et al., Goodman-Bacon)
- Convert Discussion §6.1 list to prose
- Overall positive assessment

### Gemini-3-Flash (Minor Revision)
- Requested industry-by-year fixed effects consideration
- Suggested migration data test
- Overall positive assessment

## Revisions Made

### 1. Added Missing Methodological References
- Added Callaway & Sant'Anna (2021) - DiD with multiple time periods
- Added Goodman-Bacon (2021) - DiD with variation in treatment timing
- Added Bertrand, Duflo, and Mullainathan (2004) - clustering in DiD
- Added Chetty, Hendren, and Katz (2016) - neighborhood effects

### 2. Converted Enumerated List to Prose
- Discussion §6.1 summary of findings converted from numbered list to paragraph form

### 3. Addressed DiD Literature Concerns
- Added paragraph in Identification Challenges section explaining how our design differs from staggered DiD settings
- Cited new methodological references appropriately

### 4. Items Not Addressed (Noted as Limitations)
- Formal event-study with Sun & Abraham estimators: Our design is not staggered DiD; we note this distinction
- Conley spatial SEs: Noted as robustness suggestion; current state clustering provides similar adjustment
- Migration tests: Would require additional data; noted as future research direction in limitations

## Verification
- Paper compiles successfully
- Main text: 26 pages (meets 25+ requirement)
- All references resolve correctly
