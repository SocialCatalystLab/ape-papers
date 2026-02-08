# Research Ideas

## Idea 1: Technological Obsolescence and Populist Voting

**Policy:** U.S. Presidential Elections 2016, 2020, 2024 (Trump candidacies)

**Outcome:** Republican/Trump vote share at CBSA level, aggregated from county-level returns

**Data Sources:**
1. `modal_age.dta` - CBSA × year panel (2010-2023) with modal technology age (how old the typical technology is in each metropolitan area)
2. County-level presidential election results (2016, 2020, 2024) from MIT Election Lab/GitHub
3. NBER CBSA-county FIPS crosswalk (2020 version)

**Identification:**
- Cross-sectional variation: Do CBSAs with older technology have higher Trump vote shares?
- Panel variation: Do changes in technology age within CBSAs predict changes in voting?
- First-difference specification: Regress Δ(Trump share 2020-2016) on Δ(modal_age 2016-2020)

**Why it's novel:**
- Tests Acemoglu et al.'s "New Technologies and the Skill Premium" hypothesis in the political realm
- Links technology adoption patterns to populist voting - a mechanism distinct from trade exposure (Autor et al.) or immigration (Bursztyn et al.)
- Uses unique CBSA-level technology vintage data not previously applied to political outcomes

**Feasibility check:**
- ✓ Data confirmed: modal_age.dta has 917 CBSAs × 14 years (2010-2023)
- ✓ Election data confirmed: County-level results for 2016, 2020, 2024 (3,100+ counties)
- ✓ Crosswalk confirmed: NBER provides CBSA-county mapping
- ✓ Substantial variation: Modal age ranges from 6 to 80 years across CBSAs

**Potential mechanisms:**
1. Older technology → lower productivity → stagnant wages → economic anxiety → populist voting
2. Older technology → job displacement fears → anti-establishment sentiment
3. Older technology reflects regions "left behind" by technological change → resentment

**Robustness checks:**
- Control for China trade shock (Autor, Dorn, Hanson)
- Control for immigration share (Bursztyn et al.)
- Control for education levels, manufacturing share, population density
- Placebo: Effect on non-populist Republican primaries or Senate races
- Heterogeneity by urban/rural, manufacturing vs. service economies
