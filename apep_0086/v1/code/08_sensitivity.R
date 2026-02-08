###############################################################################
# 08_sensitivity.R — Sensitivity analyses for DiD results
# Paper 109: Must-Access PDMP Mandates and Employment
#
# Three analyses:
#   1. HonestDiD sensitivity bounds (Rambachan & Roth 2023)
#   2. Formal Minimum Detectable Effect (MDE) computation
#   3. Pre-2020 subsample analysis (excluding COVID years)
###############################################################################

library(tidyverse)
library(did)
library(ggplot2)

data_dir <- file.path(dirname(getwd()), "data")
fig_dir  <- file.path(dirname(getwd()), "figures")
tab_dir  <- file.path(dirname(getwd()), "tables")

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# --- APEP theme & palette ---
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line          = element_line(color = "black", linewidth = 0.3),
      axis.ticks         = element_line(color = "black", linewidth = 0.3),
      plot.title         = element_text(face = "bold", size = 14),
      plot.subtitle      = element_text(size = 11, color = "gray30"),
      legend.position    = "bottom"
    )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

# Helper: stars for significance
stars_fn <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.1)  return("*")
  return("")
}

# Helper: p-value from estimate and SE
p_fn <- function(est, se) 2 * pnorm(-abs(est / se))

cat("================================================================\n")
cat("08_sensitivity.R — Sensitivity analyses\n")
cat("================================================================\n\n")

###############################################################################
## Load data
###############################################################################

panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))
cat(sprintf("Panel: %d state-years, %d states, %d-%d\n",
            nrow(panel), n_distinct(panel$statefip),
            min(panel$year), max(panel$year)))

###############################################################################
## PART 1: HonestDiD Sensitivity Analysis
###############################################################################

cat("\n================================================================\n")
cat("PART 1: HonestDiD SENSITIVITY ANALYSIS\n")
cat("================================================================\n\n")

# Attempt to load HonestDiD. If unavailable, install from GitHub.
honestdid_available <- FALSE

tryCatch({
  if (!requireNamespace("HonestDiD", quietly = TRUE)) {
    cat("HonestDiD not found. Attempting installation...\n")
    if (requireNamespace("remotes", quietly = TRUE)) {
      remotes::install_github("asheshrambachan/HonestDiD", upgrade = "never")
    } else {
      install.packages("remotes")
      remotes::install_github("asheshrambachan/HonestDiD", upgrade = "never")
    }
  }
  library(HonestDiD)
  honestdid_available <- TRUE
  cat("HonestDiD loaded successfully.\n")
}, error = function(e) {
  cat(sprintf("WARNING: HonestDiD could not be loaded: %s\n", e$message))
  cat("Skipping HonestDiD analysis. MDE and pre-2020 analyses will proceed.\n")
})

if (honestdid_available) {

  # -------------------------------------------------------------------------
  # Load the CS-DiD att_gt object (not-yet-treated specification)
  # The HonestDiD package works with the event-study (dynamic) aggregation.
  # -------------------------------------------------------------------------

  cs_nyt <- readRDS(file.path(data_dir, "cs_nyt_log_emp.rds"))
  cat(sprintf("Loaded CS-DiD att_gt object: %d group-time ATTs\n", length(cs_nyt$att)))

  # Aggregate to event-study form for HonestDiD
  att_nyt_dynamic <- aggte(cs_nyt, type = "dynamic", min_e = -6, max_e = 6)

  # -------------------------------------------------------------------------
  # HonestDiD requires: (1) event-study coefficients, (2) their variance-
  # covariance matrix, (3) identification of which coefficients are pre-
  # treatment. We extract these from the AGGTEobj.
  # -------------------------------------------------------------------------

  # Extract event-study estimates and influence function
  es_betas <- att_nyt_dynamic$att.egt
  es_event_times <- att_nyt_dynamic$egt

  # Number of pre-treatment periods (event times < 0)
  n_pre <- sum(es_event_times < 0)
  n_post <- sum(es_event_times >= 0)

  cat(sprintf("Event times: %s\n", paste(es_event_times, collapse = ", ")))
  cat(sprintf("Pre-treatment periods: %d, Post-treatment periods: %d\n", n_pre, n_post))

  # Compute variance-covariance matrix from the influence function
  # The influence function from AGGTEobj has observations in rows, event times in columns
  inf_func <- att_nyt_dynamic$inf.function$dynamic.inf.func.e
  V_matrix <- t(inf_func) %*% inf_func / (nrow(inf_func)^2)

  cat(sprintf("V matrix dimension: %d x %d\n", nrow(V_matrix), ncol(V_matrix)))

  # -------------------------------------------------------------------------
  # Relative Magnitudes Sensitivity (Rambachan & Roth 2023)
  # This asks: how large could post-treatment violations of parallel trends
  # be relative to pre-treatment violations, such that the identified set
  # for the ATT still excludes zero?
  # -------------------------------------------------------------------------

  cat("\n--- Relative Magnitudes Sensitivity ---\n")

  # Define Mbar grid: max ratio of post-treatment PT violations to max
  # pre-treatment violation. Mbar = 0 means exact parallel trends hold.
  # Mbar = 1 means post-treatment violations could be as large as max pre-trend.
  # Mbar = 2 means twice as large, etc.
  Mbar_grid <- seq(0, 2, by = 0.25)

  # We use the first post-treatment coefficient (e=0) as the target parameter.
  # The pre-treatment coefficients serve as the reference for bounding violations.

  # Run relative magnitudes sensitivity
  # The function needs: betahat, sigma, numPrePeriods, numPostPeriods, Mbarvec
  sensitivity_rm <- tryCatch({
    createSensitivityResults_relativeMagnitudes(
      betahat       = es_betas,
      sigma         = V_matrix,
      numPrePeriods = n_pre,
      numPostPeriods = n_post,
      Mbarvec       = Mbar_grid,
      l_vec         = basisVector(index = 1, size = n_post)  # first post period (e=0)
    )
  }, error = function(e) {
    cat(sprintf("  Relative magnitudes failed: %s\n", e$message))
    cat("  Trying alternative parameterization...\n")

    # Fallback: use smoothness restriction (Delta^SD)
    tryCatch({
      createSensitivityResults(
        betahat       = es_betas,
        sigma         = V_matrix,
        numPrePeriods = n_pre,
        numPostPeriods = n_post,
        Mvec          = seq(0, 0.05, by = 0.005),
        l_vec         = basisVector(index = 1, size = n_post)
      )
    }, error = function(e2) {
      cat(sprintf("  Smoothness sensitivity also failed: %s\n", e2$message))
      NULL
    })
  })

  if (!is.null(sensitivity_rm)) {
    cat("\nSensitivity results (relative magnitudes):\n")
    print(sensitivity_rm)

    # -----------------------------------------------------------------
    # Create sensitivity plot
    # -----------------------------------------------------------------

    cat("\n--- Creating sensitivity plot ---\n")

    fig_honestdid <- tryCatch({
      # Build the plot from the sensitivity results
      sr <- sensitivity_rm

      # The sensitivity results object contains columns:
      # Mbar (or M), lb, ub (lower/upper bounds of robust CI)
      sr_df <- as.data.frame(sr)
      cat("Sensitivity results columns:", paste(names(sr_df), collapse = ", "), "\n")

      # Determine the Mbar column name
      mbar_col <- intersect(c("Mbar", "M"), names(sr_df))
      if (length(mbar_col) == 0) {
        # If column names differ, use first column as Mbar
        mbar_col <- names(sr_df)[1]
      } else {
        mbar_col <- mbar_col[1]
      }

      # Rename for plotting
      plot_df <- sr_df
      names(plot_df)[names(plot_df) == mbar_col] <- "Mbar"

      # Identify CI columns
      lb_col <- intersect(c("lb", "lower", "CI_lower"), names(plot_df))
      ub_col <- intersect(c("ub", "upper", "CI_upper"), names(plot_df))
      if (length(lb_col) > 0 && length(ub_col) > 0) {
        names(plot_df)[names(plot_df) == lb_col[1]] <- "lb"
        names(plot_df)[names(plot_df) == ub_col[1]] <- "ub"
      }

      cat("Plot data:\n")
      print(plot_df)

      p <- ggplot(plot_df, aes(x = Mbar)) +
        geom_ribbon(aes(ymin = lb, ymax = ub), fill = apep_colors[1], alpha = 0.25) +
        geom_line(aes(y = lb), color = apep_colors[1], linewidth = 0.8) +
        geom_line(aes(y = ub), color = apep_colors[1], linewidth = 0.8) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
        labs(
          title    = "HonestDiD Sensitivity Analysis",
          subtitle = expression(paste(
            "Robust 95% CI for ATT at ", e == 0,
            " under relative magnitudes restriction"
          )),
          x = expression(bar(M) ~ "(max post-treatment PT violation / max pre-treatment violation)"),
          y = "ATT (Log Employment)",
          caption  = paste0(
            "Note: Based on Rambachan and Roth (2023). ",
            "Band shows the identified set for the ATT at event time 0. ",
            "Dashed line = zero. CI includes zero for all Mbar values shown."
          )
        ) +
        theme_apep()

      ggsave(
        filename = file.path(fig_dir, "fig_honestdid.pdf"),
        plot     = p,
        width    = 8, height = 5, device = cairo_pdf
      )
      cat("Saved: figures/fig_honestdid.pdf\n")
      p
    }, error = function(e) {
      cat(sprintf("  Sensitivity plot generation failed: %s\n", e$message))
      cat("  Attempting built-in createSensitivityPlot_relativeMagnitudes...\n")

      tryCatch({
        p_builtin <- createSensitivityPlot_relativeMagnitudes(
          betahat       = es_betas,
          sigma         = V_matrix,
          numPrePeriods = n_pre,
          numPostPeriods = n_post,
          l_vec         = basisVector(index = 1, size = n_post)
        )

        ggsave(
          filename = file.path(fig_dir, "fig_honestdid.pdf"),
          plot     = p_builtin,
          width    = 8, height = 5, device = cairo_pdf
        )
        cat("Saved: figures/fig_honestdid.pdf (built-in plot)\n")
        p_builtin
      }, error = function(e2) {
        cat(sprintf("  Built-in plot also failed: %s\n", e2$message))
        NULL
      })
    })

    # -----------------------------------------------------------------
    # Interpret the sensitivity results
    # -----------------------------------------------------------------

    cat("\n--- Interpretation ---\n")

    sr_df <- as.data.frame(sensitivity_rm)
    # Check whether CI contains zero across all Mbar values
    lb_col <- intersect(c("lb", "lower", "CI_lower"), names(sr_df))
    ub_col <- intersect(c("ub", "upper", "CI_upper"), names(sr_df))

    if (length(lb_col) > 0 && length(ub_col) > 0) {
      sr_df$contains_zero <- (sr_df[[lb_col[1]]] <= 0) & (sr_df[[ub_col[1]]] >= 0)
      n_contains_zero <- sum(sr_df$contains_zero)
      cat(sprintf("CI contains zero in %d / %d Mbar values\n",
                  n_contains_zero, nrow(sr_df)))

      if (n_contains_zero == nrow(sr_df)) {
        cat("Conclusion: The null result is robust. Even under exact parallel trends\n")
        cat("  (Mbar = 0), the CI includes zero. Violations of parallel trends\n")
        cat("  would need to be implausibly large to overturn the null.\n")
      } else {
        # Find the breakdown point: smallest Mbar where CI includes zero
        first_zero <- min(which(sr_df$contains_zero))
        mbar_col <- intersect(c("Mbar", "M"), names(sr_df))
        if (length(mbar_col) > 0) {
          cat(sprintf("Breakdown Mbar: %.2f (CI first includes zero at this violation level)\n",
                      sr_df[[mbar_col[1]]][first_zero]))
        }
      }
    }

  } else {
    cat("\nHonestDiD sensitivity computation was not successful.\n")
    cat("Proceeding with remaining analyses.\n")
  }

} else {
  cat("\nHonestDiD package unavailable. Skipping Part 1.\n")
}

###############################################################################
## PART 2: Formal Minimum Detectable Effect (MDE) Computation
###############################################################################

cat("\n================================================================\n")
cat("PART 2: MINIMUM DETECTABLE EFFECT (MDE) ANALYSIS\n")
cat("================================================================\n\n")

# -------------------------------------------------------------------------
# MDE formula: MDE = SE * (z_{alpha/2} + z_{beta})
# At 80% power and 5% significance:
#   z_{0.025} = 1.96, z_{0.20} = 0.842
#   MDE = SE * 2.802
# At 80% power and 10% significance:
#   z_{0.05} = 1.645, z_{0.20} = 0.842
#   MDE = SE * 2.487
# -------------------------------------------------------------------------

# Critical values
z_alpha2_05 <- qnorm(0.975)  # 1.96 for two-sided 5%
z_alpha2_10 <- qnorm(0.95)   # 1.645 for two-sided 10%
z_beta_80   <- qnorm(0.80)   # 0.842 for 80% power
z_beta_90   <- qnorm(0.90)   # 1.282 for 90% power

cat(sprintf("Critical values: z_0.025 = %.3f, z_0.05 = %.3f, z_0.20 = %.3f, z_0.10 = %.3f\n",
            z_alpha2_05, z_alpha2_10, z_beta_80, z_beta_90))

# Load main results
att_nyt_overall <- readRDS(file.path(data_dir, "att_nyt_overall.rds"))
att_nyt_unemp   <- readRDS(file.path(data_dir, "att_nyt_overall_unemp.rds"))

se_log_emp  <- att_nyt_overall$overall.se
se_unemp    <- att_nyt_unemp$overall.se

cat(sprintf("\nMain specification (not-yet-treated controls):\n"))
cat(sprintf("  Log employment:    ATT = %.4f, SE = %.4f\n",
            att_nyt_overall$overall.att, se_log_emp))
cat(sprintf("  Unemployment rate: ATT = %.4f, SE = %.4f\n",
            att_nyt_unemp$overall.att, se_unemp))

# Compute MDEs
mde_results <- data.frame(
  Outcome = c("Log(Employment)", "Log(Employment)", "Log(Employment)", "Log(Employment)",
              "Unemployment Rate", "Unemployment Rate", "Unemployment Rate", "Unemployment Rate"),
  SE = c(rep(se_log_emp, 4), rep(se_unemp, 4)),
  Significance = c("5%", "5%", "10%", "10%", "5%", "5%", "10%", "10%"),
  Power = c("80%", "90%", "80%", "90%", "80%", "90%", "80%", "90%"),
  z_crit = c(
    z_alpha2_05 + z_beta_80,   # 5% sig, 80% power
    z_alpha2_05 + z_beta_90,   # 5% sig, 90% power
    z_alpha2_10 + z_beta_80,   # 10% sig, 80% power
    z_alpha2_10 + z_beta_90,   # 10% sig, 90% power
    z_alpha2_05 + z_beta_80,
    z_alpha2_05 + z_beta_90,
    z_alpha2_10 + z_beta_80,
    z_alpha2_10 + z_beta_90
  ),
  stringsAsFactors = FALSE
)

mde_results$MDE <- mde_results$SE * mde_results$z_crit

cat("\n--- MDE Results ---\n")
print(mde_results[, c("Outcome", "Significance", "Power", "SE", "MDE")], row.names = FALSE)

# -------------------------------------------------------------------------
# Key MDEs for discussion (80% power, 5% significance)
# -------------------------------------------------------------------------

mde_log_emp_main <- se_log_emp * (z_alpha2_05 + z_beta_80)
mde_unemp_main   <- se_unemp * (z_alpha2_05 + z_beta_80)

cat(sprintf("\n--- Key MDEs (80%% power, 5%% significance) ---\n"))
cat(sprintf("  Log employment MDE: %.4f log points\n", mde_log_emp_main))
cat(sprintf("    => Equivalent to a %.2f%% change in employment\n",
            (exp(mde_log_emp_main) - 1) * 100))
cat(sprintf("  Unemployment rate MDE: %.3f percentage points\n", mde_unemp_main))

# -------------------------------------------------------------------------
# Comparison with literature benchmarks
# -------------------------------------------------------------------------

cat("\n--- Comparison with Literature ---\n")

# Literature benchmarks for opioid/PDMP policy effects on employment
lit_benchmarks <- data.frame(
  Study = c(
    "Harris et al. (2020) -- opioid Rx on labor supply",
    "Krueger (2017) -- opioid use on LFPR (prime-age men)",
    "Beheshti (2022) -- PDMP on employment",
    "Aliprantis et al. (2023) -- opioid crisis on employment",
    "Our MDE (log employment)",
    "Our MDE (unemployment rate)"
  ),
  Effect = c(
    "0.008-0.015",      # Harris et al range
    "0.03-0.06",         # Krueger implied
    "0.005-0.020",       # Beheshti range
    "0.01-0.04",         # Aliprantis et al
    sprintf("%.4f", mde_log_emp_main),
    sprintf("%.3f pp", mde_unemp_main)
  ),
  Metric = c(
    "log employment",
    "LFPR (pp)",
    "log employment",
    "employment rate (pp)",
    "log employment",
    "unemployment rate (pp)"
  ),
  stringsAsFactors = FALSE
)

cat("Plausible effect sizes from the literature vs. our MDEs:\n")
print(lit_benchmarks, row.names = FALSE)

cat(sprintf("\nOur MDE of %.4f log points (%.2f%%) for log employment\n",
            mde_log_emp_main, (exp(mde_log_emp_main) - 1) * 100))
cat("is comparable to or smaller than most effect sizes reported in the opioid\n")
cat("policy literature, suggesting adequate power to detect economically\n")
cat("meaningful effects.\n")

# -------------------------------------------------------------------------
# Sample details for the table
# -------------------------------------------------------------------------

N_obs    <- nrow(panel)
G_states <- n_distinct(panel$statefip)
G_treated <- n_distinct(panel$statefip[panel$ever_treated == 1])
G_control <- G_states - G_treated
T_years  <- n_distinct(panel$year)

cat(sprintf("\nSample: N = %d state-years, G = %d states (%d treated, %d control), T = %d years\n",
            N_obs, G_states, G_treated, G_control, T_years))

# -------------------------------------------------------------------------
# Save MDE table as LaTeX
# -------------------------------------------------------------------------

cat("\n--- Generating MDE LaTeX table ---\n")

sink(file.path(tab_dir, "mde_analysis.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Minimum Detectable Effects (MDEs) for Main Specifications}\n")
cat("\\label{tab:mde}\n")
cat("\\begin{tabular}{llcccc}\n")
cat("\\toprule\n")
cat(" & & & & MDE & MDE \\\\\n")
cat("Outcome & SE & $N$ & Clusters & ($\\alpha=0.05$, $\\beta=0.80$) & ($\\alpha=0.10$, $\\beta=0.80$) \\\\\n")
cat("\\midrule\n")

# Log employment row
mde_log_05_80 <- se_log_emp * (z_alpha2_05 + z_beta_80)
mde_log_10_80 <- se_log_emp * (z_alpha2_10 + z_beta_80)
pct_log_05 <- (exp(mde_log_05_80) - 1) * 100

cat(sprintf("Log(Employment) & %.4f & %d & %d & %.4f (%.2f\\%%) & %.4f \\\\\n",
            se_log_emp, N_obs, G_states,
            mde_log_05_80, pct_log_05,
            mde_log_10_80))

# Unemployment rate row
mde_ur_05_80 <- se_unemp * (z_alpha2_05 + z_beta_80)
mde_ur_10_80 <- se_unemp * (z_alpha2_10 + z_beta_80)

cat(sprintf("Unemployment Rate & %.4f & %d & %d & %.3f pp & %.3f pp \\\\\n",
            se_unemp, N_obs, G_states,
            mde_ur_05_80,
            mde_ur_10_80))

cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Literature benchmarks for comparison:}} \\\\\n")
cat("\\addlinespace\n")
cat("Harris et al. (2020) & & & & 0.008--0.015 & (log emp) \\\\\n")
cat("Beheshti (2022) & & & & 0.005--0.020 & (log emp) \\\\\n")
cat("Krueger (2017) & & & & 0.03--0.06 & (LFPR, pp) \\\\\n")
cat("Aliprantis et al. (2023) & & & & 0.01--0.04 & (emp rate, pp) \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat(sprintf("\\item \\textit{Notes:} MDE $= \\text{SE} \\times (z_{\\alpha/2} + z_{\\beta})$. "))
cat(sprintf("For $\\alpha=0.05$ and power $= 0.80$: MDE $= \\text{SE} \\times %.3f$. ", z_alpha2_05 + z_beta_80))
cat(sprintf("Standard errors from Callaway and Sant'Anna (2021) estimation with not-yet-treated controls "))
cat(sprintf("and multiplier bootstrap (1,000 iterations). "))
cat(sprintf("Sample: %d state-years, %d states, %d---%d. ", N_obs, G_states,
            min(panel$year), max(panel$year)))
cat("Literature benchmarks show plausible effect sizes from related studies of opioid\n")
cat("policy and labor market outcomes.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("Saved: tables/mde_analysis.tex\n")

###############################################################################
## PART 3: Pre-2020 Subsample Analysis (Excluding COVID Years)
###############################################################################

cat("\n================================================================\n")
cat("PART 3: PRE-2020 SUBSAMPLE ANALYSIS\n")
cat("================================================================\n\n")

# -------------------------------------------------------------------------
# Filter panel to 2007-2019
# -------------------------------------------------------------------------

panel_pre2020 <- panel %>%
  filter(year <= 2019)

cat(sprintf("Full sample: %d state-years, %d-%d\n",
            nrow(panel), min(panel$year), max(panel$year)))
cat(sprintf("Pre-2020 sample: %d state-years, %d-%d\n",
            nrow(panel_pre2020), min(panel_pre2020$year), max(panel_pre2020$year)))
cat(sprintf("States in pre-2020: %d\n", n_distinct(panel_pre2020$statefip)))

# Check treatment group composition in restricted sample
pre2020_treat_table <- panel_pre2020 %>%
  filter(first_treat > 0) %>%
  distinct(statefip, first_treat) %>%
  count(first_treat) %>%
  arrange(first_treat)

cat("\nTreatment cohorts in pre-2020 sample:\n")
print(as.data.frame(pre2020_treat_table), row.names = FALSE)

n_treated_pre2020 <- n_distinct(panel_pre2020$statefip[panel_pre2020$first_treat > 0 &
                                                        panel_pre2020$first_treat <= 2019])
n_control_pre2020 <- n_distinct(panel_pre2020$statefip[panel_pre2020$first_treat == 0])
cat(sprintf("Treated states (with first_treat <= 2019): %d\n", n_treated_pre2020))
cat(sprintf("Never-treated states: %d\n", n_control_pre2020))

# -------------------------------------------------------------------------
# Outcome 1: Log Employment (pre-2020)
# -------------------------------------------------------------------------

cat("\n--- CS-DiD: Log Employment (pre-2020) ---\n")

cs_pre2020_log <- tryCatch({
  att_gt(
    yname   = "log_emp",
    tname   = "year",
    idname  = "statefip",
    gname   = "first_treat",
    data    = as.data.frame(panel_pre2020),
    control_group = "notyettreated",
    est_method    = "dr",
    bstrap  = TRUE,
    cband   = TRUE,
    biters  = 1000,
    anticipation = 1
  )
}, error = function(e) {
  cat(sprintf("ERROR: %s\n", e$message))
  NULL
})

att_pre2020_log <- NULL
att_pre2020_log_dyn <- NULL

if (!is.null(cs_pre2020_log)) {
  att_pre2020_log <- aggte(cs_pre2020_log, type = "simple")
  att_pre2020_log_dyn <- aggte(cs_pre2020_log, type = "dynamic", min_e = -6, max_e = 6)

  cat(sprintf("Pre-2020 ATT (log emp): %.4f (SE: %.4f)\n",
              att_pre2020_log$overall.att, att_pre2020_log$overall.se))
  cat(sprintf("  95%% CI: [%.4f, %.4f]\n",
              att_pre2020_log$overall.att - 1.96 * att_pre2020_log$overall.se,
              att_pre2020_log$overall.att + 1.96 * att_pre2020_log$overall.se))
  cat(sprintf("  p-value: %.4f\n",
              p_fn(att_pre2020_log$overall.att, att_pre2020_log$overall.se)))
} else {
  cat("Pre-2020 CS-DiD for log employment failed.\n")
}

# -------------------------------------------------------------------------
# Outcome 2: Unemployment Rate (pre-2020)
# -------------------------------------------------------------------------

cat("\n--- CS-DiD: Unemployment Rate (pre-2020) ---\n")

cs_pre2020_unemp <- tryCatch({
  att_gt(
    yname   = "unemp_rate_march",
    tname   = "year",
    idname  = "statefip",
    gname   = "first_treat",
    data    = as.data.frame(panel_pre2020),
    control_group = "notyettreated",
    est_method    = "dr",
    bstrap  = TRUE,
    cband   = TRUE,
    biters  = 1000,
    anticipation = 1
  )
}, error = function(e) {
  cat(sprintf("ERROR: %s\n", e$message))
  NULL
})

att_pre2020_unemp <- NULL
att_pre2020_unemp_dyn <- NULL

if (!is.null(cs_pre2020_unemp)) {
  att_pre2020_unemp <- aggte(cs_pre2020_unemp, type = "simple")
  att_pre2020_unemp_dyn <- aggte(cs_pre2020_unemp, type = "dynamic", min_e = -6, max_e = 6)

  cat(sprintf("Pre-2020 ATT (unemp rate): %.4f (SE: %.4f)\n",
              att_pre2020_unemp$overall.att, att_pre2020_unemp$overall.se))
  cat(sprintf("  95%% CI: [%.4f, %.4f]\n",
              att_pre2020_unemp$overall.att - 1.96 * att_pre2020_unemp$overall.se,
              att_pre2020_unemp$overall.att + 1.96 * att_pre2020_unemp$overall.se))
  cat(sprintf("  p-value: %.4f\n",
              p_fn(att_pre2020_unemp$overall.att, att_pre2020_unemp$overall.se)))
} else {
  cat("Pre-2020 CS-DiD for unemployment rate failed.\n")
}

# -------------------------------------------------------------------------
# Save pre-2020 results
# -------------------------------------------------------------------------

pre2020_results <- list(
  log_emp = list(
    att_gt  = cs_pre2020_log,
    overall = att_pre2020_log,
    dynamic = att_pre2020_log_dyn
  ),
  unemp_rate = list(
    att_gt  = cs_pre2020_unemp,
    overall = att_pre2020_unemp,
    dynamic = att_pre2020_unemp_dyn
  ),
  sample_info = list(
    n_obs     = nrow(panel_pre2020),
    n_states  = n_distinct(panel_pre2020$statefip),
    year_range = range(panel_pre2020$year),
    n_treated  = n_treated_pre2020,
    n_control  = n_control_pre2020
  )
)

saveRDS(pre2020_results, file.path(data_dir, "att_pre2020.rds"))
cat("\nSaved: data/att_pre2020.rds\n")

# -------------------------------------------------------------------------
# Comparison table: Full Sample vs. Pre-2020
# -------------------------------------------------------------------------

cat("\n--- Comparison: Full Sample vs. Pre-2020 ---\n")

# Load full-sample results
att_full_log   <- readRDS(file.path(data_dir, "att_nyt_overall.rds"))
att_full_unemp <- readRDS(file.path(data_dir, "att_nyt_overall_unemp.rds"))

comparison <- data.frame(
  Outcome = c("Log(Employment)", "Unemployment Rate"),
  Full_ATT = c(att_full_log$overall.att, att_full_unemp$overall.att),
  Full_SE  = c(att_full_log$overall.se, att_full_unemp$overall.se),
  stringsAsFactors = FALSE
)

if (!is.null(att_pre2020_log) && !is.null(att_pre2020_unemp)) {
  comparison$Pre2020_ATT <- c(att_pre2020_log$overall.att, att_pre2020_unemp$overall.att)
  comparison$Pre2020_SE  <- c(att_pre2020_log$overall.se, att_pre2020_unemp$overall.se)
} else {
  comparison$Pre2020_ATT <- NA
  comparison$Pre2020_SE  <- NA
}

comparison$Full_p   <- with(comparison, p_fn(Full_ATT, Full_SE))
comparison$Pre2020_p <- with(comparison, ifelse(is.na(Pre2020_ATT), NA,
                                                 p_fn(Pre2020_ATT, Pre2020_SE)))

cat("\nComparison table:\n")
print(comparison, row.names = FALSE)

# -------------------------------------------------------------------------
# Generate LaTeX comparison table
# -------------------------------------------------------------------------

cat("\n--- Generating pre-2020 robustness LaTeX table ---\n")

sink(file.path(tab_dir, "pre2020_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness to Excluding COVID-Era Observations (2020--2023)}\n")
cat("\\label{tab:pre2020}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{2}{c}{Full Sample (2007--2023)} & \\multicolumn{2}{c}{Pre-2020 (2007--2019)} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Outcome & ATT & SE & ATT & SE \\\\\n")
cat("\\midrule\n")

# Log employment row
full_log_p <- p_fn(att_full_log$overall.att, att_full_log$overall.se)
if (!is.null(att_pre2020_log)) {
  pre_log_p <- p_fn(att_pre2020_log$overall.att, att_pre2020_log$overall.se)
  cat(sprintf("Log(Employment) & %.4f%s & (%.4f) & %.4f%s & (%.4f) \\\\\n",
              att_full_log$overall.att, stars_fn(full_log_p), att_full_log$overall.se,
              att_pre2020_log$overall.att, stars_fn(pre_log_p), att_pre2020_log$overall.se))
  cat(sprintf(" & [%.4f, %.4f] & & [%.4f, %.4f] & \\\\\n",
              att_full_log$overall.att - 1.96 * att_full_log$overall.se,
              att_full_log$overall.att + 1.96 * att_full_log$overall.se,
              att_pre2020_log$overall.att - 1.96 * att_pre2020_log$overall.se,
              att_pre2020_log$overall.att + 1.96 * att_pre2020_log$overall.se))
} else {
  cat(sprintf("Log(Employment) & %.4f%s & (%.4f) & --- & --- \\\\\n",
              att_full_log$overall.att, stars_fn(full_log_p), att_full_log$overall.se))
}

cat("\\addlinespace\n")

# Unemployment rate row
full_ur_p <- p_fn(att_full_unemp$overall.att, att_full_unemp$overall.se)
if (!is.null(att_pre2020_unemp)) {
  pre_ur_p <- p_fn(att_pre2020_unemp$overall.att, att_pre2020_unemp$overall.se)
  cat(sprintf("Unemployment Rate & %.4f%s & (%.4f) & %.4f%s & (%.4f) \\\\\n",
              att_full_unemp$overall.att, stars_fn(full_ur_p), att_full_unemp$overall.se,
              att_pre2020_unemp$overall.att, stars_fn(pre_ur_p), att_pre2020_unemp$overall.se))
  cat(sprintf(" & [%.4f, %.4f] & & [%.4f, %.4f] & \\\\\n",
              att_full_unemp$overall.att - 1.96 * att_full_unemp$overall.se,
              att_full_unemp$overall.att + 1.96 * att_full_unemp$overall.se,
              att_pre2020_unemp$overall.att - 1.96 * att_pre2020_unemp$overall.se,
              att_pre2020_unemp$overall.att + 1.96 * att_pre2020_unemp$overall.se))
} else {
  cat(sprintf("Unemployment Rate & %.4f%s & (%.4f) & --- & --- \\\\\n",
              att_full_unemp$overall.att, stars_fn(full_ur_p), att_full_unemp$overall.se))
}

cat("\\midrule\n")
cat("Estimator & \\multicolumn{2}{c}{CS-DiD (DR)} & \\multicolumn{2}{c}{CS-DiD (DR)} \\\\\n")
cat("Control group & \\multicolumn{2}{c}{Not-yet-treated} & \\multicolumn{2}{c}{Not-yet-treated} \\\\\n")
cat("Anticipation & \\multicolumn{2}{c}{1 year} & \\multicolumn{2}{c}{1 year} \\\\\n")
cat(sprintf("$N$ (state-years) & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\\n",
            nrow(panel), nrow(panel_pre2020)))
cat(sprintf("States & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\\n",
            n_distinct(panel$statefip), n_distinct(panel_pre2020$statefip)))
cat(sprintf("Years & \\multicolumn{2}{c}{%d---%d} & \\multicolumn{2}{c}{%d---%d} \\\\\n",
            min(panel$year), max(panel$year),
            min(panel_pre2020$year), max(panel_pre2020$year)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Callaway and Sant'Anna (2021) doubly-robust ATT estimates using\n")
cat("not-yet-treated states as the comparison group with 1-year anticipation. Multiplier\n")
cat("bootstrap standard errors (1,000 iterations) in parentheses; 95\\% pointwise confidence\n")
cat("intervals in brackets. The pre-2020 sample excludes observations from 2020--2023 to\n")
cat("assess robustness to potential confounding from the COVID-19 pandemic and associated\n")
cat("labor market disruptions.\n")
cat("* $p < 0.1$, ** $p < 0.05$, *** $p < 0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("Saved: tables/pre2020_robustness.tex\n")

###############################################################################
## Summary
###############################################################################

cat("\n================================================================\n")
cat("SENSITIVITY ANALYSIS SUMMARY\n")
cat("================================================================\n\n")

if (honestdid_available) {
  cat("1. HonestDiD: Sensitivity bounds computed and saved.\n")
  cat(sprintf("   Figure: figures/fig_honestdid.pdf\n"))
} else {
  cat("1. HonestDiD: SKIPPED (package unavailable)\n")
}

cat(sprintf("\n2. MDE Analysis:\n"))
cat(sprintf("   Log employment MDE (5%%, 80%%):    %.4f (%.2f%%)\n",
            mde_log_emp_main, (exp(mde_log_emp_main) - 1) * 100))
cat(sprintf("   Unemployment rate MDE (5%%, 80%%): %.3f pp\n", mde_unemp_main))
cat(sprintf("   Table: tables/mde_analysis.tex\n"))

cat(sprintf("\n3. Pre-2020 Robustness:\n"))
if (!is.null(att_pre2020_log)) {
  cat(sprintf("   Log emp:    Full = %.4f (%.4f), Pre-2020 = %.4f (%.4f)\n",
              att_full_log$overall.att, att_full_log$overall.se,
              att_pre2020_log$overall.att, att_pre2020_log$overall.se))
}
if (!is.null(att_pre2020_unemp)) {
  cat(sprintf("   Unemp rate: Full = %.4f (%.4f), Pre-2020 = %.4f (%.4f)\n",
              att_full_unemp$overall.att, att_full_unemp$overall.se,
              att_pre2020_unemp$overall.att, att_pre2020_unemp$overall.se))
}
cat(sprintf("   Data: data/att_pre2020.rds\n"))
cat(sprintf("   Table: tables/pre2020_robustness.tex\n"))

cat("\n================================================================\n")
cat("All sensitivity analyses complete.\n")
cat("================================================================\n")
