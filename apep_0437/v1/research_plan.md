# Initial Research Plan: Multi-Level Political Alignment and Local Development in India's Federal System

## Research Question

Does political alignment between local legislators and higher levels of government cause faster local economic development? Specifically, in India's federal system, do constituencies whose MLA belongs to a party that also controls (a) the state government, (b) the central government, or (c) both experience greater nighttime light growth — and how do these effects evolve over the 5-year election cycle?

## Identification Strategy

**Close-election regression discontinuity design (Lee 2008; Asher & Novosad 2017).**

In state assembly elections where the ruling party (state or central) candidate and the leading opposition candidate are the top-two finishers, the vote margin serves as the running variable. The identifying assumption: in close races, whether the aligned or unaligned candidate wins is essentially random, conditional on covariates smooth through the threshold.

**Multi-level treatment structure:**
- *State-aligned:* MLA party = state Chief Minister's party
- *Center-aligned:* MLA party = national PM's party (BJP since 2014, UPA before)
- *Doubly aligned:* MLA party = both state CM's AND central PM's party
- *Unaligned:* MLA party = neither

**Primary specification:**
Y_{it} = α + τ × Aligned_i + f(margin_i) + γ_s + δ_t + ε_{it}

where i = constituency, t = year post-election, f(·) = local polynomial in vote margin, γ_s = state FE, δ_t = year FE. Bandwidth selected via Calonico, Cattaneo & Titiunik (2014) MSE-optimal procedure.

**Dynamic specification (year-by-year):**
Y_{it} = α + Σ_{τ=-2}^{4} β_τ × Aligned_i × 1[t = election_year + τ] + f(margin_i) + γ_s + δ_t + ε_{it}

## Expected Effects and Mechanisms

1. **Alignment → fiscal transfers:** Aligned constituencies receive more discretionary state/central spending (Brollo & Nannicini 2012 for Brazil; Asher & Novosad 2017 for India)
2. **Double alignment amplification:** Constituencies aligned at both levels may benefit from coordinated fiscal federalism — both state and central schemes flowing to the same area
3. **Dynamic pattern:** Effects may concentrate in years 1–3 (investment phase) and fade in years 4–5 (pre-election uncertainty)
4. **Heterogeneity by state fiscal capacity:** Alignment effects should be larger in richer states with more discretionary budgets

**Expected magnitudes:** Asher & Novosad (2017) found ~3–4% nightlight growth from single-level alignment. We expect similar or larger effects from double alignment, with the center-alignment component being potentially stronger in the post-2014 era when BJP's parliamentary majority enabled unprecedented center-state fiscal levers.

## Primary Specification Details

- **Unit of analysis:** Assembly Constituency (AC) mapped to 2007 Delimitation boundaries
- **Running variable:** Vote margin between aligned and non-aligned candidate (top two finishers)
- **Outcome:** Log VIIRS nightlights (annual mean luminosity at AC level, 2012–2023)
- **Bandwidth:** Calonico-Cattaneo-Titiunik (2014) MSE-optimal; sensitivity analysis from 2% to 15%
- **Polynomial:** Local linear (p=1) as primary; local quadratic (p=2) as robustness
- **Kernel:** Triangular (primary), uniform and Epanechnikov (robustness)
- **Inference:** Robust bias-corrected CI (Calonico, Cattaneo, Farrell 2020)
- **Clustering:** State-level clustering for standard errors

## Planned Robustness Checks

1. **McCrary density test** at the zero-margin threshold (no manipulation of elections)
2. **Covariate balance:** Pre-election nightlights, baseline Census demographics smooth through the cutoff
3. **Donut RDD:** Drop elections decided by < 1% margin (ultra-close races where fraud risk is highest)
4. **Bandwidth sensitivity:** Plot treatment effect across bandwidths from 2% to 15%
5. **Placebo outcomes:** Pre-election nightlights should show no discontinuity at the cutoff
6. **Alternative polynomials:** Linear, quadratic, cubic local polynomials
7. **Permutation test:** Randomization inference (RI) by permuting treatment labels 1,000 times
8. **Exclude reserved constituencies:** SC/ST reserved constituencies may have different political dynamics
9. **Separate pre-2014 vs post-2014:** Test whether Modi era changed the alignment premium

## Data Sources

| Data | Source | Coverage | Access |
|------|--------|----------|--------|
| State election results | Harvard Dataverse (doi:10.7910/DVN/26526) + TCPD LokDhaba | 1977–2023, candidate-level | Free download |
| AC nightlights (VIIRS) | SHRUG (viirs_annual_con07.csv) | 4,080 ACs, 2012–2023 | Local (downloaded) |
| AC nightlights (DMSP) | SHRUG (dmsp_con07.csv) | 4,080 ACs, 1992–2013 | Local (downloaded) |
| Census 2011 demographics | SHRUG (pc11_pca_clean_con07.csv) | ~3,455 ACs | Local (downloaded) |
| Census 2011 amenities | SHRUG (pc11_td_clean_con07.csv) | ~2,888 ACs | Local (downloaded) |
| State ruling parties | Public records (ECI, news archives) | All states, all elections | Constructible |
| Central ruling party | Public record | BJP (2014–), UPA (2004–2014), NDA (1998–2004) | Known |

## Power Assessment

- **Total ACs:** ~4,080
- **Elections per AC (2012–2023):** ~2–3 (one per state election cycle)
- **Total constituency-elections:** ~10,000–12,000
- **Close races (within 10% margin):** ~2,000–4,000
- **Post-election VIIRS years:** ~3–5 per election
- **Expected effect size:** 3–5% nightlight growth (Asher & Novosad baseline)
- **Statistical power:** With 2,000+ close races and annual outcomes, well-powered to detect effects of 2–3% or larger
