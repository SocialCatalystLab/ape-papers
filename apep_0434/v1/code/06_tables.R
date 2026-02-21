## ============================================================
## 06_tables.R — Publication-ready LaTeX tables
## ============================================================

source("code/00_packages.R")

# Clean variable labels for all etable output
setFixest_dict(c(
  d_nonfarm_share = "$\\Delta$ Non-Farm Share",
  d_aglabor_share = "$\\Delta$ Ag. Labor Share",
  d_cultivator_share = "$\\Delta$ Cultivator Share",
  d_hh_ind_share = "$\\Delta$ HH Industry Share",
  d_wfpr = "$\\Delta$ WFPR",
  d_f_nonfarm_share = "$\\Delta$ Female Non-Farm Share",
  d_f_aglabor_share = "$\\Delta$ Female Ag. Labor Share",
  d_f_lit_rate = "$\\Delta$ Female Literacy Rate",
  d_log_pop = "$\\Delta$ Log Population",
  pc11_state_id = "State",
  dist_id = "District"
))

cat("=== Loading data and results ===\n")
census  <- readRDS("data/census_panel.rds")
results <- readRDS("data/main_results.rds")
rob     <- readRDS("data/robustness_results.rds")

tab_dir <- "tables"

# ============================================================
# Table 1: Summary Statistics
# ============================================================
cat("Table 1: Summary statistics...\n")

# Panel A: Village-level means by MGNREGA phase
sumstats <- census[, .(
  N = .N,
  # 2001 baseline
  pop_2001     = mean(pop_01, na.rm = TRUE),
  lit_rate_01  = mean(lit_rate_01, na.rm = TRUE),
  sc_st_01     = mean(sc_st_share_01, na.rm = TRUE),
  wfpr_01      = mean(wfpr_01, na.rm = TRUE),
  nf_01        = mean(nonfarm_share_01, na.rm = TRUE),
  al_01        = mean(aglabor_share_01, na.rm = TRUE),
  cl_01        = mean(cultivator_share_01, na.rm = TRUE),
  hh_01        = mean(hh_ind_share_01, na.rm = TRUE),
  # 2011 outcomes
  nf_11        = mean(nonfarm_share_11, na.rm = TRUE),
  al_11        = mean(aglabor_share_11, na.rm = TRUE),
  # Changes
  d_nf         = mean(d_nonfarm_share, na.rm = TRUE),
  d_al         = mean(d_aglabor_share, na.rm = TRUE),
  d_cl         = mean(d_cultivator_share, na.rm = TRUE),
  d_lit        = mean(d_lit_rate, na.rm = TRUE)
), by = .(Phase = nrega_phase)]

# Format for LaTeX
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by MGNREGA Phase}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & Phase I & Phase II & Phase III \\\\\n")
cat(" & (2006) & (2007) & (2008) \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel A: Baseline Characteristics (Census 2001)}} \\\\\n")
cat(sprintf("Villages & %s & %s & %s \\\\\n",
            format(sumstats[Phase == 1]$N, big.mark = ","),
            format(sumstats[Phase == 2]$N, big.mark = ","),
            format(sumstats[Phase == 3]$N, big.mark = ",")))
cat(sprintf("Population & %.0f & %.0f & %.0f \\\\\n",
            sumstats[Phase == 1]$pop_2001, sumstats[Phase == 2]$pop_2001,
            sumstats[Phase == 3]$pop_2001))
cat(sprintf("Literacy rate & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$lit_rate_01, sumstats[Phase == 2]$lit_rate_01,
            sumstats[Phase == 3]$lit_rate_01))
cat(sprintf("SC/ST share & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$sc_st_01, sumstats[Phase == 2]$sc_st_01,
            sumstats[Phase == 3]$sc_st_01))
cat(sprintf("Work force participation & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$wfpr_01, sumstats[Phase == 2]$wfpr_01,
            sumstats[Phase == 3]$wfpr_01))
cat(sprintf("Non-farm worker share & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$nf_01, sumstats[Phase == 2]$nf_01,
            sumstats[Phase == 3]$nf_01))
cat(sprintf("Ag. labor share & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$al_01, sumstats[Phase == 2]$al_01,
            sumstats[Phase == 3]$al_01))
cat(sprintf("Cultivator share & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$cl_01, sumstats[Phase == 2]$cl_01,
            sumstats[Phase == 3]$cl_01))
cat(sprintf("HH industry share & %.3f & %.3f & %.3f \\\\\n",
            sumstats[Phase == 1]$hh_01, sumstats[Phase == 2]$hh_01,
            sumstats[Phase == 3]$hh_01))
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: Changes (Census 2001 to 2011)}} \\\\\n")
cat(sprintf("$\\Delta$ Non-farm share & %.4f & %.4f & %.4f \\\\\n",
            sumstats[Phase == 1]$d_nf, sumstats[Phase == 2]$d_nf,
            sumstats[Phase == 3]$d_nf))
cat(sprintf("$\\Delta$ Ag. labor share & %.4f & %.4f & %.4f \\\\\n",
            sumstats[Phase == 1]$d_al, sumstats[Phase == 2]$d_al,
            sumstats[Phase == 3]$d_al))
cat(sprintf("$\\Delta$ Cultivator share & %.4f & %.4f & %.4f \\\\\n",
            sumstats[Phase == 1]$d_cl, sumstats[Phase == 2]$d_cl,
            sumstats[Phase == 3]$d_cl))
cat(sprintf("$\\Delta$ Literacy rate & %.4f & %.4f & %.4f \\\\\n",
            sumstats[Phase == 1]$d_lit, sumstats[Phase == 2]$d_lit,
            sumstats[Phase == 3]$d_lit))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Phase I districts received MGNREGA in February 2006 (200 most backward districts). Phase II districts received it in April 2007 (+130 districts). Phase III districts received it in April 2008 (all remaining). Worker shares are computed as the share of main workers in each occupational category out of total workers. All means are village-level, unweighted.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab1_summary.tex\n")

# ============================================================
# Table 2: Main Results — Census Long-Difference
# ============================================================
cat("Table 2: Main results...\n")

etable(results$m1_nf, results$m2_nf,
       results$m2_al, results$m2_cl,
       results$m2_hh, results$m2_wf,
       headers = c("Non-Farm", "Non-Farm", "Ag. Labor",
                    "Cultivator", "HH Ind.", "WFPR"),
       keep = c("%early_treat"),
       dict = c(early_treat = "Early MGNREGA (Phase I/II)"),
       se.below = TRUE,
       fitstat = c("n", "r2", "my"),
       title = "Effect of Early MGNREGA on Worker Composition (Census 2001--2011)",
       label = "tab:main",
       notes = c("All specifications include state fixed effects. Columns 2--6 include baseline (2001) controls: log population, literacy rate, SC/ST share, and lagged dependent variable. Standard errors clustered at the district level in parentheses. Dependent variables are long differences in village-level worker category shares between Census 2001 and 2011."),
       file = file.path(tab_dir, "tab2_main_results.tex"),
       replace = TRUE)
cat("  Saved tab2_main_results.tex\n")

# ============================================================
# Table 3: Robustness — Alternative Specifications
# ============================================================
cat("Table 3: Robustness...\n")

etable(results$m2_nf, rob$m_state_cl,
       rob$m_dose,
       rob$m_placebo_pop,
       headers = c("Baseline", "State Cluster", "Phase I/II Sep.",
                    "Placebo: Pop"),
       keep = c("%early_treat", "%phase1", "%phase2"),
       dict = c(early_treat = "Early MGNREGA",
                phase1 = "Phase I",
                phase2 = "Phase II"),
       se.below = TRUE,
       fitstat = c("n", "r2"),
       title = "Robustness Checks",
       label = "tab:robustness",
       notes = c("Column 1 reproduces baseline specification. Column 2 clusters SEs at state level. Column 3 separates Phase I and Phase II effects. Column 4 uses log population growth as a placebo outcome. All include state FE and baseline controls."),
       file = file.path(tab_dir, "tab3_robustness.tex"),
       replace = TRUE)
cat("  Saved tab3_robustness.tex\n")

# ============================================================
# Table 4a: Gender Heterogeneity
# ============================================================
cat("Table 4a: Gender heterogeneity...\n")

etable(results$m2_nf, rob$m_f_nf, rob$m_f_al,
       rob$m_f_lit,
       headers = c("All: NF", "Female: NF", "Female: AL",
                    "Female: Lit"),
       keep = c("%early_treat"),
       dict = c(early_treat = "Early MGNREGA"),
       se.below = TRUE,
       fitstat = c("n", "r2"),
       title = "Gender Heterogeneity in MGNREGA Effects",
       label = "tab:gender",
       notes = c("Column 1 reproduces baseline. Columns 2--4 use female-specific outcomes. All include state FE and baseline controls. SEs clustered at district level."),
       file = file.path(tab_dir, "tab4a_gender.tex"),
       replace = TRUE)

# ============================================================
# Table 4b: Caste Heterogeneity
# ============================================================
cat("Table 4b: Caste heterogeneity...\n")

etable(results$m2_nf, rob$m_caste,
       headers = c("Baseline", "Caste DDD"),
       keep = c("%early_treat", "%high_sc_st"),
       dict = c(early_treat = "Early MGNREGA",
                high_sc_st = "High SC/ST",
                "early_treat:high_sc_st" = "Early $\\times$ High SC/ST"),
       se.below = TRUE,
       fitstat = c("n", "r2"),
       title = "Caste Heterogeneity: SC/ST Interaction",
       label = "tab:caste",
       notes = c("Column 1 reproduces baseline. Column 2 interacts treatment with an indicator for above-median village-level SC/ST population share in Census 2001. Both include state FE and baseline controls. SEs clustered at district level."),
       file = file.path(tab_dir, "tab4b_caste.tex"),
       replace = TRUE)
cat("  Saved tab4_heterogeneity.tex\n")

cat("\nAll tables saved to tables/\n")
