# Revision Plan: Address External Reviewer Feedback

**Paper:** paper_169 (revision of apep_0182)
**Status:** Advisor review PASSED (3/4), External reviews complete
**Current Phase:** Stage C - Revision Cycle COMPLETE

---

## External Review Summary

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| **GPT-5-mini** | MAJOR REVISION | Uncertainty propagation, covariance, cluster counts, welfare aggregation formalization |
| **Grok-4.1-Fast** | MINOR REVISION | Missing references, relies on published TEs, imputed formality |
| **Gemini-3-Flash** | MAJOR REVISION | WTP endogeneity, pecuniary vs real spillovers, MCPF justification |

---

## Changes Made

### 1. Missing Literature (All reviewers) ✓
Added citations:
- de Chaisemartin & D'Haultfoeuille (2020) - DiD heterogeneity
- Miguel & Kremer (2004) - Experimental spillovers (saturation design methodology)
- Stuart (2022) - MVPF heterogeneity/targeting
- Jensen (2022) - Employment structure and taxation
- Baird et al. (2016) - Long-run impacts of health investments

### 2. Inference & Uncertainty (GPT priority) ✓
- Added N and cluster counts to ALL subgroup tables (quintile, gender, formality)
- Expanded discussion of cross-outcome covariance assumption
- Added sensitivity analysis with correlated draws (ρ = 0.25, 0.50)

### 3. Welfare Aggregation (GPT/Gemini) ✓
- Formalized welfare weights discussion (equal weights, utilitarian)
- Explicit accounting showing no double-counting between spillover WTP and fiscal externalities
- Distinguished pecuniary vs. real spillovers with supporting evidence from Egger et al.

### 4. WTP Assumption (Gemini) ✓
- Added discussion of credit constraints and potential WTP > $1
- Explained why baseline maintains WTP = $1 (standard, conservative)
- Noted baseline should be interpreted as lower bound

### 5. MCPF Justification (Gemini) ✓
- Expanded justification for 1.3 baseline
- Discussed Kenya-specific considerations (VAT reliance, informal sector burden)
- Referenced Besley & Persson on fiscal capacity

---

## Verification

- [x] All requested citations added to bibliography (6 new references)
- [x] Tables include N and cluster counts (3 tables updated)
- [x] Welfare aggregation formally addressed in text
- [x] Covariance sensitivity analysis added
- [x] MCPF justification expanded
- [x] Paper compiles successfully (45 pages)

---

## Next Steps

1. Run fresh advisor review
2. Run fresh external reviews
3. Publish with `--parent apep_0182`
