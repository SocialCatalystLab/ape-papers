## =============================================================================
## 06_tables.R — Generate all LaTeX tables
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "yrbs_panel.rds"))
laws <- readRDS(file.path(data_dir, "cyberbullying_laws.rds"))
twfe_results <- readRDS(file.path(data_dir, "twfe_results.rds"))
sa_att_summary <- readRDS(file.path(data_dir, "sa_att_summary.rds"))
sex_results <- readRDS(file.path(data_dir, "sex_results.rds"))
lawtype_results <- readRDS(file.path(data_dir, "lawtype_results.rds"))
ri_results <- readRDS(file.path(data_dir, "ri_results.rds"))

## Resolve namespace conflict
fpvalue <- fixest::pvalue

## =============================================================================
## Table 1: Summary Statistics
## =============================================================================

cat("Table 1: Summary statistics...\n")

outcome_vars <- c("suicide_ideation", "suicide_attempt", "suicide_plan",
                   "depression", "bullying_school", "cyberbullying")

# Compute summary stats manually to avoid list-column issues
sum_rows <- list()
for (v in outcome_vars) {
  vals <- panel[[v]]
  if (!is.null(vals) && is.numeric(vals)) {
    sum_rows[[v]] <- data.frame(
      variable = v,
      mean = mean(vals, na.rm = TRUE),
      sd = sd(vals, na.rm = TRUE),
      min = min(vals, na.rm = TRUE),
      max = max(vals, na.rm = TRUE),
      n = sum(!is.na(vals))
    )
  }
}
sum_stats <- bind_rows(sum_rows)

n_total <- nrow(laws)
n_treated <- sum(!is.na(laws$law_year))
n_criminal <- sum(laws$law_type %in% c("criminal", "both"))
n_never <- sum(is.na(laws$law_year))

get_ss <- function(var) {
  row <- sum_stats[sum_stats$variable == var, ]
  if (nrow(row) == 0) return(c(NA, NA, NA, NA, 0))
  c(row$mean, row$sd, row$min, row$max, row$n)
}

si <- get_ss("suicide_ideation")
sp <- get_ss("suicide_plan")
sa <- get_ss("suicide_attempt")
dp <- get_ss("depression")
bs <- get_ss("bullying_school")
cb <- get_ss("cyberbullying")

tab1_tex <- sprintf('
\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics}
\\label{tab:summary}
\\begin{tabular}{lccccc}
\\toprule
& Mean & SD & Min & Max & N \\\\
\\midrule
\\multicolumn{6}{l}{\\textit{Panel A: Youth Mental Health Outcomes (YRBS, \\%%)}} \\\\[3pt]
Considered suicide & %.1f & %.1f & %.1f & %.1f & %d \\\\
Suicide plan & %.1f & %.1f & %.1f & %.1f & %d \\\\
Suicide attempt & %.1f & %.1f & %.1f & %.1f & %d \\\\
Sad or hopeless (depression) & %.1f & %.1f & %.1f & %.1f & %d \\\\
Bullied at school & %.1f & %.1f & %.1f & %.1f & %d \\\\
Electronically bullied & %.1f & %.1f & %.1f & %.1f & %d \\\\
\\midrule
\\multicolumn{6}{l}{\\textit{Panel B: Treatment Variables}} \\\\[3pt]
States with cyberbullying law & \\multicolumn{5}{l}{%d of %d (%.0f\\%%)} \\\\
\\quad With criminal penalties & \\multicolumn{5}{l}{%d states} \\\\
\\quad School policy mandate only & \\multicolumn{5}{l}{%d states} \\\\
Never-treated states & \\multicolumn{5}{l}{%d (%s)} \\\\
Adoption period & \\multicolumn{5}{l}{2006--2015} \\\\
YRBS waves & \\multicolumn{5}{l}{1991--2017 (biennial)} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Panel A reports state-level prevalence rates from the CDC Youth Risk Behavior Surveillance System (YRBS). Electronic bullying available 2011--2017 only. Panel B describes the treatment variable: state adoption of anti-cyberbullying legislation.
\\end{tablenotes}
\\end{table}
',
  si[1], si[2], si[3], si[4], si[5],
  sp[1], sp[2], sp[3], sp[4], sp[5],
  sa[1], sa[2], sa[3], sa[4], sa[5],
  dp[1], dp[2], dp[3], dp[4], dp[5],
  bs[1], bs[2], bs[3], bs[4], bs[5],
  cb[1], cb[2], cb[3], cb[4], cb[5],
  n_treated, n_total, 100*n_treated/n_total,
  n_criminal, n_treated - n_criminal,
  n_never, paste(laws$state_abbr[is.na(laws$law_year)], collapse = ", ")
)

writeLines(tab1_tex, file.path(tables_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

## =============================================================================
## Table 2: Main Results (Sun-Abraham ATT and TWFE)
## =============================================================================

cat("Table 2: Main results...\n")

make_stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

outcomes_order <- c("suicide_ideation", "suicide_attempt", "depression",
                    "suicide_plan", "bullying_school")
outcome_labels <- c("Considered Suicide", "Attempted Suicide",
                    "Sad/Hopeless (Depression)", "Suicide Plan",
                    "Bullied at School")

tab2_rows <- ""
for (i in seq_along(outcomes_order)) {
  out <- outcomes_order[i]
  label <- outcome_labels[i]

  # Sun-Abraham ATT (from pre-computed summary)
  sa_sum <- sa_att_summary[[out]]
  if (!is.null(sa_sum)) {
    sa_coef <- sa_sum$att
    sa_se <- sa_sum$se
    sa_p <- sa_sum$p
  } else {
    sa_coef <- NA; sa_se <- NA; sa_p <- NA
  }

  # TWFE
  tw_fit <- twfe_results[[out]]
  if (!is.null(tw_fit)) {
    tw_coef <- coef(tw_fit)[[1]]
    tw_se <- se(tw_fit)[[1]]
    tw_p <- fpvalue(tw_fit)[[1]]
  } else {
    tw_coef <- NA; tw_se <- NA; tw_p <- NA
  }

  # RI p-value
  ri_p <- if (!is.null(ri_results[[out]])) ri_results[[out]]$p_value else NA

  # Format SA column
  sa_str <- ifelse(is.na(sa_coef), "---",
                   sprintf("%.3f%s", sa_coef, make_stars(sa_p)))
  sa_se_str <- ifelse(is.na(sa_se), "", sprintf("(%.3f)", sa_se))
  sa_ci_str <- ifelse(is.na(sa_coef), "",
                      sprintf("[%.3f, %.3f]", sa_coef - 1.96*sa_se, sa_coef + 1.96*sa_se))

  # Format TWFE column
  tw_str <- ifelse(is.na(tw_coef), "---",
                   sprintf("%.3f%s", tw_coef, make_stars(tw_p)))
  tw_se_str <- ifelse(is.na(tw_se), "", sprintf("(%.3f)", tw_se))
  tw_ci_str <- ifelse(is.na(tw_coef), "",
                      sprintf("[%.3f, %.3f]", tw_coef - 1.96*tw_se, tw_coef + 1.96*tw_se))

  # RI column
  ri_str <- ifelse(is.na(ri_p), "---", sprintf("%.3f", ri_p))

  tab2_rows <- paste0(tab2_rows, sprintf(
    "%s & %s & %s & %s \\\\\n& %s & %s & \\\\\n& %s & %s & \\\\\n",
    label, sa_str, tw_str, ri_str, sa_se_str, tw_se_str, sa_ci_str, tw_ci_str))

  if (i < length(outcomes_order)) tab2_rows <- paste0(tab2_rows, "[6pt]\n")
}

tab2_tex <- paste0('
\\begin{table}[htbp]
\\centering
\\caption{Effect of Anti-Cyberbullying Laws on Youth Mental Health}
\\label{tab:main_results}
\\begin{tabular}{lccc}
\\toprule
& Sun-Abraham & TWFE & RI $p$-value \\\\
\\midrule
', tab2_rows, '
\\midrule
State FE & Yes & Yes & --- \\\\
Year FE & Yes & Yes & --- \\\\
Estimator & SA (2021) & OLS & Permutation \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Estimates of the average treatment effect on the treated (ATT). Sun-Abraham uses the heterogeneity-robust estimator of Sun and Abraham (2021). TWFE is standard two-way fixed effects. RI $p$-values from 1,000 permutations of treatment assignment across states; reported for three primary outcomes (suicide ideation, suicide attempt, depression) only. Standard errors (in parentheses) and 95\\% CIs [in brackets] clustered at the state level. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.
\\end{tablenotes}
\\end{table}
')

writeLines(tab2_tex, file.path(tables_dir, "tab2_main_results.tex"))
cat("  Saved tab2_main_results.tex\n")

## =============================================================================
## Table 3: Heterogeneity by Sex and Law Type
## =============================================================================

cat("Table 3: Heterogeneity...\n")

het_rows <- ""
for (outcome in c("suicide_ideation", "suicide_attempt", "depression")) {
  label <- switch(outcome,
    suicide_ideation = "Considered Suicide",
    suicide_attempt = "Attempted Suicide",
    depression = "Sad/Hopeless")

  f_key <- paste("Female", outcome, sep = "_")
  m_key <- paste("Male", outcome, sep = "_")
  f_fit <- sex_results[[f_key]]
  m_fit <- sex_results[[m_key]]
  lt_fit <- lawtype_results[[outcome]]

  # Extract all four values
  f_coef <- f_se <- f_p <- NA
  m_coef <- m_se <- m_p <- NA
  c_coef <- c_se <- c_p <- NA
  s_coef <- s_se <- s_p <- NA

  if (!is.null(f_fit)) {
    f_coef <- coef(f_fit)[[1]]; f_se <- se(f_fit)[[1]]; f_p <- fpvalue(f_fit)[[1]]
  }
  if (!is.null(m_fit)) {
    m_coef <- coef(m_fit)[[1]]; m_se <- se(m_fit)[[1]]; m_p <- fpvalue(m_fit)[[1]]
  }
  if (!is.null(lt_fit)) {
    c_coef <- coef(lt_fit)[["treated_criminal"]]
    c_se <- se(lt_fit)[["treated_criminal"]]
    c_p <- 2 * pnorm(-abs(c_coef / c_se))
    s_coef <- coef(lt_fit)[["treated_school"]]
    s_se <- se(lt_fit)[["treated_school"]]
    s_p <- 2 * pnorm(-abs(s_coef / s_se))
  }

  fmt_coef <- function(coef, p) ifelse(is.na(coef), "---", sprintf("%.3f%s", coef, make_stars(p)))
  fmt_se <- function(se) ifelse(is.na(se), "", sprintf("(%.3f)", se))

  het_rows <- paste0(het_rows, sprintf(
    "%s & %s & %s & %s & %s \\\\\n& %s & %s & %s & %s \\\\\n",
    label,
    fmt_coef(f_coef, f_p), fmt_coef(m_coef, m_p),
    fmt_coef(c_coef, c_p), fmt_coef(s_coef, s_p),
    fmt_se(f_se), fmt_se(m_se), fmt_se(c_se), fmt_se(s_se)))

  if (outcome != "depression") het_rows <- paste0(het_rows, "[6pt]\n")
}

tab3_tex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Heterogeneity by Sex and Law Type}
\\label{tab:heterogeneity}
\\begin{tabular}{lcccc}
\\toprule
& Female & Male & Criminal & School Only \\\\
\\midrule
%s
\\midrule
State FE & Yes & Yes & Yes & Yes \\\\
Year FE & Yes & Yes & Yes & Yes \\\\
Clustering & State & State & State & State \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} TWFE estimates. Columns (1)--(2) estimate effects separately by sex on subsample. Columns (3)--(4) interact treatment with law type: ``Criminal'' includes states with criminal penalties for cyberbullying; ``School Only'' includes states mandating school policies without criminal sanctions. Standard errors (in parentheses) clustered at the state level. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.
\\end{tablenotes}
\\end{table}
", het_rows)

writeLines(tab3_tex, file.path(tables_dir, "tab3_heterogeneity.tex"))
cat("  Saved tab3_heterogeneity.tex\n")

## =============================================================================
## Table 4: Robustness — Alternative estimators and timing sensitivity
## =============================================================================

cat("Table 4: Robustness...\n")

timing_results <- tryCatch(readRDS(file.path(data_dir, "timing_results.rds")),
                           error = function(e) list())
dose_results <- tryCatch(readRDS(file.path(data_dir, "dose_results.rds")),
                         error = function(e) list())

rob_rows <- ""
for (outcome in c("suicide_ideation", "depression")) {
  label <- switch(outcome, suicide_ideation = "Considered Suicide",
                  depression = "Sad/Hopeless")

  rob_rows <- paste0(rob_rows, sprintf(
    "\\multicolumn{3}{l}{\\textit{%s}} \\\\[2pt]\n", label))

  # TWFE (baseline)
  tw <- twfe_results[[outcome]]
  if (!is.null(tw)) {
    rob_rows <- paste0(rob_rows, sprintf(
      "\\quad TWFE (baseline) & %.3f%s & (%.3f) \\\\\n",
      coef(tw)[[1]], make_stars(fpvalue(tw)[[1]]), se(tw)[[1]]))
  }

  # Sun-Abraham
  sa_sum <- sa_att_summary[[outcome]]
  if (!is.null(sa_sum)) {
    rob_rows <- paste0(rob_rows, sprintf(
      "\\quad Sun-Abraham (2021) & %.3f%s & (%.3f) \\\\\n",
      sa_sum$att, make_stars(sa_sum$p), sa_sum$se))
  }

  # Timing sensitivity
  early <- timing_results[[paste0("early_", outcome)]]
  late <- timing_results[[paste0("late_", outcome)]]
  if (!is.null(early)) {
    rob_rows <- paste0(rob_rows, sprintf(
      "\\quad Treatment $-$2 years & %.3f%s & (%.3f) \\\\\n",
      coef(early)[[1]], make_stars(fpvalue(early)[[1]]), se(early)[[1]]))
  }
  if (!is.null(late)) {
    rob_rows <- paste0(rob_rows, sprintf(
      "\\quad Treatment $+$2 years & %.3f%s & (%.3f) \\\\\n",
      coef(late)[[1]], make_stars(fpvalue(late)[[1]]), se(late)[[1]]))
  }

  # Dose-response
  dose <- dose_results[[outcome]]
  if (!is.null(dose)) {
    rob_rows <- paste0(rob_rows, sprintf(
      "\\quad Years since adoption & %.4f%s & (%.4f) \\\\\n",
      coef(dose)[[1]], make_stars(fpvalue(dose)[[1]]), se(dose)[[1]]))
  }

  rob_rows <- paste0(rob_rows, "[6pt]\n")
}

tab4_tex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Robustness Checks}
\\label{tab:robustness}
\\begin{tabular}{lcc}
\\toprule
Specification & Estimate & SE \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} All specifications include state and year fixed effects with standard errors clustered at the state level. Sun-Abraham uses the heterogeneity-robust estimator of Sun and Abraham (2021). Treatment $\\pm$2 years shifts the assumed law effective date by $\\pm$2 years as a timing sensitivity check. Years since adoption tests for dose-response (cumulative effect per year of exposure). * $p<0.10$, ** $p<0.05$, *** $p<0.01$.
\\end{tablenotes}
\\end{table}
", rob_rows)

writeLines(tab4_tex, file.path(tables_dir, "tab4_robustness.tex"))
cat("  Saved tab4_robustness.tex\n")

cat("\n=== All tables generated ===\n")
