###############################################################################
# 03_main_analysis.R - Spatial RDD, interaction models, multi-dimensional analysis
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

# Load analysis data
gender_panel <- readRDS(file.path(data_dir, "gender_panel.rds"))
gender_index <- readRDS(file.path(data_dir, "gender_index.rds"))
falsi_panel <- readRDS(file.path(data_dir, "falsi_panel.rds"))

cat("Loaded gender panel:", nrow(gender_panel), "rows\n")
cat("Loaded gender index:", nrow(gender_index), "municipalities\n")

# ============================================================================
# 1. CROSS-SECTIONAL ANALYSIS: LANGUAGE AND RELIGION MAIN EFFECTS
# ============================================================================
cat("\n=== Model 1: Main effects (OLS with canton FE) ===\n")

# Panel specification with referendum FE
m1_lang <- feols(yes_share ~ is_french | vote_date, data = gender_panel,
                 cluster = ~mun_id)

m1_relig <- feols(yes_share ~ is_catholic | vote_date, data = gender_panel,
                  cluster = ~mun_id)

m1_both <- feols(yes_share ~ is_french + is_catholic | vote_date,
                 data = gender_panel, cluster = ~mun_id)

m1_interaction <- feols(yes_share ~ is_french * is_catholic | vote_date,
                        data = gender_panel, cluster = ~mun_id)

# With canton FE (absorbs between-canton religion variation)
m1_canton <- feols(yes_share ~ is_french | vote_date + canton_id,
                   data = gender_panel, cluster = ~mun_id)

# Report
etable(m1_lang, m1_relig, m1_both, m1_interaction, m1_canton,
       title = "Language and Religion Effects on Gender Referendum Voting",
       dict = c(is_frenchTRUE = "French-speaking",
                is_catholicTRUE = "Catholic",
                "is_frenchTRUE:is_catholicTRUE" = "French × Catholic"),
       se.below = TRUE)

# Save coefficients for reference
main_effects <- list(
  language_gap = coef(m1_lang)["is_frenchTRUE"],
  religion_gap = coef(m1_relig)["is_catholicTRUE"],
  interaction = coef(m1_interaction)["is_frenchTRUE:is_catholicTRUE"],
  language_within_canton = coef(m1_canton)["is_frenchTRUE"]
)
cat("\nMain effects:\n")
cat("  Language gap (French - German):", round(main_effects$language_gap, 4), "\n")
cat("  Religion gap (Catholic - Protestant):", round(main_effects$religion_gap, 4), "\n")
cat("  Interaction (French × Catholic):", round(main_effects$interaction, 4), "\n")
cat("  Language within canton:", round(main_effects$language_within_canton, 4), "\n")

# ============================================================================
# 2. BORDER ANALYSIS: RESTRICT TO MUNICIPALITIES NEAR LANGUAGE BORDER
# ============================================================================
cat("\n=== Model 2: Border analysis (restrict to bilingual cantons) ===\n")

# Bilingual cantons where language border crosses: FR (10), BE (2), VS (23)
# These allow within-canton language comparison
border_cantons <- c(10, 2, 23)

border_panel <- gender_panel %>%
  filter(canton_id %in% border_cantons)

cat("  Border canton panel:", nrow(border_panel), "rows\n")
cat("  Municipalities in border cantons:", n_distinct(border_panel$mun_id), "\n")

m2_border <- feols(yes_share ~ is_french | vote_date + canton_id,
                   data = border_panel, cluster = ~mun_id)

cat("  Language gap within bilingual cantons:", round(coef(m2_border)["is_frenchTRUE"], 4), "\n")
cat("  SE:", round(se(m2_border)["is_frenchTRUE"], 4), "\n")
cat("  p-value:", round(fixest::pvalue(m2_border)["is_frenchTRUE"], 4), "\n")

# ============================================================================
# 3. INTERACTION ANALYSIS: DOES RELIGION MODERATE THE LANGUAGE GAP?
# ============================================================================
cat("\n=== Model 3: Religion moderation of language gap ===\n")

# Full interaction — this is the KEY specification
m3_full <- feols(yes_share ~ is_french * is_catholic | vote_date,
                 data = gender_panel, cluster = ~mun_id)

# Report interaction
cat("  French effect in Protestant areas:",
    round(coef(m3_full)["is_frenchTRUE"], 4), "\n")
cat("  Additional French effect in Catholic areas (interaction):",
    round(coef(m3_full)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")
cat("  Total French effect in Catholic areas:",
    round(coef(m3_full)["is_frenchTRUE"] +
            coef(m3_full)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 4. CULTURE GROUP ANALYSIS (2x2 FACTORIAL)
# ============================================================================
cat("\n=== Model 4: Culture group analysis (2x2) ===\n")

# Create explicit culture group factor with German-Protestant as reference
gender_panel <- gender_panel %>%
  mutate(
    culture_4 = case_when(
      !is_french & !is_catholic ~ "German-Protestant",
      !is_french & is_catholic ~ "German-Catholic",
      is_french & !is_catholic ~ "French-Protestant",
      is_french & is_catholic ~ "French-Catholic",
      TRUE ~ NA_character_
    ),
    culture_4 = factor(culture_4,
                       levels = c("German-Protestant", "German-Catholic",
                                  "French-Protestant", "French-Catholic"))
  )

# Drop mixed-religion cantons for clean 2x2
panel_clean <- gender_panel %>%
  filter(!is.na(culture_4))

m4_groups <- feols(yes_share ~ culture_4 | vote_date,
                   data = panel_clean, cluster = ~mun_id)

cat("Culture group means (relative to German-Protestant):\n")
cat("  German-Catholic:", round(coef(m4_groups)["culture_4German-Catholic"], 4), "\n")
cat("  French-Protestant:", round(coef(m4_groups)["culture_4French-Protestant"], 4), "\n")
cat("  French-Catholic:", round(coef(m4_groups)["culture_4French-Catholic"], 4), "\n")

# Compute group means from MUNICIPALITY-LEVEL index (consistent with Table 1)
# This avoids SD confusion: both tables report municipality-level variation
group_means <- gender_index %>%
  filter(culture_group %in% c("French-Protestant", "French-Catholic",
                               "German-Protestant", "German-Catholic")) %>%
  mutate(culture_4 = factor(culture_group,
                            levels = c("German-Protestant", "German-Catholic",
                                       "French-Protestant", "French-Catholic"))) %>%
  group_by(culture_4) %>%
  summarize(
    n_mun = n(),
    mean_yes = mean(gender_index, na.rm = TRUE),
    sd_yes = sd(gender_index, na.rm = TRUE),
    .groups = "drop"
  )
cat("\nAbsolute group means:\n")
print(group_means)

# Additivity test: Is the French-Catholic mean = (French effect + Catholic effect)?
# Under additivity: E[French-Catholic] = E[GP] + (French effect) + (Catholic effect)
# Under multiplicity: E[FC] ≠ E[GP] + δ_F + δ_C
gp_mean <- group_means$mean_yes[group_means$culture_4 == "German-Protestant"]
gc_mean <- group_means$mean_yes[group_means$culture_4 == "German-Catholic"]
fp_mean <- group_means$mean_yes[group_means$culture_4 == "French-Protestant"]
fc_mean <- group_means$mean_yes[group_means$culture_4 == "French-Catholic"]

predicted_additive <- gp_mean + (fp_mean - gp_mean) + (gc_mean - gp_mean)
actual_fc <- fc_mean
interaction_term <- actual_fc - predicted_additive

cat("\nAdditivity test:\n")
cat("  Predicted French-Catholic (additive):", round(predicted_additive, 4), "\n")
cat("  Actual French-Catholic:", round(actual_fc, 4), "\n")
cat("  Interaction (deviation from additivity):", round(interaction_term, 4), "\n")
cat("  Interpretation: ", ifelse(interaction_term > 0, "SUPER-ADDITIVE (amplifying)",
                                  "SUB-ADDITIVE (dampening)"), "\n")

# ============================================================================
# 5. TIME-VARYING ANALYSIS: CONVERGENCE DYNAMICS
# ============================================================================
cat("\n=== Model 5: Time-varying language and religion gaps ===\n")

# Estimate language and religion gaps for each referendum
time_gaps <- gender_panel %>%
  filter(!is.na(culture_4)) %>%
  group_by(vote_date) %>%
  group_modify(function(df, ...) {
    # Language gap
    fit_lang <- tryCatch(
      lm(yes_share ~ is_french, data = df),
      error = function(e) NULL
    )
    # Religion gap
    fit_relig <- tryCatch(
      lm(yes_share ~ is_catholic, data = df),
      error = function(e) NULL
    )
    # Interaction
    fit_int <- tryCatch(
      lm(yes_share ~ is_french * is_catholic, data = df),
      error = function(e) NULL
    )

    tibble(
      year = unique(df$year),
      lang_gap = if (!is.null(fit_lang)) coef(fit_lang)["is_frenchTRUE"] else NA,
      lang_se = if (!is.null(fit_lang)) summary(fit_lang)$coefficients["is_frenchTRUE", "Std. Error"] else NA,
      relig_gap = if (!is.null(fit_relig)) coef(fit_relig)["is_catholicTRUE"] else NA,
      relig_se = if (!is.null(fit_relig)) summary(fit_relig)$coefficients["is_catholicTRUE", "Std. Error"] else NA,
      interaction = if (!is.null(fit_int) && "is_frenchTRUE:is_catholicTRUE" %in% names(coef(fit_int)))
        coef(fit_int)["is_frenchTRUE:is_catholicTRUE"] else NA,
      interaction_se = if (!is.null(fit_int) && "is_frenchTRUE:is_catholicTRUE" %in% rownames(summary(fit_int)$coefficients))
        summary(fit_int)$coefficients["is_frenchTRUE:is_catholicTRUE", "Std. Error"] else NA,
      n = nrow(df)
    )
  }) %>%
  ungroup()

cat("Time-varying gaps:\n")
print(time_gaps %>% select(vote_date, year, lang_gap, relig_gap, interaction, n))

# ============================================================================
# 6. FALSIFICATION: NON-GENDER REFERENDA
# ============================================================================
cat("\n=== Model 6: Falsification (non-gender referenda) ===\n")

falsi_panel <- falsi_panel %>%
  mutate(
    culture_4 = case_when(
      !is_french & !is_catholic ~ "German-Protestant",
      !is_french & is_catholic ~ "German-Catholic",
      is_french & !is_catholic ~ "French-Protestant",
      is_french & is_catholic ~ "French-Catholic",
      TRUE ~ NA_character_
    )
  )

m6_falsi <- feols(yes_share ~ is_french * is_catholic | vote_date,
                  data = falsi_panel %>% filter(!is.na(culture_4)),
                  cluster = ~mun_id)

cat("Falsification interaction (should differ from gender pattern):\n")
cat("  French effect:", round(coef(m6_falsi)["is_frenchTRUE"], 4), "\n")
cat("  Catholic effect:", round(coef(m6_falsi)["is_catholicTRUE"], 4), "\n")
cat("  Interaction:", round(coef(m6_falsi)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 7. SAVE RESULTS
# ============================================================================

results <- list(
  m1_lang = m1_lang,
  m1_relig = m1_relig,
  m1_both = m1_both,
  m1_interaction = m1_interaction,
  m1_canton = m1_canton,
  m2_border = m2_border,
  m3_full = m3_full,
  m4_groups = m4_groups,
  m6_falsi = m6_falsi,
  group_means = group_means,
  time_gaps = time_gaps,
  interaction_test = list(
    predicted_additive = predicted_additive,
    actual_fc = actual_fc,
    interaction_term = interaction_term
  )
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
saveRDS(gender_panel, file.path(data_dir, "gender_panel_final.rds"))
saveRDS(time_gaps, file.path(data_dir, "time_gaps.rds"))

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
