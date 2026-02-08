# Research Ideas

## Idea 1: Automation Exposure and Older Worker Labor Force Exit (SELECTED)

**Policy:** Occupational automation exposure as measured by Frey-Osborne probabilities and Autor-Dorn routine task intensity indices.

**Outcome:** Labor force exit (not in labor force indicator) among workers aged 55-70 using ACS PUMS data.

**Identification:** Doubly robust estimation (AIPW) under selection-on-observables assumption. Propensity score model predicts automation exposure based on demographics, education, industry. Outcome model estimates conditional exit probabilities. Bootstrap inference for standard errors.

**Why it's novel:** Prior automation literature focuses on aggregate employment effects or wages. This paper examines the extensive margin (labor force participation vs. exit) specifically for older workers approaching retirement, where institutional features (Medicare eligibility at 65, Social Security) create heterogeneous incentives.

**Feasibility check:**
- ACS PUMS provides detailed occupation codes mappable to automation scores
- Sample size sufficient (100K+ individuals in 10 largest states)
- Rich covariates available for propensity score model
- Clear outcome definition (ESR variable)

## Idea 2: Disability Insurance Applications and Automation Exposure

**Policy:** Same automation exposure measure.

**Outcome:** SSDI application/receipt rates.

**Identification:** Similar DR approach.

**Why it's novel:** Automation may push workers toward disability as an exit pathway.

**Feasibility check:** Would require linked administrative data not readily available.

## Idea 3: Early Retirement and Automation by Industry

**Policy:** Industry-level automation adoption (robot density).

**Outcome:** Early retirement rates by industry.

**Identification:** DiD exploiting variation in robot adoption timing across industries.

**Why it's novel:** Direct measure of automation adoption rather than exposure scores.

**Feasibility check:** Robot density data limited to manufacturing; would need BLS or IFR data.
