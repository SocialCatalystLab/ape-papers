## 06_tables.R — All table generation
## Paper 110: Recreational Marijuana and Business Formation

source("00_packages.R")

# Load results
state_year <- read_csv(file.path(DATA_DIR, "panel_state_year.csv"), show_col_types = FALSE)
twfe_models <- readRDS(file.path(DATA_DIR, "twfe_models.rds"))
series_models <- readRDS(file.path(DATA_DIR, "series_models.rds"))
cs_main <- readRDS(file.path(DATA_DIR, "cs_main.rds"))
cs_cohort <- readRDS(file.path(DATA_DIR, "cs_cohort.rds"))
robustness <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

# ──────────────────────────────────────────────────────────────
# Table 1: Treatment timing
# ──────────────────────────────────────────────────────────────
cat("Creating Table 1: Treatment timing...\n")

treatment <- read_csv(file.path(DATA_DIR, "treatment_timing.csv"), show_col_types = FALSE)

tab1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Recreational Marijuana Legalization: Treatment Timing}\n",
  "\\label{tab:timing}\n",
  "\\begin{tabular}{llcc}\n",
  "\\hline\\hline\n",
  "State & Legalization & First Retail Sales & Cohort \\\\\n",
  "\\hline\n"
)

for (i in 1:nrow(treatment)) {
  tab1_tex <- paste0(tab1_tex,
    treatment$state_abbr[i], " & ",
    treatment$legalization_date[i], " & ",
    treatment$first_retail_date[i], " & ",
    treatment$retail_year[i], " \\\\\n"
  )
}

tab1_tex <- paste0(tab1_tex,
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Treatment timing based on first legal recreational retail sales. ",
  "States without retail sales (VA, DE, MN) are coded as never-treated controls. ",
  "Legalization date is when recreational possession became legal under state law.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab1_tex, file.path(TAB_DIR, "tab1_timing.tex"))
cat("  Saved tab1_timing.tex\n")

# ──────────────────────────────────────────────────────────────
# Table 2: Summary Statistics
# ──────────────────────────────────────────────────────────────
cat("Creating Table 2: Summary statistics...\n")

summary_stats <- state_year %>%
  group_by(ever_treated) %>%
  summarise(
    n_states = n_distinct(state_abbr),
    n_obs = n(),
    mean_apps = mean(annual_applications, na.rm = TRUE),
    sd_apps = sd(annual_applications, na.rm = TRUE),
    mean_apps_pc = mean(apps_per_100k, na.rm = TRUE),
    sd_apps_pc = sd(apps_per_100k, na.rm = TRUE),
    mean_pop = mean(population, na.rm = TRUE) / 1e6,
    sd_pop = sd(population, na.rm = TRUE) / 1e6,
    .groups = "drop"
  )

tab2_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\hline\\hline\n",
  " & \\multicolumn{2}{c}{Opened Retail} & \\multicolumn{2}{c}{No Retail Sales} \\\\\n",
  " & Mean & SD & Mean & SD \\\\\n",
  "\\hline\n"
)

s_treat <- summary_stats %>% filter(ever_treated == 1)
s_ctrl <- summary_stats %>% filter(ever_treated == 0)

tab2_tex <- paste0(tab2_tex,
  "Business Applications & ",
  format(round(s_treat$mean_apps), big.mark = ","), " & ",
  format(round(s_treat$sd_apps), big.mark = ","), " & ",
  format(round(s_ctrl$mean_apps), big.mark = ","), " & ",
  format(round(s_ctrl$sd_apps), big.mark = ","), " \\\\\n",
  "Applications per 100k & ",
  round(s_treat$mean_apps_pc, 1), " & ",
  round(s_treat$sd_apps_pc, 1), " & ",
  round(s_ctrl$mean_apps_pc, 1), " & ",
  round(s_ctrl$sd_apps_pc, 1), " \\\\\n",
  "Population (millions) & ",
  round(s_treat$mean_pop, 2), " & ",
  round(s_treat$sd_pop, 2), " & ",
  round(s_ctrl$mean_pop, 2), " & ",
  round(s_ctrl$sd_pop, 2), " \\\\\n",
  "\\hline\n",
  "States & \\multicolumn{2}{c}{", s_treat$n_states, "} & \\multicolumn{2}{c}{", s_ctrl$n_states, "} \\\\\n",
  "State-year observations & \\multicolumn{2}{c}{", s_treat$n_obs, "} & \\multicolumn{2}{c}{", s_ctrl$n_obs, "} \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Summary statistics for the state-year panel, 2005--2024. ",
  "Business applications are total annual EIN applications from Census Business Formation Statistics. ",
  "``Opened Retail'' includes states that opened recreational retail sales by 2024 (treated group). ",
  "``No Retail Sales'' includes states without recreational retail sales by 2024, including states that legalized possession but have not yet opened retail markets (VA, DE, MN).\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab2_tex, file.path(TAB_DIR, "tab2_summary.tex"))
cat("  Saved tab2_summary.tex\n")

# ──────────────────────────────────────────────────────────────
# Table 3: Main TWFE Results
# ──────────────────────────────────────────────────────────────
cat("Creating Table 3: TWFE results...\n")

tab3 <- modelsummary(
  list(
    "Log Applications" = twfe_models$twfe1,
    "Log Apps/Capita" = twfe_models$twfe2,
    "Log Apps/Capita + Medical" = twfe_models$twfe3
  ),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  statistic = c("({std.error})", "[{conf.low}, {conf.high}]"),
  coef_rename = c("treated" = "Rec. Retail Sales", "has_medical" = "Medical MJ"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(TAB_DIR, "tab3_twfe.tex"),
  title = "TWFE Estimates: Recreational Marijuana and Business Formation",
  notes = "State-clustered standard errors in parentheses; 95\\% confidence intervals in brackets. All specifications include state and year fixed effects."
)

# Post-process to inject \label
tab3_lines <- readLines(file.path(TAB_DIR, "tab3_twfe.tex"))
tab3_text <- paste(tab3_lines, collapse = "\n")
tab3_text <- sub("(caption=\\{[^}]+\\})", "\\1,\nlabel={tab:twfe}", tab3_text)
writeLines(tab3_text, file.path(TAB_DIR, "tab3_twfe.tex"))
cat("  Saved tab3_twfe.tex\n")

# ──────────────────────────────────────────────────────────────
# Table 4: CS Results
# ──────────────────────────────────────────────────────────────
cat("Creating Table 4: CS results...\n")

cs_agg <- aggte(cs_main, type = "simple")

tab4_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Callaway-Sant'Anna Estimates}\n",
  "\\label{tab:cs}\n",
  "\\begin{tabular}{lcc}\n",
  "\\hline\\hline\n",
  " & ATT & SE \\\\\n",
  "\\hline\n",
  "\\multicolumn{3}{l}{\\textit{Panel A: Overall ATT}} \\\\\n",
  "All cohorts & ", round(cs_agg$overall.att, 4), " & (",
  round(cs_agg$overall.se, 4), ") \\\\\n",
  " & [", round(cs_agg$overall.att - 1.96*cs_agg$overall.se, 4), ", ",
  round(cs_agg$overall.att + 1.96*cs_agg$overall.se, 4), "] & \\\\\n",
  "\\hline\n",
  "\\multicolumn{3}{l}{\\textit{Panel B: By Cohort}} \\\\\n"
)

for (i in seq_along(cs_cohort$egt)) {
  tab4_tex <- paste0(tab4_tex,
    "Cohort ", cs_cohort$egt[i], " & ",
    round(cs_cohort$att.egt[i], 4), " & (",
    round(cs_cohort$se.egt[i], 4), ") \\\\\n"
  )
}

tab4_tex <- paste0(tab4_tex,
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Callaway-Sant'Anna (2021) group-time ATT estimates using doubly robust estimator. ",
  "Outcome: log business applications per capita. ",
  "Comparison group: never-treated states. ",
  "95\\% confidence intervals in brackets. ",
  "Standard errors based on bootstrap with 999 replications. ",
  "Sample: $N = 1{,}020$ state-year observations (51 units: 21 treated, 30 never-treated; 2005--2024).\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab4_tex, file.path(TAB_DIR, "tab4_cs.tex"))
cat("  Saved tab4_cs.tex\n")

# ──────────────────────────────────────────────────────────────
# Table 5: BFS Series Decomposition
# ──────────────────────────────────────────────────────────────
cat("Creating Table 5: Series decomposition...\n")

tab5 <- modelsummary(
  list(
    "Total BA" = twfe_models$twfe2,
    "High-Propensity" = series_models$twfe_hba,
    "Planned Wages" = series_models$twfe_wba,
    "Corporate" = series_models$twfe_cba,
    "Formations (8Q)" = series_models$twfe_bf
  ),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  statistic = c("({std.error})", "[{conf.low}, {conf.high}]"),
  coef_rename = c("treated" = "Rec. Retail Sales"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(TAB_DIR, "tab5_series.tex"),
  title = "TWFE Estimates Across BFS Series: Application Types and Business Formations",
  notes = "State-clustered standard errors in parentheses; 95\\% confidence intervals in brackets. All specifications include state and year fixed effects. Outcome: log applications (or formations) per capita. BF8Q result is descriptive only (see text)."
)

# Post-process to inject \label
tab5_lines <- readLines(file.path(TAB_DIR, "tab5_series.tex"))
tab5_text <- paste(tab5_lines, collapse = "\n")
tab5_text <- sub("(caption=\\{[^}]+\\})", "\\1,\nlabel={tab:series}", tab5_text)
writeLines(tab5_text, file.path(TAB_DIR, "tab5_series.tex"))
cat("  Saved tab5_series.tex\n")

# ──────────────────────────────────────────────────────────────
# Table 6: Robustness Summary
# ──────────────────────────────────────────────────────────────
cat("Creating Table 6: Robustness summary...\n")

rob <- robustness

# Compute sample sizes for Panel B robustness specifications
# Medical-only control: states with medical MJ ever
medical_only_states <- state_year %>%
  group_by(state_abbr) %>%
  summarise(has_medical_ever = max(has_medical), .groups = "drop") %>%
  filter(has_medical_ever == 1)
n_medical <- nrow(state_year %>% filter(state_abbr %in% medical_only_states$state_abbr))
n_medical_units <- n_distinct(medical_only_states$state_abbr)
n_medical_treated <- state_year %>%
  filter(state_abbr %in% medical_only_states$state_abbr, ever_treated == 1) %>%
  distinct(state_abbr) %>% nrow()

# No-COVID: drop 2020-2021
n_nocovid <- nrow(state_year %>% filter(!(year %in% c(2020, 2021))))
n_nocovid_units <- n_distinct(state_year$state_abbr)

tab6_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks: Summary of Estimates}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lcccl}\n",
  "\\hline\\hline\n",
  "Specification & ATT & SE & $N$ & Notes \\\\\n",
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: Outcome Variations}} \\\\\n",
  "Total BA (baseline) & ", round(cs_agg$overall.att, 4), " & (", round(cs_agg$overall.se, 4), ") & 1,020 & CS, 51 units \\\\\n",
  "High-Propensity BA & ", round(rob$cs_hba$overall.att, 4), " & (", round(rob$cs_hba$overall.se, 4), ") & 1,020 & CS, 51 units \\\\\n",
  "Wage-Planned BA & ", round(rob$cs_wba$overall.att, 4), " & (", round(rob$cs_wba$overall.se, 4), ") & 1,020 & CS, 51 units \\\\\n",
  if (!is.null(rob$cs_cba)) paste0("Corporate BA & ", round(rob$cs_cba$overall.att, 4), " & (", round(rob$cs_cba$overall.se, 4), ") & 1,020 & CS, 51 units \\\\\n") else "",
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: Sample Variations}} \\\\\n",
  "Medical-only control & ", round(rob$cs_medical$overall.att, 4), " & (", round(rob$cs_medical$overall.se, 4), ") & ",
  format(n_medical, big.mark = ","), " & ", n_medical_units, " units (", n_medical_treated, " treated) \\\\\n",
  "Excl. COVID (2020--21) & ", round(rob$cs_nocovid$overall.att, 4), " & (", round(rob$cs_nocovid$overall.se, 4), ") & ",
  format(n_nocovid, big.mark = ","), " & 51 units, 2005--2019 + 2022--2024 \\\\\n",
  if (!is.null(rob$cs_interior)) paste0(
    "Interior controls only & ", round(rob$cs_interior$overall.att, 4), " & (", round(rob$cs_interior$overall.se, 4), ") & ",
    format(rob$n_interior, big.mark = ","), " & ", rob$n_interior_units, " units (", rob$n_interior_control, " controls) \\\\\n"
  ) else "",
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Panel C: Inference}} \\\\\n",
  "Randomization inference & \\multicolumn{2}{c}{$p = ", round(rob$ri_pvalue, 3), "$} & 1,020 & 999 permutations \\\\\n",
  "Pairs cluster bootstrap & \\multicolumn{2}{c}{$p = ", round(rob$wcb$p_val, 3), "$} & 1,020 & 999 replications \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Panel A varies the outcome variable across Business Formation Statistics series. ",
  "Panel B varies the sample. ``Interior controls'' excludes states bordering any treated state, retaining only non-adjacent never-treated states. ",
  "Panel C reports alternative inference procedures. ",
  "$N$ is the number of state-year observations in each specification. ",
  "All CS estimates use never-treated states as comparison group with doubly robust estimation.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab6_tex, file.path(TAB_DIR, "tab6_robustness.tex"))
cat("  Saved tab6_robustness.tex\n")

cat("\n=== All tables generated ===\n")
