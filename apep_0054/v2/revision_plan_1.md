# Revision Plan for Paper 146

**Parent Paper:** apep_0054
**External Review Decisions:**
- GPT-5-mini: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: CONDITIONALLY ACCEPT

---

## Priority 1: Critical Issues (Must Address)

### 1.1 Cohort-Level ATT Breakdown (All 3 Reviewers)
**GPT:** "Provide ATT(g,t) tables and cohort weights... conduct leave-one-cohort/state-out results"
**Grok:** "Plot cohort-specific event studies... report whether any single cohort dominates the aggregate ATT"

**Action:** Add new subsection in Results with:
- Table showing ATT(g,t) by cohort (Colorado 2021, CT/NV 2022, CA/WA/RI 2023, NY/HI 2024)
- Cohort weights in aggregation
- Leave-one-state-out sensitivity (exclude CA, exclude NY, etc.)

**Files:** `04_main_analysis.R`, `paper.tex` (new Table 10)

### 1.2 Wild Cluster Bootstrap P-Values (GPT, Grok)
**GPT:** "Report wild cluster bootstrap p-values for all main estimates"
**Grok:** "Wild bootstrap mentioned (p. 20); [need to] include them in main tables"

**Action:** Add `fwildclusterboot` package, compute bootstrap p-values for:
- Main ATT (-0.012)
- Gender DDD interaction
- Heterogeneity estimates

**Files:** `04_main_analysis.R`, `05_robustness.R`, `paper.tex` (update tables)

### 1.3 Missing DiD Diagnostics References (All 3 Reviewers)
**GPT:** de Chaisemartin & D'Haultfoeuille (2020), Borusyak et al. (2022), Cameron et al. (2008)
**Grok:** de Chaisemartin & D'Haultfoeuille (2020), Card & Dahl (2011)
**Gemini:** Hernandez-Arenaz & Iriberri (2020), Mas & Pallais (2017)

**Action:** Add all suggested references to bibliography and cite appropriately

**Files:** `paper.tex` (bibliography and citations)

---

## Priority 2: Important Enhancements (Should Address)

### 2.1 Compliance/First-Stage Evidence (GPT)
**GPT:** "Provide stronger evidence on compliance (job-posting data)... Even a brief descriptive exercise would materially strengthen causal interpretation"

**Action:** Add paragraph in Limitations discussing ITT interpretation; note that without firm-level job posting data (Burning Glass/Lightcast), we cannot measure compliance directly. Frame results as ITT estimates.

**Files:** `paper.tex` (Discussion section)

### 2.2 Employment/Composition Margins (GPT)
**GPT:** "Report whether employment rates, participation, or unemployment rates changed in treated states post-adoption"

**Action:** Add robustness check with employment status as outcome (binary: employed = 1)

**Files:** `05_robustness.R`, `paper.tex` (add composition check paragraph)

### 2.3 Sample Size Clarity (GPT, Grok)
**GPT:** "Report unweighted N... number of treated states, number of never-treated states"
**Grok:** Already addressed but could strengthen

**Action:** Update all main tables to include:
- Unweighted N (person-years)
- Number of treated states in sample
- Number of never-treated states
- Effective weighted N

**Files:** `07_tables.R`, `paper.tex` (table notes)

### 2.4 Border-County Analysis Discussion (Gemini)
**Gemini:** "A border-county DiD... would be a 'gold standard' addition... clarification on why a border-county approach was or was not feasible"

**Action:** Add paragraph explaining CPS geographic limitations (state-level only, no county identifiers in public use) and why border-county analysis is infeasible

**Files:** `paper.tex` (Limitations section)

---

## Priority 3: Nice-to-Have Improvements

### 3.1 Occupation vs Industry Interaction (Gemini)
**Gemini:** "A more granular look at 'high-skill' vs 'low-skill' within industries"

**Action:** Already have education heterogeneity; add brief mention that occupation-industry interactions could be explored in future work

**Files:** `paper.tex` (Discussion)

### 3.2 Remote Work/Spillovers Robustness (GPT)
**GPT:** "Restrict to occupations unlikely to be remote"

**Action:** Add note in Limitations about remote work spillovers as conservative bias; CPS lacks telework variable for full sample period

**Files:** `paper.tex` (Limitations)

### 3.3 New-Hire vs Incumbent (GPT)
**GPT:** "Use CPS variables related to... tenure to approximate new hires"

**Action:** Add note that CPS lacks clean new-hire identifier; this is a limitation for future research with linked employer-employee data

**Files:** `paper.tex` (Limitations/Future Work)

---

## Implementation Order

1. **R Code Changes:**
   - Add cohort-specific ATT(g,t) calculation to `04_main_analysis.R`
   - Add wild cluster bootstrap to `04_main_analysis.R`
   - Add leave-one-state-out to `05_robustness.R`
   - Add employment composition check to `05_robustness.R`
   - Update `07_tables.R` for cleaner N reporting

2. **Paper Changes:**
   - Add missing references to bibliography
   - Add cohort-level ATT table (Table 10)
   - Update existing tables with bootstrap p-values
   - Add paragraph on border-county infeasibility
   - Add paragraph on ITT interpretation
   - Expand Limitations section for remote work, new-hire, compliance

3. **Final:**
   - Recompile PDF
   - Verify 25+ pages
   - Run final review

---

## Files Modified

| File | Changes |
|------|---------|
| `code/04_main_analysis.R` | Cohort ATT, wild bootstrap |
| `code/05_robustness.R` | Leave-one-out, employment check |
| `code/07_tables.R` | Sample size details |
| `paper.tex` | New table, references, expanded discussion |
