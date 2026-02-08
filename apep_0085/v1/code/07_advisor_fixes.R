###############################################################################
# 07_advisor_fixes.R — Generate missing outputs flagged by advisor review
#
# 1. Not-yet-treated event study (log emp + unemp rate) — figures + tables
# 2. Not-yet-treated LOO analysis
# 3. Extended event-study horizon (check max feasible)
# 4. Placebo table with N
###############################################################################

source("00_packages.R")

library(patchwork)
library(scales)

data_dir <- "../data"
fig_dir  <- "../figures"
tab_dir  <- "../tables"

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

# --- APEP theme & palette ---
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major   = element_line(color = "grey90", linewidth = 0.3),
      axis.line          = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks         = element_line(color = "grey30", linewidth = 0.3),
      axis.title         = element_text(size = 11, face = "bold"),
      axis.text          = element_text(size = 10, color = "grey30"),
      legend.position    = "bottom",
      legend.title       = element_text(size = 10, face = "bold"),
      legend.text        = element_text(size = 9),
      plot.title         = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle      = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption       = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin        = margin(10, 15, 10, 10)
    )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

stars_fn <- function(p) {
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.1) return("*")
  return("")
}

p_fn <- function(est, se) 2 * pnorm(-abs(est / se))

###############################################################################
## 1. NOT-YET-TREATED EVENT STUDY — Log Employment
###############################################################################

cat("\n========================================\n")
cat("1. NOT-YET-TREATED EVENT STUDY\n")
cat("========================================\n")

# Already have cs_nyt from 04_robustness.R; reload it
cs_nyt <- readRDS(file.path(data_dir, "cs_nyt_log_emp.rds"))

# Dynamic ATT with wider window to see what's feasible
att_nyt_dynamic_wide <- aggte(cs_nyt, type = "dynamic", min_e = -6, max_e = 10)

cat("Not-yet-treated dynamic ATT (e=-6 to e=+10):\n")
nyt_dyn_wide <- data.frame(
  event_time = att_nyt_dynamic_wide$egt,
  att        = att_nyt_dynamic_wide$att.egt,
  se         = att_nyt_dynamic_wide$se.egt
)
nyt_dyn_wide$ci_lower <- nyt_dyn_wide$att - 1.96 * nyt_dyn_wide$se
nyt_dyn_wide$ci_upper <- nyt_dyn_wide$att + 1.96 * nyt_dyn_wide$se
print(nyt_dyn_wide)

# Check which event times are available
cat("\nAvailable event times for not-yet-treated:", paste(nyt_dyn_wide$event_time, collapse = ", "), "\n")
max_e_nyt <- max(nyt_dyn_wide$event_time)
cat("Max event time for not-yet-treated:", max_e_nyt, "\n")

saveRDS(att_nyt_dynamic_wide, file.path(data_dir, "att_nyt_dynamic_wide.rds"))

###############################################################################
## 1b. NOT-YET-TREATED EVENT STUDY — Unemployment Rate
###############################################################################

cat("\n--- Not-yet-treated: Unemployment Rate ---\n")

cs_nyt_unemp <- att_gt(
  yname = "unemp_rate_march",
  tname = "year",
  idname = "statefip",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  anticipation = 1
)

att_nyt_overall_unemp <- aggte(cs_nyt_unemp, type = "simple")
att_nyt_dynamic_unemp <- aggte(cs_nyt_unemp, type = "dynamic", min_e = -6, max_e = max_e_nyt)

cat(sprintf("Not-yet-treated Unemployment Rate ATT: %.4f (SE: %.4f)\n",
            att_nyt_overall_unemp$overall.att, att_nyt_overall_unemp$overall.se))

saveRDS(cs_nyt_unemp, file.path(data_dir, "cs_nyt_unemp.rds"))
saveRDS(att_nyt_overall_unemp, file.path(data_dir, "att_nyt_overall_unemp.rds"))
saveRDS(att_nyt_dynamic_unemp, file.path(data_dir, "att_nyt_dynamic_unemp.rds"))

###############################################################################
## 2. NEVER-TREATED EVENT STUDY — Extended horizon
###############################################################################

cat("\n========================================\n")
cat("2. NEVER-TREATED EVENT STUDY — EXTENDED HORIZON\n")
cat("========================================\n")

cs_log_emp <- readRDS(file.path(data_dir, "cs_log_emp.rds"))
cs_unemp <- readRDS(file.path(data_dir, "cs_unemp.rds"))

# Extend to e=+10
att_dynamic_ext <- aggte(cs_log_emp, type = "dynamic", min_e = -6, max_e = 10)
att_dynamic_unemp_ext <- aggte(cs_unemp, type = "dynamic", min_e = -6, max_e = 10)

cat("Never-treated dynamic ATT extended (e=-6 to e=+10):\n")
nt_dyn_ext <- data.frame(
  event_time = att_dynamic_ext$egt,
  att        = att_dynamic_ext$att.egt,
  se         = att_dynamic_ext$se.egt
)
nt_dyn_ext$ci_lower <- nt_dyn_ext$att - 1.96 * nt_dyn_ext$se
nt_dyn_ext$ci_upper <- nt_dyn_ext$att + 1.96 * nt_dyn_ext$se
print(nt_dyn_ext)

max_e_nt <- max(att_dynamic_ext$egt)
cat("Max event time for never-treated:", max_e_nt, "\n")

saveRDS(att_dynamic_ext, file.path(data_dir, "att_dynamic_log_emp_ext.rds"))
saveRDS(att_dynamic_unemp_ext, file.path(data_dir, "att_dynamic_unemp_ext.rds"))

###############################################################################
## 3. FIGURES — Not-yet-treated event study
###############################################################################

cat("\n========================================\n")
cat("3. NOT-YET-TREATED EVENT STUDY FIGURES\n")
cat("========================================\n")

extract_es <- function(aggte_obj, outcome_label = "") {
  tibble(
    event_time = aggte_obj$egt,
    att        = aggte_obj$att.egt,
    se         = aggte_obj$se.egt,
    crit_val   = aggte_obj$crit.val.egt
  ) %>%
    mutate(
      ci_lower = att - crit_val * se,
      ci_upper = att + crit_val * se,
      outcome  = outcome_label
    )
}

# Figure: Not-yet-treated event study — log employment
es_nyt_log <- extract_es(att_nyt_dynamic_wide, "Log Employment")

fig_es_nyt_main <- ggplot(es_nyt_log, aes(x = event_time, y = att)) +
  geom_ribbon(
    aes(ymin = ci_lower, ymax = ci_upper),
    fill  = apep_colors[3],
    alpha = 0.2
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40", linewidth = 0.5) +
  geom_line(color = apep_colors[3], linewidth = 0.7) +
  geom_point(color = apep_colors[3], size = 2.5, shape = 16) +
  scale_x_continuous(
    breaks = seq(min(es_nyt_log$event_time), max(es_nyt_log$event_time), by = 1)
  ) +
  scale_y_continuous(labels = label_number(accuracy = 0.001)) +
  labs(
    title    = "Dynamic Treatment Effects on Log Employment (Not-Yet-Treated Controls)",
    subtitle = "Callaway & Sant'Anna (2021) event-study estimates with uniform 95% CI",
    x        = "Years Relative to Mandate Exposure",
    y        = "ATT (Log Points)",
    caption  = paste0(
      "Note: Estimates use not-yet-treated states as comparison group. ",
      "Uniform confidence bands account for simultaneous inference across all event times."
    )
  ) +
  theme_apep()

ggsave(
  filename = file.path(fig_dir, "fig_event_study_nyt_main.pdf"),
  plot     = fig_es_nyt_main,
  width    = 8, height = 5, device = cairo_pdf
)
cat("Saved: fig_event_study_nyt_main.pdf\n")

# Panel figure: Not-yet-treated — (a) log emp, (b) unemp rate
make_es_panel <- function(aggte_obj, outcome_label, y_lab, color_idx = 1) {
  es_df <- extract_es(aggte_obj, outcome_label)
  ggplot(es_df, aes(x = event_time, y = att)) +
    geom_ribbon(
      aes(ymin = ci_lower, ymax = ci_upper),
      fill  = apep_colors[color_idx],
      alpha = 0.2
    ) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40", linewidth = 0.5) +
    geom_line(color = apep_colors[color_idx], linewidth = 0.7) +
    geom_point(color = apep_colors[color_idx], size = 2.5, shape = 16) +
    scale_x_continuous(
      breaks = seq(min(es_df$event_time), max(es_df$event_time), by = 1)
    ) +
    labs(
      title = outcome_label,
      x     = "Years Relative to Mandate Exposure",
      y     = y_lab
    ) +
    theme_apep()
}

p_nyt_log <- make_es_panel(att_nyt_dynamic_wide, "(a) Log Employment", "ATT (Log Points)", 3)
p_nyt_unemp <- make_es_panel(att_nyt_dynamic_unemp, "(b) Unemployment Rate", "ATT (Percentage Points)", 2)

fig_es_nyt_panel <- p_nyt_log / p_nyt_unemp +
  plot_annotation(
    title    = "Dynamic Treatment Effects (Not-Yet-Treated Controls)",
    subtitle = "Callaway & Sant'Anna (2021) estimates with uniform 95% confidence bands",
    caption  = "Note: Event time 0 = first full year of mandate exposure. Dashed line = zero effect. Dotted line = treatment onset.",
    theme    = theme(
      plot.title    = element_text(size = 14, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption  = element_text(size = 8, color = "grey50", hjust = 1)
    )
  )

ggsave(
  filename = file.path(fig_dir, "fig_event_study_nyt_panel.pdf"),
  plot     = fig_es_nyt_panel,
  width    = 8, height = 8, device = cairo_pdf
)
cat("Saved: fig_event_study_nyt_panel.pdf\n")

###############################################################################
## 4. TABLES — Not-yet-treated event-study coefficients
###############################################################################

cat("\n========================================\n")
cat("4. NOT-YET-TREATED EVENT STUDY TABLES\n")
cat("========================================\n")

# Table: Not-yet-treated dynamic ATT — Log Employment
nyt_log_df <- data.frame(
  event_time = att_nyt_dynamic_wide$egt,
  att        = att_nyt_dynamic_wide$att.egt,
  se         = att_nyt_dynamic_wide$se.egt
) %>%
  mutate(
    p_value  = 2 * pnorm(-abs(att / se)),
    ci_lower = att - att_nyt_dynamic_wide$crit.val.egt * se,
    ci_upper = att + att_nyt_dynamic_wide$crit.val.egt * se
  )

sink(file.path(tab_dir, "event_study_nyt_log_emp.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Dynamic ATT Estimates: Log Employment (Not-Yet-Treated Controls)}\n")
cat("\\label{tab:es_nyt_log}\n")
cat("\\begin{tabular}{rcccc}\n")
cat("\\toprule\n")
cat("Event Time & ATT & SE & 95\\% Uniform CI \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(nyt_log_df))) {
  r <- nyt_log_df[i, ]
  cat(sprintf("$e = %+d$ & %.4f%s & (%.4f) & [%.4f, %.4f] \\\\\n",
              r$event_time, r$att, stars_fn(r$p_value), r$se,
              r$ci_lower, r$ci_upper))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Callaway and Sant'Anna (2021) dynamic ATT estimates using\n")
cat("not-yet-treated states as the comparison group. Doubly-robust estimation with\n")
cat("multiplier bootstrap (1,000 iterations). Uniform confidence bands account for\n")
cat("simultaneous inference across all event times.\n")
cat("* $p < 0.1$, ** $p < 0.05$, *** $p < 0.01$ (pointwise).\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/event_study_nyt_log_emp.tex\n")

# Table: Not-yet-treated dynamic ATT — Unemployment Rate
nyt_unemp_df <- data.frame(
  event_time = att_nyt_dynamic_unemp$egt,
  att        = att_nyt_dynamic_unemp$att.egt,
  se         = att_nyt_dynamic_unemp$se.egt
) %>%
  mutate(
    p_value  = 2 * pnorm(-abs(att / se)),
    ci_lower = att - att_nyt_dynamic_unemp$crit.val.egt * se,
    ci_upper = att + att_nyt_dynamic_unemp$crit.val.egt * se
  )

sink(file.path(tab_dir, "event_study_nyt_unemp.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Dynamic ATT Estimates: Unemployment Rate (Not-Yet-Treated Controls)}\n")
cat("\\label{tab:es_nyt_unemp}\n")
cat("\\begin{tabular}{rcccc}\n")
cat("\\toprule\n")
cat("Event Time & ATT & SE & 95\\% Uniform CI \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(nyt_unemp_df))) {
  r <- nyt_unemp_df[i, ]
  cat(sprintf("$e = %+d$ & %.4f%s & (%.4f) & [%.4f, %.4f] \\\\\n",
              r$event_time, r$att, stars_fn(r$p_value), r$se,
              r$ci_lower, r$ci_upper))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Callaway and Sant'Anna (2021) dynamic ATT estimates using\n")
cat("not-yet-treated states as the comparison group. Doubly-robust estimation with\n")
cat("multiplier bootstrap (1,000 iterations). Uniform confidence bands account for\n")
cat("simultaneous inference across all event times.\n")
cat("* $p < 0.1$, ** $p < 0.05$, *** $p < 0.01$ (pointwise).\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/event_study_nyt_unemp.tex\n")

###############################################################################
## 5. LOO ANALYSIS — Not-Yet-Treated
###############################################################################

cat("\n========================================\n")
cat("5. LOO ANALYSIS — NOT-YET-TREATED\n")
cat("========================================\n")

early_adopters <- panel %>%
  filter(first_treat > 0 & first_treat <= 2014) %>%
  distinct(statefip, first_treat) %>%
  arrange(statefip)

cat(sprintf("Early adopter states: %d\n", nrow(early_adopters)))

loo_nyt_results <- data.frame(
  dropped_state = integer(),
  first_treat   = integer(),
  att           = numeric(),
  se            = numeric(),
  ci_lower      = numeric(),
  ci_upper      = numeric(),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(early_adopters))) {
  drop_fip <- early_adopters$statefip[i]
  drop_ft  <- early_adopters$first_treat[i]

  cat(sprintf("  Dropping state %d (first_treat = %d)... ", drop_fip, drop_ft))

  panel_loo <- panel %>% filter(statefip != drop_fip)

  cs_loo <- tryCatch({
    att_gt(
      yname = "log_emp",
      tname = "year",
      idname = "statefip",
      gname = "first_treat",
      data = as.data.frame(panel_loo),
      control_group = "notyettreated",
      est_method = "dr",
      bstrap = TRUE,
      cband = FALSE,
      biters = 500,
      anticipation = 1
    )
  }, error = function(e) {
    cat(sprintf("ERROR: %s\n", e$message))
    NULL
  })

  if (!is.null(cs_loo)) {
    att_loo <- aggte(cs_loo, type = "simple")
    loo_nyt_results <- rbind(loo_nyt_results, data.frame(
      dropped_state = drop_fip,
      first_treat   = drop_ft,
      att           = att_loo$overall.att,
      se            = att_loo$overall.se,
      ci_lower      = att_loo$overall.att - 1.96 * att_loo$overall.se,
      ci_upper      = att_loo$overall.att + 1.96 * att_loo$overall.se,
      stringsAsFactors = FALSE
    ))
    cat(sprintf("ATT = %.4f (SE = %.4f)\n", att_loo$overall.att, att_loo$overall.se))
  }
}

cat("\n--- LOO Results (Not-Yet-Treated) ---\n")
att_nyt <- readRDS(file.path(data_dir, "att_nyt_overall.rds"))
cat(sprintf("Baseline ATT (not-yet-treated): %.4f (SE = %.4f)\n\n",
            att_nyt$overall.att, att_nyt$overall.se))

print(as.data.frame(loo_nyt_results), row.names = FALSE)

cat(sprintf("\nATT range across LOO (NYT): [%.4f, %.4f]\n",
            min(loo_nyt_results$att), max(loo_nyt_results$att)))
cat(sprintf("ATT mean across LOO (NYT):  %.4f\n", mean(loo_nyt_results$att)))

saveRDS(loo_nyt_results, file.path(data_dir, "loo_nyt_early_adopters.rds"))
cat("Saved: loo_nyt_early_adopters.rds\n")

# Generate LOO table for not-yet-treated
# Map FIPS to state abbreviations
state_map <- panel %>%
  distinct(statefip) %>%
  left_join(
    readRDS(file.path(data_dir, "pdmp_mandate_dates.rds")) %>%
      select(statefip, state_abbr),
    by = "statefip"
  )

sink(file.path(tab_dir, "loo_nyt.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Leave-One-Out Sensitivity: Not-Yet-Treated Controls}\n")
cat("\\label{tab:loo_nyt}\n")
cat("\\begin{tabular}{llcccc}\n")
cat("\\toprule\n")
cat("Dropped State & Cohort & ATT & SE & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(loo_nyt_results))) {
  r <- loo_nyt_results[i, ]
  st_abbr <- state_map$state_abbr[state_map$statefip == r$dropped_state]
  if (length(st_abbr) == 0) st_abbr <- as.character(r$dropped_state)
  cat(sprintf("%s & %d & %.4f & (%.4f) & [%.4f, %.4f] \\\\\n",
              st_abbr, r$first_treat, r$att, r$se, r$ci_lower, r$ci_upper))
}

cat("\\midrule\n")
cat(sprintf("None (baseline) & --- & %.4f & (%.4f) & [%.4f, %.4f] \\\\\n",
            att_nyt$overall.att, att_nyt$overall.se,
            att_nyt$overall.att - 1.96 * att_nyt$overall.se,
            att_nyt$overall.att + 1.96 * att_nyt$overall.se))
cat("\\midrule\n")
cat(sprintf("\\multicolumn{2}{l}{ATT Range} & \\multicolumn{4}{l}{[%.4f, %.4f]} \\\\\n",
            min(loo_nyt_results$att), max(loo_nyt_results$att)))
cat(sprintf("\\multicolumn{2}{l}{ATT Mean} & \\multicolumn{4}{l}{%.4f} \\\\\n",
            mean(loo_nyt_results$att)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Each row drops one early-adopter state (first treated $\\leq$ 2014)\n")
cat("and re-estimates the overall ATT using not-yet-treated controls.\n")
cat("Callaway and Sant'Anna (2021) doubly-robust estimation.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/loo_nyt.tex\n")

###############################################################################
## 6. PLACEBO TABLE — Add N
###############################################################################

cat("\n========================================\n")
cat("6. PLACEBO TABLE WITH N\n")
cat("========================================\n")

# Load placebo results
placebo_file <- file.path(data_dir, "twfe_placebo.rds")
cs_placebo_file <- file.path(data_dir, "cs_placebo.rds")

if (file.exists(placebo_file)) {
  twfe_placebo <- readRDS(placebo_file)
  placebo_coef <- coef(twfe_placebo)["treated_placebo"]
  placebo_se <- se(twfe_placebo)["treated_placebo"]
  placebo_p <- 2 * pnorm(-abs(placebo_coef / placebo_se))
  placebo_n <- nobs(twfe_placebo)
  placebo_type <- "TWFE"
} else if (file.exists(cs_placebo_file)) {
  cs_plac <- readRDS(cs_placebo_file)
  att_plac <- aggte(cs_plac, type = "simple")
  placebo_coef <- att_plac$overall.att
  placebo_se <- att_plac$overall.se
  placebo_p <- p_fn(placebo_coef, placebo_se)
  placebo_n <- nrow(panel)  # approximate
  placebo_type <- "CS-DiD"
}

# Regenerate placebo table with N
sink(file.path(tab_dir, "placebo_test.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Placebo Test: Treatment Shifted Back Three Years}\n")
cat("\\label{tab:placebo}\n")
cat("\\begin{tabular}{lc}\n")
cat("\\toprule\n")
cat(" & Log(Employment) \\\\\n")
cat("\\midrule\n")
cat(sprintf("Placebo treatment & %.4f%s \\\\\n", placebo_coef, stars_fn(placebo_p)))
cat(sprintf(" & (%.4f) \\\\\n", placebo_se))
cat(sprintf("$p$-value & %.3f \\\\\n", placebo_p))
cat("\\midrule\n")
cat("State FE & \\checkmark \\\\\n")
cat("Year FE & \\checkmark \\\\\n")
cat(sprintf("N (state-years) & %d \\\\\n", placebo_n))
cat(sprintf("Estimator & %s \\\\\n", placebo_type))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Placebo test shifts actual mandate effective dates back three years.\n")
cat("Sample restricted to pre-actual-treatment observations for treated states.\n")
cat("An insignificant coefficient supports the parallel trends assumption.\n")
cat("* $p < 0.1$, ** $p < 0.05$, *** $p < 0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/placebo_test.tex\n")

###############################################################################
## 7. Print summary of pre-trend coefficients for both control groups
###############################################################################

cat("\n========================================\n")
cat("7. PRE-TREND COMPARISON\n")
cat("========================================\n")

# Never-treated pre-trends
att_dyn_nt <- readRDS(file.path(data_dir, "att_dynamic_log_emp.rds"))
nt_pre <- data.frame(
  event_time = att_dyn_nt$egt,
  att = att_dyn_nt$att.egt,
  se = att_dyn_nt$se.egt
) %>%
  filter(event_time < 0) %>%
  mutate(
    p = 2 * pnorm(-abs(att / se)),
    sig = ifelse(p < 0.05, "***", ifelse(p < 0.1, "*", ""))
  )

cat("Never-treated pre-trends:\n")
print(nt_pre)

# Not-yet-treated pre-trends
nyt_pre <- nyt_log_df %>%
  filter(event_time < 0) %>%
  mutate(sig = ifelse(p_value < 0.05, "***", ifelse(p_value < 0.1, "*", "")))

cat("\nNot-yet-treated pre-trends:\n")
print(nyt_pre)

n_sig_nt <- sum(nt_pre$p < 0.05)
n_sig_nyt <- sum(nyt_pre$p_value < 0.05)
cat(sprintf("\nSignificant pre-trends (5%%): never-treated %d/%d, not-yet-treated %d/%d\n",
            n_sig_nt, nrow(nt_pre), n_sig_nyt, nrow(nyt_pre)))

cat("\n========================================\n")
cat("ALL ADVISOR FIXES COMPLETE\n")
cat("========================================\n")
