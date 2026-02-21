###############################################################################
# 04_robustness.R - Robustness checks, permutation inference, placebo tests
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

gender_panel <- readRDS(file.path(data_dir, "gender_panel_final.rds"))
gender_index <- readRDS(file.path(data_dir, "gender_index.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
full_panel <- readRDS(file.path(data_dir, "full_panel.rds"))

# ============================================================================
# 1. ROBUSTNESS: ALTERNATIVE CLUSTERING
# ============================================================================
cat("=== Robustness 1: Alternative clustering ===\n")

# Baseline: cluster at municipality
r1_mun <- feols(yes_share ~ is_french * is_catholic | vote_date,
                data = gender_panel, cluster = ~mun_id)

# Cluster at canton level (26 clusters)
r1_canton <- feols(yes_share ~ is_french * is_catholic | vote_date,
                   data = gender_panel, cluster = ~canton_id)

# Two-way clustering: municipality + vote_date
r1_twoway <- feols(yes_share ~ is_french * is_catholic | vote_date,
                   data = gender_panel, cluster = ~mun_id + vote_date)

etable(r1_mun, r1_canton, r1_twoway,
       headers = c("Cluster: Mun", "Cluster: Canton", "Two-way"),
       dict = c(is_frenchTRUE = "French", is_catholicTRUE = "Catholic",
                "is_frenchTRUE:is_catholicTRUE" = "French × Catholic"))

# ============================================================================
# 2. ROBUSTNESS: WITHIN-CANTON ESTIMATION
# ============================================================================
cat("\n=== Robustness 2: Within-canton estimation ===\n")

# Canton FE absorbs all between-canton variation
# Language effect identified only from bilingual cantons (FR, BE, VS)
r2_canton_fe <- feols(yes_share ~ is_french * is_catholic | vote_date + canton_id,
                      data = gender_panel, cluster = ~mun_id)

# For religion: canton × referendum FE
r2_canton_ref_fe <- feols(yes_share ~ is_french | vote_date^canton_id,
                          data = gender_panel, cluster = ~mun_id)

etable(r2_canton_fe, r2_canton_ref_fe,
       headers = c("Canton FE", "Canton × Referendum FE"),
       dict = c(is_frenchTRUE = "French", is_catholicTRUE = "Catholic",
                "is_frenchTRUE:is_catholicTRUE" = "French × Catholic"))

# ============================================================================
# 3. PERMUTATION INFERENCE (500 iterations)
# ============================================================================
cat("\n=== Robustness 3: Permutation inference ===\n")

# Observed interaction coefficient
obs_interaction <- coef(results$m1_interaction)["is_frenchTRUE:is_catholicTRUE"]

# Permutation: randomly reassign French/Catholic labels across municipalities
set.seed(42)
n_perm <- 500
perm_coefs <- numeric(n_perm)

# Get unique municipality-level data
mun_data <- gender_panel %>%
  distinct(mun_id, .keep_all = TRUE) %>%
  select(mun_id, is_french, is_catholic)

for (i in seq_len(n_perm)) {
  if (i %% 100 == 0) cat("  Permutation", i, "/", n_perm, "\n")

  # Randomly shuffle language and religion labels
  shuffled <- mun_data %>%
    mutate(
      is_french_perm = sample(is_french),
      is_catholic_perm = sample(is_catholic)
    )

  # Merge permuted labels
  perm_panel <- gender_panel %>%
    select(-is_french, -is_catholic) %>%
    left_join(shuffled %>% select(mun_id, is_french_perm, is_catholic_perm),
              by = "mun_id") %>%
    rename(is_french = is_french_perm, is_catholic = is_catholic_perm)

  # Estimate permuted interaction
  fit_perm <- tryCatch({
    feols(yes_share ~ is_french * is_catholic | vote_date,
          data = perm_panel, cluster = ~mun_id)
  }, error = function(e) NULL)

  if (!is.null(fit_perm)) {
    perm_coefs[i] <- coef(fit_perm)["is_frenchTRUE:is_catholicTRUE"]
  } else {
    perm_coefs[i] <- NA
  }
}

# Permutation p-value
perm_coefs_valid <- perm_coefs[!is.na(perm_coefs)]
perm_p <- mean(abs(perm_coefs_valid) >= abs(obs_interaction))
cat("  Observed interaction:", round(obs_interaction, 4), "\n")
cat("  Permutation p-value (two-sided):", round(perm_p, 4), "\n")
cat("  N valid permutations:", length(perm_coefs_valid), "\n")

# Also compute permutation p for language main effect
obs_lang <- coef(results$m1_lang)["is_frenchTRUE"]
perm_lang_coefs <- numeric(n_perm)

set.seed(43)
for (i in seq_len(n_perm)) {
  if (i %% 100 == 0) cat("  Lang permutation", i, "/", n_perm, "\n")

  shuffled_lang <- mun_data %>%
    mutate(is_french_perm = sample(is_french))

  perm_panel_lang <- gender_panel %>%
    select(-is_french) %>%
    left_join(shuffled_lang %>% select(mun_id, is_french_perm), by = "mun_id") %>%
    rename(is_french = is_french_perm)

  fit_perm_lang <- tryCatch({
    feols(yes_share ~ is_french | vote_date, data = perm_panel_lang, cluster = ~mun_id)
  }, error = function(e) NULL)

  if (!is.null(fit_perm_lang)) {
    perm_lang_coefs[i] <- coef(fit_perm_lang)["is_frenchTRUE"]
  } else {
    perm_lang_coefs[i] <- NA
  }
}

perm_lang_valid <- perm_lang_coefs[!is.na(perm_lang_coefs)]
perm_p_lang <- mean(abs(perm_lang_valid) >= abs(obs_lang))
cat("  Language main effect permutation p:", round(perm_p_lang, 4), "\n")

# ============================================================================
# 4. ROBUSTNESS: INDIVIDUAL REFERENDUM ESTIMATES
# ============================================================================
cat("\n=== Robustness 4: Individual referendum estimates ===\n")

ref_results <- gender_panel %>%
  filter(!is.na(culture_4)) %>%
  group_by(vote_date, year) %>%
  group_modify(function(df, keys) {
    fit <- tryCatch(
      lm(yes_share ~ is_french * is_catholic, data = df),
      error = function(e) NULL
    )
    if (is.null(fit)) return(tibble())

    coefs <- summary(fit)$coefficients
    tibble(
      n = nrow(df),
      french = coefs["is_frenchTRUE", "Estimate"],
      french_se = coefs["is_frenchTRUE", "Std. Error"],
      french_p = coefs["is_frenchTRUE", "Pr(>|t|)"],
      catholic = if ("is_catholicTRUE" %in% rownames(coefs))
        coefs["is_catholicTRUE", "Estimate"] else NA,
      interaction = if ("is_frenchTRUE:is_catholicTRUE" %in% rownames(coefs))
        coefs["is_frenchTRUE:is_catholicTRUE", "Estimate"] else NA,
      interaction_se = if ("is_frenchTRUE:is_catholicTRUE" %in% rownames(coefs))
        coefs["is_frenchTRUE:is_catholicTRUE", "Std. Error"] else NA
    )
  }) %>%
  ungroup()

cat("Individual referendum results:\n")
print(ref_results %>% select(vote_date, year, french, catholic, interaction, n))

# ============================================================================
# 5. ROBUSTNESS: EXCLUDE URBAN MUNICIPALITIES
# ============================================================================
cat("\n=== Robustness 5: Exclude large cities ===\n")

# Exclude municipalities with >50,000 eligible voters (major cities)
r5_no_cities <- feols(
  yes_share ~ is_french * is_catholic | vote_date,
  data = gender_panel %>% filter(eligible < 50000),
  cluster = ~mun_id
)

cat("  Without large cities - interaction:",
    round(coef(r5_no_cities)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# Exclude municipalities with >10,000 eligible voters
r5_rural <- feols(
  yes_share ~ is_french * is_catholic | vote_date,
  data = gender_panel %>% filter(eligible < 10000),
  cluster = ~mun_id
)

cat("  Rural only (<10K eligible) - interaction:",
    round(coef(r5_rural)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 5B. ROBUSTNESS: VOTER-WEIGHTED REGRESSION
# ============================================================================
cat("\n=== Robustness 5B: Voter-weighted ===\n")

# Weight by eligible voters to estimate average voter effect (not average municipality)
r5b_weighted <- feols(
  yes_share ~ is_french * is_catholic | vote_date,
  data = gender_panel,
  weights = ~eligible,
  cluster = ~mun_id
)

cat("  Voter-weighted interaction:",
    round(coef(r5b_weighted)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 6. FALSIFICATION: NON-GENDER REFERENDUM CATEGORIES
# ============================================================================
cat("\n=== Robustness 6: Extended falsification ===\n")

# Sample non-gender referenda (random selection for broad falsification)
# Take 6 random non-gender referenda from each decade
set.seed(44)
non_gender_dates <- full_panel %>%
  filter(ref_type == "other") %>%
  distinct(vote_date, year) %>%
  mutate(decade = floor(year / 10) * 10) %>%
  group_by(decade) %>%
  slice_sample(prop = 1) %>%     # shuffle within decade
  slice_head(n = 6) %>%          # take up to 6 per decade
  ungroup() %>%
  pull(vote_date)

falsi_extended <- full_panel %>%
  filter(vote_date %in% non_gender_dates) %>%
  mutate(
    culture_4 = case_when(
      !is_french & !is_catholic ~ "German-Protestant",
      !is_french & is_catholic ~ "German-Catholic",
      is_french & !is_catholic ~ "French-Protestant",
      is_french & is_catholic ~ "French-Catholic"
    )
  ) %>%
  filter(!is.na(culture_4))

r6_falsi_ext <- feols(yes_share ~ is_french * is_catholic | vote_date,
                      data = falsi_extended, cluster = ~mun_id)

cat("Extended falsification (non-gender referenda):\n")
cat("  French:", round(coef(r6_falsi_ext)["is_frenchTRUE"], 4), "\n")
cat("  Catholic:", round(coef(r6_falsi_ext)["is_catholicTRUE"], 4), "\n")
cat("  Interaction:", round(coef(r6_falsi_ext)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 7. SAVE ROBUSTNESS RESULTS
# ============================================================================

robustness <- list(
  alt_clustering = list(r1_mun = r1_mun, r1_canton = r1_canton, r1_twoway = r1_twoway),
  within_canton = list(r2_canton_fe = r2_canton_fe),
  permutation = list(
    obs_interaction = obs_interaction,
    perm_coefs = perm_coefs_valid,
    perm_p_interaction = perm_p,
    obs_lang = obs_lang,
    perm_lang_coefs = perm_lang_valid,
    perm_p_lang = perm_p_lang
  ),
  individual_ref = ref_results,
  no_cities = r5_no_cities,
  rural_only = r5_rural,
  voter_weighted = r5b_weighted,
  falsi_extended = r6_falsi_ext
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

cat("\n=== ROBUSTNESS ANALYSIS COMPLETE ===\n")
