## =============================================================================
## 06_tables.R — All Table Generation
## APEP-0369: Click to Prescribe
## =============================================================================

source("00_packages.R")

cat("=== Generating tables ===\n")

panel <- readRDS("../data/analysis_panel.rds")

## ---------------------------------------------------------------------------
## Table 1: Summary Statistics
## ---------------------------------------------------------------------------

cat("Table 1: Summary statistics...\n")

# Separate treated and control
treated_panel <- panel %>% filter(epcs_mandate_year > 0)
control_panel <- panel %>% filter(epcs_mandate_year == 0)

make_summary <- function(df, label) {
  df %>%
    summarise(
      Group = label,
      N = n(),
      States = n_distinct(state_abbr),
      `Rx Opioid Deaths/100K` = sprintf("%.2f (%.2f)", mean(rx_opioid_death_rate, na.rm = TRUE),
                                         sd(rx_opioid_death_rate, na.rm = TRUE)),
      `Synth Opioid Deaths/100K` = sprintf("%.2f (%.2f)", mean(synth_opioid_death_rate, na.rm = TRUE),
                                            sd(synth_opioid_death_rate, na.rm = TRUE)),
      `All Opioid Deaths/100K` = sprintf("%.2f (%.2f)", mean(all_opioid_death_rate, na.rm = TRUE),
                                          sd(all_opioid_death_rate, na.rm = TRUE)),
      `Total OD Deaths/100K` = sprintf("%.2f (%.2f)", mean(total_od_death_rate, na.rm = TRUE),
                                        sd(total_od_death_rate, na.rm = TRUE)),
      `Population (millions)` = sprintf("%.2f", mean(population, na.rm = TRUE) / 1e6)
    )
}

summary_stats <- bind_rows(
  make_summary(panel, "Full Sample"),
  make_summary(treated_panel, "EPCS States"),
  make_summary(control_panel, "Non-EPCS States")
)

# LaTeX output
sink("../tables/tab1_summary_stats.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{1}{c}{N} & \\multicolumn{1}{c}{Rx Opioid} & \\multicolumn{1}{c}{Synth Opioid} & \\multicolumn{1}{c}{All Opioid} & \\multicolumn{1}{c}{Total OD} \\\\\n")
cat(" & \\multicolumn{1}{c}{(State-Yrs)} & \\multicolumn{1}{c}{Deaths/100K} & \\multicolumn{1}{c}{Deaths/100K} & \\multicolumn{1}{c}{Deaths/100K} & \\multicolumn{1}{c}{Deaths/100K} \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(summary_stats)) {
  row <- summary_stats[i, ]
  cat(sprintf("%s & %d & %s & %s & %s & %s \\\\\n",
              row$Group, row$N,
              row$`Rx Opioid Deaths/100K`,
              row$`Synth Opioid Deaths/100K`,
              row$`All Opioid Deaths/100K`,
              row$`Total OD Deaths/100K`))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Means with standard deviations in parentheses. Sample period: 2015--2023. ")
cat("EPCS States enacted electronic prescribing mandates for controlled substances between 2011 and 2024. ")
cat("Death rates are per 100,000 state population. ")
cat("Rx Opioid = natural \\& semi-synthetic opioids (ICD-10 T40.2); ")
cat("Synth Opioid = synthetic opioids excl.~methadone (T40.4); ")
cat("All Opioid = T40.0--T40.4, T40.6; Total OD = all drug overdose deaths.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## ---------------------------------------------------------------------------
## Table 2: Main Results
## ---------------------------------------------------------------------------

cat("Table 2: Main results...\n")

results <- readRDS("../data/results_summary.rds")
cs_rx <- readRDS("../data/cs_rx_results.rds")
cs_synth <- readRDS("../data/cs_synth_results.rds")
cs_all <- readRDS("../data/cs_all_results.rds")
cs_total <- readRDS("../data/cs_total_results.rds")
twfe_results <- readRDS("../data/twfe_results.rds")
sa_results <- readRDS("../data/sunab_results.rds")

# Get CS aggregates
agg_rx <- aggte(cs_rx, type = "simple")
agg_synth <- aggte(cs_synth, type = "simple")
agg_all <- aggte(cs_all, type = "simple")
agg_total <- aggte(cs_total, type = "simple")

# CS data for counts
cs_data <- panel %>%
  filter(!is.na(rx_opioid_death_rate), !is.na(population)) %>%
  mutate(gname = epcs_mandate_year)

n_obs <- nrow(cs_data)
n_states <- n_distinct(cs_data$state_id)
n_treated <- n_distinct(cs_data$state_id[cs_data$gname > 0])

sink("../tables/tab2_main_results.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of EPCS Mandates on Opioid Overdose Deaths}\n")
cat("\\label{tab:main_results}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{1}{c}{Rx Opioid} & \\multicolumn{1}{c}{Synth Opioid} & \\multicolumn{1}{c}{All Opioid} & \\multicolumn{1}{c}{Total OD} \\\\\n")
cat(" & \\multicolumn{1}{c}{(T40.2)} & \\multicolumn{1}{c}{(T40.4)} & \\multicolumn{1}{c}{(All)} & \\multicolumn{1}{c}{Deaths} \\\\\n")
cat(" & \\multicolumn{1}{c}{(1)} & \\multicolumn{1}{c}{(2)} & \\multicolumn{1}{c}{(3)} & \\multicolumn{1}{c}{(4)} \\\\\n")
cat("\\midrule\n")

# Panel A: Callaway-Sant'Anna
cat("\\multicolumn{5}{l}{\\textit{Panel A: Callaway-Sant'Anna}} \\\\\n")
cat("\\addlinespace\n")

pval_fn <- function(att, se) 2 * pnorm(-abs(att/se))
stars_fn <- function(p) ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))

for (agg in list(agg_rx, agg_synth, agg_all, agg_total)) {
  p <- pval_fn(agg$overall.att, agg$overall.se)
  s <- stars_fn(p)
}

cat(sprintf("EPCS Mandate & %.3f%s & %.3f%s & %.3f%s & %.3f%s \\\\\n",
            agg_rx$overall.att, stars_fn(pval_fn(agg_rx$overall.att, agg_rx$overall.se)),
            agg_synth$overall.att, stars_fn(pval_fn(agg_synth$overall.att, agg_synth$overall.se)),
            agg_all$overall.att, stars_fn(pval_fn(agg_all$overall.att, agg_all$overall.se)),
            agg_total$overall.att, stars_fn(pval_fn(agg_total$overall.att, agg_total$overall.se))))

cat(sprintf(" & (%.3f) & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            agg_rx$overall.se, agg_synth$overall.se,
            agg_all$overall.se, agg_total$overall.se))

ci_str <- function(att, se) sprintf("[%.3f, %.3f]", att - 1.96*se, att + 1.96*se)
cat(sprintf(" & %s & %s & %s & %s \\\\\n",
            ci_str(agg_rx$overall.att, agg_rx$overall.se),
            ci_str(agg_synth$overall.att, agg_synth$overall.se),
            ci_str(agg_all$overall.att, agg_all$overall.se),
            ci_str(agg_total$overall.att, agg_total$overall.se)))

cat("\\addlinespace\n")

# Panel B: TWFE
cat("\\multicolumn{5}{l}{\\textit{Panel B: Two-Way Fixed Effects}} \\\\\n")
cat("\\addlinespace\n")

twfe_rx_coef <- coef(twfe_results$twfe_rx)["epcs_treated"]
twfe_rx_se <- se(twfe_results$twfe_rx)["epcs_treated"]
twfe_synth_coef <- coef(twfe_results$twfe_synth)["epcs_treated"]
twfe_synth_se <- se(twfe_results$twfe_synth)["epcs_treated"]

p_twfe_rx <- pval_fn(twfe_rx_coef, twfe_rx_se)
p_twfe_synth <- pval_fn(twfe_synth_coef, twfe_synth_se)

cat(sprintf("EPCS Mandate & %.3f%s & %.3f%s & & \\\\\n",
            twfe_rx_coef, stars_fn(p_twfe_rx),
            twfe_synth_coef, stars_fn(p_twfe_synth)))
cat(sprintf(" & (%.3f) & (%.3f) & & \\\\\n",
            twfe_rx_se, twfe_synth_se))

cat("\\addlinespace\n")

# Panel C: Sun-Abraham
cat("\\multicolumn{5}{l}{\\textit{Panel C: Sun-Abraham}} \\\\\n")
cat("\\addlinespace\n")

# Recreate Sun-Abraham estimates from panel data
cs_data_sa <- panel %>%
  filter(!is.na(rx_opioid_death_rate), !is.na(population)) %>%
  mutate(gname = epcs_mandate_year,
         cohort = ifelse(gname == 0, Inf, gname))

sa_rx_refit <- feols(
  rx_opioid_death_rate ~ sunab(cohort, year) | state_id + year,
  data = cs_data_sa,
  cluster = ~state_id
)
sa_synth_refit <- feols(
  synth_opioid_death_rate ~ sunab(cohort, year) | state_id + year,
  data = cs_data_sa,
  cluster = ~state_id
)

sa_rx_summ <- summary(sa_rx_refit, agg = "ATT")
sa_synth_summ <- summary(sa_synth_refit, agg = "ATT")

sa_rx_att <- sa_rx_summ$coeftable[1, 1]
sa_rx_se_val <- sa_rx_summ$coeftable[1, 2]
sa_synth_att <- sa_synth_summ$coeftable[1, 1]
sa_synth_se_val <- sa_synth_summ$coeftable[1, 2]

p_sa_rx <- pval_fn(sa_rx_att, sa_rx_se_val)
p_sa_synth <- pval_fn(sa_synth_att, sa_synth_se_val)

cat(sprintf("EPCS Mandate & %.3f%s & %.3f%s & & \\\\\n",
            sa_rx_att, stars_fn(p_sa_rx),
            sa_synth_att, stars_fn(p_sa_synth)))
cat(sprintf(" & (%.3f) & (%.3f) & & \\\\\n",
            sa_rx_se_val, sa_synth_se_val))

cat("\\midrule\n")
cat(sprintf("Observations & %d & %d & %d & %d \\\\\n", n_obs, n_obs, n_obs, n_obs))
cat(sprintf("States & %d & %d & %d & %d \\\\\n", n_states, n_states, n_states, n_states))
cat(sprintf("Treated States & %d & %d & %d & %d \\\\\n", n_treated, n_treated, n_treated, n_treated))
cat("Estimator & CS & CS & CS & CS \\\\\n")
cat("Control Group & Never & Never & Never & Never \\\\\n")
cat("Clustering & State & State & State & State \\\\\n")

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Standard errors clustered at the state level in parentheses; 95\\% confidence intervals in brackets (Panel A). ")
cat("$^{***}$~$p<0.01$, $^{**}$~$p<0.05$, $^{*}$~$p<0.1$. ")
cat("Panel A uses the Callaway and Sant'Anna (2021) doubly robust estimator with never-treated controls and 1-year anticipation. ")
cat("Panel B reports standard two-way fixed effects. ")
cat("Panel C uses the Sun and Abraham (2021) interaction-weighted estimator. ")
cat("Columns (1)--(2) test EPCS mandates against treatment (T40.2) and placebo (T40.4) outcomes.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## ---------------------------------------------------------------------------
## Table 3: Robustness
## ---------------------------------------------------------------------------

cat("Table 3: Robustness...\n")

robustness <- readRDS("../data/robustness_summary.rds")

# Load additional results
nyt <- readRDS("../data/robustness_nyt.rds")
ant0 <- readRDS("../data/robustness_ant0.rds")
ant2 <- readRDS("../data/robustness_ant2.rds")
log_result <- readRDS("../data/robustness_log.rds")

sink("../tables/tab3_robustness.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness of EPCS Mandate Effects on Prescription Opioid Deaths}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Specification & ATT & SE & $p$-value & 95\\% CI \\\\\n")
cat("\\midrule\n")

# Helper function
print_row <- function(label, att, se) {
  p <- pval_fn(att, se)
  cat(sprintf("%s & %.3f%s & (%.3f) & %.3f & [%.3f, %.3f] \\\\\n",
              label, att, stars_fn(p), se, p, att - 1.96*se, att + 1.96*se))
}

agg_rx <- aggte(readRDS("../data/cs_rx_results.rds"), type = "simple")
print_row("Primary (never-treated)", agg_rx$overall.att, agg_rx$overall.se)
print_row("Not-yet-treated controls", nyt$agg$overall.att, nyt$agg$overall.se)
print_row("No anticipation", ant0$agg$overall.att, ant0$agg$overall.se)
print_row("2-year anticipation", ant2$agg$overall.att, ant2$agg$overall.se)

cat(sprintf("Log outcome & %.3f%s & (%.3f) & %.3f & \\\\\n",
            log_result$agg$overall.att, stars_fn(pval_fn(log_result$agg$overall.att, log_result$agg$overall.se)),
            log_result$agg$overall.se,
            pval_fn(log_result$agg$overall.att, log_result$agg$overall.se)))

pdmp_ctrl <- readRDS("../data/robustness_pdmp_control.rds")
pdmp_coef <- coef(pdmp_ctrl)["epcs_treated"]
pdmp_se <- se(pdmp_ctrl)["epcs_treated"]
print_row("TWFE + PDMP control", pdmp_coef, pdmp_se)

# Wild bootstrap
tryCatch({
  boot <- readRDS("../data/robustness_bootstrap.rds")
  cat(sprintf("Wild cluster bootstrap & & & %.3f & [%.3f, %.3f] \\\\\n",
              boot$p_val, boot$conf_int[1], boot$conf_int[2]))
}, error = function(e) {})

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Each row reports the aggregate ATT from a different specification. ")
cat("The primary specification uses the Callaway and Sant'Anna (2021) doubly robust estimator ")
cat("with never-treated controls and 1-year anticipation. ")
cat("$^{***}$~$p<0.01$, $^{**}$~$p<0.05$, $^{*}$~$p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## ---------------------------------------------------------------------------
## Table 4: EPCS Mandate Adoption Dates
## ---------------------------------------------------------------------------

cat("Table 4: Treatment timing...\n")

epcs <- readRDS("../data/epcs_mandates.rds")

sink("../tables/tab4_treatment_timing.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{State EPCS Mandate Adoption Dates}\n")
cat("\\label{tab:timing}\n")
cat("\\begin{tabular}{lc|lc}\n")
cat("\\toprule\n")
cat("State & Year & State & Year \\\\\n")
cat("\\midrule\n")

treated <- epcs %>%
  filter(epcs_mandate_year > 0) %>%
  arrange(epcs_mandate_year, state_name) %>%
  select(state_name, epcs_mandate_year)

# Split into two columns
n_half <- ceiling(nrow(treated) / 2)
for (i in 1:n_half) {
  left <- treated[i, ]
  if (i + n_half <= nrow(treated)) {
    right <- treated[i + n_half, ]
    cat(sprintf("%s & %d & %s & %d \\\\\n",
                left$state_name, left$epcs_mandate_year,
                right$state_name, right$epcs_mandate_year))
  } else {
    cat(sprintf("%s & %d & & \\\\\n", left$state_name, left$epcs_mandate_year))
  }
}

cat("\\midrule\n")

never <- epcs %>% filter(epcs_mandate_year == 0) %>% arrange(state_name)
cat(sprintf("\\multicolumn{4}{l}{\\textit{Never-treated (%d):} %s} \\\\\n",
            nrow(never), paste(never$state_name, collapse = ", ")))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Year indicates when the state EPCS mandate became effective. ")
cat("Sources: RXNT EPCS mandates database; state legislative records.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables generated ===\n")
