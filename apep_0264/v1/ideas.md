# Research Ideas

## Idea 1: The Quiet Life Goes Macro: Anti-Takeover Laws and the Rise of Market Power

**Policy:** State Business Combination (BC) statutes adopted by ~33 states between 1985-2001. These laws raised barriers to hostile takeovers by imposing moratoriums on mergers between large shareholders and target firms. Treatment dates from Karpoff & Wittry (2018, JoF) corrected classifications. Key variation: New York (1985), Indiana (1986), Wisconsin/Minnesota/Washington (1987), Delaware (1988), through Oregon (1991) and later adopters.

**Outcome:** State-level business dynamism (establishment entry/exit rates from Census Business Dynamics Statistics), employment concentration (HHI from County Business Patterns by state-industry), and labor share of income (compensation/GDP from BEA Regional Accounts). All datasets cover 1977-2022+, providing 5-10+ pre-treatment periods for all adopters.

**Identification:** Callaway-Sant'Anna (2021) staggered DiD. Treatment = year state adopted BC statute. Never-treated and not-yet-treated states serve as controls. Event-study specification traces dynamic effects. Address endogeneity concerns from Karpoff-Wittry by: (1) dropping states where specific firm lobbying documented, (2) showing flat pre-trends, (3) randomization inference, (4) synthetic control for early adopters.

**Why it's novel:** Bertrand & Mullainathan (2003, JPE) showed anti-takeover protection induces "quiet life" (higher wages, lower productivity at firm level). Giroud & Mueller (2010, JFE) confirmed plant-level productivity effects. Atanassov (2013, JoF) found innovation declines. But NOBODY has connected these micro-level governance distortions to the macro-level rise of market power documented by De Loecker, Eeckhout & Unger (2020, QJE) and the declining labor share (Autor et al. 2020). This paper provides the first causal evidence linking corporate governance reforms to secular macro trends — potentially explaining part of the puzzle that has consumed macro for a decade.

**Theoretical contribution:** Simple Cournot model with endogenous entry and a "takeover discipline" parameter. When takeover threat declines: incumbents invest less in efficiency → markups rise → entry barriers increase → business dynamism falls → labor share declines. Calibrate model to pre/post to generate welfare counterfactuals.

**Feasibility check:** Confirmed. 33 treated states (well above 20). BDS data: 1978-2021, state level, free download. CBP data: 1986-present, state-industry, Census API confirmed working. BEA labor share data: 1977-present, FRED API confirmed. Adoption dates well-documented in Karpoff & Wittry (2018). Incorporation-vs-location concern addressed through focus on aggregate state-level outcomes (where protected firms are major employers) rather than firm-level matching.


## Idea 2: The Green Transition's Hidden Cost: Renewable Portfolio Standards and Manufacturing Reallocation

**Policy:** State Renewable Portfolio Standards (RPS) mandating minimum percentages of electricity from renewable sources, adopted by ~29 states plus DC between 1997-2015. Staggered implementation with varying stringency targets (10-50% by target year). Dates from NCSL and EIA.

**Outcome:** State-level employment shares by sector (manufacturing vs. services vs. green energy) from BLS QCEW, establishment entry/exit in manufacturing from BDS, state manufacturing GDP share from BEA, and electricity prices from EIA as a mechanism channel.

**Identification:** CS-DiD with RPS adoption as treatment. Both extensive margin (binary adoption) and intensive margin (interaction with mandate stringency). Controls for concurrent state policies, pre-existing industrial composition, regional trends.

**Why it's novel:** Curtis (NBER WP 30502) studies the electricity price channel — RPS raises prices ~2% → modest manufacturing declines. Curtis et al. (NBER WP 31539) study individual job transitions. But no paper has estimated the SECTORAL REALLOCATION effect at the state level: do workers move from manufacturing to green sectors, or do they simply lose manufacturing jobs without gaining green ones? This is the central question for climate policy evaluation.

**Feasibility check:** Confirmed. 29 treated states. BLS QCEW available 1990-present by state-industry. RPS dates documented by NCSL/EIA. Pre-treatment period adequate for most adopters (1997 earliest). Risk: effects may be economically small per Curtis.


## Idea 3: Automatic Stabilizers in Practice: State EITCs and Local Fiscal Multipliers

**Policy:** State-level Earned Income Tax Credits adopted by ~33 states plus DC, staggered 1986-2023. Most set as percentage of federal EITC (5-50%), creating both extensive margin (adoption) and intensive margin (generosity) variation.

**Outcome:** County-level consumption proxies (retail sales from Census, auto registrations from DMV records), employment from QCEW, and income from BEA personal income data. State-level GDP from BEA.

**Identification:** CS-DiD with state EITC adoption. Triple-difference: adoption × recession periods to estimate whether EITC acts as automatic stabilizer during downturns (fiscal multiplier during recessions vs. expansions).

**Why it's novel:** Massive micro literature on EITC labor supply effects. Some aggregate estimates (AEA conference paper finding 1.5% employment boost per $1000 EITC). But no rigorous DiD estimation of state EITC as automatic fiscal stabilizer with recession-specific multipliers. Connects to Blanchard-Perotti fiscal multiplier literature with a clean policy experiment.

**Feasibility check:** Confirmed. 33+ states adopted, dates documented by NCSL/ITEP. BEA and FRED data available. Risk: EITC is well-studied (crowded space), need to clearly differentiate the macro stabilizer angle.


## Idea 4: Data Privacy as Industrial Policy: State Breach Notification Laws and the Digital Economy

**Policy:** State data breach notification laws requiring firms to disclose security breaches to affected consumers. All 50 states adopted at staggered times, 2003 (California first, SB 1386 effective July 2003) through 2018 (Alabama and South Dakota last). Dates from NCSL.

**Outcome:** State-level information sector employment and GDP (BEA, BLS), technology establishment counts from CBP, new business formation in tech sectors from BDS, and possibly IT patent counts from USPTO.

**Identification:** CS-DiD with breach notification law adoption. Perfect stagger across all 50 states over 15 years provides exceptional statistical power. Never-treated states serve as controls for early adopters.

**Why it's novel:** Existing work studies firm-level responses (stock price crash risk, private debt costs, IT investment changes). No paper examines the AGGREGATE MACRO effects: did these laws redirect investment patterns, alter state-level technology sector growth, or affect the geography of the digital economy?

**Feasibility check:** Confirmed. All 50 states, perfect stagger. CBP and BEA data available by industry sector. Adoption dates well-documented (NCSL, IAPP). Risk: "information sector" is a noisy proxy for digital economy; effect may be diffuse across sectors.


## Idea 5: Does Monitoring Cure the Epidemic? Prescription Drug Monitoring Programs and Aggregate Labor Supply

**Policy:** Prescription Drug Monitoring Programs (PDMPs) mandating electronic monitoring of controlled substance prescriptions. ~49 states adopted staggered 1990s-2017. Key variation in "must-access" provisions requiring prescriber queries (subset of ~40 states, staggered 2012-2019).

**Outcome:** State-level labor force participation rate from CPS/BLS, employment-to-population ratio, disability applications from SSA, state GDP from BEA.

**Identification:** CS-DiD with PDMP adoption (or must-access provision adoption for more exogenous variation). Rich pre-period for most states. Missouri as the sole never-treated state provides an extreme comparison.

**Why it's novel:** Krueger (2017, BPEA) established the opioid-LFP correlation using cross-sectional evidence. Several micro papers study individual prescribing and employment. But no paper uses the staggered PDMP adoption as a DiD shock to estimate the AGGREGATE labor supply response — how much of the macro LFP decline was causally driven by opioids, and how much did PDMPs recover?

**Feasibility check:** Confirmed. ~49 states adopted PDMPs. BLS/CPS data excellent. PDMP dates documented by FSMB/NCBI. Risk: space is crowded (many opioid papers), and the macro angle may be seen as incremental over Krueger.
