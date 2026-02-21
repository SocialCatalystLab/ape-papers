## Extract all key coefficient values from saved models
## for integration into paper.tex

library(fixest)
library(dplyr)
library(tidyr)

DATA_DIR <- "../data"

models <- readRDS(file.path(DATA_DIR, "models.rds"))
rob <- readRDS(file.path(DATA_DIR, "robustness_models.rds"))

cat("=== PERSISTENCE COEFFICIENTS ===\n")

# Bivariate
cat(sprintf("Persistence bivariate: beta = %.4f, SE = %.4f, p = %.6f, R2 = %.4f\n",
            coef(models$persistence_bivariate)["yes_equal_rights_1981"],
            se(models$persistence_bivariate)["yes_equal_rights_1981"],
            fixest::pvalue(models$persistence_bivariate)["yes_equal_rights_1981"],
            r2(models$persistence_bivariate, "r2")))

# + Language
cat(sprintf("Persistence + language: beta = %.4f, SE = %.4f, p = %.6f, R2 = %.4f\n",
            coef(models$persistence_language)["yes_equal_rights_1981"],
            se(models$persistence_language)["yes_equal_rights_1981"],
            fixest::pvalue(models$persistence_language)["yes_equal_rights_1981"],
            r2(models$persistence_language, "r2")))

# + Religion
cat(sprintf("Persistence + religion: beta = %.4f, SE = %.4f, p = %.6f, R2 = %.4f\n",
            coef(models$persistence_religion)["yes_equal_rights_1981"],
            se(models$persistence_religion)["yes_equal_rights_1981"],
            fixest::pvalue(models$persistence_religion)["yes_equal_rights_1981"],
            r2(models$persistence_religion, "r2")))

# Canton FE
cat(sprintf("Persistence canton FE: beta = %.4f, SE = %.4f, p = %.6f, R2 = %.4f\n",
            coef(models$persistence_canton_fe)["yes_equal_rights_1981"],
            se(models$persistence_canton_fe)["yes_equal_rights_1981"],
            fixest::pvalue(models$persistence_canton_fe)["yes_equal_rights_1981"],
            r2(models$persistence_canton_fe, "r2")))

# German only
cat(sprintf("Persistence German only: beta = %.4f, SE = %.4f, p = %.6f, R2 = %.4f\n",
            coef(models$persistence_german_only)["yes_equal_rights_1981"],
            se(models$persistence_german_only)["yes_equal_rights_1981"],
            fixest::pvalue(models$persistence_german_only)["yes_equal_rights_1981"],
            r2(models$persistence_german_only, "r2")))

cat("\n=== BETA-CONVERGENCE COEFFICIENTS ===\n")

cat(sprintf("Convergence ALL: beta = %.4f, SE = %.4f, p = %.6f\n",
            coef(models$convergence_all)["yes_equal_rights_1981"],
            se(models$convergence_all)["yes_equal_rights_1981"],
            fixest::pvalue(models$convergence_all)["yes_equal_rights_1981"]))

cat(sprintf("Convergence German: beta = %.4f, SE = %.4f\n",
            coef(models$convergence_german)["yes_equal_rights_1981"],
            se(models$convergence_german)["yes_equal_rights_1981"]))

cat(sprintf("Convergence French: beta = %.4f, SE = %.4f\n",
            coef(models$convergence_french)["yes_equal_rights_1981"],
            se(models$convergence_french)["yes_equal_rights_1981"]))

cat(sprintf("Convergence Canton FE: beta = %.4f, SE = %.4f\n",
            coef(models$convergence_canton_fe)["yes_equal_rights_1981"],
            se(models$convergence_canton_fe)["yes_equal_rights_1981"]))

cat("\n=== SIGMA-CONVERGENCE ===\n")
print(models$sigma_results)

cat("\n=== AIPW ESTIMATES ===\n")
cat(sprintf("AIPW weighted: beta = %.4f, SE = %.4f, p = %.6f\n",
            coef(models$aipw_weighted)["yes_equal_rights_1981"],
            se(models$aipw_weighted)["yes_equal_rights_1981"],
            fixest::pvalue(models$aipw_weighted)["yes_equal_rights_1981"]))

cat(sprintf("AIPW full: beta = %.4f, SE = %.4f, p = %.6f\n",
            coef(models$aipw_full)["yes_equal_rights_1981"],
            se(models$aipw_full)["yes_equal_rights_1981"],
            fixest::pvalue(models$aipw_full)["yes_equal_rights_1981"]))

cat("\n=== WILD CLUSTER BOOTSTRAP ===\n")
cat("Boot bivariate:\n")
str(models$boot_bivariate)
cat("Boot canton FE:\n")
str(models$boot_canton_fe)
cat("Boot convergence:\n")
str(models$boot_convergence)

cat("\n=== ROBUSTNESS: OSTER DELTA ===\n")
cat(sprintf("Oster delta: %.4f\n", rob$oster_delta))

cat("\n=== ROBUSTNESS: DECOMPOSITION ===\n")
print(rob$decomposition)

cat("\n=== ROBUSTNESS: GERMAN-ONLY ===\n")
cat(sprintf("German bivariate: beta = %.4f, SE = %.4f\n",
            coef(rob$german_bivariate)["yes_equal_rights_1981"],
            se(rob$german_bivariate)["yes_equal_rights_1981"]))
cat(sprintf("German + religion: beta = %.4f, SE = %.4f\n",
            coef(rob$german_religion)["yes_equal_rights_1981"],
            se(rob$german_religion)["yes_equal_rights_1981"]))
cat(sprintf("German FE: beta = %.4f, SE = %.4f\n",
            coef(rob$german_fe)["yes_equal_rights_1981"],
            se(rob$german_fe)["yes_equal_rights_1981"]))
cat(sprintf("German convergence: beta = %.4f, SE = %.4f\n",
            coef(rob$german_convergence)["yes_equal_rights_1981"],
            se(rob$german_convergence)["yes_equal_rights_1981"]))
cat(sprintf("German convergence FE: beta = %.4f, SE = %.4f\n",
            coef(rob$german_convergence_fe)["yes_equal_rights_1981"],
            se(rob$german_convergence_fe)["yes_equal_rights_1981"]))

cat("\n=== ROBUSTNESS: FALSIFICATION ===\n")
print(rob$falsification_results |> select(outcome, type, beta, se, pval, r2))

cat("\n=== ROBUSTNESS: ALTERNATIVE OUTCOMES (Marriage 2021 as DV) ===\n")
cat(sprintf("Marriage bivariate: beta = %.4f, SE = %.4f\n",
            coef(rob$alt_marriage_biv)["yes_equal_rights_1981"],
            se(rob$alt_marriage_biv)["yes_equal_rights_1981"]))
cat(sprintf("Marriage FE: beta = %.4f, SE = %.4f\n",
            coef(rob$alt_marriage_fe)["yes_equal_rights_1981"],
            se(rob$alt_marriage_fe)["yes_equal_rights_1981"]))
cat(sprintf("Maternity 2004 bivariate: beta = %.4f, SE = %.4f\n",
            coef(rob$alt_maternity_biv)["yes_equal_rights_1981"],
            se(rob$alt_maternity_biv)["yes_equal_rights_1981"]))
cat(sprintf("Maternity 2004 FE: beta = %.4f, SE = %.4f\n",
            coef(rob$alt_maternity_fe)["yes_equal_rights_1981"],
            se(rob$alt_maternity_fe)["yes_equal_rights_1981"]))

cat("\n=== N-OBS ===\n")
cat(sprintf("Full sample: %d\n", nobs(models$persistence_bivariate)))
cat(sprintf("German-only: %d\n", nobs(models$persistence_german_only)))

cat("\n=== ADDITIONAL: Nobs and R2 for all persistence specifications ===\n")
for (nm in c("persistence_bivariate", "persistence_language", "persistence_religion",
             "persistence_canton_fe", "persistence_german_only")) {
  m <- models[[nm]]
  cat(sprintf("  %s: N = %d, R2 = %.4f, adj.R2 = %.4f\n",
              nm, nobs(m), r2(m, "r2"), r2(m, "ar2")))
}

cat("\n=== LANGUAGE REGION MEANS ===\n")
df <- readRDS(file.path(DATA_DIR, "analysis_data.rds"))
df_de <- df |> filter(primary_language == "de")
df_fr <- df |> filter(primary_language == "fr")

for (v in c("yes_equal_rights_1981", "yes_paternity_2020", "yes_marriage_2021",
            "yes_maternity_1999", "yes_maternity_2004")) {
  cat(sprintf("\n%s:\n", v))
  cat(sprintf("  Overall: mean=%.2f, sd=%.2f\n", mean(df[[v]], na.rm=TRUE), sd(df[[v]], na.rm=TRUE)))
  cat(sprintf("  German:  mean=%.2f, sd=%.2f\n", mean(df_de[[v]], na.rm=TRUE), sd(df_de[[v]], na.rm=TRUE)))
  cat(sprintf("  French:  mean=%.2f, sd=%.2f\n", mean(df_fr[[v]], na.rm=TRUE), sd(df_fr[[v]], na.rm=TRUE)))
}

cat("\n=== SIGMA CONVERGENCE: IQR and P90-P10 ===\n")
for (v in c("yes_equal_rights_1981", "yes_maternity_1984", "yes_maternity_1999",
            "yes_maternity_2004", "yes_paternity_2020", "yes_marriage_2021")) {
  vals <- df[[v]]
  q <- quantile(vals, c(0.10, 0.25, 0.75, 0.90), na.rm = TRUE)
  cat(sprintf("%s: IQR=%.2f, P90-P10=%.2f (P10=%.2f, P25=%.2f, P75=%.2f, P90=%.2f)\n",
              v, q[3]-q[2], q[4]-q[1], q[1], q[2], q[3], q[4]))
}

cat("\n=== CONVERGENCE MAGNITUDES ===\n")
# "A municipality starting one SD below the mean converged by..."
sd_1981 <- sd(df$yes_equal_rights_1981, na.rm=TRUE)
beta_all <- coef(models$convergence_all)["yes_equal_rights_1981"]
cat(sprintf("SD of 1981 YES share: %.2f\n", sd_1981))
cat(sprintf("Convergence: 1 SD * beta = %.2f * %.4f = %.2f pp\n",
            sd_1981, beta_all, sd_1981 * abs(beta_all)))

# "A municipality 1 SD more progressive in 1981 is expected to be X pp more progressive"
beta_fe <- coef(models$persistence_canton_fe)["yes_equal_rights_1981"]
cat(sprintf("Persistence: 1 SD * beta_fe = %.2f * %.4f = %.2f pp\n",
            sd_1981, beta_fe, sd_1981 * beta_fe))

cat("\n=== CONLEY SE COMPARISON ===\n")
# Compare canton-clustered SE to HC0 SE for reference
se_canton <- se(models$persistence_canton_fe)["yes_equal_rights_1981"]
cat(sprintf("Canton-clustered SE (persistence FE): %.4f\n", se_canton))

cat("\n=== MERGED MUNICIPALITIES COUNT ===\n")
# Estimate number of merged municipalities
cat(sprintf("Total municipalities in sample: %d\n", nrow(df)))
cat(sprintf("German municipalities: %d\n", nrow(df_de)))
cat(sprintf("French municipalities: %d\n", nrow(df_fr)))

cat("\n=== FE MARRIAGE (PANEL B) ===\n")
cat(sprintf("FE Marriage 2021: beta = %.4f, SE = %.4f\n",
            coef(rob$fe_marriage)["yes_equal_rights_1981"],
            se(rob$fe_marriage)["yes_equal_rights_1981"]))
cat(sprintf("FE Maternity 2004: beta = %.4f, SE = %.4f\n",
            coef(rob$fe_maternity04)["yes_equal_rights_1981"],
            se(rob$fe_maternity04)["yes_equal_rights_1981"]))

cat("\n=== DONE ===\n")
