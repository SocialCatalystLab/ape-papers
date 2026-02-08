# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 09_appendix.R - Appendix tables and figures
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# All appendix tables formatted with kableExtra / booktabs style.
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================\n")
cat("  09_appendix.R\n")
cat("========================================\n\n")

# ==============================================================================
# 0. LOAD DATA AND RESULTS
# ==============================================================================

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Loaded analysis panel: %s rows, %d cols\n",
            format(nrow(analysis), big.mark = ","), ncol(analysis)))

# Ensure output directories
dir.create("tables", showWarnings = FALSE, recursive = TRUE)
dir.create("figures", showWarnings = FALSE, recursive = TRUE)

# Load descriptive results
if (file.exists("data/descriptive_results.RData")) {
  load("data/descriptive_results.RData")
  cat("  Loaded: descriptive_results.RData\n")
}

# Load main results
main_results <- if (file.exists("tables/main_results.csv")) {
  read_csv("tables/main_results.csv", show_col_types = FALSE)
} else NULL

# Load robustness results
robustness_results <- if (file.exists("tables/robustness_results.csv")) {
  read_csv("tables/robustness_results.csv", show_col_types = FALSE)
} else NULL

# Load Bacon decomposition results
bacon_results <- if (file.exists("tables/bacon_decomposition.csv")) {
  read_csv("tables/bacon_decomposition.csv", show_col_types = FALSE)
} else NULL

# Load HonestDiD results
honestdid_results <- if (file.exists("tables/honestdid_bounds.csv")) {
  read_csv("tables/honestdid_bounds.csv", show_col_types = FALSE)
} else NULL

# Load pre-trend test results
pretrend_results <- if (file.exists("tables/pretrend_tests.csv")) {
  read_csv("tables/pretrend_tests.csv", show_col_types = FALSE)
} else NULL

# Sample info
sample_info <- list(
  N          = nrow(analysis),
  n_clusters = n_distinct(analysis$state_fips),
  n_treated  = n_distinct(analysis$place_id[analysis$treated])
)


# ==============================================================================
# APPENDIX TABLE A1: DETAILED BALANCE TABLE
# ==============================================================================
cat("\n=== Appendix Table A1: Detailed Balance Table ===\n")

# Variables for balance: all outcomes + all controls + volume measures
balance_vars <- c(
  "individualizing", "binding", "universalism_index", "log_univ_comm",
  "moral_intensity",
  "care_p", "fairness_p", "loyalty_p", "authority_p", "sanctity_p",
  "broadband_rate", "population", "median_income", "pct_college",
  "pct_white", "median_age", "n_meetings", "n_total_words"
)

# Keep only those present in data
available_balance <- balance_vars[balance_vars %in% names(analysis)]

# Variable display labels
balance_labels <- c(
  individualizing    = "Individualizing",
  binding            = "Binding",
  universalism_index = "Universalism Index",
  log_univ_comm      = "Log Ratio (Ind./Bind.)",
  moral_intensity    = "Moral Intensity",
  care_p             = "Care",
  fairness_p         = "Fairness",
  loyalty_p          = "Loyalty",
  authority_p        = "Authority",
  sanctity_p         = "Sanctity",
  broadband_rate     = "Broadband Rate",
  population         = "Population",
  median_income      = "Median Income",
  pct_college        = "\\% College",
  pct_white          = "\\% White",
  median_age         = "Median Age",
  n_meetings         = "N Meetings",
  n_total_words      = "N Total Words"
)

# Restrict to pre-treatment periods
pre_treatment <- analysis %>%
  filter(
    (treated & year < treat_year) |
    (!treated)
  )

# Collapse to place-level means
place_means <- pre_treatment %>%
  group_by(place_id, treated) %>%
  summarise(
    across(all_of(available_balance), ~mean(., na.rm = TRUE)),
    n_years = n(),
    .groups = "drop"
  )

# Compute detailed balance statistics
tabA1_rows <- lapply(available_balance, function(v) {
  x_t <- place_means[[v]][place_means$treated]
  x_c <- place_means[[v]][!place_means$treated]

  n_t <- sum(!is.na(x_t))
  n_c <- sum(!is.na(x_c))
  mean_t <- mean(x_t, na.rm = TRUE)
  mean_c <- mean(x_c, na.rm = TRUE)
  sd_t <- sd(x_t, na.rm = TRUE)
  sd_c <- sd(x_c, na.rm = TRUE)

  # Normalized difference (Imbens & Rubin 2015)
  norm_diff <- (mean_t - mean_c) / sqrt((sd_t^2 + sd_c^2) / 2)

  # Welch t-test
  tt <- tryCatch(
    t.test(x_t, x_c, var.equal = FALSE),
    error = function(e) list(p.value = NA_real_, stderr = NA_real_)
  )

  tibble(
    Variable      = ifelse(v %in% names(balance_labels), balance_labels[v], v),
    N_Treated     = n_t,
    N_Control     = n_c,
    Mean_Treated  = mean_t,
    SD_Treated    = sd_t,
    Mean_Control  = mean_c,
    SD_Control    = sd_c,
    Difference    = mean_t - mean_c,
    Norm_Diff     = norm_diff,
    p_value       = tt$p.value,
    Balanced      = abs(norm_diff) < 0.25
  )
})

tabA1 <- bind_rows(tabA1_rows)

write_csv(tabA1, "tables/tableA1_balance.csv")

# LaTeX formatting
tabA1_latex <- tabA1 %>%
  mutate(
    N_Treated    = format(N_Treated, big.mark = ","),
    N_Control    = format(N_Control, big.mark = ","),
    Mean_Treated = sprintf("%.4f", Mean_Treated),
    SD_Treated   = sprintf("%.4f", SD_Treated),
    Mean_Control = sprintf("%.4f", Mean_Control),
    SD_Control   = sprintf("%.4f", SD_Control),
    Difference   = sprintf("%.4f", Difference),
    Norm_Diff    = sprintf("%.3f", Norm_Diff),
    p_value      = sprintf("%.3f", p_value)
  ) %>%
  select(-Balanced)

kbl_A1 <- kbl(tabA1_latex,
    format   = "latex",
    booktabs = TRUE,
    escape   = FALSE,
    align    = c("l", "r", "r", "r", "r", "r", "r", "r", "r", "r"),
    col.names = c("Variable", "$N_T$", "$N_C$",
                  "Mean$_T$", "SD$_T$",
                  "Mean$_C$", "SD$_C$",
                  "Diff.", "Norm.\\ Diff.", "$p$-value"),
    caption  = "Detailed Pre-Treatment Balance: Treated vs.\\ Never-Treated Places",
    label    = "tab:balance_detail") %>%
  kable_styling(latex_options = c("hold_position", "scale_down")) %>%
  footnote(
    general = paste0(
      "Pre-treatment place-level means for treated and never-treated places. ",
      "Normalized differences follow Imbens and Rubin (2015): ",
      "$\\\\Delta_{\\\\text{norm}} = (\\\\bar{x}_T - \\\\bar{x}_C) / ",
      "\\\\sqrt{(s_T^2 + s_C^2)/2}$. ",
      "Values $|\\\\Delta_{\\\\text{norm}}| < 0.25$ indicate acceptable balance. ",
      "$p$-values from Welch $t$-tests (unequal variances)."),
    general_title = "Notes:",
    footnote_as_chunk = TRUE,
    escape = FALSE
  )

writeLines(kbl_A1, "tables/tableA1_balance.tex")
cat("  Saved: tables/tableA1_balance.tex, tables/tableA1_balance.csv\n")

# Flag imbalanced
n_imbalanced <- sum(!tabA1$Balanced, na.rm = TRUE)
if (n_imbalanced > 0) {
  cat(sprintf("  WARNING: %d variable(s) with |norm. diff.| >= 0.25\n", n_imbalanced))
  imb_vars <- tabA1$Variable[!tabA1$Balanced]
  cat(paste("    -", imb_vars, collapse = "\n"), "\n")
} else {
  cat("  All variables balanced (|norm. diff.| < 0.25).\n")
}


# ==============================================================================
# APPENDIX TABLE A2: PRE-TREND TEST RESULTS
# ==============================================================================
cat("\n=== Appendix Table A2: Pre-Trend Test Results ===\n")

if (!is.null(pretrend_results)) {
  # Use pre-computed results
  tabA2 <- pretrend_results
} else {
  # Compute pre-trend tests via joint F-test on event-study pre-treatment coefficients
  # This requires the did package and the analysis panel
  cat("  Computing pre-trend tests from analysis panel...\n")

  pretrend_outcomes <- c("individualizing", "binding", "universalism_index",
                         "log_univ_comm", "care_p", "fairness_p",
                         "loyalty_p", "authority_p", "sanctity_p")
  pretrend_outcomes <- pretrend_outcomes[pretrend_outcomes %in% names(analysis)]

  tabA2_rows <- lapply(pretrend_outcomes, function(out) {
    cat(sprintf("    Testing pre-trends for: %s ...", out))

    # Estimate C-S group-time ATTs
    cs_result <- tryCatch({
      did::att_gt(
        yname       = out,
        tname       = "year",
        idname      = "place_id",
        gname       = "treat_year",
        data        = analysis,
        control_group = "nevertreated",
        clustervars = "state_fips",
        base_period = "universal",
        bstrap      = TRUE,
        cband       = FALSE
      )
    }, error = function(e) {
      cat(sprintf(" ERROR: %s\n", e$message))
      return(NULL)
    })

    if (is.null(cs_result)) {
      return(tibble(
        Outcome = out,
        Chi2    = NA_real_,
        df      = NA_integer_,
        p_value = NA_real_,
        Power   = NA_real_
      ))
    }

    # Extract pre-treatment ATTs
    pre_idx <- which(cs_result$t < cs_result$group)
    pre_att <- cs_result$att[pre_idx]
    pre_se  <- cs_result$se[pre_idx]

    if (length(pre_att) == 0 || all(is.na(pre_se)) || all(pre_se == 0)) {
      cat(" no pre-treatment periods\n")
      return(tibble(
        Outcome = out,
        Chi2    = NA_real_,
        df      = NA_integer_,
        p_value = NA_real_,
        Power   = NA_real_
      ))
    }

    # Joint Wald chi-squared test: sum of (att/se)^2
    valid <- !is.na(pre_att) & !is.na(pre_se) & pre_se > 0
    pre_att_v <- pre_att[valid]
    pre_se_v  <- pre_se[valid]
    k <- length(pre_att_v)

    if (k == 0) {
      cat(" no valid pre-treatment estimates\n")
      return(tibble(
        Outcome = out,
        Chi2    = NA_real_,
        df      = NA_integer_,
        p_value = NA_real_,
        Power   = NA_real_
      ))
    }

    chi2_stat <- sum((pre_att_v / pre_se_v)^2)
    p_val     <- 1 - pchisq(chi2_stat, df = k)

    # Power of the pre-trend test (probability of detecting a trend of 0.05 SD/year)
    sd_y <- sd(analysis[[out]], na.rm = TRUE)
    ncp  <- sum((0.05 * sd_y / pre_se_v)^2)
    power_val <- 1 - pchisq(qchisq(0.95, df = k), df = k, ncp = ncp)

    cat(sprintf(" chi2 = %.2f (df = %d), p = %.3f, power = %.2f\n",
                chi2_stat, k, p_val, power_val))

    tibble(
      Outcome = out,
      Chi2    = chi2_stat,
      df      = k,
      p_value = p_val,
      Power   = power_val
    )
  })

  tabA2 <- bind_rows(tabA2_rows)
}

write_csv(tabA2, "tables/tableA2_pretrends.csv")

# Nice outcome labels
outcome_labels_full <- c(
  individualizing    = "Individualizing",
  binding            = "Binding",
  universalism_index = "Universalism Index",
  log_univ_comm      = "Log Ratio",
  care_p             = "Care",
  fairness_p         = "Fairness",
  loyalty_p          = "Loyalty",
  authority_p        = "Authority",
  sanctity_p         = "Sanctity"
)

tabA2_latex <- tabA2 %>%
  mutate(
    Outcome = ifelse(Outcome %in% names(outcome_labels_full),
                     outcome_labels_full[Outcome], Outcome),
    Chi2    = ifelse(is.na(Chi2), "---", sprintf("%.2f", Chi2)),
    df      = ifelse(is.na(df), "---", as.character(df)),
    p_value = ifelse(is.na(p_value), "---", sprintf("%.3f", as.numeric(p_value))),
    Power   = ifelse(is.na(Power), "---", sprintf("%.2f", as.numeric(Power)))
  )

kbl_A2 <- kbl(tabA2_latex,
    format   = "latex",
    booktabs = TRUE,
    escape   = FALSE,
    align    = c("l", "r", "r", "r", "r"),
    col.names = c("Outcome", "$\\chi^2$", "df", "$p$-value", "Power"),
    caption  = "Joint Pre-Trend Tests",
    label    = "tab:pretrends") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(
    general = paste0(
      "Joint Wald $\\\\chi^2$ test of the null that all pre-treatment ",
      "event-study coefficients are jointly zero. ",
      "Computed from Callaway--Sant'Anna group-time ATTs. ",
      "Power is the probability of detecting a linear trend of 0.05 SD/year ",
      "in the pre-period at the 5\\% level. ",
      "Standard errors clustered at state level."),
    general_title = "Notes:",
    footnote_as_chunk = TRUE,
    escape = FALSE
  )

writeLines(kbl_A2, "tables/tableA2_pretrends.tex")
cat("  Saved: tables/tableA2_pretrends.tex, tables/tableA2_pretrends.csv\n")


# ==============================================================================
# APPENDIX TABLE A3: TWFE vs C-S COMPARISON
# ==============================================================================
cat("\n=== Appendix Table A3: TWFE vs C-S Comparison ===\n")

comparison_outcomes <- c("individualizing", "binding", "universalism_index",
                         "log_univ_comm", "care_p", "fairness_p",
                         "loyalty_p", "authority_p", "sanctity_p")
comparison_outcomes <- comparison_outcomes[comparison_outcomes %in% names(analysis)]

# Create post-treatment indicator
analysis <- analysis %>%
  mutate(
    post = ifelse(treated & year >= treat_year, 1, 0)
  )

tabA3_rows <- lapply(comparison_outcomes, function(out) {
  cat(sprintf("    Estimating TWFE and C-S for: %s\n", out))

  # --- TWFE via fixest ---
  twfe <- tryCatch({
    fml <- as.formula(sprintf("%s ~ post | place_id + year", out))
    feols(fml, data = analysis, cluster = ~state_fips)
  }, error = function(e) {
    cat(sprintf("      TWFE error: %s\n", e$message))
    NULL
  })

  twfe_att <- if (!is.null(twfe)) coef(twfe)["post"] else NA_real_
  twfe_se  <- if (!is.null(twfe)) {
    sqrt(vcov(twfe)["post", "post"])
  } else NA_real_
  twfe_p <- if (!is.na(twfe_att) && !is.na(twfe_se)) {
    2 * pnorm(-abs(twfe_att / twfe_se))
  } else NA_real_

  # --- C-S from main_results if available ---
  cs_att <- NA_real_
  cs_se  <- NA_real_
  cs_p   <- NA_real_

  if (!is.null(main_results)) {
    cs_row <- main_results %>%
      filter(outcome == out,
             specification %in% c("with_controls", "no_controls")) %>%
      slice(1)
    if (nrow(cs_row) > 0) {
      cs_att <- cs_row$att
      cs_se  <- cs_row$se
      cs_p <- ifelse("pval" %in% names(cs_row), cs_row$pval,
              ifelse("p_value" %in% names(cs_row), cs_row$p_value,
                     2 * pnorm(-abs(cs_att / cs_se))))
    }
  }

  # If C-S not in main_results, estimate directly
  if (is.na(cs_att)) {
    cs_result <- tryCatch({
      did::att_gt(
        yname         = out,
        tname         = "year",
        idname        = "place_id",
        gname         = "treat_year",
        data          = analysis,
        control_group = "nevertreated",
        clustervars   = "state_fips",
        base_period   = "universal",
        bstrap        = TRUE,
        cband         = FALSE
      )
    }, error = function(e) NULL)

    if (!is.null(cs_result)) {
      agg <- did::aggte(cs_result, type = "simple")
      cs_att <- agg$overall.att
      cs_se  <- agg$overall.se
      cs_p   <- ifelse(cs_se > 0, 2 * pnorm(-abs(cs_att / cs_se)), NA_real_)
    }
  }

  tibble(
    Outcome  = out,
    TWFE_ATT = twfe_att,
    TWFE_SE  = twfe_se,
    TWFE_p   = as.numeric(twfe_p),
    CS_ATT   = cs_att,
    CS_SE    = cs_se,
    CS_p     = as.numeric(cs_p)
  )
})

tabA3 <- bind_rows(tabA3_rows)
write_csv(tabA3, "tables/tableA3_twfe_vs_cs.csv")

# LaTeX formatting
tabA3_latex <- tabA3 %>%
  mutate(
    Outcome   = ifelse(Outcome %in% names(outcome_labels_full),
                       outcome_labels_full[Outcome], Outcome),
    TWFE_coef = mapply(format_coef, TWFE_ATT, TWFE_SE, TWFE_p),
    TWFE_se   = ifelse(is.na(TWFE_SE), "", sprintf("(%.4f)", TWFE_SE)),
    CS_coef   = mapply(format_coef, CS_ATT, CS_SE, CS_p),
    CS_se     = ifelse(is.na(CS_SE), "", sprintf("(%.4f)", CS_SE))
  ) %>%
  select(Outcome, TWFE_coef, TWFE_se, CS_coef, CS_se)

# Interleave coefficient and SE rows
tabA3_interleaved <- list()
for (i in seq_len(nrow(tabA3_latex))) {
  r <- tabA3_latex[i, ]
  tabA3_interleaved <- c(tabA3_interleaved, list(
    tibble(Outcome = r$Outcome, TWFE = r$TWFE_coef, CS = r$CS_coef),
    tibble(Outcome = "", TWFE = r$TWFE_se, CS = r$CS_se)
  ))
}
tabA3_final <- bind_rows(tabA3_interleaved)

kbl_A3 <- kbl(tabA3_final,
    format   = "latex",
    booktabs = TRUE,
    escape   = FALSE,
    align    = c("l", "c", "c"),
    col.names = c("Outcome", "TWFE", "Callaway--Sant'Anna"),
    caption  = "Comparison of TWFE and Callaway--Sant'Anna Estimates",
    label    = "tab:twfe_cs") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(
    general = sprintf(
      paste0("TWFE: Two-way fixed effects with place and year FEs. ",
             "Callaway--Sant'Anna (2021): heterogeneity-robust staggered DiD. ",
             "Both use never-treated places as controls. ",
             "N = %s. Clusters (states) = %d. ",
             "Standard errors clustered at state level. ",
             "$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.10$."),
      format(sample_info$N, big.mark = ","),
      sample_info$n_clusters),
    general_title = "Notes:",
    footnote_as_chunk = TRUE,
    escape = FALSE
  )

writeLines(kbl_A3, "tables/tableA3_twfe_vs_cs.tex")
cat("  Saved: tables/tableA3_twfe_vs_cs.tex, tables/tableA3_twfe_vs_cs.csv\n")

# Helper function for format_coef (needed for Table A3 and A4)
format_coef <- function(coef, se, pval = NULL) {
  if (is.na(coef) || is.na(se)) return("---")
  if (is.null(pval) || is.na(pval)) pval <- 2 * pnorm(-abs(coef / se))
  stars <- ifelse(pval < 0.01, "***",
           ifelse(pval < 0.05, "**",
           ifelse(pval < 0.10, "*", "")))
  sprintf("%.4f%s", coef, stars)
}


# ==============================================================================
# APPENDIX TABLE A4: GOODMAN-BACON DECOMPOSITION
# ==============================================================================
cat("\n=== Appendix Table A4: Goodman-Bacon Decomposition ===\n")

if (!is.null(bacon_results)) {
  tabA4 <- bacon_results
} else {
  # Compute Bacon decomposition for universalism_index
  cat("  Computing Bacon decomposition...\n")

  tabA4 <- tryCatch({
    # bacondecomp requires balanced panel and binary treatment indicator
    bacon_data <- analysis %>%
      select(place_id, year, universalism_index, post, state_fips) %>%
      filter(!is.na(universalism_index))

    bacon_out <- bacon(
      universalism_index ~ post,
      data  = bacon_data,
      id_var = "place_id",
      time_var = "year"
    )

    # Aggregate by type
    bacon_summary <- bacon_out %>%
      group_by(type) %>%
      summarise(
        N_Comparisons = n(),
        Weight        = sum(weight),
        Avg_ATT       = weighted.mean(estimate, weight),
        Min_ATT       = min(estimate),
        Max_ATT       = max(estimate),
        .groups       = "drop"
      ) %>%
      arrange(desc(Weight))

    cat("  Bacon decomposition complete.\n")
    bacon_summary
  }, error = function(e) {
    cat(sprintf("  ERROR in Bacon decomposition: %s\n", e$message))
    cat("  This may occur if the panel is not balanced.\n")
    tibble(
      type          = character(),
      N_Comparisons = integer(),
      Weight        = numeric(),
      Avg_ATT       = numeric(),
      Min_ATT       = numeric(),
      Max_ATT       = numeric()
    )
  })
}

if (nrow(tabA4) > 0) {
  write_csv(tabA4, "tables/tableA4_bacon.csv")

  # Type labels
  type_labels <- c(
    "Earlier vs Later Treated"  = "Earlier vs.\\ Later Treated",
    "Later vs Earlier Treated"  = "Later vs.\\ Earlier Treated",
    "Treated vs Untreated"      = "Treated vs.\\ Never-Treated",
    "Later vs Always Treated"   = "Later vs.\\ Always Treated",
    "Earlier vs Always Treated" = "Earlier vs.\\ Always Treated"
  )

  tabA4_latex <- tabA4 %>%
    mutate(
      Type = ifelse(type %in% names(type_labels), type_labels[type], type),
      N_Comparisons = format(N_Comparisons, big.mark = ","),
      Weight  = sprintf("%.3f", Weight),
      Avg_ATT = sprintf("%.4f", Avg_ATT),
      Min_ATT = sprintf("%.4f", Min_ATT),
      Max_ATT = sprintf("%.4f", Max_ATT)
    ) %>%
    select(Type, N_Comparisons, Weight, Avg_ATT, Min_ATT, Max_ATT)

  kbl_A4 <- kbl(tabA4_latex,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("l", "r", "r", "r", "r", "r"),
      col.names = c("Comparison Type", "N Pairs", "Weight",
                    "Avg.\\ ATT", "Min ATT", "Max ATT"),
      caption  = "Goodman-Bacon (2021) Decomposition of TWFE Estimate",
      label    = "tab:bacon") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(
      general = paste0(
        "Outcome: universalism index. Decomposition of the static TWFE ",
        "estimate into its constituent $2 \\\\times 2$ DiD comparisons, ",
        "following Goodman-Bacon (2021). ",
        "Weights sum to 1. ``Earlier vs.\\\\ Later Treated'' comparisons ",
        "are vulnerable to heterogeneous treatment effect bias. ",
        "N = %s. ", sprintf(format(sample_info$N, big.mark = ",")),
        "Clusters (states) = %d.", sample_info$n_clusters),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_A4, "tables/tableA4_bacon.tex")
  cat("  Saved: tables/tableA4_bacon.tex, tables/tableA4_bacon.csv\n")
} else {
  cat("  SKIPPED: Bacon decomposition produced no results.\n")
}


# ==============================================================================
# APPENDIX TABLE A5: HONESTDID BOUNDS
# ==============================================================================
cat("\n=== Appendix Table A5: HonestDiD Bounds ===\n")

if (!is.null(honestdid_results)) {
  tabA5 <- honestdid_results
  cat("  Loaded pre-computed HonestDiD bounds.\n")
} else {
  # Attempt to compute HonestDiD bounds
  cat("  Attempting to compute HonestDiD bounds...\n")

  tabA5 <- tryCatch({
    library(HonestDiD)

    # Need event-study estimates from C-S
    cs_result <- did::att_gt(
      yname         = "universalism_index",
      tname         = "year",
      idname        = "place_id",
      gname         = "treat_year",
      data          = analysis,
      control_group = "nevertreated",
      clustervars   = "state_fips",
      base_period   = "universal",
      bstrap        = TRUE,
      cband         = FALSE
    )

    es <- did::aggte(cs_result, type = "dynamic")

    # Extract event-study coefficients and VCV
    beta_hat <- es$att.egt
    sigma    <- es$V_analytical
    if (is.null(sigma)) sigma <- es$V

    # Identify pre and post indices
    event_times <- es$egt
    pre_idx  <- which(event_times < 0)
    post_idx <- which(event_times >= 0)

    if (length(pre_idx) < 2 || length(post_idx) < 1) {
      stop("Not enough pre/post periods for HonestDiD")
    }

    # Compute bounds for range of M values
    M_values <- c(0, 0.01, 0.02, 0.05, 0.10)
    honest_rows <- list()

    for (M in M_values) {
      honest <- tryCatch({
        HonestDiD::createSensitivityResults(
          betahat        = beta_hat,
          sigma          = sigma,
          numPrePeriods  = length(pre_idx),
          numPostPeriods = length(post_idx),
          Mvec           = M,
          method         = "C-LF"
        )
      }, error = function(e) NULL)

      if (!is.null(honest) && nrow(honest) > 0) {
        honest_rows <- c(honest_rows, list(tibble(
          M        = M,
          CI_Lower = honest$lb[1],
          CI_Upper = honest$ub[1],
          Includes_Zero = (honest$lb[1] <= 0 & honest$ub[1] >= 0)
        )))
      }
    }

    bind_rows(honest_rows)
  }, error = function(e) {
    cat(sprintf("  HonestDiD failed: %s\n", e$message))
    cat("  This requires the HonestDiD package and sufficient pre-periods.\n")
    tibble(
      M             = numeric(),
      CI_Lower      = numeric(),
      CI_Upper      = numeric(),
      Includes_Zero = logical()
    )
  })
}

if (nrow(tabA5) > 0) {
  write_csv(tabA5, "tables/tableA5_honestdid.csv")

  tabA5_latex <- tabA5 %>%
    mutate(
      M             = sprintf("%.2f", M),
      CI_Lower      = sprintf("%.4f", CI_Lower),
      CI_Upper      = sprintf("%.4f", CI_Upper),
      CI_95         = sprintf("[%s, %s]", CI_Lower, CI_Upper),
      Includes_Zero = ifelse(Includes_Zero, "Yes", "No")
    ) %>%
    select(M, CI_95, Includes_Zero)

  kbl_A5 <- kbl(tabA5_latex,
      format   = "latex",
      booktabs = TRUE,
      escape   = FALSE,
      align    = c("r", "c", "c"),
      col.names = c("$\\bar{M}$", "95\\% Robust CI", "Includes Zero?"),
      caption  = "HonestDiD Sensitivity Analysis: Universalism Index",
      label    = "tab:honestdid") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(
      general = paste0(
        "Sensitivity analysis following Rambachan and Roth (2023). ",
        "$\\\\bar{M}$ bounds the maximum deviation from a linear pre-trend. ",
        "When $\\\\bar{M} = 0$, the result assumes parallel trends hold exactly. ",
        "Larger $\\\\bar{M}$ allows increasingly nonlinear deviations. ",
        "CI computed using the conditional-on-linear-fit method (C-LF). ",
        "Outcome: universalism index. ",
        "N = %s. Clusters (states) = %d.",
        format(sample_info$N, big.mark = ","), sample_info$n_clusters),
      general_title = "Notes:",
      footnote_as_chunk = TRUE,
      escape = FALSE
    )

  writeLines(kbl_A5, "tables/tableA5_honestdid.tex")
  cat("  Saved: tables/tableA5_honestdid.tex, tables/tableA5_honestdid.csv\n")

} else {
  cat("  SKIPPED: HonestDiD produced no results.\n")
}


# ==============================================================================
# APPENDIX TABLE A6: ATTRITION ANALYSIS
# ==============================================================================
cat("\n=== Appendix Table A6: Attrition Analysis ===\n")

# Does treatment predict exit from the panel?
# For each place, determine if it has a full panel (all years present)

all_years <- sort(unique(analysis$year))
n_years_total <- length(all_years)

panel_coverage <- analysis %>%
  group_by(place_id) %>%
  summarise(
    n_years_obs = n(),
    treated     = first(treated),
    treat_year  = first(treat_year),
    state_fips  = first(state_fips),
    .groups     = "drop"
  ) %>%
  mutate(
    full_panel    = (n_years_obs == n_years_total),
    attrited      = !full_panel,
    pct_coverage  = n_years_obs / n_years_total * 100
  )

cat(sprintf("  Total places: %s\n", format(nrow(panel_coverage), big.mark = ",")))
cat(sprintf("  Full panel places: %s (%.1f%%)\n",
            format(sum(panel_coverage$full_panel), big.mark = ","),
            mean(panel_coverage$full_panel) * 100))
cat(sprintf("  Attrited places: %s (%.1f%%)\n",
            format(sum(panel_coverage$attrited), big.mark = ","),
            mean(panel_coverage$attrited) * 100))

# Regression: attrition ~ treated
# (1) Simple: attrited ~ treated
# (2) With state FE: attrited ~ treated | state_fips
# (3) With state FE + controls (pre-treatment characteristics)

# Add pre-treatment means of key variables
pre_means <- analysis %>%
  filter(
    (treated & year < treat_year) | (!treated)
  ) %>%
  group_by(place_id) %>%
  summarise(
    pre_broadband  = mean(broadband_rate, na.rm = TRUE),
    pre_population = mean(population, na.rm = TRUE),
    pre_income     = mean(median_income, na.rm = TRUE),
    pre_meetings   = mean(n_meetings, na.rm = TRUE),
    .groups = "drop"
  )

attrition_data <- panel_coverage %>%
  left_join(pre_means, by = "place_id") %>%
  mutate(
    log_pop = log(pre_population + 1),
    treated_num = as.numeric(treated)
  )

# Model 1: Simple
m1 <- tryCatch(
  feols(attrited ~ treated_num, data = attrition_data, cluster = ~state_fips),
  error = function(e) NULL
)

# Model 2: State FE
m2 <- tryCatch(
  feols(attrited ~ treated_num | state_fips, data = attrition_data, cluster = ~state_fips),
  error = function(e) NULL
)

# Model 3: State FE + controls
m3 <- tryCatch(
  feols(attrited ~ treated_num + pre_broadband + log_pop + pre_income + pre_meetings | state_fips,
        data = attrition_data, cluster = ~state_fips),
  error = function(e) NULL
)

# Build table
attrition_rows <- list()

extract_row <- function(model, spec_name) {
  if (is.null(model)) {
    return(tibble(
      Specification = spec_name,
      Coef = NA_real_, SE = NA_real_, p_value = NA_real_,
      N = NA_integer_, R2 = NA_real_
    ))
  }
  cf <- coef(model)["treated_num"]
  se_val <- sqrt(vcov(model)["treated_num", "treated_num"])
  p_val <- 2 * pnorm(-abs(cf / se_val))
  tibble(
    Specification = spec_name,
    Coef    = as.numeric(cf),
    SE      = as.numeric(se_val),
    p_value = as.numeric(p_val),
    N       = nobs(model),
    R2      = r2(model, type = "r2")
  )
}

attrition_rows <- bind_rows(
  extract_row(m1, "No controls"),
  extract_row(m2, "State FE"),
  extract_row(m3, "State FE + controls")
)

# Dependent variable mean
dep_mean <- mean(attrition_data$attrited, na.rm = TRUE)

# Treated vs untreated attrition rates
att_treated <- mean(attrition_data$attrited[attrition_data$treated], na.rm = TRUE)
att_control <- mean(attrition_data$attrited[!attrition_data$treated], na.rm = TRUE)

tabA6 <- attrition_rows
write_csv(tabA6, "tables/tableA6_attrition.csv")

# LaTeX formatting
tabA6_latex <- tabA6 %>%
  mutate(
    Coef_str = mapply(format_coef, Coef, SE, p_value),
    SE_str   = ifelse(is.na(SE), "", sprintf("(%.4f)", SE)),
    p_value  = ifelse(is.na(p_value), "---", sprintf("%.3f", p_value)),
    N        = ifelse(is.na(N), "---", format(N, big.mark = ",")),
    R2       = ifelse(is.na(R2), "---", sprintf("%.3f", R2))
  ) %>%
  select(Specification, Coef_str, SE_str, p_value, N, R2) %>%
  rename(Treated = Coef_str, SE = SE_str)

# Interleave coefficient and SE rows
tabA6_interleaved <- list()
for (i in seq_len(nrow(tabA6_latex))) {
  r <- tabA6_latex[i, ]
  tabA6_interleaved <- c(tabA6_interleaved, list(
    tibble(Col1 = r$Specification, Col2 = r$Treated, Col3 = r$p_value,
           Col4 = r$N, Col5 = r$R2),
    tibble(Col1 = "", Col2 = r$SE, Col3 = "", Col4 = "", Col5 = "")
  ))
}
tabA6_final <- bind_rows(tabA6_interleaved)

kbl_A6 <- kbl(tabA6_final,
    format   = "latex",
    booktabs = TRUE,
    escape   = FALSE,
    align    = c("l", "c", "r", "r", "r"),
    col.names = c("Specification", "Treated", "$p$-value", "N", "$R^2$"),
    caption  = "Attrition Analysis: Does Treatment Predict Panel Exit?",
    label    = "tab:attrition") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_header_above(c(" " = 1, "Dep.\\ Var.: Attrited" = 4)) %>%
  footnote(
    general = sprintf(
      paste0("Dependent variable: indicator for whether a place has fewer ",
             "than %d years in the panel (mean = %.3f). ",
             "Attrition rate: treated = %.3f, never-treated = %.3f. ",
             "Controls in column (3): pre-treatment broadband rate, ",
             "log population, median income, and number of meetings. ",
             "Standard errors clustered at state level. ",
             "$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.10$."),
      n_years_total, dep_mean, att_treated, att_control),
    general_title = "Notes:",
    footnote_as_chunk = TRUE,
    escape = FALSE
  )

writeLines(kbl_A6, "tables/tableA6_attrition.tex")
cat("  Saved: tables/tableA6_attrition.tex, tables/tableA6_attrition.csv\n")


# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n========================================\n")
cat("  09_appendix.R COMPLETE\n")
cat("========================================\n")
cat("  Appendix tables generated:\n")
for (f in list.files("tables", pattern = "^tableA.*\\.(tex|csv)$")) {
  cat(sprintf("    %s\n", f))
}
cat("========================================\n")
