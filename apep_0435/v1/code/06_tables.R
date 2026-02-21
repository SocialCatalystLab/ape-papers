## ============================================================
## 06_tables.R — Publication-quality LaTeX tables
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

source("00_packages.R")

DATA_DIR <- "../data"
TABLE_DIR <- "../tables"
dir.create(TABLE_DIR, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(DATA_DIR, "analysis_data.rds"))
cat(sprintf("Loaded analysis data: %d municipalities\n", nrow(df)))

## ---------------------------------------------------------------
## Table 1: Summary Statistics by Language Region
## ---------------------------------------------------------------
cat("=== Table 1: Summary Statistics ===\n")

# Variables to summarize
summ_vars <- c(
  "yes_equal_rights_1981", "yes_maternity_1984", "yes_maternity_1999",
  "yes_maternity_2004", "yes_paternity_2020", "yes_marriage_2021",
  "yes_immigration_2014", "yes_jets_2020", "yes_corporate_2020",
  "yes_burqa_2021", "delta_gender"
)

var_labels <- c(
  "Equal Rights 1981", "Maternity Insurance 1984", "Maternity Insurance 1999",
  "Maternity Insurance 2004", "Paternity Leave 2020", "Marriage Equality 2021",
  "Mass Immigration 2014", "Fighter Jets 2020", "Corporate Resp. 2020",
  "Burqa Ban 2021", "$\\Delta_{\\text{gender}}$ (2020 $-$ 1981)"
)

# Full sample statistics
full_stats <- df |>
  select(all_of(summ_vars)) |>
  pivot_longer(everything(), names_to = "variable") |>
  group_by(variable) |>
  summarise(
    N = sum(!is.na(value)),
    Mean = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    Min = min(value, na.rm = TRUE),
    Max = max(value, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(variable = factor(variable, levels = summ_vars))  |>
  arrange(variable)

# By language region
lang_stats <- df |>
  select(primary_language, all_of(summ_vars)) |>
  pivot_longer(cols = all_of(summ_vars), names_to = "variable") |>
  group_by(primary_language, variable) |>
  summarise(
    N = sum(!is.na(value)),
    Mean = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(variable = factor(variable, levels = summ_vars)) |>
  arrange(variable, primary_language)

# Construct the table: Full | German | French | Italian
summ_wide <- full_stats |>
  select(variable, Mean, SD, Min, Max) |>
  rename(Mean_All = Mean, SD_All = SD) |>
  left_join(
    lang_stats |> filter(primary_language == "de") |>
      select(variable, N_de = N, Mean_de = Mean, SD_de = SD),
    by = "variable"
  ) |>
  left_join(
    lang_stats |> filter(primary_language == "fr") |>
      select(variable, N_fr = N, Mean_fr = Mean, SD_fr = SD),
    by = "variable"
  ) |>
  left_join(
    lang_stats |> filter(primary_language == "it") |>
      select(variable, N_it = N, Mean_it = Mean, SD_it = SD),
    by = "variable"
  ) |>
  mutate(
    Label = var_labels,
    across(c(Mean_All, SD_All, Min, Max, Mean_de, SD_de, Mean_fr, SD_fr, Mean_it, SD_it),
           ~ round(., 1))
  ) |>
  select(Label, Mean_All, SD_All, Min, Max, Mean_de, SD_de, Mean_fr, SD_fr, Mean_it, SD_it)

# Create LaTeX table
n_de <- sum(df$primary_language == "de")
n_fr <- sum(df$primary_language == "fr")
n_it <- sum(df$primary_language == "it")

summ_kable <- kbl(
  summ_wide,
  format = "latex",
  booktabs = TRUE,
  col.names = c("Variable",
                "Mean", "SD", "Min", "Max",
                "Mean", "SD",
                "Mean", "SD",
                "Mean", "SD"),
  caption = sprintf("Summary Statistics: Referendum YES Shares by Language Region ($N$ = %s)",
                    format(nrow(df), big.mark = ",")),
  label = "tab:summary_stats",
  escape = FALSE,
  align = c("l", rep("c", 10))
) |>
  kable_styling(latex_options = c("hold_position", "scale_down")) |>
  add_header_above(setNames(
    c(1, 4, 2, 2, 2),
    c(" ", "Full Sample",
      sprintf("German ($n$ = %d)", n_de),
      sprintf("French ($n$ = %d)", n_fr),
      sprintf("Italian ($n$ = %d)", n_it))
  ), escape = FALSE) |>
  footnote(
    general = paste0(
      "YES share = percentage of valid votes cast in favor. ",
      "$\\Delta_{\\text{gender}}$ = YES share paternity leave 2020 $-$ YES share equal rights 1981. ",
      "Language region assigned based on municipality's primary language."
    ),
    escape = FALSE, threeparttable = TRUE
  )

writeLines(as.character(summ_kable), file.path(TABLE_DIR, "summary_statistics.tex"))
cat("Saved summary_statistics.tex\n")

## ---------------------------------------------------------------
## Table 2: Persistence Regression Table
## ---------------------------------------------------------------
cat("=== Table 2: Persistence Regression ===\n")

df_de <- df |> filter(primary_language == "de")

# Estimate all 5 specifications
m2_1 <- feols(yes_paternity_2020 ~ yes_equal_rights_1981,
              data = df, cluster = ~canton)
m2_2 <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 +
                lang_french + lang_italian,
              data = df, cluster = ~canton)
m2_3 <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 +
                lang_french + lang_italian + i(hist_religion),
              data = df, cluster = ~canton)
m2_4 <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
              data = df, cluster = ~canton)
m2_5 <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
              data = df_de, cluster = ~canton)

persistence_models <- list(
  "(1)" = m2_1,
  "(2)" = m2_2,
  "(3)" = m2_3,
  "(4)" = m2_4,
  "(5)" = m2_5
)

gm <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4),
  list("raw" = "adj.r.squared", "clean" = "Adj.\\ $R^2$", "fmt" = 4),
  list("raw" = "FE: canton", "clean" = "Canton FE", "fmt" = function(x) ifelse(x == "X", "Yes", "No"))
)

cm_persist <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism",
  "lang_frenchTRUE" = "French-speaking",
  "lang_italianTRUE" = "Italian-speaking",
  "hist_religion::prot" = "Protestant",
  "hist_religion::mixed" = "Mixed religion"
)

# Add manual rows for Canton FE and Sample
rows_df <- data.frame(
  term = c("Canton FE", "Sample"),
  `(1)` = c("No", "All"),
  `(2)` = c("No", "All"),
  `(3)` = c("No", "All"),
  `(4)` = c("Yes", "All"),
  `(5)` = c("Yes", "German"),
  check.names = FALSE
)
attr(rows_df, "position") <- c(13, 14)

modelsummary(
  persistence_models,
  output = file.path(TABLE_DIR, "tab_persistence.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_persist,
  gof_map = list(
    list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
    list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4),
    list("raw" = "adj.r.squared", "clean" = "Adj.\\ $R^2$", "fmt" = 4)
  ),
  add_rows = rows_df,
  title = "Persistence of Gender Progressivism: 1981 Equal Rights $\\rightarrow$ 2020 Paternity Leave",
  notes = list(
    "Dependent variable: YES share paternity leave 2020.",
    "Standard errors clustered at the canton level (26 cantons) in parentheses.",
    "Column (5) restricts to German-speaking municipalities."
  ),
  escape = FALSE
)
cat("Saved tab_persistence.tex\n")

## ---------------------------------------------------------------
## Table 3: Beta-Convergence
## ---------------------------------------------------------------
cat("=== Table 3: Beta-Convergence ===\n")

df_fr <- df |> filter(primary_language == "fr")

m3_1 <- feols(delta_gender ~ yes_equal_rights_1981,
              data = df, cluster = ~canton)
m3_2 <- feols(delta_gender ~ yes_equal_rights_1981,
              data = df_de, cluster = ~canton)
m3_3 <- feols(delta_gender ~ yes_equal_rights_1981,
              data = df_fr, cluster = ~canton)

conv_models <- list(
  "(1) All" = m3_1,
  "(2) German" = m3_2,
  "(3) French" = m3_3
)

cm_conv <- c(
  "yes_equal_rights_1981" = "1981 Gender Progressivism"
)

# Manual rows
rows_conv <- data.frame(
  term = c("Sample"),
  `(1) All` = c("All"),
  `(2) German` = c("German"),
  `(3) French` = c("French"),
  check.names = FALSE
)
attr(rows_conv, "position") <- c(5)

modelsummary(
  conv_models,
  output = file.path(TABLE_DIR, "tab_beta_convergence.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_conv,
  gof_map = list(
    list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
    list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4)
  ),
  add_rows = rows_conv,
  title = "$\\beta$-Convergence: Change in Gender Attitudes on Initial Progressivism",
  notes = list(
    "Dependent variable: $\\Delta_{\\text{gender}}$ = YES share paternity leave 2020 $-$ YES share equal rights 1981.",
    "Negative coefficient $\\Rightarrow$ $\\beta$-convergence: initially progressive municipalities gain less (or lose ground).",
    "Standard errors clustered at canton level."
  ),
  escape = FALSE
)
cat("Saved tab_beta_convergence.tex\n")

## ---------------------------------------------------------------
## Table 4: Falsification — Gender vs Non-Gender
## ---------------------------------------------------------------
cat("=== Table 4: Falsification ===\n")

m4_pat <- feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)
m4_mar <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)
m4_mat <- feols(yes_maternity_2004 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)
m4_imm <- feols(yes_immigration_2014 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)
m4_jet <- feols(yes_jets_2020 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)
m4_cor <- feols(yes_corporate_2020 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)
m4_bur <- feols(yes_burqa_2021 ~ yes_equal_rights_1981 | canton,
                data = df, cluster = ~canton)

falsi_models <- list(
  "(1)" = m4_pat,
  "(2)" = m4_mar,
  "(3)" = m4_mat,
  "(4)" = m4_imm,
  "(5)" = m4_jet,
  "(6)" = m4_cor,
  "(7)" = m4_bur
)

cm_falsi <- c("yes_equal_rights_1981" = "1981 Gender Progressivism")

# Manual DV label and type rows
rows_falsi <- data.frame(
  term = c("Outcome", "Vote type", "Canton FE"),
  `(1)` = c("Paternity 2020", "Gender", "Yes"),
  `(2)` = c("Marriage 2021", "Gender", "Yes"),
  `(3)` = c("Maternity 2004", "Gender", "Yes"),
  `(4)` = c("Immigration 2014", "Non-gender", "Yes"),
  `(5)` = c("Jets 2020", "Non-gender", "Yes"),
  `(6)` = c("Corp.\\ Resp.\\ 2020", "Non-gender", "Yes"),
  `(7)` = c("Burqa Ban 2021", "Non-gender", "Yes"),
  check.names = FALSE
)
attr(rows_falsi, "position") <- c(5, 6, 7)

modelsummary(
  falsi_models,
  output = file.path(TABLE_DIR, "tab_falsification.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = cm_falsi,
  gof_map = list(
    list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
    list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 4),
    list("raw" = "adj.r.squared", "clean" = "Adj.\\ $R^2$", "fmt" = 4)
  ),
  add_rows = rows_falsi,
  title = "Falsification: 1981 Gender Baseline Predicting Gender vs.\\ Non-Gender Referendum Outcomes",
  notes = list(
    "All models include canton fixed effects with SEs clustered at canton level.",
    "Columns (1)--(3): gender-related referenda. Columns (4)--(7): non-gender referenda.",
    "Higher $R^2$ and larger coefficients for gender outcomes supports domain-specificity of persistence."
  ),
  escape = FALSE
)
cat("Saved tab_falsification.tex\n")

## ---------------------------------------------------------------
## Table 5: Sigma-Convergence by Year and Language Region
## ---------------------------------------------------------------
cat("=== Table 5: Sigma-Convergence ===\n")

sigma_vars <- tribble(
  ~year, ~variable,                ~label,
  1981,  "yes_equal_rights_1981",  "Equal Rights",
  1984,  "yes_maternity_1984",     "Maternity Insurance",
  1999,  "yes_maternity_1999",     "Maternity Insurance",
  2004,  "yes_maternity_2004",     "Maternity Insurance",
  2020,  "yes_paternity_2020",     "Paternity Leave",
  2021,  "yes_marriage_2021",      "Marriage Equality"
)

sigma_tab <- sigma_vars |>
  rowwise() |>
  summarise(
    Year = year,
    Referendum = label,
    Mean_All = mean(df[[variable]], na.rm = TRUE),
    SD_All = sd(df[[variable]], na.rm = TRUE),
    SD_German = sd(df_de[[variable]], na.rm = TRUE),
    SD_French = sd(df_fr[[variable]], na.rm = TRUE),
    IQR_All = IQR(df[[variable]], na.rm = TRUE),
    CV_All = SD_All / Mean_All,
    .groups = "drop"
  ) |>
  mutate(
    across(c(Mean_All, SD_All, SD_German, SD_French, IQR_All), ~ round(., 2)),
    CV_All = round(CV_All, 3)
  )

sigma_kable <- kbl(
  sigma_tab,
  format = "latex",
  booktabs = TRUE,
  col.names = c("Year", "Referendum", "Mean", "SD (All)", "SD (German)",
                "SD (French)", "IQR", "CV"),
  caption = "$\\sigma$-Convergence: Cross-Municipality Dispersion of Gender Referendum YES Shares",
  label = "tab:sigma_convergence",
  escape = FALSE,
  align = c("c", "l", rep("c", 6))
) |>
  kable_styling(latex_options = c("hold_position")) |>
  footnote(
    general = paste0(
      "SD = standard deviation. IQR = interquartile range. CV = coefficient of variation (SD/Mean). ",
      "Declining dispersion over time indicates $\\sigma$-convergence. ",
      "All statistics computed over the balanced panel of ",
      format(nrow(df), big.mark = ","), " municipalities."
    ),
    escape = FALSE, threeparttable = TRUE
  )

writeLines(as.character(sigma_kable), file.path(TABLE_DIR, "tab_sigma_convergence.tex"))
cat("Saved tab_sigma_convergence.tex\n")

## ---------------------------------------------------------------
## Summary of all tables
## ---------------------------------------------------------------
cat("\n=== All tables saved to", TABLE_DIR, "===\n")
cat("Files:\n")
list.files(TABLE_DIR, pattern = "\\.tex$") |> cat(sep = "\n")
cat("\n=== Tables complete ===\n")
