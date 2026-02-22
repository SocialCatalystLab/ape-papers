## ============================================================================
## 06_tables.R — Generate all tables
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")
load("../data/cs_results.RData")
load("../data/robustness_results.RData")
load("../data/ri_results.RData")

tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel_2000 <- panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

## ============================================================================
## Table 1: Summary Statistics
## ============================================================================

cat("=== Table 1: Summary Statistics ===\n")

# Compute district-level means first (one row per district), then group means
dist_baseline <- panel_2000[year <= 1999, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(dist_id, treated, pop_2011, lit_rate_2011, ag_worker_share_2011,
          sc_share_2011, st_share_2011)]

# Group-level summary
group_stats <- dist_baseline[, .(
  mean_nl = mean(mean_nl, na.rm = TRUE),
  mean_log_nl = mean(mean_log_nl, na.rm = TRUE),
  mean_pop = mean(pop_2011, na.rm = TRUE),
  mean_lit = mean(lit_rate_2011, na.rm = TRUE),
  mean_ag = mean(ag_worker_share_2011, na.rm = TRUE),
  mean_sc = mean(sc_share_2011, na.rm = TRUE),
  mean_st = mean(st_share_2011, na.rm = TRUE),
  n_districts = .N
), by = .(treated)]

cat("Group statistics:\n")
print(group_stats)

# Balance t-tests (district level)
pvals <- numeric(7)
vars <- c("mean_nl", "mean_log_nl", "pop_2011", "lit_rate_2011",
          "ag_worker_share_2011", "sc_share_2011", "st_share_2011")
for (i in seq_along(vars)) {
  v <- vars[i]
  tt <- t.test(dist_baseline[[v]][dist_baseline$treated == 1],
               dist_baseline[[v]][dist_baseline$treated == 0])
  pvals[i] <- tt$p.value
}

# Write LaTeX table with EXPLICIT ordering
ns <- group_stats[treated == 1]
ps <- group_stats[treated == 0]

sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: New State vs Parent State Districts}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & New State & Parent State & $p$-value \\\\\n")
cat("\\hline\n")
cat(sprintf("Mean Nightlights & %.1f & %.1f & %.3f \\\\\n",
            ns$mean_nl, ps$mean_nl, pvals[1]))
cat(sprintf("Mean Log(NL+1) & %.3f & %.3f & %.3f \\\\\n",
            ns$mean_log_nl, ps$mean_log_nl, pvals[2]))
cat(sprintf("Population (2011, millions) & %.2f & %.2f & %.3f \\\\\n",
            ns$mean_pop / 1e6, ps$mean_pop / 1e6, pvals[3]))
cat(sprintf("Literacy Rate & %.3f & %.3f & %.3f \\\\\n",
            ns$mean_lit, ps$mean_lit, pvals[4]))
cat(sprintf("Ag. Worker Share & %.3f & %.3f & %.3f \\\\\n",
            ns$mean_ag, ps$mean_ag, pvals[5]))
cat(sprintf("SC Share & %.3f & %.3f & %.3f \\\\\n",
            ns$mean_sc, ps$mean_sc, pvals[6]))
cat(sprintf("ST Share & %.3f & %.3f & %.3f \\\\\n",
            ns$mean_st, ps$mean_st, pvals[7]))
cat("\\hline\n")
cat(sprintf("Districts & %d & %d & \\\\\n", ns$n_districts, ps$n_districts))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.9\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Pre-treatment means (1994--1999) for districts in newly created states (Uttarakhand, Jharkhand, Chhattisgarh) vs remaining districts in parent states (UP, Bihar, MP). Nightlights from DMSP calibrated luminosity. Population and sociodemographic characteristics from Census 2011. $p$-values from two-sample $t$-tests of equal means across districts.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved: summary statistics\n")

## ============================================================================
## Table 2: Main DiD Results
## ============================================================================

cat("\n=== Table 2: Main Results ===\n")

n_obs <- nrow(panel_2000)
n_dist <- uniqueN(panel_2000$dist_id)
n_clust <- uniqueN(panel_2000$cluster_state)
n_years <- uniqueN(panel_2000$year)
cat("Panel dimensions: ", n_dist, " districts x ", n_years, " years = ", n_obs, " obs\n")

# Extract CS-DiD ATT
cs_att_est <- cs_att$overall.att
cs_att_se <- cs_att$overall.se

# Helper to format stars
stars_fn <- function(b, s) {
  z <- abs(b / s)
  if (z > 2.576) return("***")
  if (z > 1.96) return("**")
  if (z > 1.645) return("*")
  return("")
}

# Write LaTeX table
sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of State Creation on Nightlight Intensity}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & TWFE & Pair$\\times$Year FE & Pop-Weighted & Levels \\\\\n")
cat("\\hline\n")
cat("\\addlinespace\n")

models_list <- list(twfe_basic, twfe_pair, weighted_fit, levels_fit)
# Coefficients row
cat("New State $\\times$ Post")
for (m in models_list) {
  b <- coef(m)["treat_post"]
  s <- se(m)["treat_post"]
  st <- stars_fn(b, s)
  if (abs(b) > 100) {
    cat(sprintf(" & %.1f%s", b, st))
  } else {
    cat(sprintf(" & %.4f%s", b, st))
  }
}
cat(" \\\\\n")

# SE row
cat(" ")
for (m in models_list) {
  s <- se(m)["treat_post"]
  if (s > 100) {
    cat(sprintf(" & (%.1f)", s))
  } else {
    cat(sprintf(" & (%.4f)", s))
  }
}
cat(" \\\\\n")

cat("\\addlinespace\n")
cat(sprintf("CS-DiD ATT & \\multicolumn{4}{c}{%.4f (%.4f)} \\\\\n",
            cs_att_est, cs_att_se))
cat("\\addlinespace\n")

if (!is.null(boot_result)) {
  cat(sprintf("Wild Bootstrap $p$ & %.3f & & & \\\\\n", boot_result$p_val))
}
cat(sprintf("RI $p$-value & %.3f & & & \\\\\n", ri_pvalue))

cat("\\addlinespace\n")
cat("\\hline\n")
cat("District FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Year FE & Yes & & Yes & Yes \\\\\n")
cat("Pair$\\times$Year FE & & Yes & & \\\\\n")
cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
            formatC(n_obs, big.mark = ","), formatC(n_obs, big.mark = ","),
            formatC(n_obs, big.mark = ","), formatC(n_obs, big.mark = ",")))
cat(sprintf("Districts & %d & %d & %d & %d \\\\\n", n_dist, n_dist, n_dist, n_dist))
cat(sprintf("State Clusters & %d & %d & %d & %d \\\\\n", n_clust, n_clust, n_clust, n_clust))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat(sprintf("\\footnotesize \\textit{Notes:} Dependent variable is log(nightlights + 1) in columns (1)--(3) and nightlight levels in column (4). Sample: districts in Uttarakhand, Jharkhand, Chhattisgarh and their parent states (UP, Bihar, MP), 1994--2013 (DMSP). %d districts $\\times$ %d years = %s observations. ``New State $\\times$ Post'' equals one for districts assigned to newly created states after 2000. Standard errors clustered at the state level in parentheses. CS-DiD reports the Callaway-Sant'Anna simple aggregate ATT using never-treated controls. Wild bootstrap uses Rademacher weights with 999 iterations. RI permutes treatment across all $\\binom{6}{3}=20$ state assignments. $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n",
    n_dist, n_years, formatC(n_obs, big.mark = ",")))
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 2 saved: main results\n")

## ============================================================================
## Table 3: Heterogeneity by State Pair
## ============================================================================

cat("\n=== Table 3: Heterogeneity ===\n")

# Re-estimate pair-specific regressions with district-level clustering
# (state-level clustering with only 2 clusters per pair is degenerate)
pair_results_dist <- list()
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- panel_2000[state_pair == pair]
  fit <- feols(log_nl ~ treat_post | did + year,
               data = sub, cluster = ~did)
  pair_results_dist[[pair]] <- fit
  cat(pair, ": coef =", round(coef(fit)["treat_post"], 4),
      ", se =", round(se(fit)["treat_post"], 4), "\n")
}

sink(file.path(tab_dir, "tab3_heterogeneity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneous Effects by State Pair}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & Uttarakhand & Jharkhand & Chhattisgarh \\\\\n")
cat(" & vs UP & vs Bihar & vs MP \\\\\n")
cat("\\hline\n")

# Coefficient row
cat("New State $\\times$ Post")
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  fit <- pair_results_dist[[pair]]
  b <- coef(fit)["treat_post"]
  s <- se(fit)["treat_post"]
  st <- stars_fn(b, s)
  cat(sprintf(" & %.4f%s", b, st))
}
cat(" \\\\\n")

# SE row
cat(" ")
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  fit <- pair_results_dist[[pair]]
  s <- se(fit)["treat_post"]
  cat(sprintf(" & (%.4f)", s))
}
cat(" \\\\\n")

cat("\\addlinespace\n")
cat("\\hline\n")

# Districts
cat("Districts")
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- panel_2000[state_pair == pair]
  cat(sprintf(" & %d", uniqueN(sub$dist_id)))
}
cat(" \\\\\n")

cat("New Capital & Dehradun & Ranchi & Raipur \\\\\n")

# Observations
cat("Observations")
for (pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- panel_2000[state_pair == pair]
  cat(sprintf(" & %s", formatC(nrow(sub), big.mark = ",")))
}
cat(" \\\\\n")

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Each column estimates the DiD effect separately for one state pair. DMSP nightlights, 1994--2013. Standard errors clustered at the district level (state-level clustering infeasible with 2 clusters per pair). $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 3 saved: heterogeneity\n")

## ============================================================================
## Table 4: Robustness Checks
## ============================================================================

cat("\n=== Table 4: Robustness ===\n")

# Re-estimate Telangana with district-level clustering
panel_tg <- panel_full[state_pair == "TG-AP" & year >= 2012]
panel_tg[, event_time := year - 2015L]
panel_tg[, tg_treat_post := new_state_2014 * fifelse(year >= 2015, 1L, 0L)]
panel_tg[, did_tg := as.integer(factor(dist_id))]

tg_fit_dist <- feols(log_nl ~ tg_treat_post | did_tg + year,
                      data = panel_tg, cluster = ~did_tg)
cat("Telangana (district-clustered):\n")
print(summary(tg_fit_dist))

# Compute observation counts for each specification
n_baseline <- nrow(panel_2000)
panel_placebo_tab <- panel_2000[year <= 2000]
n_placebo <- nrow(panel_placebo_tab)
panel_ext_tab <- panel_full[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]
n_ext <- nrow(panel_ext_tab)
n_weighted <- n_baseline  # same sample, different weights
n_tg <- nrow(panel_tg)

sink(file.path(tab_dir, "tab4_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat("Specification & Coefficient & SE & $N$ \\\\\n")
cat("\\hline\n")

# Helper to format robustness row with stars
rob_row <- function(label, b, s, n) {
  st <- stars_fn(b, s)
  cat(sprintf("%s & %.4f%s & (%.4f) & %s \\\\\n",
              label, b, st, s, formatC(n, big.mark = ",")))
}

rob_row("Baseline TWFE",
        coef(twfe_basic)["treat_post"], se(twfe_basic)["treat_post"], n_baseline)

rob_row("Placebo (1997)",
        coef(placebo_fit)["fake_treat_post"], se(placebo_fit)["fake_treat_post"], n_placebo)

rob_row("Extended (1994--2023)",
        coef(ext_fit)["treat_post"], se(ext_fit)["treat_post"], n_ext)

rob_row("Population-weighted",
        coef(weighted_fit)["treat_post"], se(weighted_fit)["treat_post"], n_weighted)

for (drop_pair in c("UK-UP", "JH-BR", "CG-MP")) {
  fit <- loo_results[[paste0("drop_", drop_pair)]]
  sub <- panel_2000[state_pair != drop_pair]
  rob_row(paste0("Drop ", drop_pair),
          coef(fit)["treat_post"], se(fit)["treat_post"], nrow(sub))
}

rob_row("Telangana (2014, VIIRS)",
        coef(tg_fit_dist)["tg_treat_post"], se(tg_fit_dist)["tg_treat_post"], n_tg)

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} All specifications include district and year fixed effects. ``Placebo (1997)'' assigns a fake treatment date of 1997 using only pre-treatment data (1994--2000). ``Extended'' uses calibrated DMSP+VIIRS panel through 2023. Leave-one-out drops one state pair at a time. Telangana uses VIIRS 2012--2023 with standard errors clustered at the district level (only 2 state clusters). Main specifications cluster at the state level (6 clusters). $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 4 saved: robustness\n")

cat("\n=== All tables generated ===\n")
