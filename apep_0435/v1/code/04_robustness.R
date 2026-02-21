## ============================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

source("00_packages.R")

DATA_DIR <- "../data"
TABLE_DIR <- "../tables"
dir.create(TABLE_DIR, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(DATA_DIR, "analysis_data.rds"))
cat(sprintf("Loaded analysis data: %d municipalities\n", nrow(df)))

## ---------------------------------------------------------------
## 1. Within-German-Only Analysis
## ---------------------------------------------------------------
cat("\n=== 1. Within-German-Only Subsample ===\n")

df_de <- df |> filter(primary_language == "de")
cat(sprintf("German-speaking municipalities: %d\n", nrow(df_de)))

# Re-run persistence specification ladder (German-only)
m_de_biv <- feols(yes_paternity_2020 ~ yes_equal_rights_1981,
                  data = df_de, cluster = ~canton)
m_de_relig <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 + i(hist_religion),
                    data = df_de, cluster = ~canton)
m_de_fe <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                 data = df_de, cluster = ~canton)

# Beta-convergence (German-only)
m_de_conv <- feols(delta_gender ~ yes_equal_rights_1981,
                   data = df_de, cluster = ~canton)
m_de_conv_fe <- feols(delta_gender ~ yes_equal_rights_1981 | canton,
                      data = df_de, cluster = ~canton)

cat("German-only persistence:\n")
cat(sprintf("  Bivariate:  beta = %.4f (SE = %.4f), R2 = %.4f\n",
            coef(m_de_biv)["yes_equal_rights_1981"],
            se(m_de_biv)["yes_equal_rights_1981"],
            r2(m_de_biv, "r2")))
cat(sprintf("  + Religion: beta = %.4f (SE = %.4f), R2 = %.4f\n",
            coef(m_de_relig)["yes_equal_rights_1981"],
            se(m_de_relig)["yes_equal_rights_1981"],
            r2(m_de_relig, "r2")))
cat(sprintf("  Canton FE:  beta = %.4f (SE = %.4f), R2 = %.4f\n",
            coef(m_de_fe)["yes_equal_rights_1981"],
            se(m_de_fe)["yes_equal_rights_1981"],
            r2(m_de_fe, "r2")))
cat(sprintf("  Convergence (biv): beta = %.4f (SE = %.4f)\n",
            coef(m_de_conv)["yes_equal_rights_1981"],
            se(m_de_conv)["yes_equal_rights_1981"]))
cat(sprintf("  Convergence (FE):  beta = %.4f (SE = %.4f)\n",
            coef(m_de_conv_fe)["yes_equal_rights_1981"],
            se(m_de_conv_fe)["yes_equal_rights_1981"]))

## ---------------------------------------------------------------
## 2. Within-Canton Fixed Effects (Full Sample)
## ---------------------------------------------------------------
cat("\n=== 2. Canton Fixed Effects (Full Sample) ===\n")

# Already estimated in main analysis, but add marriage 2021 as alternative DV
m_fe_marriage <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 | canton,
                       data = df, cluster = ~canton)
m_fe_maternity04 <- feols(yes_maternity_2004 ~ yes_equal_rights_1981 | canton,
                          data = df, cluster = ~canton)

cat(sprintf("Canton FE — DV: Paternity 2020 — in models.rds\n"))
cat(sprintf("Canton FE — DV: Marriage 2021:  beta = %.4f (SE = %.4f), R2 = %.4f\n",
            coef(m_fe_marriage)["yes_equal_rights_1981"],
            se(m_fe_marriage)["yes_equal_rights_1981"],
            r2(m_fe_marriage, "r2")))
cat(sprintf("Canton FE — DV: Maternity 2004: beta = %.4f (SE = %.4f), R2 = %.4f\n",
            coef(m_fe_maternity04)["yes_equal_rights_1981"],
            se(m_fe_maternity04)["yes_equal_rights_1981"],
            r2(m_fe_maternity04, "r2")))

## ---------------------------------------------------------------
## 3. Falsification: Non-Gender Votes
## ---------------------------------------------------------------
cat("\n=== 3. Falsification Tests ===\n")

# Gender-related outcomes (for comparison)
m_gender_pat <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                      data = df, cluster = ~canton)
m_gender_mar <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 | canton,
                      data = df, cluster = ~canton)
m_gender_mat04 <- feols(yes_maternity_2004 ~ yes_equal_rights_1981 | canton,
                        data = df, cluster = ~canton)

# Non-gender outcomes (falsification)
m_falsi_immig <- feols(yes_immigration_2014 ~ yes_equal_rights_1981 | canton,
                       data = df, cluster = ~canton)
m_falsi_jets <- feols(yes_jets_2020 ~ yes_equal_rights_1981 | canton,
                      data = df, cluster = ~canton)
m_falsi_corp <- feols(yes_corporate_2020 ~ yes_equal_rights_1981 | canton,
                      data = df, cluster = ~canton)
m_falsi_burqa <- feols(yes_burqa_2021 ~ yes_equal_rights_1981 | canton,
                       data = df, cluster = ~canton)

# Collect results
falsification_results <- tibble(
  outcome = c("Paternity 2020", "Marriage 2021", "Maternity 2004",
              "Immigration 2014", "Fighter Jets 2020",
              "Corporate Resp. 2020", "Burqa Ban 2021"),
  type = c("Gender", "Gender", "Gender",
           "Non-gender", "Non-gender", "Non-gender", "Non-gender"),
  model = list(m_gender_pat, m_gender_mar, m_gender_mat04,
               m_falsi_immig, m_falsi_jets, m_falsi_corp, m_falsi_burqa)
) |>
  rowwise() |>
  mutate(
    beta = coef(model)["yes_equal_rights_1981"],
    se = se(model)["yes_equal_rights_1981"],
    tstat = beta / se,
    pval = fixest::pvalue(model)["yes_equal_rights_1981"],
    r2 = r2(model, "r2"),
    adj_r2 = r2(model, "ar2")
  ) |>
  ungroup()

cat("Falsification comparison (all with canton FE + canton clustering):\n")
falsification_results |>
  select(outcome, type, beta, se, pval, r2) |>
  mutate(across(c(beta, se), ~ round(., 4)),
         pval = round(pval, 4),
         r2 = round(r2, 4)) |>
  print(n = 10)

cat("\nKey finding: R2 for gender outcomes vs non-gender outcomes\n")
cat(sprintf("  Mean R2 (gender):     %.4f\n",
            mean(falsification_results |> filter(type == "Gender") |> pull(r2))))
cat(sprintf("  Mean R2 (non-gender): %.4f\n",
            mean(falsification_results |> filter(type == "Non-gender") |> pull(r2))))

## ---------------------------------------------------------------
## 4. Oster (2019) Proportional Selection Index (delta)
## ---------------------------------------------------------------
cat("\n=== 4. Oster (2019) Proportional Selection Delta ===\n")

# Oster's delta measures how strong selection on unobservables would
# need to be (relative to selection on observables) to explain away
# the treatment effect.
#
# delta = (beta_full * (R_max - R_full)) / ((beta_nc - beta_full) * (R_full - R_nc))
#
# where:
#   beta_nc = no-controls coefficient
#   beta_full = full-controls coefficient
#   R_nc = R-squared with no controls
#   R_full = R-squared with full controls
#   R_max = hypothetical maximum R-squared (Oster suggests 1.3 * R_full)

# Persistence: yes_paternity_2020 ~ yes_equal_rights_1981
# No controls (bivariate OLS — NOT feols with clustering, need raw R2)
ols_nc <- lm(yes_paternity_2020 ~ yes_equal_rights_1981, data = df)
beta_nc <- coef(ols_nc)["yes_equal_rights_1981"]
r2_nc <- summary(ols_nc)$r.squared

# Full controls (language + religion + suffrage year)
ols_full <- lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                 I(primary_language == "fr") + I(primary_language == "it") +
                 hist_religion + suffrage_year, data = df)
beta_full <- coef(ols_full)["yes_equal_rights_1981"]
r2_full <- summary(ols_full)$r.squared

# R_max = 1.3 * R_full (Oster's rule of thumb)
r2_max <- min(1.3 * r2_full, 1.0)

# Compute delta
if (abs(beta_nc - beta_full) > 1e-10) {
  oster_delta <- (beta_full * (r2_max - r2_full)) /
    ((beta_nc - beta_full) * (r2_full - r2_nc))
} else {
  oster_delta <- Inf  # Controls do not change coefficient
}

cat(sprintf("No-controls:   beta = %.4f, R2 = %.4f\n", beta_nc, r2_nc))
cat(sprintf("Full-controls: beta = %.4f, R2 = %.4f\n", beta_full, r2_full))
cat(sprintf("R_max (1.3 x R_full): %.4f\n", r2_max))
cat(sprintf("Oster delta: %.2f\n", oster_delta))

if (is.finite(oster_delta) && abs(oster_delta) > 1) {
  cat("Interpretation: delta > 1 implies unobservables would need to be\n")
  cat("MORE than proportionally as important as observables to explain\n")
  cat("away the result. This suggests robustness to omitted variable bias.\n")
} else if (is.finite(oster_delta) && oster_delta < 0) {
  cat("Interpretation: delta < 0 implies controls move the coefficient\n")
  cat("in the opposite direction of what OVB would predict. This is\n")
  cat("reassuring — adding controls strengthens the finding.\n")
} else if (is.finite(oster_delta)) {
  cat("Interpretation: delta between 0 and 1 suggests some vulnerability\n")
  cat("to selection on unobservables.\n")
}

# Alternative R_max bounds
for (rmax_mult in c(1.0, 1.3, 2.0)) {
  rmax_alt <- min(rmax_mult * r2_full, 1.0)
  if (abs(beta_nc - beta_full) > 1e-10) {
    delta_alt <- (beta_full * (rmax_alt - r2_full)) /
      ((beta_nc - beta_full) * (r2_full - r2_nc))
  } else {
    delta_alt <- Inf
  }
  cat(sprintf("  R_max = %.1f x R_full (= %.4f): delta = %.2f\n",
              rmax_mult, rmax_alt, delta_alt))
}

## ---------------------------------------------------------------
## 5. Sensitivity: Decomposition of R-squared
## ---------------------------------------------------------------
cat("\n=== 5. R-squared Decomposition ===\n")

# How much of the persistence effect is absorbed by each set of controls?
# Run nested models and track coefficient + R2 changes

models_nested <- list(
  "Bivariate" = lm(yes_paternity_2020 ~ yes_equal_rights_1981, data = df),
  "+ Language" = lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                      I(primary_language == "fr") + I(primary_language == "it"), data = df),
  "+ Religion" = lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                      I(primary_language == "fr") + I(primary_language == "it") +
                      hist_religion, data = df),
  "+ Suffrage" = lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                      I(primary_language == "fr") + I(primary_language == "it") +
                      hist_religion + suffrage_year, data = df),
  "+ Canton FE" = lm(yes_paternity_2020 ~ yes_equal_rights_1981 + factor(canton), data = df)
)

decomposition <- tibble(
  specification = names(models_nested),
  beta = map_dbl(models_nested, ~ coef(.)["yes_equal_rights_1981"]),
  r2 = map_dbl(models_nested, ~ summary(.)$r.squared)
) |>
  mutate(
    beta_share_remaining = beta / beta[1] * 100,
    r2_increment = r2 - lag(r2, default = 0)
  )

cat("R-squared decomposition (share of persistence absorbed):\n")
print(decomposition)

cat(sprintf("\nShare of bivariate beta surviving canton FE: %.1f%%\n",
            decomposition$beta_share_remaining[decomposition$specification == "+ Canton FE"]))

## ---------------------------------------------------------------
## 6. Additional Robustness: Alternative DVs
## ---------------------------------------------------------------
cat("\n=== 6. Alternative Outcome Variables ===\n")

# Marriage equality 2021 as alternative DV
m_alt_mar_biv <- feols(yes_marriage_2021 ~ yes_equal_rights_1981,
                       data = df, cluster = ~canton)
m_alt_mar_fe <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 | canton,
                      data = df, cluster = ~canton)

# Maternity 2004 as intermediate DV
m_alt_mat_biv <- feols(yes_maternity_2004 ~ yes_equal_rights_1981,
                       data = df, cluster = ~canton)
m_alt_mat_fe <- feols(yes_maternity_2004 ~ yes_equal_rights_1981 | canton,
                      data = df, cluster = ~canton)

# Convergence with marriage 2021
m_conv_mar <- feols(delta_gender2 ~ yes_equal_rights_1981,
                    data = df, cluster = ~canton)

cat(sprintf("Marriage 2021 (biv):  beta = %.4f, R2 = %.4f\n",
            coef(m_alt_mar_biv)["yes_equal_rights_1981"],
            r2(m_alt_mar_biv, "r2")))
cat(sprintf("Marriage 2021 (FE):   beta = %.4f, R2 = %.4f\n",
            coef(m_alt_mar_fe)["yes_equal_rights_1981"],
            r2(m_alt_mar_fe, "r2")))
cat(sprintf("Maternity 2004 (biv): beta = %.4f, R2 = %.4f\n",
            coef(m_alt_mat_biv)["yes_equal_rights_1981"],
            r2(m_alt_mat_biv, "r2")))
cat(sprintf("Maternity 2004 (FE):  beta = %.4f, R2 = %.4f\n",
            coef(m_alt_mat_fe)["yes_equal_rights_1981"],
            r2(m_alt_mat_fe, "r2")))
cat(sprintf("Convergence (marriage): beta = %.4f\n",
            coef(m_conv_mar)["yes_equal_rights_1981"]))

## ---------------------------------------------------------------
## 7. Save Robustness Tables
## ---------------------------------------------------------------
cat("\n=== 7. Saving robustness tables ===\n")

# Table: Falsification
falsi_models <- list(
  "(1) Paternity 2020" = m_gender_pat,
  "(2) Marriage 2021"   = m_gender_mar,
  "(3) Maternity 2004"  = m_gender_mat04,
  "(4) Immigration 2014" = m_falsi_immig,
  "(5) Fighter Jets 2020" = m_falsi_jets,
  "(6) Corp. Resp. 2020" = m_falsi_corp,
  "(7) Burqa Ban 2021"  = m_falsi_burqa
)

gm <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4),
  list("raw" = "adj.r.squared", "clean" = "Adj. $R^2$", "fmt" = 4)
)

cm_falsi <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism"
)

modelsummary(
  falsi_models,
  output = file.path(TABLE_DIR, "falsification.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_falsi,
  gof_map = gm,
  title = "Falsification: 1981 Gender Baseline Predicting Gender vs.\\ Non-Gender Votes",
  notes = list("All models include canton fixed effects. SEs clustered at canton level.",
               "Columns (1)--(3): gender-related outcomes. Columns (4)--(7): non-gender outcomes.",
               "Higher $R^2$ for gender outcomes supports domain-specificity of persistence."),
  escape = FALSE
)
cat("Saved falsification.tex\n")

# Table: German-only robustness
german_models <- list(
  "(1) Bivariate"  = m_de_biv,
  "(2) + Religion" = m_de_relig,
  "(3) Canton FE"  = m_de_fe,
  "(4) Convergence" = m_de_conv,
  "(5) Conv. + FE" = m_de_conv_fe
)

cm_german <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism",
  "hist_religion::prot" = "Protestant",
  "hist_religion::mixed" = "Mixed religion"
)

modelsummary(
  german_models,
  output = file.path(TABLE_DIR, "robustness_german_only.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_german,
  gof_map = gm,
  title = "Robustness: German-Speaking Municipalities Only",
  notes = list(
    sprintf("Sample restricted to %d German-speaking municipalities in %d cantons.",
            nrow(df_de), n_distinct(df_de$canton)),
    "Columns (1)--(3): DV = Paternity 2020. Columns (4)--(5): DV = $\\Delta_{\\text{gender}}$.",
    "SEs clustered at canton level."
  ),
  escape = FALSE
)
cat("Saved robustness_german_only.tex\n")

# Table: R-squared decomposition
decomp_kable <- kbl(
  decomposition |>
    mutate(across(c(beta, r2, r2_increment), ~ round(., 4)),
           beta_share_remaining = round(beta_share_remaining, 1)),
  format = "latex",
  booktabs = TRUE,
  col.names = c("Specification", "$\\hat{\\beta}$", "$R^2$",
                "Share of $\\hat{\\beta}_{\\text{biv}}$ (\\%)",
                "$\\Delta R^2$"),
  caption = "Sensitivity: R-Squared Decomposition and Coefficient Stability",
  label = "tab:decomposition",
  escape = FALSE
) |>
  kable_styling(latex_options = c("hold_position")) |>
  footnote(
    general = paste0(
      "DV: YES share paternity leave 2020. ",
      "Oster (2019) $\\delta$ with $R_{\\max} = 1.3 \\times R_{\\text{full}}$: ",
      sprintf("$\\hat{\\delta} = %.2f$. ", oster_delta),
      "$|\\delta| > 1$ implies robustness to proportional selection on unobservables."
    ),
    escape = FALSE, threeparttable = TRUE
  )

writeLines(as.character(decomp_kable), file.path(TABLE_DIR, "oster_decomposition.tex"))
cat("Saved oster_decomposition.tex\n")

# Table: Alternative outcomes
alt_models <- list(
  "(1) Paternity 2020"  = feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                                 data = df, cluster = ~canton),
  "(2) Marriage 2021"    = m_alt_mar_fe,
  "(3) Maternity 2004"   = m_alt_mat_fe,
  "(4) Maternity 1999"   = feols(yes_maternity_1999 ~ yes_equal_rights_1981 | canton,
                                  data = df, cluster = ~canton),
  "(5) Maternity 1984"   = feols(yes_maternity_1984 ~ yes_equal_rights_1981 | canton,
                                  data = df, cluster = ~canton)
)

modelsummary(
  alt_models,
  output = file.path(TABLE_DIR, "alternative_outcomes.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_falsi,
  gof_map = gm,
  title = "Persistence Across Gender-Related Referendum Outcomes",
  notes = list("All models include canton FE. SEs clustered at canton level.",
               "Each column uses a different gender referendum as dependent variable.",
               "The treatment variable is 1981 equal rights YES share in all columns."),
  escape = FALSE
)
cat("Saved alternative_outcomes.tex\n")

# Save robustness objects
robustness_models <- list(
  german_bivariate = m_de_biv,
  german_religion = m_de_relig,
  german_fe = m_de_fe,
  german_convergence = m_de_conv,
  german_convergence_fe = m_de_conv_fe,
  fe_marriage = m_fe_marriage,
  fe_maternity04 = m_fe_maternity04,
  falsi_immigration = m_falsi_immig,
  falsi_jets = m_falsi_jets,
  falsi_corporate = m_falsi_corp,
  falsi_burqa = m_falsi_burqa,
  alt_marriage_biv = m_alt_mar_biv,
  alt_marriage_fe = m_alt_mar_fe,
  alt_maternity_biv = m_alt_mat_biv,
  alt_maternity_fe = m_alt_mat_fe,
  convergence_marriage = m_conv_mar,
  oster_delta = oster_delta,
  decomposition = decomposition,
  falsification_results = falsification_results
)

saveRDS(robustness_models, file.path(DATA_DIR, "robustness_models.rds"))
cat("Saved robustness_models.rds\n")

cat("\n=== Robustness analysis complete ===\n")
