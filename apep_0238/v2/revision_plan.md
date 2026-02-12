# Revision Plan: apep_0238 v2

## Parent Paper
- **ID:** apep_0238
- **Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
- **Tournament Rating:** mu=25.5, sigma=2.14, Conservative=19.1 (#4 APEP)
- **Scan Verdict:** SUSPICIOUS (leave-one-out Bartik mismatch)
- **Replication:** FULL SUCCESS (7/7 scripts, 11/11 figures)

## Revision Objectives

### Workstream 1: Bibliography Expansion (PRIMARY)
Add ~13 missing citations that potential referees would notice and flag.

**Tier 1 — Must Add (likely referees):**
1. Pissarides (1992, QJE) "Loss of Skill During Unemployment" — THE theoretical paper on skill depreciation in search models. Our model's key mechanism.
2. Blanchard & Katz (1992, BPEA) "Regional Evolutions" — foundational regional labor market adjustment paper.
3. Beraja, Hurst & Ospina (2019, Econometrica) — uses cross-state GR variation (same ID strategy). Hurst is on our COVID cite.
4. Giroud & Mueller (2017, QJE) — firm leverage and GR employment, balance sheet channel.
5. Jarosch (2023, Econometrica) — searching for job security, scarring in search models.
6. Cerra, Fatas & Saxena (2023, JEL) — definitive hysteresis survey (updates Cerra & Saxena 2008 which we cite).

**Tier 2 — Should Add (field-defining):**
7. Blanchard & Summers (2018, NBER) — modern hysteresis restatement by the original authors.
8. Fatas & Summers (2018, JIE) — permanent effects of fiscal consolidation on output.
9. Barrero, Bloom & Davis (2020, BPEA) — COVID as reallocation shock (challenges pure supply framing).
10. Oreopoulos, von Wachter & Heisz (2012, AEJ:Applied) — graduation into recession scarring.
11. Jaimovich & Siu (2020, REStat) — jobless recoveries via routine job polarization.

**Tier 3 — Nice to Have:**
12. Dao, Furceri & Loungani (2017, REStat) — declining interstate labor mobility.
13. Schmieder & von Wachter (2016, Annual Review) — UI duration effects survey.

### Workstream 2: Code Integrity Fix
Fix the leave-one-out Bartik construction in `02_clean_data.py`:
- Current: uses `nat_ind` national totals directly
- Should: subtract state s's own contribution before computing industry shift
- Re-run full pipeline (01→08) to regenerate all results

### Workstream 3: Paper Text Updates
- Add revision footnote to title
- Weave new citations into text at ~15 locations
- Update any numbers that change from the Bartik fix (likely small)

## Execution Order
1. Fix code (02_clean_data.py leave-one-out)
2. Re-run data pipeline (01→08)
3. Add bib entries to references.bib
4. Edit paper.tex: add citations throughout + revision footnote
5. Recompile PDF
6. Visual QA
7. Review & publish

## Verification Criteria
- All 13 bib entries present and cited at least once
- Code scanner re-scan shows no METHODOLOGY_MISMATCH for Bartik
- Results quantitatively similar (leave-one-out correction is small with 50 states)
- All figures/tables regenerated from corrected code
- PDF compiles with no unresolved references
