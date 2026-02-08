source("code/00_packages.R")
panel <- readRDS("data/analysis_panel.rds")
main_results <- readRDS("data/main_results.rds")
robustness <- readRDS("data/robustness_results.rds")
twfe_basic <- main_results$twfe_basic
coef_val <- coef(twfe_basic)["treated"]

# 1. Standard cluster-robust
se_cr <- summary(twfe_basic, cluster = ~state_id)
se1 <- se_cr$coeftable["treated", "Std. Error"]
p1 <- se_cr$coeftable["treated", "Pr(>|t|)"]

# 2. CR2 (small-sample corrected)
se_cr2 <- summary(twfe_basic, cluster = ~state_id,
                   ssc = ssc(adj = TRUE, fixef.K = "full", cluster.adj = TRUE))
se2 <- se_cr2$coeftable["treated", "Std. Error"]
p2 <- se_cr2$coeftable["treated", "Pr(>|t|)"]

# 3. Wild bootstrap
wb_p <- if (!is.null(robustness$wild_bootstrap)) robustness$wild_bootstrap$p_val else NA

sink("tables/tableA3_inference.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Inference Robustness: Three SE Types for TWFE Treatment Effect}\n")
cat("\\label{tab:inference}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & SE & $p$-value & 95\\% CI \\\\\n")
cat("\\hline\n")
cat(sprintf("Cluster-robust & %.3f & %.3f & [%.3f, %.3f] \\\\\n",
            se1, p1, coef_val - 1.96*se1, coef_val + 1.96*se1))
cat(sprintf("CR2 (small-sample adj.) & %.3f & %.3f & [%.3f, %.3f] \\\\\n",
            se2, p2, coef_val - 1.96*se2, coef_val + 1.96*se2))
if (!is.na(wb_p)) {
  wb_ci <- robustness$wild_bootstrap$conf_int
  cat(sprintf("Wild cluster bootstrap & -- & %.3f & [%.3f, %.3f] \\\\\n",
              wb_p, wb_ci[1], wb_ci[2]))
} else {
  cat("Wild cluster bootstrap & -- & -- & -- \\\\\n")
}
cat("\\hline\n")
cat(sprintf("\\multicolumn{4}{l}{Point estimate: %.3f} \\\\\n", coef_val))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat(sprintf("\\item \\textit{Notes:} N = %d. Clusters = %d states.\n",
            nrow(panel), n_distinct(panel$state_fips)))
cat("\\item Wild bootstrap: fwildclusterboot unavailable for this R version.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Success: tableA3_inference.tex created\n")
