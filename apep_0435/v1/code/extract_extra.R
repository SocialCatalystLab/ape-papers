## Extract additional values needed for tab3 Panel B and other placeholders
library(fixest)
library(dplyr)

DATA_DIR <- "../data"
df <- readRDS(file.path(DATA_DIR, "analysis_data.rds"))

## Panel B convergence at intermediate horizons needs:
## delta from 1981 to 1999, 2004, 2021

# Construct deltas
df$delta_1999 <- df$yes_maternity_1999 - df$yes_equal_rights_1981
df$delta_2004 <- df$yes_maternity_2004 - df$yes_equal_rights_1981
df$delta_2021 <- df$yes_marriage_2021 - df$yes_equal_rights_1981

# Unconditional
m_1999 <- feols(delta_1999 ~ yes_equal_rights_1981, data = df, cluster = ~canton)
m_2004 <- feols(delta_2004 ~ yes_equal_rights_1981, data = df, cluster = ~canton)
m_2021 <- feols(delta_2021 ~ yes_equal_rights_1981, data = df, cluster = ~canton)

# Canton FE
m_1999_fe <- feols(delta_1999 ~ yes_equal_rights_1981 | canton, data = df, cluster = ~canton)
m_2004_fe <- feols(delta_2004 ~ yes_equal_rights_1981 | canton, data = df, cluster = ~canton)
m_2021_fe <- feols(delta_2021 ~ yes_equal_rights_1981 | canton, data = df, cluster = ~canton)

cat("\n=== INTERMEDIATE CONVERGENCE (UNCONDITIONAL) ===\n")
cat(sprintf("1981->1999: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_1999)["yes_equal_rights_1981"],
            se(m_1999)["yes_equal_rights_1981"],
            r2(m_1999, "r2")))
cat(sprintf("1981->2004: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_2004)["yes_equal_rights_1981"],
            se(m_2004)["yes_equal_rights_1981"],
            r2(m_2004, "r2")))
cat(sprintf("1981->2021: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_2021)["yes_equal_rights_1981"],
            se(m_2021)["yes_equal_rights_1981"],
            r2(m_2021, "r2")))

cat("\n=== INTERMEDIATE CONVERGENCE (CANTON FE) ===\n")
cat(sprintf("1981->1999 FE: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_1999_fe)["yes_equal_rights_1981"],
            se(m_1999_fe)["yes_equal_rights_1981"],
            r2(m_1999_fe, "r2")))
cat(sprintf("1981->2004 FE: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_2004_fe)["yes_equal_rights_1981"],
            se(m_2004_fe)["yes_equal_rights_1981"],
            r2(m_2004_fe, "r2")))
cat(sprintf("1981->2021 FE: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_2021_fe)["yes_equal_rights_1981"],
            se(m_2021_fe)["yes_equal_rights_1981"],
            r2(m_2021_fe, "r2")))

cat("\n=== FULL CONVERGENCE SPEC LADDER (Panel A) ===\n")
# Need full ladder for cols (2)-(4): +language, +religion, +suffrage
m_conv_lang <- feols(delta_gender ~ yes_equal_rights_1981 + lang_french + lang_italian,
                     data = df, cluster = ~canton)
m_conv_relig <- feols(delta_gender ~ yes_equal_rights_1981 + lang_french + lang_italian +
                        i(hist_religion), data = df, cluster = ~canton)
m_conv_suff <- feols(delta_gender ~ yes_equal_rights_1981 + lang_french + lang_italian +
                       i(hist_religion) + suffrage_year, data = df, cluster = ~canton)

cat(sprintf("Conv + lang: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_conv_lang)["yes_equal_rights_1981"],
            se(m_conv_lang)["yes_equal_rights_1981"],
            r2(m_conv_lang, "r2")))
cat(sprintf("Conv + relig: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_conv_relig)["yes_equal_rights_1981"],
            se(m_conv_relig)["yes_equal_rights_1981"],
            r2(m_conv_relig, "r2")))
cat(sprintf("Conv + suff: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_conv_suff)["yes_equal_rights_1981"],
            se(m_conv_suff)["yes_equal_rights_1981"],
            r2(m_conv_suff, "r2")))

cat("\n=== PERSISTENCE SPEC LADDER FOR MARRIAGE (Panel B) ===\n")
m_mar_biv <- feols(yes_marriage_2021 ~ yes_equal_rights_1981, data = df, cluster = ~canton)
m_mar_lang <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 + lang_french + lang_italian,
                    data = df, cluster = ~canton)
m_mar_relig <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 + lang_french + lang_italian +
                       i(hist_religion), data = df, cluster = ~canton)
m_mar_suff <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 + lang_french + lang_italian +
                      i(hist_religion) + suffrage_year, data = df, cluster = ~canton)
m_mar_fe <- feols(yes_marriage_2021 ~ yes_equal_rights_1981 | canton, data = df, cluster = ~canton)

cat(sprintf("Marriage biv: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_mar_biv)["yes_equal_rights_1981"], se(m_mar_biv)["yes_equal_rights_1981"],
            r2(m_mar_biv, "r2")))
cat(sprintf("Marriage + lang: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_mar_lang)["yes_equal_rights_1981"], se(m_mar_lang)["yes_equal_rights_1981"],
            r2(m_mar_lang, "r2")))
cat(sprintf("Marriage + relig: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_mar_relig)["yes_equal_rights_1981"], se(m_mar_relig)["yes_equal_rights_1981"],
            r2(m_mar_relig, "r2")))
cat(sprintf("Marriage + suff: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_mar_suff)["yes_equal_rights_1981"], se(m_mar_suff)["yes_equal_rights_1981"],
            r2(m_mar_suff, "r2")))
cat(sprintf("Marriage FE: beta=%.4f, SE=%.4f, R2=%.4f\n",
            coef(m_mar_fe)["yes_equal_rights_1981"], se(m_mar_fe)["yes_equal_rights_1981"],
            r2(m_mar_fe, "r2")))

cat("\n=== OSTER DELTAS FOR MARRIAGE ===\n")
# Compute Oster delta for marriage as well
ols_nc_mar <- lm(yes_marriage_2021 ~ yes_equal_rights_1981, data = df)
beta_nc_mar <- coef(ols_nc_mar)["yes_equal_rights_1981"]
r2_nc_mar <- summary(ols_nc_mar)$r.squared

ols_full_mar <- lm(yes_marriage_2021 ~ yes_equal_rights_1981 +
                     I(primary_language == "fr") + I(primary_language == "it") +
                     hist_religion + suffrage_year, data = df)
beta_full_mar <- coef(ols_full_mar)["yes_equal_rights_1981"]
r2_full_mar <- summary(ols_full_mar)$r.squared

r2_max_mar <- min(1.3 * r2_full_mar, 1.0)
if (abs(beta_nc_mar - beta_full_mar) > 1e-10) {
  oster_delta_mar <- (beta_full_mar * (r2_max_mar - r2_full_mar)) /
    ((beta_nc_mar - beta_full_mar) * (r2_full_mar - r2_nc_mar))
} else {
  oster_delta_mar <- Inf
}
cat(sprintf("Marriage Oster delta: %.4f\n", oster_delta_mar))
cat(sprintf("  beta_nc=%.4f, R2_nc=%.4f, beta_full=%.4f, R2_full=%.4f, R2_max=%.4f\n",
            beta_nc_mar, r2_nc_mar, beta_full_mar, r2_full_mar, r2_max_mar))

# Oster deltas for each spec level (paternity)
ols_nc_pat <- lm(yes_paternity_2020 ~ yes_equal_rights_1981, data = df)
beta_nc_pat <- coef(ols_nc_pat)["yes_equal_rights_1981"]
r2_nc_pat <- summary(ols_nc_pat)$r.squared

for (spec in list(
  list(name="+Language", lm=lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                                 I(primary_language == "fr") + I(primary_language == "it"), data = df)),
  list(name="+Religion", lm=lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                                  I(primary_language == "fr") + I(primary_language == "it") +
                                  hist_religion, data = df)),
  list(name="+Suffrage", lm=lm(yes_paternity_2020 ~ yes_equal_rights_1981 +
                                  I(primary_language == "fr") + I(primary_language == "it") +
                                  hist_religion + suffrage_year, data = df)),
  list(name="+CantonFE", lm=lm(yes_paternity_2020 ~ yes_equal_rights_1981 + factor(canton), data = df))
)) {
  b <- coef(spec$lm)["yes_equal_rights_1981"]
  r2 <- summary(spec$lm)$r.squared
  rmax <- min(1.3 * r2, 1)
  if (abs(beta_nc_pat - b) > 1e-10) {
    d <- (b * (rmax - r2)) / ((beta_nc_pat - b) * (r2 - r2_nc_pat))
  } else {
    d <- Inf
  }
  cat(sprintf("Paternity %s: delta=%.4f (beta=%.4f, R2=%.4f)\n", spec$name, d, b, r2))
}

# Same for marriage
for (spec in list(
  list(name="+Language", lm=lm(yes_marriage_2021 ~ yes_equal_rights_1981 +
                                 I(primary_language == "fr") + I(primary_language == "it"), data = df)),
  list(name="+Religion", lm=lm(yes_marriage_2021 ~ yes_equal_rights_1981 +
                                  I(primary_language == "fr") + I(primary_language == "it") +
                                  hist_religion, data = df)),
  list(name="+Suffrage", lm=lm(yes_marriage_2021 ~ yes_equal_rights_1981 +
                                  I(primary_language == "fr") + I(primary_language == "it") +
                                  hist_religion + suffrage_year, data = df)),
  list(name="+CantonFE", lm=lm(yes_marriage_2021 ~ yes_equal_rights_1981 + factor(canton), data = df))
)) {
  b <- coef(spec$lm)["yes_equal_rights_1981"]
  r2 <- summary(spec$lm)$r.squared
  rmax <- min(1.3 * r2, 1)
  if (abs(beta_nc_mar - b) > 1e-10) {
    d <- (b * (rmax - r2)) / ((beta_nc_mar - b) * (r2 - r2_nc_mar))
  } else {
    d <- Inf
  }
  cat(sprintf("Marriage %s: delta=%.4f (beta=%.4f, R2=%.4f)\n", spec$name, d, b, r2))
}

cat("\n=== FALSIFICATION WITH CONTROLS (tab4 needs canton FE results) ===\n")
# The falsification models in robustness_models.rds use canton FE
# But the tab4_falsification has different note saying "language region, and religion controls"
# Let me also run with language + religion + suffrage (no FE) for comparison
m_fals_mat04_ctrl <- feols(yes_maternity_2004 ~ yes_equal_rights_1981 +
                             lang_french + lang_italian + i(hist_religion) + suffrage_year,
                           data = df, cluster = ~canton)
cat(sprintf("Maternity 2004 w/ controls: beta=%.4f, SE=%.4f\n",
            coef(m_fals_mat04_ctrl)["yes_equal_rights_1981"],
            se(m_fals_mat04_ctrl)["yes_equal_rights_1981"]))

cat("\n=== N for various samples ===\n")
cat(sprintf("Total: %d\n", nrow(df)))
cat(sprintf("Complete 1981+2020: %d\n",
            sum(!is.na(df$yes_equal_rights_1981) & !is.na(df$yes_paternity_2020))))
cat(sprintf("Complete 1981+2021: %d\n",
            sum(!is.na(df$yes_equal_rights_1981) & !is.na(df$yes_marriage_2021))))

cat("\n=== HORIZON PERSISTENCE COEFFICIENTS ===\n")
# 1981 -> each year (for heterogeneity appendix)
for (v in c("yes_maternity_1984", "yes_maternity_1999", "yes_maternity_2004",
            "yes_paternity_2020", "yes_marriage_2021")) {
  m <- feols(as.formula(paste(v, "~ yes_equal_rights_1981 | canton")),
             data = df, cluster = ~canton)
  cat(sprintf("1981 -> %s: beta=%.4f, SE=%.4f\n",
              v, coef(m)["yes_equal_rights_1981"], se(m)["yes_equal_rights_1981"]))
}

cat("\n=== DONE ===\n")
