# Paper 49: Novel Angles for Women's Suffrage Research

**Date:** 2026-01-21
**Focus:** Gender outcomes with urban/rural heterogeneity
**Constraint:** Must not duplicate apep_0043 (female LFP, marital/age heterogeneity) or apep_0044 (children's education, gender heterogeneity)

---

## Angle 1: The Urban-Rural Suffrage Dividend (RECOMMENDED)

**Title:** *City Votes, Country Voices: Urban-Rural Heterogeneity in the Labor Market Effects of Women's Suffrage*

### Conceptual Hook

The political economy of suffrage operated through very different labor markets. Urban areas in 1880-1920 offered wage employment in manufacturing, clerical work, and services—markets where political advocacy for protective legislation, equal pay, and workplace safety could directly affect women's opportunities. Rural areas featured family farms where women's labor was often unpaid, informal, and embedded in household production. 

**Key prediction:** If suffrage enabled women to advocate for labor-friendly policies, effects should concentrate in urban areas where such policies could bite. If suffrage primarily shifted social norms about women's roles, effects might be equally strong (or even stronger) in rural areas where traditional gender norms were more entrenched.

### Literature Connection

- **Miller (2008)**: Suffrage → public health spending → child mortality. But did this spending differ by urban/rural context?
- **Lott & Kenny (1999)**: Suffrage → government size. Urban vs rural fiscal impacts unexplored.
- **Goldin (1990, 2006)**: Documents urban/rural differences in women's labor markets, but doesn't connect to suffrage.
- **Political economy models (Acemoglu & Robinson)**: Democratic expansion redistributes toward median voter. Urban vs rural median voter preferences differ.

### Empirical Strategy

- **Outcome:** Female labor force participation (LABFORCE)
- **Treatment:** State-level suffrage adoption (1893-1918)
- **Heterogeneity:** Triple-difference: Suffrage × Post × Urban
- **Sample:** Women ages 18-64, 1880-1920 censuses
- **Method:** Callaway-Sant'Anna with interaction terms, or fully stratified estimation

### Feasibility

- ✅ URBAN variable available in all census years
- ✅ Sufficient variation: urban rates range from 10% (rural states) to 60%+ (NY, MA)
- ✅ apep_0043 did NOT examine urban/rural heterogeneity (verified by reading paper)
- ✅ Pre-treatment periods: 2-3 censuses for states adopting 1910+
- ⚠️ Urban/rural classification may shift over time (need to account for this)

### What Would Be Surprising

- **Surprising finding 1:** Effects ONLY in rural areas → suggests norm change mechanism, not policy advocacy
- **Surprising finding 2:** Effects ONLY in urban areas → confirms policy channel but raises questions about suffrage's reach
- **Surprising finding 3:** Differential timing (urban effects immediate, rural effects delayed) → speaks to mechanisms

---

## Angle 2: Occupational Upgrading and the Urban Ladder

**Title:** *From Farm to Factory: Women's Suffrage and Occupational Mobility in Urban America*

### Conceptual Hook

Beyond labor force participation (extensive margin), suffrage might have affected what women did when they worked (intensive margin). Urban areas offered occupational ladders—clerical work, teaching, nursing—that were largely absent in rural areas. If suffrage enabled women to advocate for professional opportunities or reduced discrimination in urban occupations, we might see occupational upgrading concentrated in cities.

### Literature Connection

- **Goldin (1998)**: Documents the rise of "white-collar" women's work in early 20th century
- **Costa (2000)**: Structural transformation and women's labor
- **Acemoglu, Autor, Lyle (2004)**: WWII mobilization shifted women into higher-wage occupations. Did suffrage do the same?

### Empirical Strategy

- **Outcome:** OCC1950 coded to occupational prestige or skill tiers
- **Treatment:** State-level suffrage
- **Heterogeneity:** Urban × Suffrage effect on occupational composition
- **Sample:** Working women ages 18-64

### Feasibility

- ✅ OCC1950 available and harmonized across censuses
- ✅ Can construct skill/prestige indices from occupational data
- ⚠️ Occupational coding in early censuses may be noisy
- ⚠️ This is more complex than Angle 1—save for future paper?

---

## Angle 3: Migration to Opportunity

**Title:** *Voting with Their Feet: Did Suffrage Affect Women's Internal Migration to Cities?*

### Conceptual Hook

If suffrage improved urban labor markets for women more than rural ones, we might observe differential migration patterns—women moving from non-suffrage rural areas to suffrage urban areas. This tests a general equilibrium response to political empowerment.

### Literature Connection

- **Boustan (2010)**: Great Migration and labor market responses
- **Collins & Wanamaker (2014)**: Selection into migration

### Empirical Strategy

- **Outcome:** Migration indicator (MIGRATE variables or state-of-birth ≠ state-of-residence)
- **Treatment:** Suffrage in destination vs origin states
- **Heterogeneity:** Rural-to-urban vs urban-to-urban flows

### Feasibility

- ⚠️ Migration measurement in historical censuses is limited (only birthplace, not previous residence)
- ⚠️ HISTID linking could help but sample sizes for movers may be small
- ❌ This angle is more speculative—higher risk of insufficient power

---

## Recommendation

**Pursue Angle 1: Urban-Rural Heterogeneity in Female LFP**

**Rationale:**
1. Clean triple-difference design (Suffrage × Post × Urban)
2. Data is definitely available (URBAN coded in all censuses)
3. Clear theoretical predictions from political economy
4. Direct extension of apep_0043 without duplicating it
5. Speaks to mechanism (policy vs norms) in a testable way

**Reject Angle 2** for now—more complex, save for follow-up
**Reject Angle 3**—migration measurement too limited for this period

---

## Data Requirements

For Angle 1, we need:

**Variables from IPUMS:**
- HISTID (optional, for panel robustness)
- YEAR, STATEFIP
- SEX, AGE, RACE, MARST
- LABFORCE
- URBAN (key heterogeneity variable)
- OCC1950 (optional, for mechanism exploration)

**Census years:** 1880, 1900, 1910, 1920

**Sample:** Women ages 18-64 in suffrage states + control states

**States to include:**
- Treated: CO (1893), ID (1896), WA (1910), CA (1911), OR (1912), KS (1912), AZ (1912), MT (1914), NV (1914), NY (1917), MI (1918), OK (1918), SD (1918)
- Never-treated: All states that adopted only via 19th Amendment (1920)
- Exclude: WY (1869) and UT (1870) — no pre-treatment census data

**Estimated sample size:** 
- Full-count: ~50-80 million women across 4 censuses
- Sufficient for urban/rural stratification even in smaller states
