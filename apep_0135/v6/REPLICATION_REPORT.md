# Replication Report

**Paper ID:** apep_0143
**Title:** Technological Obsolescence and Populist Voting: \\ Evidence from U.S. Metropolitan Areas\footnote{This paper is a revision of APEP-0141. See \url{https://github.com/SocialCatalystLab/auto-policy-evals/tree/main/papers/apep_0141
**Replication Date:** 2026-02-03
**Replicator:** Claude Code

---

## Summary

**Classification:** PARTIAL REPLICATION

**Overall Assessment:**
Scripts executed but some outputs not generated. Review execution log.

### Execution Summary

- **Total Scripts:** 9
- **Successful:** 9
- **Failed:** 0

---

## 1. Computing Environment

- **Platform:** macOS-15.6.1-arm64-arm-64bit-Mach-O
- **Processor:** arm
- **Python Version:** 3.14.2
- **R Version:** R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"

### R Packages
```
> 
>         pkgs <- c("fixest", "rdrobust", "did", "ggplot2", "modelsummary", "haven", "tidyverse")
>         installed <- installed.packages()
>         for (p in pkgs) {
+             if (p %in% rownames(installed)) {
+                 cat(sprintf("%s: %s
+ ", p, installed[p, "Version"]))
+             }
+         }
fixest: 0.13.2
rdrobust: 3.0.0
did: 2.3.0
ggplot2: 4.0.1
modelsummary: 2.5.0
haven: 2.5.5
tidyverse: 2.0.0
>         
>
```

---

## 2. Code Inventory

**R Scripts:** 9
**Python Scripts:** 0
**Main Script:** 00_fetch_data.R

| Script | Language |
|--------|----------|
| `00_fetch_data.R` | R |
| `00_packages.R` | R |
| `01_clean_data.R` | R |
| `01b_fetch_alternative_controls.R` | R |
| `02_main_analysis.R` | R |
| `03_robustness.R` | R |
| `04_alternative_explanations.R` | R |
| `04_figures.R` | R |
| `05_tables.R` | R |

---

## 3. Execution Results

| Script | Success | Duration | Exit Code |
|--------|---------|----------|-----------|
| `00_fetch_data.R` | Yes | 0.7s | 0 |
| `00_packages.R` | Yes | 1.7s | 0 |
| `01_clean_data.R` | Yes | 3.9s | 0 |
| `01b_fetch_alternative_controls.R` | Yes | 10.3s | 0 |
| `02_main_analysis.R` | Yes | 2.0s | 0 |
| `03_robustness.R` | Yes | 1.8s | 0 |
| `04_alternative_explanations.R` | Yes | 1.6s | 0 |
| `04_figures.R` | Yes | 5.9s | 0 |
| `05_tables.R` | Yes | 4.6s | 0 |

---

## 4. Figure Comparisons

| Figure | Original | Generated | Status |
|--------|----------|-----------|--------|
| `fig3_binscatter.pdf` | Yes | Yes | Visual inspection required |
| `fig9_event_study.pdf` | Yes | Yes | Visual inspection required |
| `fig10_2008_baseline.pdf` | Yes | Yes | Visual inspection required |
| `fig4_terciles.pdf` | Yes | Yes | Visual inspection required |
| `fig7_size_scatter.pdf` | Yes | **No** | NOT GENERATED |
| `fig2_scatter_tech_trump.pdf` | Yes | Yes | Visual inspection required |
| `fig1_tech_age_distribution.pdf` | Yes | Yes | Visual inspection required |
| `fig8_tech_vs_change_2008.pdf` | Yes | Yes | Visual inspection required |
| `fig7_maps.pdf` | Yes | Yes | Visual inspection required |
| `fig5_regional.pdf` | Yes | Yes | Visual inspection required |
| `fig6_gains_vs_levels.pdf` | Yes | Yes | Visual inspection required |

---

## 5. Classification

### Final Classification: PARTIAL REPLICATION

**Justification:**
Scripts executed but some outputs not generated. Review execution log.

---

## 6. Next Steps

1. Visually compare generated figures to published figures
2. Compare table values
3. Verify in-text numbers
4. Update classification to FULL if all match

---

## Appendix: File Locations

- **Execution Log:** `logs/execution.log`
- **Generated Figures:** `figures/`
- **Generated Tables:** `tables/`
- **Original Paper:** `/Users/dyanag/auto-policy-evals/papers/apep_0143/paper.pdf`
