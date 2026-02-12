## 06_tables.R — Generate all tables
## Paper: "The Quiet Life Goes Macro" (apep_0243)

source("00_packages.R")

cat("=== GENERATING TABLES ===\n")

panel <- readRDS("../data/analysis_panel.rds")
treatment <- readRDS("../data/treatment_dates.rds")

# ============================================================
# TABLE 1: Summary Statistics
# ============================================================

cat("--- Table 1: Summary statistics ---\n")

# Pre-treatment period (before median adoption year ~1988)
panel_pre <- panel %>% filter(year <= 1988)

summ_treated <- panel_pre %>%
  filter(treated == 1) %>%
  summarise(
    n = n(),
    n_states = n_distinct(state_fips),
    estab_mean = mean(ESTAB, na.rm = TRUE),
    estab_sd = sd(ESTAB, na.rm = TRUE),
    emp_mean = mean(EMP, na.rm = TRUE),
    emp_sd = sd(EMP, na.rm = TRUE),
    size_mean = mean(avg_estab_size, na.rm = TRUE),
    size_sd = sd(avg_estab_size, na.rm = TRUE),
    wage_mean = mean(payroll_per_worker, na.rm = TRUE),
    wage_sd = sd(payroll_per_worker, na.rm = TRUE),
    pop_mean = mean(population / 1e6, na.rm = TRUE),
    pop_sd = sd(population / 1e6, na.rm = TRUE)
  )

summ_control <- panel_pre %>%
  filter(treated == 0) %>%
  summarise(
    n = n(),
    n_states = n_distinct(state_fips),
    estab_mean = mean(ESTAB, na.rm = TRUE),
    estab_sd = sd(ESTAB, na.rm = TRUE),
    emp_mean = mean(EMP, na.rm = TRUE),
    emp_sd = sd(EMP, na.rm = TRUE),
    size_mean = mean(avg_estab_size, na.rm = TRUE),
    size_sd = sd(avg_estab_size, na.rm = TRUE),
    wage_mean = mean(payroll_per_worker, na.rm = TRUE),
    wage_sd = sd(payroll_per_worker, na.rm = TRUE),
    pop_mean = mean(population / 1e6, na.rm = TRUE),
    pop_sd = sd(population / 1e6, na.rm = TRUE)
  )

# Full panel stats
panel_full <- panel %>%
  filter(year >= 1988, year <= 2019) %>%
  summarise(
    N = n(),
    n_states = n_distinct(state_fips),
    years = sprintf("%d-%d", min(year), max(year)),
    n_treated = n_distinct(state_fips[treated == 1]),
    n_control = n_distinct(state_fips[treated == 0])
  )

# Export as LaTeX
sink("../tables/tab1_summary.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Pre-Treatment Characteristics (1988 and Earlier)}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{2}{c}{BC Statute States} & \\multicolumn{2}{c}{Never-Treated States} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Variable & Mean & Std. Dev. & Mean & Std. Dev. \\\\\n")
cat("\\midrule\n")
cat(sprintf("Establishments & %s & %s & %s & %s \\\\\n",
            format(round(summ_treated$estab_mean), big.mark = ","),
            format(round(summ_treated$estab_sd), big.mark = ","),
            format(round(summ_control$estab_mean), big.mark = ","),
            format(round(summ_control$estab_sd), big.mark = ",")))
cat(sprintf("Employment & %s & %s & %s & %s \\\\\n",
            format(round(summ_treated$emp_mean), big.mark = ","),
            format(round(summ_treated$emp_sd), big.mark = ","),
            format(round(summ_control$emp_mean), big.mark = ","),
            format(round(summ_control$emp_sd), big.mark = ",")))
cat(sprintf("Avg. establishment size & %.1f & %.1f & %.1f & %.1f \\\\\n",
            summ_treated$size_mean, summ_treated$size_sd,
            summ_control$size_mean, summ_control$size_sd))
cat(sprintf("Payroll per employee (\\$000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            summ_treated$wage_mean, summ_treated$wage_sd,
            summ_control$wage_mean, summ_control$wage_sd))
cat(sprintf("Population (millions) & %.2f & %.2f & %.2f & %.2f \\\\\n",
            summ_treated$pop_mean, summ_treated$pop_sd,
            summ_control$pop_mean, summ_control$pop_sd))
cat("\\midrule\n")
cat(sprintf("Number of states & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\\n",
            summ_treated$n_states, summ_control$n_states))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat(sprintf("\\item Notes: Pre-treatment period (1988 and earlier). BC statute states adopted business combination statutes between 1985 and 1997 (Karpoff \\& Wittry, 2018). Establishments, employment, and payroll from County Business Patterns. Payroll per employee = annual payroll / employment. Population from Census.\n"))
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tab1_summary.tex\n")

# ============================================================
# TABLE 2: BC Statute Adoption Dates
# ============================================================

cat("--- Table 2: Adoption dates ---\n")

sink("../tables/tab2_adoption.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Business Combination Statute Adoption Dates}\n")
cat("\\label{tab:adoption}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{llcllc}\n")
cat("\\toprule\n")
cat("State & Year & & State & Year & \\\\\n")
cat("\\midrule\n")

adopted <- treatment %>%
  filter(bc_year > 0) %>%
  arrange(bc_year, state_name)

# Print in two columns
n_rows <- ceiling(nrow(adopted) / 2)
for (i in 1:n_rows) {
  left <- adopted[i, ]
  if (i + n_rows <= nrow(adopted)) {
    right <- adopted[i + n_rows, ]
    cat(sprintf("%s & %d & & %s & %d & \\\\\n",
                left$state_name, left$bc_year,
                right$state_name, right$bc_year))
  } else {
    cat(sprintf("%s & %d & & & & \\\\\n",
                left$state_name, left$bc_year))
  }
}

cat("\\midrule\n")
cat(sprintf("\\multicolumn{6}{l}{Never-treated states (%d): %s} \\\\\n",
            nrow(treatment %>% filter(bc_year == 0)),
            paste(treatment %>% filter(bc_year == 0) %>% pull(state_abbr), collapse = ", ")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Adoption dates from Karpoff \\& Wittry (2018), which corrects several dating errors in earlier studies. Business combination statutes impose moratoriums on mergers between large shareholders and target firms.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tab2_adoption.tex\n")

# ============================================================
# TABLE 3: Main Results
# ============================================================

cat("--- Table 3: Main results ---\n")

att_size <- readRDS("../data/att_size.rds")
att_nr <- readRDS("../data/att_nr.rds")

# Load wage ATT
has_wage <- file.exists("../data/att_wage.rds")
if (has_wage) att_wage <- readRDS("../data/att_wage.rds")

sink("../tables/tab3_main.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Main Results: Effect of Business Combination Statutes}\n")
cat("\\label{tab:main}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) \\\\\n")
cat(" & Log Avg. Size & Net Entry Rate & Log Payroll/Emp \\\\\n")
cat("\\midrule\n")

p_size <- 2 * pnorm(-abs(att_size$overall.att / att_size$overall.se))
p_nr <- 2 * pnorm(-abs(att_nr$overall.att / att_nr$overall.se))

stars <- function(p) {
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

if (has_wage) {
  p_wage <- 2 * pnorm(-abs(att_wage$overall.att / att_wage$overall.se))
  cat(sprintf("ATT & %.4f%s & %.4f%s & %.4f%s \\\\\n",
              att_size$overall.att, stars(p_size),
              att_nr$overall.att, stars(p_nr),
              att_wage$overall.att, stars(p_wage)))
  cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
              att_size$overall.se, att_nr$overall.se, att_wage$overall.se))
  cat(sprintf("95\\%% CI & [%.4f, %.4f] & [%.4f, %.4f] & [%.4f, %.4f] \\\\\n",
              att_size$overall.att - 1.96 * att_size$overall.se,
              att_size$overall.att + 1.96 * att_size$overall.se,
              att_nr$overall.att - 1.96 * att_nr$overall.se,
              att_nr$overall.att + 1.96 * att_nr$overall.se,
              att_wage$overall.att - 1.96 * att_wage$overall.se,
              att_wage$overall.att + 1.96 * att_wage$overall.se))
} else {
  cat(sprintf("ATT & %.4f%s & %.4f%s & --- \\\\\n",
              att_size$overall.att, stars(p_size),
              att_nr$overall.att, stars(p_nr)))
  cat(sprintf(" & (%.4f) & (%.4f) & \\\\\n",
              att_size$overall.se, att_nr$overall.se))
  cat(sprintf("95\\%% CI & [%.4f, %.4f] & [%.4f, %.4f] & \\\\\n",
              att_size$overall.att - 1.96 * att_size$overall.se,
              att_size$overall.att + 1.96 * att_size$overall.se,
              att_nr$overall.att - 1.96 * att_nr$overall.se,
              att_nr$overall.att + 1.96 * att_nr$overall.se))
}

# Observation counts
panel_main <- panel %>% filter(year >= 1988, year <= 2019)
n_size <- sum(!is.na(panel_main$avg_estab_size))
n_nr <- sum(!is.na(panel_main$net_entry_rate))
n_wage <- sum(!is.na(panel_main$payroll_per_worker) & panel_main$payroll_per_worker > 0)

cat("\\midrule\n")
cat(sprintf("Observations & %s & %s & %s \\\\\n",
            format(n_size, big.mark = ","),
            format(n_nr, big.mark = ","),
            format(n_wage, big.mark = ",")))
cat("Estimator & \\multicolumn{3}{c}{Callaway \\& Sant'Anna (2021)} \\\\\n")
cat("Control group & \\multicolumn{3}{c}{Never-treated states} \\\\\n")
# States actually contributing (CS-DiD drops early adopters)
# 1988+ cohorts = those with pre-treatment data
n_effective_treated <- panel %>%
  filter(treated == 1, first_treat >= 1988) %>%
  pull(state_fips) %>% n_distinct()
cat(sprintf("Effective treated states & \\multicolumn{3}{c}{%d (of 32 adopters)} \\\\\n",
            n_effective_treated))
cat(sprintf("Control states & \\multicolumn{3}{c}{%d} \\\\\n",
            n_distinct(panel$state_fips[panel$treated == 0])))
cat("Clustering & \\multicolumn{3}{c}{State} \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: TWFE Benchmark (for comparison)}} \\\\\n")
cat("\\midrule\n")

# Run TWFE for size only (main comparison)
panel_twfe <- panel %>%
  filter(year >= 1988, year <= 2019, !is.na(avg_estab_size)) %>%
  mutate(log_avg_size = log(avg_estab_size))
twfe_size <- feols(log_avg_size ~ post | state_id + year,
                   data = panel_twfe, cluster = ~state_id)
twfe_coef <- coef(twfe_size)["post"]
twfe_se <- sqrt(vcov(twfe_size)["post", "post"])
twfe_p <- 2 * pt(-abs(twfe_coef / twfe_se), df = twfe_size$nobs - twfe_size$nparams)

cat(sprintf("TWFE coefficient & %.4f%s & & \\\\\n", twfe_coef, stars(twfe_p)))
cat(sprintf(" & (%.4f) & & \\\\\n", twfe_se))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: * p$<$0.10, ** p$<$0.05, *** p$<$0.01. Panel A: Standard errors clustered at the state level in parentheses. ATT is the aggregate average treatment effect on the treated using the Callaway \\& Sant'Anna (2021) estimator with never-treated states as the control group and universal base period. ``Effective treated states'' are those with pre-treatment data (adopted 1988+); the earliest 17 units (adopted 1985--1987) are automatically dropped. Column (1): log of average establishment size (employees/establishments) from County Business Patterns. Column (2): net establishment entry rate. Column (3): log payroll per employee from CBP, a proxy for average wages. Panel B: TWFE regression of Column (1) outcome on post-treatment indicator with state and year fixed effects; note the sign reversal relative to Panel A.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tab3_main.tex\n")

# ============================================================
# TABLE 4: Robustness
# ============================================================

cat("--- Table 4: Robustness ---\n")

# Collect all robustness ATTs
rob_results <- list()

# Baseline
rob_results[["Baseline (never-treated)"]] <- c(att_size$overall.att, att_size$overall.se)

# Drop lobbying
if (file.exists("../data/rob_att_no_lobby.rds")) {
  r <- readRDS("../data/rob_att_no_lobby.rds")
  rob_results[["Drop lobbying states"]] <- c(r$overall.att, r$overall.se)
}

# NYT controls
if (file.exists("../data/rob_att_nyt.rds")) {
  r <- readRDS("../data/rob_att_nyt.rds")
  rob_results[["Not-yet-treated controls"]] <- c(r$overall.att, r$overall.se)
}

# Drop Delaware
if (file.exists("../data/rob_att_no_de.rds")) {
  r <- readRDS("../data/rob_att_no_de.rds")
  rob_results[["Drop Delaware"]] <- c(r$overall.att, r$overall.se)
}

# Placebo
if (file.exists("../data/rob_att_placebo.rds")) {
  r <- readRDS("../data/rob_att_placebo.rds")
  rob_results[["Placebo (5-year pre-shift)"]] <- c(r$overall.att, r$overall.se)
}

sink("../tables/tab4_robustness.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Alternative Specifications for Average Establishment Size}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Specification & ATT & SE & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (nm in names(rob_results)) {
  att_val <- rob_results[[nm]][1]
  se_val <- rob_results[[nm]][2]
  p_val <- 2 * pnorm(-abs(att_val / se_val))
  cat(sprintf("%s & %.4f%s & (%.4f) & [%.4f, %.4f] \\\\\n",
              nm, att_val, stars(p_val), se_val,
              att_val - 1.96 * se_val, att_val + 1.96 * se_val))
}

# RI p-value
if (file.exists("../data/rob_ri.rds")) {
  ri <- readRDS("../data/rob_ri.rds")
  cat("\\midrule\n")
  cat(sprintf("Randomization inference p-value & \\multicolumn{3}{c}{%.3f (500 permutations)} \\\\\n",
              ri$ri_pvalue))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: * p$<$0.10, ** p$<$0.05, *** p$<$0.01. All specifications use the Callaway \\& Sant'Anna (2021) estimator. Baseline uses never-treated states as controls with universal base period. ``Drop lobbying states'' excludes Indiana, Pennsylvania, Delaware, and New York where documented firm lobbying influenced adoption. ``Drop Delaware'' addresses the incorporation-location concern (most large firms incorporate in Delaware regardless of location). Placebo test shifts treatment dates 5 years earlier and uses only pre-treatment data.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("  Saved tab4_robustness.tex\n")

cat("\n=== ALL TABLES GENERATED ===\n")
