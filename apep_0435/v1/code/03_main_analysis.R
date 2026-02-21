## ============================================================
## 03_main_analysis.R — Main empirical analysis
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

source("00_packages.R")

DATA_DIR <- "../data"
TABLE_DIR <- "../tables"
dir.create(TABLE_DIR, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(DATA_DIR, "analysis_data.rds"))
cat(sprintf("Loaded analysis data: %d municipalities, %d columns\n",
            nrow(df), ncol(df)))

## ---------------------------------------------------------------
## 1. OLS Persistence Regressions
## ---------------------------------------------------------------
cat("\n=== 1. OLS Persistence: yes_paternity_2020 ~ yes_equal_rights_1981 ===\n")

# (1) Bivariate
m1_biv <- feols(yes_paternity_2020 ~ yes_equal_rights_1981,
                data = df, cluster = ~canton)

# (2) + Language region controls
m1_lang <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 +
                   lang_french + lang_italian,
                 data = df, cluster = ~canton)

# (3) + Historical religion
m1_relig <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 +
                    lang_french + lang_italian + i(hist_religion),
                  data = df, cluster = ~canton)

# (4) + Canton fixed effects (absorbs language + religion)
m1_canton <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                   data = df, cluster = ~canton)

# (5) German-speaking only
df_de <- df |> filter(primary_language == "de")
m1_german <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                   data = df_de, cluster = ~canton)

cat("R-squared progression:\n")
cat(sprintf("  Bivariate:        R2 = %.4f (adj = %.4f)\n",
            r2(m1_biv, "r2"), r2(m1_biv, "ar2")))
cat(sprintf("  + Language:       R2 = %.4f (adj = %.4f)\n",
            r2(m1_lang, "r2"), r2(m1_lang, "ar2")))
cat(sprintf("  + Religion:       R2 = %.4f (adj = %.4f)\n",
            r2(m1_relig, "r2"), r2(m1_relig, "ar2")))
cat(sprintf("  + Canton FE:      R2 = %.4f (adj = %.4f)\n",
            r2(m1_canton, "r2"), r2(m1_canton, "ar2")))
cat(sprintf("  German only + FE: R2 = %.4f (adj = %.4f)\n",
            r2(m1_german, "r2"), r2(m1_german, "ar2")))

cat("\nKey coefficient — bivariate:\n")
print(summary(m1_biv))

cat("\nKey coefficient — canton FE:\n")
print(summary(m1_canton))

## ---------------------------------------------------------------
## 2. Beta-Convergence
## ---------------------------------------------------------------
cat("\n=== 2. Beta-Convergence: delta_gender ~ yes_equal_rights_1981 ===\n")

# Full sample
m2_all <- feols(delta_gender ~ yes_equal_rights_1981,
                data = df, cluster = ~canton)

# German-only
m2_de <- feols(delta_gender ~ yes_equal_rights_1981,
               data = df_de, cluster = ~canton)

# French-only
df_fr <- df |> filter(primary_language == "fr")
m2_fr <- feols(delta_gender ~ yes_equal_rights_1981,
               data = df_fr, cluster = ~canton)

# With canton FE
m2_fe <- feols(delta_gender ~ yes_equal_rights_1981 | canton,
               data = df, cluster = ~canton)

cat("Beta-convergence results (negative beta = convergence):\n")
cat(sprintf("  All:        beta = %.4f (SE = %.4f), t = %.2f\n",
            coef(m2_all)["yes_equal_rights_1981"],
            se(m2_all)["yes_equal_rights_1981"],
            tstat(m2_all)["yes_equal_rights_1981"]))
cat(sprintf("  German:     beta = %.4f (SE = %.4f), t = %.2f\n",
            coef(m2_de)["yes_equal_rights_1981"],
            se(m2_de)["yes_equal_rights_1981"],
            tstat(m2_de)["yes_equal_rights_1981"]))
cat(sprintf("  French:     beta = %.4f (SE = %.4f), t = %.2f\n",
            coef(m2_fr)["yes_equal_rights_1981"],
            se(m2_fr)["yes_equal_rights_1981"],
            tstat(m2_fr)["yes_equal_rights_1981"]))
cat(sprintf("  Canton FE:  beta = %.4f (SE = %.4f), t = %.2f\n",
            coef(m2_fe)["yes_equal_rights_1981"],
            se(m2_fe)["yes_equal_rights_1981"],
            tstat(m2_fe)["yes_equal_rights_1981"]))

## ---------------------------------------------------------------
## 3. Sigma-Convergence
## ---------------------------------------------------------------
cat("\n=== 3. Sigma-Convergence ===\n")

# Cross-municipality SD of gender YES share for each referendum year
sigma_data <- tribble(
  ~year, ~variable,                  ~label,
  1981,  "yes_equal_rights_1981",    "Equal Rights 1981",
  1984,  "yes_maternity_1984",       "Maternity 1984",
  1999,  "yes_maternity_1999",       "Maternity 1999",
  2004,  "yes_maternity_2004",       "Maternity 2004",
  2020,  "yes_paternity_2020",       "Paternity 2020",
  2021,  "yes_marriage_2021",        "Marriage Equality 2021"
)

sigma_results <- sigma_data |>
  rowwise() |>
  mutate(
    sd_all = sd(df[[variable]], na.rm = TRUE),
    sd_german = sd(df_de[[variable]], na.rm = TRUE),
    sd_french = sd(df_fr[[variable]], na.rm = TRUE),
    mean_all = mean(df[[variable]], na.rm = TRUE),
    cv_all = sd_all / mean_all  # coefficient of variation
  ) |>
  ungroup()

cat("Cross-municipality standard deviation by referendum year:\n")
print(sigma_results |> select(year, label, sd_all, sd_german, sd_french, cv_all))

# Test: is sigma declining over time? Regress SD on year
sigma_lm <- lm(sd_all ~ year, data = sigma_results)
cat(sprintf("\nSigma-trend regression: slope = %.4f (p = %.4f)\n",
            coef(sigma_lm)["year"],
            summary(sigma_lm)$coefficients["year", "Pr(>|t|)"]))

# Also compute coefficient of variation trend
cv_lm <- lm(cv_all ~ year, data = sigma_results)
cat(sprintf("CV-trend regression: slope = %.6f (p = %.4f)\n",
            coef(cv_lm)["year"],
            summary(cv_lm)$coefficients["year", "Pr(>|t|)"]))

## ---------------------------------------------------------------
## 4. AIPW / Doubly Robust Estimation
## ---------------------------------------------------------------
cat("\n=== 4. AIPW / Doubly Robust Estimation ===\n")

# For continuous treatment (1981 YES share), we implement a manual AIPW:
# (a) Generalized propensity score: f(T | X) using Gaussian kernel density
# (b) Outcome model: E(Y | T, X)
# (c) Augmented estimator combining both

# Prepare variables — drop NAs
df_aipw <- df |>
  filter(!is.na(yes_equal_rights_1981),
         !is.na(yes_paternity_2020),
         !is.na(primary_language),
         !is.na(hist_religion),
         !is.na(suffrage_year)) |>
  mutate(
    lang_fr = as.numeric(primary_language == "fr"),
    lang_it = as.numeric(primary_language == "it"),
    rel_prot = as.numeric(hist_religion == "prot"),
    rel_mixed = as.numeric(hist_religion == "mixed")
  )

cat(sprintf("AIPW sample: %d municipalities\n", nrow(df_aipw)))

# Step (a): Generalized propensity score via parametric model
# Model: T ~ X (normal linear model for continuous treatment)
gps_mod <- lm(yes_equal_rights_1981 ~ lang_fr + lang_it + rel_prot + rel_mixed +
                suffrage_year, data = df_aipw)
gps_resid <- residuals(gps_mod)
gps_sd <- sd(gps_resid)

# Generalized propensity score: f(T_i | X_i) = dnorm((T_i - mu_i) / sigma) / sigma
df_aipw$gps_mu <- fitted(gps_mod)
df_aipw$gps <- dnorm((df_aipw$yes_equal_rights_1981 - df_aipw$gps_mu) / gps_sd) / gps_sd

cat(sprintf("GPS model R2: %.4f\n", summary(gps_mod)$r.squared))
cat(sprintf("GPS: mean = %.4f, sd = %.4f, min = %.6f, max = %.4f\n",
            mean(df_aipw$gps), sd(df_aipw$gps),
            min(df_aipw$gps), max(df_aipw$gps)))

# Step (b): Outcome model
outcome_mod <- lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                    lang_fr + lang_it + rel_prot + rel_mixed + suffrage_year,
                  data = df_aipw)

df_aipw$y_hat <- fitted(outcome_mod)
df_aipw$y_resid <- df_aipw$yes_paternity_2020 - df_aipw$y_hat

cat(sprintf("Outcome model R2: %.4f\n", summary(outcome_mod)$r.squared))

# Step (c): AIPW estimator for the dose-response slope
# Following Hirano & Imbens (2004) generalized propensity score framework
# We use IPW-augmented regression: weight observations by 1/GPS stabilized weights

# Stabilized weights: f(T) / f(T|X)
marginal_sd <- sd(df_aipw$yes_equal_rights_1981)
marginal_mean <- mean(df_aipw$yes_equal_rights_1981)
df_aipw$marginal_gps <- dnorm((df_aipw$yes_equal_rights_1981 - marginal_mean) / marginal_sd) / marginal_sd
df_aipw$stab_weight <- df_aipw$marginal_gps / df_aipw$gps

# Trim extreme weights (1st and 99th percentile)
w_lower <- quantile(df_aipw$stab_weight, 0.01)
w_upper <- quantile(df_aipw$stab_weight, 0.99)
df_aipw$stab_weight_trim <- pmax(pmin(df_aipw$stab_weight, w_upper), w_lower)

cat(sprintf("Stabilized weights: mean = %.3f, sd = %.3f, range = [%.3f, %.3f]\n",
            mean(df_aipw$stab_weight_trim), sd(df_aipw$stab_weight_trim),
            min(df_aipw$stab_weight_trim), max(df_aipw$stab_weight_trim)))

# IPW-weighted regression (doubly robust)
m_aipw <- feols(yes_paternity_2020 ~ yes_equal_rights_1981,
                data = df_aipw, weights = ~stab_weight_trim,
                cluster = ~canton)

cat("\nAIPW (GPS-weighted) persistence estimate:\n")
print(summary(m_aipw))

# Compare: unweighted vs weighted
cat(sprintf("\nUnweighted beta: %.4f (SE = %.4f)\n",
            coef(m1_biv)["yes_equal_rights_1981"],
            se(m1_biv)["yes_equal_rights_1981"]))
cat(sprintf("AIPW-weighted beta: %.4f (SE = %.4f)\n",
            coef(m_aipw)["yes_equal_rights_1981"],
            se(m_aipw)["yes_equal_rights_1981"]))

# Full AIPW with controls (augmented component)
m_aipw_full <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 +
                       lang_fr + lang_it + rel_prot + rel_mixed + suffrage_year,
                     data = df_aipw, weights = ~stab_weight_trim,
                     cluster = ~canton)

cat("\nAIPW with controls (doubly robust):\n")
print(summary(m_aipw_full))

## ---------------------------------------------------------------
## 5. Wild Cluster Bootstrap
## ---------------------------------------------------------------
cat("\n=== 5. Wild Cluster Bootstrap ===\n")

wcb_available <- requireNamespace("fwildclusterboot", quietly = TRUE)

if (wcb_available) {
  library(fwildclusterboot)

  # Bootstrap the main persistence regression (bivariate with canton clustering)
  # fwildclusterboot requires a model from lm() or feols()
  set.seed(2024)  # Reproducibility for bootstrap draws
  cat("Running wild cluster bootstrap (Rademacher, 999 iterations)...\n")

  # Use the bivariate model
  boot_biv <- tryCatch({
    boottest(m1_biv,
             param = "yes_equal_rights_1981",
             B = 999,
             clustid = "canton",
             type = "rademacher")
  }, error = function(e) {
    cat(sprintf("  Bootstrap error: %s\n", e$message))
    NULL
  })

  if (!is.null(boot_biv)) {
    cat("Wild cluster bootstrap — bivariate model:\n")
    print(summary(boot_biv))
    boot_biv_summ <- summary(boot_biv)
    cat(sprintf("  Bootstrap p-value: %.4f\n", boot_biv_summ$p_val))
    cat(sprintf("  Bootstrap CI: [%.4f, %.4f]\n",
                boot_biv$conf_int[1], boot_biv$conf_int[2]))
  }

  # Bootstrap the canton FE model
  cat("\nRunning wild cluster bootstrap for canton FE model...\n")
  boot_fe <- tryCatch({
    boottest(m1_canton,
             param = "yes_equal_rights_1981",
             B = 999,
             clustid = "canton",
             type = "rademacher")
  }, error = function(e) {
    cat(sprintf("  Bootstrap error: %s\n", e$message))
    NULL
  })

  if (!is.null(boot_fe)) {
    cat("Wild cluster bootstrap — canton FE model:\n")
    print(summary(boot_fe))
    boot_fe_summ <- summary(boot_fe)
    cat(sprintf("  Bootstrap p-value: %.4f\n", boot_fe_summ$p_val))
    cat(sprintf("  Bootstrap CI: [%.4f, %.4f]\n",
                boot_fe$conf_int[1], boot_fe$conf_int[2]))
  }

  # Bootstrap the beta-convergence model
  cat("\nRunning wild cluster bootstrap for beta-convergence...\n")
  boot_conv <- tryCatch({
    boottest(m2_all,
             param = "yes_equal_rights_1981",
             B = 999,
             clustid = "canton",
             type = "rademacher")
  }, error = function(e) {
    cat(sprintf("  Bootstrap error: %s\n", e$message))
    NULL
  })

  if (!is.null(boot_conv)) {
    cat("Wild cluster bootstrap — beta-convergence:\n")
    print(summary(boot_conv))
    boot_conv_summ <- summary(boot_conv)
    cat(sprintf("  Bootstrap p-value: %.4f\n", boot_conv_summ$p_val))
  }

} else {
  cat("NOTE: fwildclusterboot not available.\n")
  cat("Canton-clustered SEs with 26 clusters may understate uncertainty.\n")
  cat("This is a limitation — Cameron, Gelbach & Miller (2008) suggest\n")
  cat("bootstrap inference is advisable with fewer than ~50 clusters.\n")
  boot_biv <- NULL
  boot_fe <- NULL
  boot_conv <- NULL
}

## ---------------------------------------------------------------
## 6. Save all model objects and key estimates
## ---------------------------------------------------------------
cat("\n=== 6. Saving results ===\n")

models <- list(
  # Persistence
  persistence_bivariate = m1_biv,
  persistence_language = m1_lang,
  persistence_religion = m1_relig,
  persistence_canton_fe = m1_canton,
  persistence_german_only = m1_german,
  # Beta-convergence
  convergence_all = m2_all,
  convergence_german = m2_de,
  convergence_french = m2_fr,
  convergence_canton_fe = m2_fe,
  # AIPW
  aipw_weighted = m_aipw,
  aipw_full = m_aipw_full,
  gps_model = gps_mod,
  outcome_model = outcome_mod,
  # Sigma-convergence
  sigma_results = sigma_results,
  # Bootstrap (may be NULL)
  boot_bivariate = boot_biv,
  boot_canton_fe = boot_fe,
  boot_convergence = boot_conv
)

saveRDS(models, file.path(DATA_DIR, "models.rds"))
cat("Saved models.rds\n")

# Save persistence table as LaTeX
cat("Generating persistence table...\n")
persistence_models <- list(
  "(1) Bivariate"    = m1_biv,
  "(2) + Language"   = m1_lang,
  "(3) + Religion"   = m1_relig,
  "(4) Canton FE"    = m1_canton,
  "(5) German Only"  = m1_german
)

# Custom statistics rows
gm <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4),
  list("raw" = "adj.r.squared", "clean" = "Adj. $R^2$", "fmt" = 4)
)

cm <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism",
  "lang_frenchTRUE" = "French-speaking",
  "lang_italianTRUE" = "Italian-speaking",
  "lang_fr" = "French-speaking",
  "lang_it" = "Italian-speaking",
  "hist_religion::prot" = "Protestant",
  "hist_religion::mixed" = "Mixed religion"
)

modelsummary(
  persistence_models,
  output = file.path(TABLE_DIR, "persistence_regression.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm,
  gof_map = gm,
  title = "Persistence of Gender Progressivism: 1981 Equal Rights $\\rightarrow$ 2020 Paternity Leave",
  notes = list("Standard errors clustered at the canton level (26 cantons) in parentheses.",
               "Columns (4)--(5) include canton fixed effects."),
  escape = FALSE
)
cat("Saved persistence_regression.tex\n")

# Save convergence table
convergence_models <- list(
  "(1) All" = m2_all,
  "(2) German" = m2_de,
  "(3) French" = m2_fr,
  "(4) Canton FE" = m2_fe
)

cm_conv <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism"
)

modelsummary(
  convergence_models,
  output = file.path(TABLE_DIR, "beta_convergence.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_conv,
  gof_map = gm,
  title = "$\\beta$-Convergence: $\\Delta$ Gender Attitudes on Initial Progressivism",
  notes = list("Dependent variable: $\\Delta_{\\text{gender}}$ = YES share 2020 $-$ YES share 1981.",
               "Negative coefficient = convergence toward common mean.",
               "Standard errors clustered at the canton level."),
  escape = FALSE
)
cat("Saved beta_convergence.tex\n")

# Save AIPW comparison table
aipw_models <- list(
  "(1) OLS Bivariate"  = m1_biv,
  "(2) AIPW Weighted"  = m_aipw,
  "(3) AIPW + Controls" = m_aipw_full
)

cm_aipw <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism",
  "lang_fr" = "French-speaking",
  "lang_it" = "Italian-speaking",
  "rel_prot" = "Protestant",
  "rel_mixed" = "Mixed religion",
  "suffrage_year" = "Suffrage year"
)

modelsummary(
  aipw_models,
  output = file.path(TABLE_DIR, "aipw_estimates.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_aipw,
  gof_map = gm,
  title = "Doubly Robust Estimates of Gender Attitude Persistence",
  notes = list("Column (1): OLS. Columns (2)--(3): GPS-weighted (stabilized, trimmed 1\\%--99\\%).",
               "GPS model: 1981 YES share $\\sim$ language + religion + suffrage year.",
               "Standard errors clustered at the canton level."),
  escape = FALSE
)
cat("Saved aipw_estimates.tex\n")

# Save sigma-convergence as LaTeX table
sigma_tab <- sigma_results |>
  select(year, label, mean_all, sd_all, sd_german, sd_french, cv_all) |>
  mutate(across(c(mean_all, sd_all, sd_german, sd_french), ~ round(., 2)),
         cv_all = round(cv_all, 3))

sigma_kable <- kbl(sigma_tab,
                   format = "latex",
                   booktabs = TRUE,
                   col.names = c("Year", "Referendum", "Mean", "SD (All)",
                                 "SD (German)", "SD (French)", "CV"),
                   caption = "$\\sigma$-Convergence: Cross-Municipality Dispersion Over Time",
                   label = "tab:sigma_convergence",
                   escape = FALSE) |>
  kable_styling(latex_options = c("hold_position")) |>
  footnote(general = "SD = standard deviation of municipal YES shares. CV = coefficient of variation. Declining SD indicates $\\sigma$-convergence.",
           escape = FALSE, threeparttable = TRUE)

writeLines(as.character(sigma_kable), file.path(TABLE_DIR, "sigma_convergence.tex"))
cat("Saved sigma_convergence.tex\n")

cat("\n=== Main analysis complete ===\n")
