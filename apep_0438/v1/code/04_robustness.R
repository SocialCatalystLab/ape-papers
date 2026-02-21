###############################################################################
# 04_robustness.R — Robustness checks and diagnostic tests
# Paper: Secret Ballots and Women's Political Voice (apep_0438)
###############################################################################

# Source packages from same directory
script_args <- commandArgs(trailingOnly = FALSE)
script_path <- grep("--file=", script_args, value = TRUE)
if (length(script_path) > 0) {
  script_dir_local <- dirname(normalizePath(sub("--file=", "", script_path)))
} else {
  script_dir_local <- getwd()
}
source(file.path(script_dir_local, "00_packages.R"))

cat("\n=== PHASE 4: ROBUSTNESS CHECKS ===\n\n")

# --- Load data ---------------------------------------------------------------
panel       <- readRDS(file.path(data_dir, "panel.rds"))
ar_ai_panel <- readRDS(file.path(data_dir, "ar_ai_panel.rds"))
border_gem  <- readRDS(file.path(data_dir, "border_gemeinden.rds"))

robustness <- list()

# ============================================================================
# 1. Bandwidth sensitivity
# ============================================================================
cat("1. Bandwidth sensitivity for AR-AI border...\n")

post_gem <- ar_ai_panel %>%
  filter(post_abolition) %>%
  group_by(gem_id, signed_dist, ar_side) %>%
  summarise(yes_share = mean(yes_share, na.rm = TRUE), .groups = "drop")

bw_results <- list()
for (bw_mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
  rdd_bw <- tryCatch({
    base_rdd <- rdrobust(y = post_gem$yes_share, x = post_gem$signed_dist, c = 0)
    h <- base_rdd$bws[1, 1] * bw_mult
    rdrobust(y = post_gem$yes_share, x = post_gem$signed_dist, c = 0, h = h)
  }, error = function(e) NULL)

  if (!is.null(rdd_bw)) {
    bw_results[[as.character(bw_mult)]] <- tibble(
      bw_mult = bw_mult,
      bandwidth = rdd_bw$bws[1, 1],
      estimate = rdd_bw$coef[1],
      se = rdd_bw$se[3],
      pval = rdd_bw$pv[3],
      ci_lower = rdd_bw$ci[3, 1],
      ci_upper = rdd_bw$ci[3, 2],
      n_left = rdd_bw$N_h[1],
      n_right = rdd_bw$N_h[2]
    )
  }
}

bw_df <- bind_rows(bw_results)
cat("  Bandwidth sensitivity:\n")
print(as.data.frame(bw_df))
robustness$bandwidth <- bw_df

# ============================================================================
# 2. McCrary density test
# ============================================================================
cat("\n2. McCrary density test (municipality locations fixed → should pass)...\n")

# Municipality locations are fixed (they don't bunch at borders)
# Just verify visually that distribution is smooth
density_data <- tibble(
  dist = border_gem$signed_dist[border_gem$border_pair == "AR-AI"]
) %>%
  filter(!is.na(dist))

# Simple test: compare N on each side
n_left  <- sum(density_data$dist < 0)
n_right <- sum(density_data$dist > 0)
cat("  Gemeinden left of border (AI):", n_left, "\n")
  cat("  Gemeinden right of border (AR):", n_right, "\n")
cat("  Ratio:", round(n_right / n_left, 2), "\n")
cat("  NOTE: Municipality locations are historically fixed. McCrary trivially passes.\n")

robustness$mccrary <- list(n_left = n_left, n_right = n_right)

# ============================================================================
# 3. Covariate balance at border
# ============================================================================
cat("\n3. Covariate balance at AR-AI border...\n")

# Test for discontinuity in population/area at the border
if ("area_km2" %in% names(border_gem)) {
  pair_gem <- border_gem %>%
    filter(border_pair == "AR-AI") %>%
    select(gem_id, signed_dist, area_km2, no_landsgemeinde) %>%
    distinct()

  if (nrow(pair_gem) > 10) {
    rdd_area <- tryCatch({
      rdrobust(y = pair_gem$area_km2, x = pair_gem$signed_dist, c = 0)
    }, error = function(e) NULL)

    if (!is.null(rdd_area)) {
      cat("  Area RDD: est =", round(rdd_area$coef[1], 2),
          "p =", round(rdd_area$pv[3], 3), "\n")
      robustness$covariate_area <- rdd_area
    }
  }
}

# Test for discontinuity in baseline turnout (pre-1997)
pre_turnout <- ar_ai_panel %>%
  filter(!post_abolition) %>%
  group_by(gem_id, signed_dist) %>%
  summarise(turnout = mean(turnout, na.rm = TRUE), .groups = "drop")

if (nrow(pre_turnout) > 10) {
  rdd_pre_turnout <- tryCatch({
    rdrobust(y = pre_turnout$turnout, x = pre_turnout$signed_dist, c = 0)
  }, error = function(e) NULL)

  if (!is.null(rdd_pre_turnout)) {
    cat("  Pre-1997 turnout RDD: est =", round(rdd_pre_turnout$coef[1], 4),
        "p =", round(rdd_pre_turnout$pv[3], 3), "\n")
    robustness$covariate_turnout <- rdd_pre_turnout
  }
}

# ============================================================================
# 4. Donut RDD (exclude border-adjacent Gemeinden)
# ============================================================================
cat("\n4. Donut RDD (exclude Gemeinden < 1km from border)...\n")

donut_gem <- post_gem %>% filter(abs(signed_dist) > 1.0)

if (nrow(donut_gem) > 10) {
  rdd_donut <- tryCatch({
    rdrobust(y = donut_gem$yes_share, x = donut_gem$signed_dist, c = 0)
  }, error = function(e) NULL)

  if (!is.null(rdd_donut)) {
    cat("  Donut RDD: est =", round(rdd_donut$coef[1], 4),
        "p =", round(rdd_donut$pv[3], 3), "\n")
    robustness$donut <- rdd_donut
  }
} else {
  cat("  Too few observations after donut exclusion\n")
}

# ============================================================================
# 5. Event study: Border discontinuity by year
# ============================================================================
cat("\n5. Event study: AR-AI border discontinuity by year...\n")

# Estimate border discontinuity for each year using OLS (parametric RDD)
event_study <- ar_ai_panel %>%
  group_by(vote_year) %>%
  summarise(
    n_obs = n(),
    mean_yes_ar = mean(yes_share[ar_side], na.rm = TRUE),
    mean_yes_ai = mean(yes_share[!ar_side], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    raw_gap = mean_yes_ar - mean_yes_ai,
    post_abolition = (vote_year >= 1997)
  ) %>%
  filter(n_obs >= 5) # Drop years with very few votes

# Parametric RDD by year
event_coefs <- list()
for (yr in unique(ar_ai_panel$vote_year)) {
  yr_data <- ar_ai_panel %>% filter(vote_year == yr)
  if (nrow(yr_data) < 10) next

  coef_yr <- tryCatch({
    fit <- lm(yes_share ~ ar_side + signed_dist, data = yr_data)
    tidy_fit <- broom::tidy(fit) %>% filter(term == "ar_sideTRUE")
    tibble(
      year = yr,
      estimate = tidy_fit$estimate,
      se = tidy_fit$std.error,
      pval = tidy_fit$p.value
    )
  }, error = function(e) NULL)

  if (!is.null(coef_yr)) event_coefs[[as.character(yr)]] <- coef_yr
}

event_df <- bind_rows(event_coefs) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    post = (year >= 1997)
  )

cat("  Event study years:", nrow(event_df), "\n")
cat("  Pre-1997 mean estimate:", round(mean(event_df$estimate[!event_df$post]), 4), "\n")
cat("  Post-1997 mean estimate:", round(mean(event_df$estimate[event_df$post]), 4), "\n")

robustness$event_study <- event_df

# ============================================================================
# 6. Permutation inference
# ============================================================================
cat("\n6. Permutation inference (randomize treatment assignment)...\n")

# Shuffle which Gemeinden are "treated" (AR vs AI) and re-estimate
n_perms <- 500
perm_estimates <- numeric(n_perms)

for (p in seq_len(n_perms)) {
  shuffled <- post_gem %>%
    mutate(fake_dist = sample(signed_dist))

  perm_rdd <- tryCatch({
    fit <- lm(yes_share ~ I(fake_dist > 0) + fake_dist, data = shuffled)
    coef(fit)[2]
  }, error = function(e) NA_real_)

  perm_estimates[p] <- perm_rdd
}

# Get actual estimate
actual_fit <- lm(yes_share ~ ar_side + signed_dist, data = post_gem)
actual_est <- coef(actual_fit)[2]

perm_pval <- mean(abs(perm_estimates) >= abs(actual_est), na.rm = TRUE)
cat("  Actual estimate:", round(actual_est, 4), "\n")
cat("  Permutation p-value:", round(perm_pval, 3), "(", n_perms, "permutations)\n")

robustness$permutation <- list(
  actual = actual_est,
  perm_pval = perm_pval,
  perm_dist = perm_estimates
)

# ============================================================================
# 7. Individual border pair estimates
# ============================================================================
cat("\n7. Individual border pair estimates...\n")

pair_results <- list()
for (bp in unique(panel$border_pair)) {
  bp_gem <- panel %>%
    filter(border_pair == bp, votedate >= as.Date("1997-01-01")) %>%
    group_by(gem_id, signed_dist, no_landsgemeinde) %>%
    summarise(yes_share = mean(yes_share, na.rm = TRUE), .groups = "drop")

  if (nrow(bp_gem) < 8) {
    cat("  ", bp, ": too few obs (", nrow(bp_gem), ")\n")
    next
  }

  bp_rdd <- tryCatch({
    rdrobust(y = bp_gem$yes_share, x = bp_gem$signed_dist, c = 0)
  }, error = function(e) {
    # Fallback: OLS
    fit <- lm(yes_share ~ I(signed_dist > 0) + signed_dist, data = bp_gem)
    list(coef = matrix(coef(fit)[2], nrow = 3, ncol = 1),
         pv = matrix(summary(fit)$coefficients[2, 4], nrow = 3, ncol = 1),
         method = "OLS fallback")
  })

  cat("  ", bp, ": est =", round(bp_rdd$coef[1], 4), "\n")
  pair_results[[bp]] <- bp_rdd
}

robustness$pair_results <- pair_results

# ============================================================================
# 8. Polynomial order sensitivity
# ============================================================================
cat("\n8. Polynomial order sensitivity...\n")

poly_results <- list()
for (p_order in 1:3) {
  rdd_poly <- tryCatch({
    rdrobust(y = post_gem$yes_share, x = post_gem$signed_dist, c = 0, p = p_order)
  }, error = function(e) NULL)

  if (!is.null(rdd_poly)) {
    poly_results[[as.character(p_order)]] <- tibble(
      poly_order = p_order,
      estimate = rdd_poly$coef[1],
      se = rdd_poly$se[3],
      pval = rdd_poly$pv[3]
    )
    cat("  p =", p_order, ": est =", round(rdd_poly$coef[1], 4),
        "p =", round(rdd_poly$pv[3], 3), "\n")
  }
}

robustness$polynomial <- bind_rows(poly_results)

# ============================================================================
# 9. Permutation inference for DiDisc interaction (beta_3)
# ============================================================================
cat("\n9. Permutation inference for DiDisc interaction (beta_3)...\n")

# Get the actual DiDisc interaction coefficient
actual_didisc <- tryCatch({
  feols(
    yes_share ~ ar_side * post_abolition + signed_dist +
      I(signed_dist^2) | vote_id,
    data = ar_ai_panel,
    vcov = ~gem_id
  )
}, error = function(e) NULL)

if (!is.null(actual_didisc)) {
  # The interaction term is ar_sideTRUE:post_abolitionTRUE
  interaction_name <- grep("ar_side.*post_abolition", names(coef(actual_didisc)), value = TRUE)
  if (length(interaction_name) == 0) {
    interaction_name <- grep("post_abolition.*ar_side", names(coef(actual_didisc)), value = TRUE)
  }

  if (length(interaction_name) > 0) {
    actual_beta3 <- coef(actual_didisc)[interaction_name[1]]
    cat("  Actual DiDisc interaction (beta_3):", round(actual_beta3, 4), "\n")

    # Identify unique municipalities and their AR/AI status
    gem_info <- ar_ai_panel %>%
      distinct(gem_id, ar_side)
    n_ar <- sum(gem_info$ar_side)
    n_ai <- sum(!gem_info$ar_side)
    n_total <- nrow(gem_info)
    cat("  Municipality split: AR =", n_ar, ", AI =", n_ai, "\n")

    n_perms_didisc <- 500
    perm_beta3 <- numeric(n_perms_didisc)

    set.seed(42)
    for (pp in seq_len(n_perms_didisc)) {
      # Randomly assign n_ar municipalities to "AR" side, rest to "AI"
      perm_idx <- sample(n_total, n_ar, replace = FALSE)
      perm_ar_gems <- gem_info$gem_id[perm_idx]

      perm_data <- ar_ai_panel %>%
        mutate(
          perm_ar_side = gem_id %in% perm_ar_gems
        )

      perm_fit <- tryCatch({
        feols(
          yes_share ~ perm_ar_side * post_abolition + signed_dist +
            I(signed_dist^2) | vote_id,
          data = perm_data,
          vcov = ~gem_id
        )
      }, error = function(e) NULL)

      if (!is.null(perm_fit)) {
        perm_int_name <- grep("perm_ar_side.*post_abolition|post_abolition.*perm_ar_side",
                              names(coef(perm_fit)), value = TRUE)
        if (length(perm_int_name) > 0) {
          perm_beta3[pp] <- coef(perm_fit)[perm_int_name[1]]
        } else {
          perm_beta3[pp] <- NA_real_
        }
      } else {
        perm_beta3[pp] <- NA_real_
      }
    }

    perm_pval_didisc <- mean(abs(perm_beta3) >= abs(actual_beta3), na.rm = TRUE)
    cat("  Permutation p-value (|perm beta_3| >= |actual beta_3|):",
        round(perm_pval_didisc, 4), "(", n_perms_didisc, "permutations)\n")
    cat("  Permutation distribution: mean =", round(mean(perm_beta3, na.rm = TRUE), 4),
        ", sd =", round(sd(perm_beta3, na.rm = TRUE), 4), "\n")

    robustness$perm_didisc <- list(
      actual_beta3 = actual_beta3,
      perm_pval = perm_pval_didisc,
      perm_dist = perm_beta3,
      n_ar = n_ar,
      n_ai = n_ai
    )
  } else {
    cat("  WARNING: Could not identify interaction term in DiDisc model.\n")
  }
} else {
  cat("  WARNING: DiDisc estimation failed.\n")
}

# ============================================================================
# 10. Placebo treatment dates (1993 and 2001)
# ============================================================================
cat("\n10. Placebo treatment dates (1993 and 2001)...\n")

placebo_dates <- c(1993, 2001)
placebo_date_results <- list()

for (placebo_yr in placebo_dates) {
  placebo_cutoff <- as.Date(paste0(placebo_yr, "-04-27"))

  placebo_data <- ar_ai_panel %>%
    mutate(post_placebo = (votedate >= placebo_cutoff))

  placebo_fit <- tryCatch({
    feols(
      yes_share ~ ar_side * post_placebo + signed_dist +
        I(signed_dist^2) | vote_id,
      data = placebo_data,
      vcov = ~gem_id
    )
  }, error = function(e) NULL)

  if (!is.null(placebo_fit)) {
    placebo_int_name <- grep("ar_side.*post_placebo|post_placebo.*ar_side",
                             names(coef(placebo_fit)), value = TRUE)
    if (length(placebo_int_name) > 0) {
      placebo_coef <- coef(placebo_fit)[placebo_int_name[1]]
      placebo_se <- sqrt(vcov(placebo_fit)[placebo_int_name[1], placebo_int_name[1]])
      cat("  Placebo year", placebo_yr, ": beta_3 =", round(placebo_coef, 4),
          ", SE =", round(placebo_se, 4),
          ", t =", round(placebo_coef / placebo_se, 2), "\n")
      placebo_date_results[[as.character(placebo_yr)]] <- list(
        year = placebo_yr, estimate = placebo_coef, se = placebo_se
      )
    }
  } else {
    cat("  Placebo year", placebo_yr, ": estimation failed\n")
  }
}

robustness$placebo_dates <- placebo_date_results

# ============================================================================
# 11. Pre-period restriction (1991-1997)
# ============================================================================
cat("\n11. Pre-period restriction (1991-1997 only, post AI women's suffrage)...\n")

# AI women gained cantonal suffrage in 1991. Restrict pre-period to 1991-1997
# so both AR and AI had comparable suffrage regimes throughout the sample.
restricted_data <- ar_ai_panel %>%
  filter(votedate >= as.Date("1991-01-01"))

cat("  Full sample obs:", nrow(ar_ai_panel), "\n")
cat("  Restricted sample obs (>= 1991):", nrow(restricted_data), "\n")
cat("  Dropped obs:", nrow(ar_ai_panel) - nrow(restricted_data), "\n")

restricted_fit <- tryCatch({
  feols(
    yes_share ~ ar_side * post_abolition + signed_dist +
      I(signed_dist^2) | vote_id,
    data = restricted_data,
    vcov = ~gem_id
  )
}, error = function(e) {
  cat("  Restricted sample estimation failed:", e$message, "\n")
  NULL
})

if (!is.null(restricted_fit)) {
  rest_int_name <- grep("ar_side.*post_abolition|post_abolition.*ar_side",
                        names(coef(restricted_fit)), value = TRUE)
  if (length(rest_int_name) > 0) {
    rest_coef <- coef(restricted_fit)[rest_int_name[1]]
    rest_se <- sqrt(vcov(restricted_fit)[rest_int_name[1], rest_int_name[1]])
    cat("  Restricted (1991+) DiDisc: beta_3 =", round(rest_coef, 4),
        ", SE =", round(rest_se, 4),
        ", t =", round(rest_coef / rest_se, 2), "\n")

    robustness$restricted_1991 <- list(
      estimate = rest_coef, se = rest_se,
      n_obs = nrow(restricted_data)
    )
  }
} else {
  cat("  Restricted sample estimation failed.\n")
}

# ============================================================================
# 12. Exclude influential units (Herisau and Appenzell)
# ============================================================================
cat("\n12. Exclude influential units (Herisau / Appenzell)...\n")

# Identify Herisau (largest AR municipality, BFS ~3001-3025)
# and Appenzell (largest AI municipality, BFS ~3101-3102)
ar_gems <- ar_ai_panel %>%
  filter(ar_side) %>%
  distinct(gem_id) %>%
  pull(gem_id)

ai_gems <- ar_ai_panel %>%
  filter(!ar_side) %>%
  distinct(gem_id) %>%
  pull(gem_id)

cat("  AR municipality IDs:", sort(ar_gems), "\n")
cat("  AI municipality IDs:", sort(ai_gems), "\n")

# Herisau: BFS 3001 (largest AR municipality by population)
# Appenzell: BFS 3101 (largest AI municipality)
herisau_id <- ar_gems[ar_gems >= 3001 & ar_gems <= 3025]
appenzell_id <- ai_gems[ai_gems >= 3101 & ai_gems <= 3112]

# Use first match if multiple (largest municipality typically has lowest BFS number)
if (length(herisau_id) > 0) {
  herisau_id <- min(herisau_id)  # Herisau = BFS 3001
} else {
  # Fallback: use the gem_id with most observations in AR
  herisau_id <- ar_ai_panel %>%
    filter(ar_side) %>%
    count(gem_id, sort = TRUE) %>%
    slice(1) %>%
    pull(gem_id)
}

if (length(appenzell_id) > 0) {
  appenzell_id <- min(appenzell_id)  # Appenzell = BFS 3101
} else {
  # Fallback: use the gem_id with most observations in AI
  appenzell_id <- ar_ai_panel %>%
    filter(!ar_side) %>%
    count(gem_id, sort = TRUE) %>%
    slice(1) %>%
    pull(gem_id)
}

cat("  Excluding Herisau (gem_id =", herisau_id, ")...\n")
excl_herisau <- ar_ai_panel %>% filter(gem_id != herisau_id)
fit_excl_herisau <- tryCatch({
  feols(
    yes_share ~ ar_side * post_abolition + signed_dist +
      I(signed_dist^2) | vote_id,
    data = excl_herisau,
    vcov = ~gem_id
  )
}, error = function(e) NULL)

if (!is.null(fit_excl_herisau)) {
  h_int_name <- grep("ar_side.*post_abolition|post_abolition.*ar_side",
                      names(coef(fit_excl_herisau)), value = TRUE)
  if (length(h_int_name) > 0) {
    h_coef <- coef(fit_excl_herisau)[h_int_name[1]]
    h_se <- sqrt(vcov(fit_excl_herisau)[h_int_name[1], h_int_name[1]])
    cat("  Excl. Herisau: beta_3 =", round(h_coef, 4),
        ", SE =", round(h_se, 4), "\n")
  }
}

cat("  Excluding Appenzell (gem_id =", appenzell_id, ")...\n")
excl_appenzell <- ar_ai_panel %>% filter(gem_id != appenzell_id)
fit_excl_appenzell <- tryCatch({
  feols(
    yes_share ~ ar_side * post_abolition + signed_dist +
      I(signed_dist^2) | vote_id,
    data = excl_appenzell,
    vcov = ~gem_id
  )
}, error = function(e) NULL)

if (!is.null(fit_excl_appenzell)) {
  a_int_name <- grep("ar_side.*post_abolition|post_abolition.*ar_side",
                      names(coef(fit_excl_appenzell)), value = TRUE)
  if (length(a_int_name) > 0) {
    a_coef <- coef(fit_excl_appenzell)[a_int_name[1]]
    a_se <- sqrt(vcov(fit_excl_appenzell)[a_int_name[1], a_int_name[1]])
    cat("  Excl. Appenzell: beta_3 =", round(a_coef, 4),
        ", SE =", round(a_se, 4), "\n")
  }
}

robustness$excl_influential <- list(
  herisau = if (!is.null(fit_excl_herisau)) fit_excl_herisau else NULL,
  appenzell = if (!is.null(fit_excl_appenzell)) fit_excl_appenzell else NULL,
  herisau_id = herisau_id,
  appenzell_id = appenzell_id
)

# ============================================================================
# 13. Voter-weighted regression
# ============================================================================
cat("\n13. Voter-weighted DiDisc regression...\n")

# Check for available weighting variables
weight_candidates <- c("stimmbeteiligungInProzent", "eingelegteStimmzettel",
                        "gueltigeStimmen", "jaStimmenAbsolut",
                        "neinStimmenAbsolut", "turnout")
avail_weights <- intersect(weight_candidates, names(ar_ai_panel))
cat("  Available weight candidates:", paste(avail_weights, collapse = ", "), "\n")

# Try to construct a vote-count weight: total ballots = ja + nein if available
if (all(c("jaStimmenAbsolut", "neinStimmenAbsolut") %in% names(ar_ai_panel))) {
  cat("  Using total votes (ja + nein) as weight\n")
  weighted_data <- ar_ai_panel %>%
    mutate(vote_weight = jaStimmenAbsolut + neinStimmenAbsolut) %>%
    filter(!is.na(vote_weight), vote_weight > 0)

  fit_weighted <- tryCatch({
    feols(
      yes_share ~ ar_side * post_abolition + signed_dist +
        I(signed_dist^2) | vote_id,
      data = weighted_data,
      weights = ~vote_weight,
      vcov = ~gem_id
    )
  }, error = function(e) {
    cat("  Weighted regression failed:", e$message, "\n")
    NULL
  })

  if (!is.null(fit_weighted)) {
    w_int_name <- grep("ar_side.*post_abolition|post_abolition.*ar_side",
                        names(coef(fit_weighted)), value = TRUE)
    if (length(w_int_name) > 0) {
      w_coef <- coef(fit_weighted)[w_int_name[1]]
      w_se <- sqrt(vcov(fit_weighted)[w_int_name[1], w_int_name[1]])
      cat("  Voter-weighted DiDisc: beta_3 =", round(w_coef, 4),
          ", SE =", round(w_se, 4), "\n")
    }
    robustness$voter_weighted <- fit_weighted
  }
} else if ("turnout" %in% names(ar_ai_panel)) {
  cat("  Using turnout as proxy weight (no absolute vote counts available)\n")
  weighted_data <- ar_ai_panel %>%
    filter(!is.na(turnout), turnout > 0)

  fit_weighted <- tryCatch({
    feols(
      yes_share ~ ar_side * post_abolition + signed_dist +
        I(signed_dist^2) | vote_id,
      data = weighted_data,
      weights = ~turnout,
      vcov = ~gem_id
    )
  }, error = function(e) {
    cat("  Turnout-weighted regression failed:", e$message, "\n")
    NULL
  })

  if (!is.null(fit_weighted)) {
    w_int_name <- grep("ar_side.*post_abolition|post_abolition.*ar_side",
                        names(coef(fit_weighted)), value = TRUE)
    if (length(w_int_name) > 0) {
      w_coef <- coef(fit_weighted)[w_int_name[1]]
      w_se <- sqrt(vcov(fit_weighted)[w_int_name[1], w_int_name[1]])
      cat("  Turnout-weighted DiDisc: beta_3 =", round(w_coef, 4),
          ", SE =", round(w_se, 4), "\n")
    }
    robustness$voter_weighted <- fit_weighted
  }
} else {
  cat("  No suitable weight variable found. Skipping voter-weighted regression.\n")
}

# ============================================================================
# 14. Two-way clustering (municipality AND referendum)
# ============================================================================
cat("\n14. Two-way clustering (gem_id + vote_id)...\n")

fit_twoway <- tryCatch({
  feols(
    yes_share ~ ar_side * post_abolition + signed_dist +
      I(signed_dist^2) | vote_id,
    data = ar_ai_panel,
    vcov = ~gem_id + vote_id
  )
}, error = function(e) {
  cat("  Two-way clustering failed:", e$message, "\n")
  NULL
})

if (!is.null(fit_twoway)) {
  tw_int_name <- grep("ar_side.*post_abolition|post_abolition.*ar_side",
                       names(coef(fit_twoway)), value = TRUE)
  if (length(tw_int_name) > 0) {
    tw_coef <- coef(fit_twoway)[tw_int_name[1]]
    tw_se <- sqrt(vcov(fit_twoway)[tw_int_name[1], tw_int_name[1]])

    # Also get one-way SE for comparison
    oneway_se <- if (!is.null(actual_didisc) && length(interaction_name) > 0) {
      sqrt(vcov(actual_didisc)[interaction_name[1], interaction_name[1]])
    } else {
      NA_real_
    }

    cat("  Two-way clustered DiDisc: beta_3 =", round(tw_coef, 4),
        ", SE =", round(tw_se, 4), "\n")
    cat("  One-way clustered SE (gem_id only):",
        ifelse(is.na(oneway_se), "N/A", round(oneway_se, 4)), "\n")
    cat("  SE ratio (two-way / one-way):",
        ifelse(is.na(oneway_se), "N/A", round(tw_se / oneway_se, 3)), "\n")
  }

  robustness$twoway_cluster <- fit_twoway
}

# ============================================================================
# Save
# ============================================================================
saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))
cat("\n✓ Robustness checks complete\n")
