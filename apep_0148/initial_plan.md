# Initial Plan (Revision of APEP-0146)

## Research Question

What are the causal effects of state salary transparency laws—requiring employers to disclose salary ranges in job postings—on wage levels and the gender wage gap?

## Identification Strategy

**Design:** Staggered difference-in-differences

**Treatment:** State-level adoption of salary transparency laws requiring salary range disclosure in job postings

**Treated units:** Workers in 8 states with transparency laws (CO, CT, NV, RI, CA, WA, NY, HI)

**Control units:** Workers in 43 states without transparency laws (as of 2024)

**Estimator:** Callaway-Sant'Anna heterogeneity-robust estimator with never-treated controls

**Key assumption:** Parallel trends in wages between treated and control states absent treatment

## Exposure Alignment

**Who is treated?** All wage/salary workers ages 25-64 residing in states with active transparency laws. The affected population includes both job seekers (who see posted ranges) and incumbents (who can compare their wages to market rates).

**Treatment-eligible population:** Workers in the 8 treated states represent ~35% of the sample by weighted observations.

**Design:** Standard DiD for average wage effects; Triple-diff (DDD) for gender-specific effects using Female × Treated × Post interaction.

## Expected Effects

Following Cullen & Pakzad-Hurson (2023):
- **Average wages:** Decline of 1-3% due to employer commitment mechanism
- **Gender gap:** Narrowing of 0.5-2 pp due to information equalization
- **Heterogeneity:** Larger effects in high-bargaining occupations

## Revision Focus

This revision addresses:
1. **Code integrity issues:**
   - Fix Table 1 state counts (`statefip > 0` should be `first_treat > 0`)
   - Fix border state definitions (14 hard-coded states should be 8 from policy data)
2. **Sharper economic contribution:** Emphasize equity-efficiency trade-off
3. **Tighter prose:** Streamline institutional background and discussion

## Planned Robustness Checks

Inherited from parent:
- Sun-Abraham estimator
- Gardner two-stage (did2s)
- Not-yet-treated controls
- Excluding border states
- Full-time workers only
- Education subsample splits
- Placebo tests
- HonestDiD sensitivity analysis
