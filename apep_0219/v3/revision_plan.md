# Revision Plan — apep_0219 v3

## Parent Paper
- **Paper ID:** apep_0219
- **Title:** The Distress Label Trap: Place-Based Aid and Economic Stagnation in Appalachia
- **Rating:** mu=20.2, sigma=1.65, conservative=15.2

## Changes Planned

### 1. New Title
Replace "The Distress Label Trap" with a more academic framing that conveys the RDD, the ARC setting, and the precise null without sensationalism.

### 2. Literature Woven into Introduction (AER Style)
Expand the introduction by ~2 pages with proper literature positioning:
- Big Push vs. Spatial Equilibrium debate (Kline & Moretti 2014, Glaeser & Gottlieb 2008, Busso et al. 2013)
- Why existing evidence is incomplete (most studies evaluate on/off treatments, not marginal thresholds)
- Dose-response and mechanism questions (Kang 2024, Chetty et al. 2016)
- Shorten Discussion Section 6.1 to avoid duplication

### 3. Strengthen Contribution Framing
- First causal RDD estimate at the ARC threshold (60-year gap)
- Resolves Big Push vs. marginal aid debate
- Policy design implications for all threshold-based federal programs
- First empirical test of distress label effects in place-based setting

### 4. Fix LaTeX Compilation
- Fix broken `\thanks{}` macro (line 71: extra `.}}`)
- Add missing references (Lee 2008, Neumark & Kolko 2010, Eggers et al. 2018)
- Full compilation sequence

### 5. First-Stage Proxy (Reviewer Priority #1)
Attempt USAspending.gov API for county-level ARC grant data FY2007-2017.

### 6. Additional Reviewer Fixes
- Tighten abstract with specific CI bounds
- Kill roadmap paragraphs at start of Sections 3 and 4
- Add vivid summary stat comparisons
- Strengthen conclusion
