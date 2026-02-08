# Revision Plan - Round 2

## Review Feedback Summary

Phase 1: PASS (format requirements met)
Phase 2: Major Revision Required

### Critical Issues Identified

1. **Control group contamination** - Oklahoma (SQ 792, Oct 2018) and Colorado (~2019) had contemporaneous alcohol retail reforms
2. **Missing state fixed effects** - Main specification omits state FE with multiple control states
3. **Wild bootstrap not shown** - Paper claims wild bootstrap inference but doesn't report results
4. **Outcome levels implausible** - 1.3% beverage retail employment seems high for NAICS 4453
5. **2019 partial exposure** - Policy effective April 2019, but ACS covers full year

## Planned Changes

### 1. Address Control Group Contamination (Critical)

**Approach**: Rather than dismiss this concern, we will:
- Add explicit policy timing table (Table 3) documenting alcohol laws in each state
- Acknowledge Oklahoma and Colorado reforms in the text
- Re-estimate using ONLY Nebraska and Missouri as "clean" controls
- Present both specifications (4-state vs 2-state controls) for transparency
- Add synthetic control as robustness check

**New Analysis**:
- Create `analysis_v3.py` with state FE and restricted control group
- Two specifications: (A) All 4 controls, (B) NE+MO only

### 2. Add State Fixed Effects (Critical)

**Change specification from**:
```
Y_ist = α + β(KS × Post) + γ(Kansas) + δ(Post) + X'γ + Year_FE + ε
```

**To canonical two-way FE**:
```
Y_ist = α + β(KS × Post) + η_s + λ_t + X'γ + ε
```

Where η_s = state fixed effects absorb level differences across NE, MO, OK, CO.

### 3. Add Wild Cluster Bootstrap (Critical)

Using `wildboottest` package in Python or manual implementation:
- Report wild bootstrap p-values for main DiD coefficient
- Given 5 states (1 treated, 4 controls), use Webb 6-point distribution
- Add to Table 2 as separate row

### 4. Policy Timing Table (New Table 3)

| State | Pre-2019 Grocery Beer | Post-2019 Changes | Clean Control? |
|-------|----------------------|-------------------|----------------|
| Kansas | 3.2% only | Full-strength Apr 2019 | TREATED |
| Nebraska | Full-strength | None | YES |
| Missouri | Full-strength | None | YES |
| Oklahoma | 3.2% only | Full-strength Oct 2018 (SQ 792) | NO |
| Colorado | 3.2% only | Full-strength Jan 2019 | NO |

### 5. Validate Outcome Levels

- Cross-reference with BLS QCEW for NAICS 4453 (Beer, Wine, and Liquor Stores)
- Clarify denominator (all employed, all working-age, or labor force)
- Add footnote explaining ACS industry classification methodology

### 6. Address 2019 Partial Exposure

- Treat 2019 as "transition year" in robustness check
- Primary specification: 2019 as POST (intent-to-treat interpretation)
- Robustness: Exclude 2019, use 2021-2022 as clean post

### 7. Tone Down Causal Language

Change:
- "rare clean natural experiment" → "useful policy variation"
- "clean causal evidence" → "suggestive evidence consistent with causal interpretation"
- Add explicit discussion of identification assumptions and limitations

### 8. Add Missing Literature Citations

As recommended by reviewer:
- Bertrand, Duflo, Mullainathan (2004)
- Cameron and Miller (2015)
- MacKinnon and Webb (2017)
- Sun and Abraham (2021)
- Callaway and Sant'Anna (2021)
- Goodman-Bacon (2021)

## Implementation Order

1. Update analysis_v3.py with state FE + restricted controls
2. Run wild bootstrap inference
3. Create policy timing table
4. Revise paper.tex with all changes
5. Recompile and run Review 3

## Lock Status
Locked before making revisions.
