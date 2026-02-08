# Initial Research Plan — Paper 184

## Revision of apep_0128: Dutch Nitrogen Crisis and Housing Markets

### Research Question
How did the May 2019 Dutch Council of State nitrogen ruling affect housing supply and prices across municipalities with varying exposure to Natura 2000 protected areas?

### Identification Strategy
Sub-national difference-in-differences using continuous treatment (municipality N2000 area share) with municipality and year fixed effects. The nitrogen ruling is a sharp, unexpected regulatory shock whose practical impact varies geographically based on proximity to Natura 2000 sites.

### Primary Specification
log(Price_mt) = beta * (N2000Share_m * Post_t) + alpha_m + gamma_t + epsilon_mt

### Expected Effects
1. First stage: Building permits decline more in high-N2000 municipalities (supply constraint)
2. Housing prices: Direction ambiguous — supply restriction raises prices, but development freeze may reduce demand

### Planned Robustness
- Alternative treatment definitions (5km, 10km, 15km binary; inverse distance)
- Pre-COVID vs full sample
- Province-by-year fixed effects
- Heterogeneity by Randstad/non-Randstad
- Placebo treatment dates
- Augmented SCM national complement
- HonestDiD sensitivity analysis

### Data Sources
- CBS 83625ENG: Municipality housing prices (annual, 2012-2024)
- CBS 83671NED: Building permits (quarterly)
- EEA/PDOK: Natura 2000 + municipality GIS boundaries
- FRED/BIS: National HPI for 16 European countries (SCM complement)
