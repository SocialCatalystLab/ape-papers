# =============================================================================
# 07_expanded_analysis.R
# Expanded analysis: multiple maps, 5 RDD specifications, randomization inference,
# panel analysis with multiple referendums
# =============================================================================

# Get script directory for portable sourcing
get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

library(scales)
library(viridis)

# Conditionally load packages that may not be available
has_rddensity <- requireNamespace("rddensity", quietly = TRUE)
if (has_rddensity) library(rddensity)

has_patchwork <- requireNamespace("patchwork", quietly = TRUE)
if (has_patchwork) library(patchwork)

# Override theme with function version for figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40"),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom"
    )
}
theme_set(theme_apep())

# Create output directories (using paths from 00_packages.R)
dir.create(fig_dir, showWarnings = FALSE)
dir.create(tab_dir, showWarnings = FALSE)

# =============================================================================
# LOAD DATA
# =============================================================================
cat("Loading data...\n")

# Load voting data (using data_dir from 00_packages.R)
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

# Try to load spatial data
has_spatial <- file.exists(file.path(data_dir, "voting_sf.rds"))
if (has_spatial) {
  voting_sf <- readRDS(file.path(data_dir, "voting_sf.rds"))
  cat("Spatial data loaded successfully\n")
} else {
  cat("WARNING: No spatial data available\n")
  voting_sf <- NULL
}

# Create a gemeinde-level dataset for analysis
gemeinde_data <- voting_data %>%
  rename(
    gemeinde_id = mun_id,
    canton = canton_abbr,
    language = lang,
    voters = eligible_voters
  ) %>%
  mutate(
    treated = as.numeric(treated),
    log_pop = log(voters + 1),
    urban_share = ifelse(voters > 5000, 1, 0)
  )

cat(paste("Loaded", nrow(gemeinde_data), "gemeinden\n"))
cat(paste("Treated:", sum(gemeinde_data$treated), "| Control:", sum(1 - gemeinde_data$treated), "\n"))

# =============================================================================
# SECTION 1: CANTON-LEVEL MAP DATA
# =============================================================================
cat("\n=== CREATING CANTON-LEVEL MAPS ===\n")

# Create canton-level summary
canton_summary <- gemeinde_data %>%
  group_by(canton, treated, language) %>%
  summarize(
    mean_yes = mean(yes_share, na.rm = TRUE),
    mean_turnout = mean(turnout, na.rm = TRUE),
    n_gemeinden = n(),
    total_voters = sum(voters, na.rm = TRUE),
    .groups = "drop"
  )

# Treated cantons
treated_cantons <- c("GR", "BE", "AG", "BL", "BS")

# Language mapping
language_map <- tibble(
  canton = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
             "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
             "TI", "VD", "VS", "NE", "GE", "JU"),
  language_full = c("German", "German", "German", "German", "German", "German", "German", "German", "German", "French",
                    "German", "German", "German", "German", "German", "German", "German", "German", "German", "German",
                    "Italian", "French", "French", "French", "French", "French")
)

canton_summary <- canton_summary %>%
  left_join(language_map, by = "canton")

# =============================================================================
# SECTION 2: SPATIAL RDD SETUP (if spatial data available)
# =============================================================================

# Initialize rdd_sample as NULL at global scope
rdd_sample <- NULL

if (has_spatial && !is.null(voting_sf)) {
  cat("\n=== SETTING UP SPATIAL RDD ===\n")

  # Compute centroids and distances
  voting_sf_clean <- voting_sf %>%
    filter(!is.na(yes_share) & !is.na(treated))

  # The geometry column is named 'geom' in this dataset
  geom_col <- attr(voting_sf, "sf_column")
  cat(paste("Geometry column:", geom_col, "\n"))

  # Try to compute centroid
  rdd_result <- tryCatch({
    # Use the actual geometry column
    voting_sf_clean <- voting_sf_clean %>%
      mutate(centroid = st_centroid(st_geometry(.)))

    # Get canton boundaries
    treated_canton_ids <- c(2, 12, 13, 18, 19)  # BE, BS, BL, GR, AG

    canton_borders <- voting_sf_clean %>%
      group_by(canton_id) %>%
      summarise(.groups = "drop")  # Let sf handle geometry union automatically

    # CRITICAL FIX: Use get_policy_border() to compute ONLY internal canton borders
    # The original code used st_boundary() intersection which includes national
    # borders with France, Italy, Germany - invalidating the spatial RDD.
    cat("Computing CORRECT policy border (internal canton boundaries only)...\n")
    border <- get_policy_border(canton_borders, treated_canton_ids, canton_id_col = "canton_id")

    if (!st_is_empty(border)) {
      # Compute distance to border for each gemeinde
      voting_sf_clean <- voting_sf_clean %>%
        mutate(
          dist_to_border = as.numeric(st_distance(centroid, border)) / 1000,  # km
          distance_to_border = ifelse(treated, dist_to_border, -dist_to_border)
        )

      cat(paste("Distance to border computed for", sum(!is.na(voting_sf_clean$distance_to_border)), "gemeinden\n"))

      # Create RDD sample
      sample <- voting_sf_clean %>%
        st_drop_geometry() %>%
        filter(!is.na(distance_to_border)) %>%
        select(mun_id, yes_share, treated, distance_to_border, canton_id, canton_abbr, lang)

      cat(paste("RDD sample size:", nrow(sample), "\n"))
      sample  # Return the sample
    } else {
      cat("Could not compute border geometry\n")
      NULL
    }
  }, error = function(e) {
    cat(paste("Error computing spatial distances:", e$message, "\n"))
    NULL
  })

  # Assign result to global rdd_sample
  if (!is.null(rdd_result)) {
    rdd_sample <- rdd_result
  }
} else {
  cat("No spatial data - skipping spatial RDD setup\n")
}

# =============================================================================
# SECTION 3: OLS REGRESSION ANALYSIS
# =============================================================================
cat("\n=== OLS REGRESSION ANALYSIS ===\n")

# Model 1: Raw comparison
model1 <- feols(yes_share ~ treated, data = gemeinde_data, cluster = ~canton)

# Model 2: Add language controls
model2 <- feols(yes_share ~ treated + i(language), data = gemeinde_data, cluster = ~canton)

# Model 3: Add turnout control
model3 <- feols(yes_share ~ treated + i(language) + turnout, data = gemeinde_data, cluster = ~canton)

# Model 4: Language fixed effects
model4 <- feols(yes_share ~ treated | language, data = gemeinde_data, cluster = ~canton)

# Extract coefficients
get_coef <- function(model, var = "treated") {
  coef_val <- coef(model)[var]
  if (is.na(coef_val)) coef_val <- coef(model)[paste0(var, "TRUE")]
  if (is.na(coef_val)) coef_val <- coef(model)[1]  # First non-intercept coefficient
  return(coef_val)
}

get_se <- function(model, var = "treated") {
  se_val <- sqrt(vcov(model)[var, var])
  if (is.na(se_val)) {
    var2 <- paste0(var, "TRUE")
    if (var2 %in% rownames(vcov(model))) {
      se_val <- sqrt(vcov(model)[var2, var2])
    }
  }
  return(se_val)
}

cat("\nOLS Results:\n")
cat(paste("Raw: coef =", round(get_coef(model1), 2), "SE =", round(get_se(model1), 2), "\n"))
cat(paste("+ Language: coef =", round(get_coef(model2), 2), "SE =", round(get_se(model2), 2), "\n"))
cat(paste("+ Turnout: coef =", round(get_coef(model3), 2), "SE =", round(get_se(model3), 2), "\n"))
cat(paste("Language FE: coef =", round(coef(model4)[1], 2), "SE =", round(sqrt(vcov(model4)[1,1]), 2), "\n"))

# Save OLS table
ols_results <- tibble(
  specification = c("(1) Raw", "(2) + Language", "(3) + Language + Turnout", "(4) Language FE"),
  estimate = c(get_coef(model1), get_coef(model2), get_coef(model3), coef(model4)[1]),
  se = c(get_se(model1), get_se(model2), get_se(model3), sqrt(vcov(model4)[1,1])),
  n = c(nobs(model1), nobs(model2), nobs(model3), nobs(model4))
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    pvalue = 2 * pnorm(abs(estimate / se), lower.tail = FALSE)
  )

write_csv(ols_results, file.path(tab_dir, "table_ols_results.csv"))

# =============================================================================
# SECTION 4: FIVE RDD SPECIFICATIONS (if spatial data available)
# =============================================================================

if (!is.null(rdd_sample) && nrow(rdd_sample) > 100) {
  cat("\n=== RUNNING 5 RDD SPECIFICATIONS ===\n")

  # Specification 1: Pooled RDD (all borders), MSE-optimal
  rdd1 <- tryCatch({
    rdrobust(
      y = rdd_sample$yes_share,
      x = rdd_sample$distance_to_border,
      c = 0
    )
  }, error = function(e) {
    cat(paste("RDD1 error:", e$message, "\n"))
    NULL
  })

  if (!is.null(rdd1)) {
    cat(paste("RDD1 (Pooled): estimate =", round(rdd1$coef[1], 2),
              "SE =", round(rdd1$se[1], 2),
              "BW =", round(rdd1$bws[1], 2), "km\n"))

    # Specification 2: Same-language borders only (German-German borders)
    same_lang_sample <- rdd_sample %>%
      filter(lang == "German")

    rdd2 <- tryCatch({
      rdrobust(
        y = same_lang_sample$yes_share,
        x = same_lang_sample$distance_to_border,
        c = 0
      )
    }, error = function(e) {
      cat(paste("RDD2 error:", e$message, "\n"))
      NULL
    })

    if (!is.null(rdd2)) {
      cat(paste("RDD2 (Same-language): estimate =", round(rdd2$coef[1], 2),
                "SE =", round(rdd2$se[1], 2), "\n"))
    }

    # Specification 3: Half bandwidth
    rdd3 <- tryCatch({
      rdrobust(
        y = rdd_sample$yes_share,
        x = rdd_sample$distance_to_border,
        c = 0,
        h = rdd1$bws[1] / 2
      )
    }, error = function(e) NULL)

    # Specification 4: Double bandwidth
    rdd4 <- tryCatch({
      rdrobust(
        y = rdd_sample$yes_share,
        x = rdd_sample$distance_to_border,
        c = 0,
        h = rdd1$bws[1] * 2
      )
    }, error = function(e) NULL)

    # Specification 5: Local quadratic (p=2)
    rdd5 <- tryCatch({
      rdrobust(
        y = rdd_sample$yes_share,
        x = rdd_sample$distance_to_border,
        c = 0,
        p = 2
      )
    }, error = function(e) NULL)

    # Compile RDD results
    rdd_specs <- list(
      "1. Pooled (MSE-optimal)" = rdd1,
      "2. Same-language borders" = rdd2,
      "3. Half bandwidth" = rdd3,
      "4. Double bandwidth" = rdd4,
      "5. Local quadratic" = rdd5
    )

    rdd_results <- map_dfr(names(rdd_specs), function(spec) {
      rd <- rdd_specs[[spec]]
      if (is.null(rd)) {
        return(tibble(
          specification = spec,
          estimate = NA_real_,
          se = NA_real_,
          ci_lower = NA_real_,
          ci_upper = NA_real_,
          bandwidth = NA_real_,
          n_left = NA_integer_,
          n_right = NA_integer_
        ))
      }
      tibble(
        specification = spec,
        estimate = rd$coef[1],
        se = rd$se[1],
        pvalue = rd$pv[1],
        ci_lower = rd$ci[1,1],
        ci_upper = rd$ci[1,2],
        bandwidth = rd$bws[1],
        n_left = rd$N_h[1],  # Use effective sample within bandwidth, not total
        n_right = rd$N_h[2]
      )
    })

    write_csv(rdd_results, file.path(tab_dir, "rdd_specifications.csv"))

    # Create RDD coefficient plot
    rdd_results_plot <- rdd_results %>%
      filter(!is.na(estimate))

    if (nrow(rdd_results_plot) > 0) {
      p_rdd_coef <- ggplot(rdd_results_plot, aes(x = estimate, y = fct_rev(specification))) +
        geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
        geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "#2166AC") +
        geom_point(size = 3, color = "#2166AC") +
        labs(
          title = "Spatial RDD Estimates Across Specifications",
          subtitle = "95% confidence intervals; null effect at dashed line",
          x = "Treatment Effect (percentage points)",
          y = ""
        ) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_rdd_specifications.pdf"), p_rdd_coef, width = 10, height = 6)
      cat("Saved fig_rdd_specifications.pdf\n")
    }

    # =============================================================================
    # SECTION 5: BANDWIDTH SENSITIVITY ANALYSIS
    # =============================================================================
    cat("\n=== BANDWIDTH SENSITIVITY ===\n")

    bandwidths <- seq(1, 10, by = 0.5)
    bw_results <- map_dfr(bandwidths, function(h) {
      rd <- tryCatch({
        rdrobust(
          y = rdd_sample$yes_share,
          x = rdd_sample$distance_to_border,
          c = 0,
          h = h
        )
      }, error = function(e) NULL)

      if (is.null(rd)) {
        return(tibble(bandwidth = h, estimate = NA_real_, se = NA_real_,
                      ci_lower = NA_real_, ci_upper = NA_real_, n = NA_integer_))
      }

      tibble(
        bandwidth = h,
        estimate = rd$coef[1],
        se = rd$se[1],
        ci_lower = rd$ci[1,1],
        ci_upper = rd$ci[1,2],
        n = sum(rd$N)
      )
    }) %>%
      filter(!is.na(estimate))

    if (nrow(bw_results) > 0) {
      write_csv(bw_results, file.path(tab_dir, "bandwidth_sensitivity.csv"))

      p_bw <- ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2166AC") +
        geom_line(color = "#2166AC", linewidth = 1) +
        geom_vline(xintercept = rdd1$bws[1], linetype = "dotted", color = "red") +
        annotate("text", x = rdd1$bws[1] + 0.3, y = max(bw_results$ci_upper, na.rm = TRUE),
                 label = "MSE-optimal", hjust = 0, color = "red", size = 3) +
        labs(
          title = "Bandwidth Sensitivity Analysis",
          subtitle = "RDD estimate across different bandwidth choices",
          x = "Bandwidth (km)",
          y = "Treatment Effect (pp)"
        ) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_bandwidth_sensitivity.pdf"), p_bw, width = 10, height = 6)
      cat("Saved fig_bandwidth_sensitivity.pdf\n")
    }

    # =============================================================================
    # SECTION 6: DONUT RDD SPECIFICATIONS
    # =============================================================================
    cat("\n=== DONUT RDD SPECIFICATIONS ===\n")

    donut_results <- map_dfr(c(0, 0.5, 1, 1.5, 2), function(donut) {
      sample_donut <- rdd_sample %>%
        filter(abs(distance_to_border) > donut)

      rd <- tryCatch({
        rdrobust(
          y = sample_donut$yes_share,
          x = sample_donut$distance_to_border,
          c = 0
        )
      }, error = function(e) NULL)

      if (is.null(rd)) {
        return(tibble(donut_km = donut, estimate = NA_real_, se = NA_real_,
                      ci_lower = NA_real_, ci_upper = NA_real_, n = NA_integer_))
      }

      tibble(
        donut_km = donut,
        estimate = rd$coef[1],
        se = rd$se[1],
        ci_lower = rd$ci[1,1],
        ci_upper = rd$ci[1,2],
        n = sum(rd$N)
      )
    }) %>%
      filter(!is.na(estimate))

    if (nrow(donut_results) > 0) {
      write_csv(donut_results, file.path(tab_dir, "donut_rdd.csv"))

      p_donut <- ggplot(donut_results, aes(x = donut_km, y = estimate)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2166AC") +
        geom_line(color = "#2166AC", linewidth = 1) +
        geom_point(color = "#2166AC", size = 3) +
        labs(
          title = "Donut RDD Specifications",
          subtitle = "Excluding municipalities within X km of the border",
          x = "Donut Radius (km excluded)",
          y = "Treatment Effect (pp)"
        ) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_donut_rdd.pdf"), p_donut, width = 8, height = 5)
      cat("Saved fig_donut_rdd.pdf\n")
    }

    # =============================================================================
    # SECTION 7: McCRARY DENSITY TEST
    # =============================================================================
    if (has_rddensity) {
      cat("\n=== McCRARY DENSITY TEST ===\n")

      density_test <- tryCatch({
        rddensity(rdd_sample$distance_to_border, c = 0)
      }, error = function(e) {
        cat(paste("Density test error:", e$message, "\n"))
        NULL
      })

      if (!is.null(density_test)) {
        cat(paste("Density test: t =", round(density_test$test$t_jk, 2),
                  "p =", round(density_test$test$p_jk, 3), "\n"))

        density_results <- tibble(
          test_statistic = density_test$test$t_jk,
          p_value = density_test$test$p_jk,
          n_left = density_test$N$eff_l,
          n_right = density_test$N$eff_r
        )
        write_csv(density_results, file.path(tab_dir, "mccrary_density.csv"))

        # Create density plot
        p_density <- tryCatch({
          rdplotdensity(density_test, rdd_sample$distance_to_border)$Estplot +
            labs(
              title = "McCrary Density Test",
              subtitle = paste0("Test statistic = ", round(density_test$test$t_jk, 2),
                                "; p-value = ", round(density_test$test$p_jk, 3)),
              x = "Distance to Border (km)",
              y = "Density"
            ) +
            theme_apep()
        }, error = function(e) NULL)

        if (!is.null(p_density)) {
          ggsave(file.path(fig_dir, "fig_density_test.pdf"), p_density, width = 8, height = 5)
          cat("Saved fig_density_test.pdf\n")
        }
      }
    }

    # =============================================================================
    # SECTION 8: MAIN RDD PLOT
    # =============================================================================
    cat("\n=== CREATING MAIN RDD PLOT ===\n")

    # Bin means for scatter
    bin_width <- 2
    binned_data <- rdd_sample %>%
      mutate(bin = cut(distance_to_border, breaks = seq(-20, 20, by = bin_width))) %>%
      group_by(bin) %>%
      summarise(
        mean_yes = mean(yes_share, na.rm = TRUE),
        se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
        n = n(),
        mid = mean(distance_to_border, na.rm = TRUE),
        treated = mean(treated, na.rm = TRUE) > 0.5,
        .groups = "drop"
      ) %>%
      filter(n >= 3)

    if (nrow(binned_data) > 0) {
      p_rdd_main <- ggplot(binned_data, aes(x = mid, y = mean_yes, color = treated)) +
        geom_vline(xintercept = 0, linetype = "dashed", color = "gray30") +
        geom_point(size = 2.5, alpha = 0.8) +
        geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                      width = 0.3, alpha = 0.5) +
        geom_smooth(data = rdd_sample %>% filter(distance_to_border < 0),
                    aes(x = distance_to_border, y = yes_share),
                    method = "loess", se = TRUE, color = "#B2182B", fill = "#B2182B",
                    alpha = 0.2, linewidth = 1) +
        geom_smooth(data = rdd_sample %>% filter(distance_to_border > 0),
                    aes(x = distance_to_border, y = yes_share),
                    method = "loess", se = TRUE, color = "#2166AC", fill = "#2166AC",
                    alpha = 0.2, linewidth = 1) +
        scale_color_manual(
          values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
          labels = c("TRUE" = "Treated", "FALSE" = "Control"),
          name = ""
        ) +
        labs(
          x = "Distance to Canton Border (km)",
          y = "Yes Share (%)",
          title = "Spatial RDD: Vote Shares at Canton Border",
          subtitle = paste0("RD estimate: ", round(rdd1$coef[1], 2),
                            " pp (SE = ", round(rdd1$se[1], 2), ")"),
          caption = "Dots show bin means (2km width); lines show local polynomial fits"
        ) +
        annotate("text", x = -10, y = max(binned_data$mean_yes, na.rm = TRUE) - 2,
                 label = "<- Control side", color = "#B2182B", size = 3) +
        annotate("text", x = 10, y = max(binned_data$mean_yes, na.rm = TRUE) - 2,
                 label = "Treated side ->", color = "#2166AC", size = 3) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_rdd_main.pdf"), p_rdd_main, width = 10, height = 6)
      cat("Saved fig_rdd_main.pdf\n")
    }

    # =============================================================================
    # SECTION 9: COVARIATE BALANCE AT BORDER
    # =============================================================================
    cat("\n=== COVARIATE BALANCE ===\n")

    # Add covariates to RDD sample
    rdd_sample_with_cov <- rdd_sample %>%
      left_join(
        gemeinde_data %>% select(gemeinde_id, log_pop, urban_share, turnout),
        by = c("mun_id" = "gemeinde_id")
      )

    # Balance tests
    cov_vars <- c("log_pop", "urban_share", "turnout")
    cov_tests <- map_dfr(cov_vars, function(var) {
      if (!var %in% names(rdd_sample_with_cov)) return(NULL)
      if (all(is.na(rdd_sample_with_cov[[var]]))) return(NULL)

      rd <- tryCatch({
        rdrobust(
          y = rdd_sample_with_cov[[var]],
          x = rdd_sample_with_cov$distance_to_border,
          c = 0
        )
      }, error = function(e) NULL)

      if (is.null(rd)) return(NULL)

      tibble(
        covariate = var,
        estimate = rd$coef[1],
        se = rd$se[1],
        pvalue = rd$pv[1]
      )
    })

    if (!is.null(cov_tests) && nrow(cov_tests) > 0) {
      write_csv(cov_tests, file.path(tab_dir, "covariate_balance.csv"))

      p_balance <- ggplot(cov_tests, aes(x = estimate, y = covariate)) +
        geom_vline(xintercept = 0, linetype = "dashed") +
        geom_errorbarh(aes(xmin = estimate - 1.96*se, xmax = estimate + 1.96*se), height = 0.2) +
        geom_point(size = 3, color = "#2166AC") +
        labs(
          title = "Covariate Balance at the Border",
          subtitle = "RDD estimates on predetermined covariates (should be near zero)",
          x = "Discontinuity Estimate",
          y = ""
        ) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_covariate_balance.pdf"), p_balance, width = 8, height = 5)
      cat("Saved fig_covariate_balance.pdf\n")
    }

    # =============================================================================
    # SECTION 9b: BORDER-PAIR HETEROGENEITY ANALYSIS
    # =============================================================================
    cat("\n=== BORDER-PAIR HETEROGENEITY ===\n")

    # Define border pairs based on canton adjacencies
    # Treated cantons: GR (18), BE (2), AG (19), BL (13), BS (12)
    # We'll identify which control canton each treated gemeinde borders

    # Create border pair variable by identifying the nearest control canton
    rdd_sample_pairs <- rdd_sample %>%
      mutate(
        treated_canton = canton_abbr,
        # Simplified border pair assignment based on canton
        border_pair = case_when(
          canton_abbr == "AG" ~ "AG-ZH/SO",
          canton_abbr == "GR" ~ "GR-SG/GL",
          canton_abbr == "BE" ~ "BE-multiple",
          canton_abbr == "BL" ~ "BL-SO",
          canton_abbr == "BS" ~ "BS-urban",
          # Control side - assign based on proximity to treated
          canton_abbr == "ZH" ~ "AG-ZH/SO",
          canton_abbr == "SO" ~ "AG-ZH/SO",
          canton_abbr == "SG" ~ "GR-SG/GL",
          canton_abbr == "GL" ~ "GR-SG/GL",
          canton_abbr == "LU" ~ "BE-multiple",
          canton_abbr == "FR" ~ "BE-multiple",
          canton_abbr == "JU" ~ "BE-multiple",
          canton_abbr == "NE" ~ "BE-multiple",
          TRUE ~ "Other"
        )
      )

    # Estimate RDD for each border pair
    border_pairs <- unique(rdd_sample_pairs$border_pair)
    border_pairs <- border_pairs[border_pairs != "Other" & border_pairs != "BS-urban"]

    border_pair_results <- map_dfr(border_pairs, function(bp) {
      sample_bp <- rdd_sample_pairs %>%
        filter(border_pair == bp)

      if (nrow(sample_bp) < 50) {
        return(tibble(
          border_pair = bp,
          estimate = NA_real_,
          se = NA_real_,
          ci_lower = NA_real_,
          ci_upper = NA_real_,
          n = nrow(sample_bp)
        ))
      }

      rd <- tryCatch({
        rdrobust(
          y = sample_bp$yes_share,
          x = sample_bp$distance_to_border,
          c = 0
        )
      }, error = function(e) NULL)

      if (is.null(rd)) {
        return(tibble(
          border_pair = bp,
          estimate = NA_real_,
          se = NA_real_,
          ci_lower = NA_real_,
          ci_upper = NA_real_,
          n = nrow(sample_bp)
        ))
      }

      tibble(
        border_pair = bp,
        estimate = rd$coef[1],
        se = rd$se[1],
        ci_lower = rd$ci[1,1],
        ci_upper = rd$ci[1,2],
        n = sum(rd$N)
      )
    })

    # Add pooled estimate for comparison
    pooled_row <- tibble(
      border_pair = "POOLED (all borders)",
      estimate = rdd1$coef[1],
      se = rdd1$se[1],
      ci_lower = rdd1$ci[1,1],
      ci_upper = rdd1$ci[1,2],
      n = sum(rdd1$N)
    )

    border_pair_results <- bind_rows(pooled_row, border_pair_results) %>%
      filter(!is.na(estimate))

    if (nrow(border_pair_results) > 1) {
      write_csv(border_pair_results, file.path(tab_dir, "border_pair_estimates.csv"))

      # Save border pair data for figure generation
      border_pair_data <- rdd_sample_pairs %>%
        st_drop_geometry() %>%
        select(mun_id, canton_abbr, yes_share, treated, distance_to_border,
               border_pair) %>%
        mutate(running_var = ifelse(treated, distance_to_border, -distance_to_border))
      saveRDS(border_pair_data, file.path(data_dir, "border_pair_data.rds"))
      cat("Saved border_pair_data.rds for figure generation\n")

      # Create forest plot
      p_forest <- ggplot(border_pair_results,
                         aes(x = estimate, y = fct_rev(border_pair))) +
        geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
        geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2,
                       color = ifelse(border_pair_results$border_pair == "POOLED (all borders)",
                                      "#D73027", "#2166AC")) +
        geom_point(size = 3,
                   color = ifelse(border_pair_results$border_pair == "POOLED (all borders)",
                                  "#D73027", "#2166AC")) +
        labs(
          title = "Border-Pair Specific RDD Estimates",
          subtitle = "Forest plot of treatment effects by canton border segment",
          x = "Treatment Effect (pp)",
          y = "",
          caption = "Pooled estimate in red; border-specific estimates in blue"
        ) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_border_pairs_forest.pdf"), p_forest, width = 10, height = 6)
      cat("Saved fig_border_pairs_forest.pdf\n")
      cat(paste("Border pairs analyzed:", nrow(border_pair_results) - 1, "\n"))
    }
  }
} else {
  cat("Skipping RDD analysis (no spatial data or insufficient sample)\n")
}

# =============================================================================
# SECTION 10: RANDOMIZATION INFERENCE
# =============================================================================
cat("\n=== RANDOMIZATION INFERENCE ===\n")

set.seed(42)
n_permutations <- 1000

# Original estimate
original_model <- feols(yes_share ~ treated | language, data = gemeinde_data, cluster = ~canton)
original_estimate <- coef(original_model)[1]

cat(paste("Original estimate:", round(original_estimate, 3), "\n"))
cat(paste("Running", n_permutations, "permutations...\n"))

# Get unique cantons and their treatment status
canton_list <- gemeinde_data %>%
  select(canton, treated) %>%
  distinct() %>%
  arrange(canton)

n_treated <- sum(canton_list$treated)
all_cantons <- canton_list$canton

# Permutation distribution
perm_estimates <- replicate(n_permutations, {
  # Randomly assign treatment to n_treated cantons
  treated_cantons_perm <- sample(all_cantons, n_treated)

  gemeinde_data_perm <- gemeinde_data %>%
    mutate(treated_perm = as.numeric(canton %in% treated_cantons_perm))

  model_perm <- tryCatch({
    feols(yes_share ~ treated_perm | language, data = gemeinde_data_perm, cluster = ~canton)
  }, error = function(e) NULL)

  if (is.null(model_perm)) return(NA_real_)
  coef(model_perm)[1]
})

perm_estimates <- perm_estimates[!is.na(perm_estimates)]

# Calculate p-value (two-tailed)
ri_pvalue <- mean(abs(perm_estimates) >= abs(original_estimate))

cat(paste("Randomization inference p-value:", round(ri_pvalue, 3), "\n"))
cat(paste("Permutation mean:", round(mean(perm_estimates), 3), "\n"))
cat(paste("Permutation SD:", round(sd(perm_estimates), 3), "\n"))

# Save RI results
ri_results <- tibble(
  original_estimate = original_estimate,
  ri_pvalue = ri_pvalue,
  n_permutations = length(perm_estimates),
  perm_mean = mean(perm_estimates),
  perm_sd = sd(perm_estimates),
  perm_ci_lower = quantile(perm_estimates, 0.025),
  perm_ci_upper = quantile(perm_estimates, 0.975)
)
write_csv(ri_results, file.path(tab_dir, "randomization_inference.csv"))

# Create RI distribution plot
p_ri <- ggplot(tibble(estimate = perm_estimates), aes(x = estimate)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = original_estimate, color = "#D73027", linewidth = 1.5) +
  geom_vline(xintercept = -original_estimate, color = "#D73027", linewidth = 1.5, linetype = "dashed") +
  annotate("text", x = original_estimate + 0.5, y = Inf,
           label = paste("Observed =", round(original_estimate, 2)),
           vjust = 2, hjust = 0, color = "#D73027", fontface = "bold") +
  labs(
    title = "Randomization Inference",
    subtitle = paste0("Distribution under ", n_permutations, " random canton assignments; two-tailed p = ", round(ri_pvalue, 3)),
    x = "Permuted Treatment Effect (pp)",
    y = "Count"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_randomization_inference.pdf"), p_ri, width = 10, height = 6)
cat("Saved fig_randomization_inference.pdf\n")

# =============================================================================
# SECTION 11: PANEL ANALYSIS WITH MULTIPLE REFERENDUMS
# =============================================================================
cat("\n=== PANEL ANALYSIS ===\n")

# =============================================================================
# CRITICAL FIX: Fetch REAL historical referendum data instead of simulating
# The original code used rnorm() to fabricate pre-treatment voting data,
# which invalidates all pre-trend claims.
# =============================================================================

cat("Fetching REAL historical referendum data from swissdd...\n")

# Function to fetch and aggregate referendum data by canton
fetch_referendum_by_canton <- function(from_date, to_date, name_pattern) {
  tryCatch({
    votes <- get_nationalvotes(
      from_date = from_date,
      to_date = to_date,
      geolevel = "municipality"
    )

    if (nrow(votes) == 0) {
      cat(paste("  No votes found for", from_date, "to", to_date, "\n"))
      return(NULL)
    }

    # Filter by name pattern if provided
    if (!is.null(name_pattern)) {
      votes <- votes %>%
        filter(str_detect(tolower(name), name_pattern))
    }

    if (nrow(votes) == 0) {
      cat(paste("  No matching votes for pattern:", name_pattern, "\n"))
      return(NULL)
    }

    # Aggregate to canton level
    canton_votes <- votes %>%
      group_by(canton_id, canton_name) %>%
      summarize(
        yes_share = weighted.mean(jaStimmenInProzent, anzahlStimmberechtigte, na.rm = TRUE),
        n_gemeinden = n(),
        total_voters = sum(anzahlStimmberechtigte, na.rm = TRUE),
        .groups = "drop"
      )

    cat(paste("  Fetched", nrow(canton_votes), "canton results\n"))
    return(canton_votes)
  }, error = function(e) {
    cat(paste("  Error fetching:", e$message, "\n"))
    return(NULL)
  })
}

# Fetch historical energy-related referendums
cat("\n1. Fetching 2000 Solar Initiative (Förderung der Solarenergie)...\n")
votes_2000 <- fetch_referendum_by_canton("2000-09-01", "2000-09-30", "solar|energie")

cat("\n2. Fetching 2003 Electricity Without Nuclear...\n")
votes_2003 <- fetch_referendum_by_canton("2003-05-01", "2003-05-31", "strom|nuclear|moratorium")

cat("\n3. Fetching 2016 Atomausstieg Initiative...\n")
votes_2016 <- fetch_referendum_by_canton("2016-11-01", "2016-11-30", "ausstieg|atom")

# Create canton lookup for treatment status
canton_lookup <- tibble(
  canton_id = 1:26,
  canton = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
             "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
             "TI", "VD", "VS", "NE", "GE", "JU")
)

# Get 2017 data aggregated to canton level
canton_2017 <- gemeinde_data %>%
  group_by(canton, treated, language) %>%
  summarize(
    yes_2017 = weighted.mean(yes_share, voters, na.rm = TRUE),
    n_gemeinden = n(),
    total_voters = sum(voters, na.rm = TRUE),
    .groups = "drop"
  )

# Build panel from real data
if (!is.null(votes_2000) && !is.null(votes_2003) && !is.null(votes_2016)) {
  cat("\nBuilding panel from REAL referendum data...\n")

  # Add canton abbreviation to historical votes
  add_canton_abbr <- function(df) {
    df %>%
      mutate(canton_id = as.integer(canton_id)) %>%
      left_join(canton_lookup, by = "canton_id")
  }

  votes_2000 <- add_canton_abbr(votes_2000) %>% mutate(year = 2000)
  votes_2003 <- add_canton_abbr(votes_2003) %>% mutate(year = 2003)
  votes_2016 <- add_canton_abbr(votes_2016) %>% mutate(year = 2016)
  votes_2017_panel <- canton_2017 %>%
    select(canton, yes_share = yes_2017) %>%
    mutate(year = 2017)

  # Combine into panel
  canton_panel_long <- bind_rows(
    votes_2000 %>% select(canton, yes_share, year),
    votes_2003 %>% select(canton, yes_share, year),
    votes_2016 %>% select(canton, yes_share, year),
    votes_2017_panel
  ) %>%
    left_join(canton_2017 %>% select(canton, treated, language), by = "canton") %>%
    mutate(
      post = year >= 2010,
      treat_post = treated * post
    )

  cat(paste("Panel built with", nrow(canton_panel_long), "observations (", n_distinct(canton_panel_long$canton), "cantons x", n_distinct(canton_panel_long$year), "years)\n"))

} else {
  # Fallback: use 2016 and 2017 data only (we have 2017, try 2016)
  cat("\nWARNING: Could not fetch all historical data. Using 2016-2017 only.\n")

  if (!is.null(votes_2016)) {
    votes_2016_clean <- add_canton_abbr(votes_2016) %>%
      select(canton, yes_share, year = year)
    votes_2017_panel <- canton_2017 %>%
      select(canton, yes_share = yes_2017) %>%
      mutate(year = 2017)

    canton_panel_long <- bind_rows(votes_2016_clean, votes_2017_panel) %>%
      left_join(canton_2017 %>% select(canton, treated, language), by = "canton") %>%
      mutate(
        post = year >= 2017,  # Only 2017 is post
        treat_post = treated * post
      )
  } else {
    # Last resort: just use 2017 data, no panel analysis possible
    cat("WARNING: No historical data available. Panel analysis will be skipped.\n")
    canton_panel_long <- canton_2017 %>%
      select(canton, treated, language, yes_share = yes_2017) %>%
      mutate(year = 2017, post = TRUE, treat_post = treated)
  }
}

# NOTE: canton_panel_long is already created above from real data

# Event study summary
event_study <- canton_panel_long %>%
  group_by(year, treated) %>%
  summarize(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(treated == 1, "Treated Cantons", "Control Cantons"))

# Create event study plot
p_event <- ggplot(event_study, aes(x = year, y = mean_yes, color = group, shape = group)) +
  geom_vline(xintercept = 2011, linetype = "dashed", color = "gray50") +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se, ymax = mean_yes + 1.96*se), width = 0.3) +
  annotate("text", x = 2011, y = max(event_study$mean_yes) + 2,
           label = "First treatment (GR 2011)", hjust = -0.05, vjust = -0.5, size = 3) +
  scale_color_manual(values = c("Treated Cantons" = "#2166AC", "Control Cantons" = "#B2182B")) +
  labs(
    title = "Event Study: Energy Referendum Support Over Time",
    subtitle = "Canton-level yes-shares across four energy-related referendums",
    x = "Year",
    y = "Yes Share (%)",
    color = "", shape = ""
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_event_study.pdf"), p_event, width = 10, height = 6)
cat("Saved fig_event_study.pdf\n")

# DiD regression
did_model <- feols(
  yes_share ~ treat_post | canton + year,
  data = canton_panel_long,
  cluster = ~canton
)

cat("\nDiD Results:\n")
print(summary(did_model))

did_results <- tibble(
  term = "treat_post",
  estimate = coef(did_model)[1],
  se = sqrt(vcov(did_model)[1,1]),
  ci_lower = coef(did_model)[1] - 1.96 * sqrt(vcov(did_model)[1,1]),
  ci_upper = coef(did_model)[1] + 1.96 * sqrt(vcov(did_model)[1,1]),
  n_obs = nobs(did_model)
)
write_csv(did_results, file.path(tab_dir, "did_results.csv"))

# Save panel data
write_csv(canton_panel_long, file.path(tab_dir, "panel_data_summary.csv"))

# =============================================================================
# SECTION 11b: CALLAWAY-SANT'ANNA HETEROGENEITY-ROBUST DiD
# =============================================================================
cat("\n=== CALLAWAY-SANT'ANNA DiD ===\n")

# Check if did package is available
has_did <- requireNamespace("did", quietly = TRUE)

if (has_did) {
  library(did)

  # Prepare data for Callaway-Sant'Anna
  # Need: unit id, time period, treatment timing (g), outcome
  canton_cs <- canton_panel_long %>%
    mutate(
      canton_id = as.numeric(factor(canton)),
      # Treatment timing: year when first treated (0 = never treated)
      first_treat = case_when(
        canton == "GR" ~ 2010,
        canton == "BE" ~ 2011,
        canton == "AG" ~ 2012,
        canton == "BL" ~ 2016,
        canton == "BS" ~ 2017,
        TRUE ~ 0  # Never treated
      )
    )

  # Run Callaway-Sant'Anna estimator
  cs_result <- tryCatch({
    att_gt(
      yname = "yes_share",
      tname = "year",
      idname = "canton_id",
      gname = "first_treat",
      data = canton_cs,
      control_group = "nevertreated",
      base_period = "universal"
    )
  }, error = function(e) {
    cat(paste("Callaway-Sant'Anna error:", e$message, "\n"))
    NULL
  })

  if (!is.null(cs_result)) {
    # Aggregate to overall ATT
    cs_agg <- aggte(cs_result, type = "simple")

    cat(paste("Callaway-Sant'Anna ATT:", round(cs_agg$overall.att, 2),
              "(SE =", round(cs_agg$overall.se, 2), ")\n"))

    # Save results
    cs_summary <- tibble(
      estimator = "Callaway-Sant'Anna",
      att = cs_agg$overall.att,
      se = cs_agg$overall.se,
      ci_lower = cs_agg$overall.att - 1.96 * cs_agg$overall.se,
      ci_upper = cs_agg$overall.att + 1.96 * cs_agg$overall.se
    )
    write_csv(cs_summary, file.path(tab_dir, "callaway_santanna.csv"))

    # Create event study plot from CS
    cs_event <- tryCatch({
      aggte(cs_result, type = "dynamic")
    }, error = function(e) NULL)

    if (!is.null(cs_event)) {
      cs_event_df <- tibble(
        event_time = cs_event$egt,
        att = cs_event$att.egt,
        se = cs_event$se.egt
      ) %>%
        mutate(
          ci_lower = att - 1.96 * se,
          ci_upper = att + 1.96 * se
        )

      p_cs_event <- ggplot(cs_event_df, aes(x = event_time, y = att)) +
        geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
        geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray30") +
        geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2166AC") +
        geom_line(color = "#2166AC", linewidth = 1) +
        geom_point(color = "#2166AC", size = 3) +
        labs(
          title = "Callaway-Sant'Anna Event Study",
          subtitle = "Heterogeneity-robust ATT by event time",
          x = "Years Since Treatment",
          y = "ATT (pp)",
          caption = "Shaded area shows 95% CI; vertical line indicates treatment"
        ) +
        theme_apep()

      ggsave(file.path(fig_dir, "fig_cs_event_study.pdf"), p_cs_event, width = 10, height = 6)
      cat("Saved fig_cs_event_study.pdf\n")
    }
  }
} else {
  cat("did package not available - skipping Callaway-Sant'Anna\n")

  # Create placeholder result based on TWFE
  cs_summary <- tibble(
    estimator = "TWFE (standard)",
    att = coef(did_model)[1],
    se = sqrt(vcov(did_model)[1,1]),
    ci_lower = coef(did_model)[1] - 1.96 * sqrt(vcov(did_model)[1,1]),
    ci_upper = coef(did_model)[1] + 1.96 * sqrt(vcov(did_model)[1,1])
  )
  write_csv(cs_summary, file.path(tab_dir, "callaway_santanna.csv"))
}

# =============================================================================
# SECTION 11c: POWER ANALYSIS
# =============================================================================
cat("\n=== POWER ANALYSIS ===\n")

# Calculate the minimum detectable effect (MDE)
# Using the standard error from the preferred specification (language FE)
preferred_se <- sqrt(vcov(model4)[1,1])

# MDE at 80% power, alpha = 0.05 (two-tailed)
# MDE = (z_alpha/2 + z_beta) * SE = (1.96 + 0.84) * SE = 2.8 * SE
mde_80 <- 2.8 * preferred_se

# MDE at 95% power
mde_95 <- (1.96 + 1.645) * preferred_se

cat(paste("Preferred specification SE:", round(preferred_se, 2), "pp\n"))
cat(paste("MDE at 80% power:", round(mde_80, 2), "pp\n"))
cat(paste("MDE at 95% power:", round(mde_95, 2), "pp\n"))

# What effect sizes can we rule out?
# 95% CI upper bound
ci_upper <- get_coef(model4) + 1.96 * preferred_se
ci_lower <- get_coef(model4) - 1.96 * preferred_se

cat(paste("95% CI:", round(ci_lower, 2), "to", round(ci_upper, 2), "pp\n"))
cat(paste("Can rule out effects larger than:", round(ci_upper, 2), "pp (positive)\n"))
cat(paste("Can rule out effects smaller than:", round(ci_lower, 2), "pp (negative)\n"))

# Save power analysis results
power_results <- tibble(
  preferred_se = preferred_se,
  mde_80_power = mde_80,
  mde_95_power = mde_95,
  ci_lower = ci_lower,
  ci_upper = ci_upper,
  point_estimate = get_coef(model4)
)
write_csv(power_results, file.path(tab_dir, "power_analysis.csv"))

# =============================================================================
# SECTION 11d: HETEROGENEITY BY URBANITY
# =============================================================================
cat("\n=== HETEROGENEITY BY URBANITY ===\n")

# Create urban indicator (population > 5000)
gemeinde_data <- gemeinde_data %>%
  mutate(
    urban = ifelse(voters > 5000, 1, 0),
    urban_label = ifelse(urban == 1, "Urban", "Rural")
  )

# Interaction model
model_urban <- feols(
  yes_share ~ treated * urban + i(language),
  data = gemeinde_data,
  cluster = ~canton
)

cat("\nUrbanity Heterogeneity Results:\n")
print(summary(model_urban))

# Extract coefficients
urban_results <- tibble(
  term = c("Treated (Rural)", "Treated x Urban", "Treated (Urban, total)"),
  estimate = c(
    coef(model_urban)["treated"],
    coef(model_urban)["treated:urban"],
    coef(model_urban)["treated"] + coef(model_urban)["treated:urban"]
  ),
  se = c(
    sqrt(vcov(model_urban)["treated", "treated"]),
    sqrt(vcov(model_urban)["treated:urban", "treated:urban"]),
    NA  # Need delta method for combined SE
  )
)

# Calculate SE for total urban effect using delta method
var_total <- vcov(model_urban)["treated", "treated"] +
             vcov(model_urban)["treated:urban", "treated:urban"] +
             2 * vcov(model_urban)["treated", "treated:urban"]
urban_results$se[3] <- sqrt(var_total)

urban_results <- urban_results %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

write_csv(urban_results, file.path(tab_dir, "urbanity_heterogeneity.csv"))

# Subgroup analysis
urban_subgroups <- gemeinde_data %>%
  group_by(urban_label, treated) %>%
  summarise(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(treated_label = ifelse(treated == 1, "Treated", "Control"))

# Plot heterogeneity
p_urban <- ggplot(urban_subgroups, aes(x = urban_label, y = mean_yes, fill = treated_label)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                position = position_dodge(0.8), width = 0.2) +
  geom_hline(yintercept = 58.2, linetype = "dashed", color = "gray30") +
  scale_fill_manual(
    values = c("Treated" = "#2166AC", "Control" = "#B2182B"),
    name = ""
  ) +
  labs(
    x = "",
    y = "Mean Yes Share (%)",
    title = "Treatment Effect Heterogeneity by Urbanity",
    subtitle = "Rural (<5,000 voters) vs Urban (>=5,000 voters)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_urbanity_heterogeneity.pdf"), p_urban, width = 8, height = 5)
cat("Saved fig_urbanity_heterogeneity.pdf\n")

# =============================================================================
# SECTION 12: DISTRIBUTION FIGURE
# =============================================================================
cat("\n=== CREATING DISTRIBUTION FIGURES ===\n")

# Distribution by treatment and language
p_dist_treatment <- ggplot(gemeinde_data, aes(x = yes_share, fill = factor(treated))) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 40, color = "white") +
  geom_vline(xintercept = 58.2, linetype = "dashed", color = "gray30") +
  annotate("text", x = 59, y = Inf, label = "National avg\n(58.2%)",
           hjust = 0, vjust = 1.5, size = 3, color = "gray30") +
  scale_fill_manual(
    values = c("1" = "#2166AC", "0" = "#B2182B"),
    labels = c("1" = "Treated", "0" = "Control"),
    name = ""
  ) +
  labs(
    x = "Yes Share (%)",
    y = "Number of Gemeinden",
    title = "Distribution of Vote Shares by Treatment Status",
    subtitle = "Energy Strategy 2050 referendum, May 2017"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_distribution_treatment.pdf"), p_dist_treatment, width = 8, height = 5)

# Distribution by language
p_dist_language <- ggplot(gemeinde_data, aes(x = yes_share, fill = language)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 40, color = "white") +
  geom_vline(xintercept = 58.2, linetype = "dashed", color = "gray30") +
  scale_fill_manual(
    values = c("German" = "#E6AB02", "French" = "#7570B3", "Italian" = "#1B9E77"),
    name = "Language Region"
  ) +
  labs(
    x = "Yes Share (%)",
    y = "Number of Gemeinden",
    title = "Distribution of Vote Shares by Language Region",
    subtitle = "The Röstigraben: French cantons voted more in favor"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_distribution_language.pdf"), p_dist_language, width = 8, height = 5)

# Language comparison bar chart
lang_summary <- gemeinde_data %>%
  group_by(language, treated) %>%
  summarize(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(treated_label = ifelse(treated == 1, "Treated", "Control"))

p_lang_comparison <- ggplot(lang_summary, aes(x = language, y = mean_yes, fill = treated_label)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                position = position_dodge(0.8), width = 0.2) +
  geom_hline(yintercept = 58.2, linetype = "dashed", color = "gray30") +
  annotate("text", x = 0.5, y = 59, label = "National avg", hjust = 0, size = 3, color = "gray30") +
  scale_fill_manual(
    values = c("Treated" = "#2166AC", "Control" = "#B2182B"),
    name = ""
  ) +
  labs(
    x = "Language Region",
    y = "Mean Yes Share (%)",
    title = "Vote Shares by Language Region and Treatment Status",
    subtitle = "Error bars show 95% confidence intervals"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_language_comparison.pdf"), p_lang_comparison, width = 8, height = 5)
cat("Saved distribution and language comparison figures\n")

# =============================================================================
# SECTION 13: OLS COEFFICIENT PLOT
# =============================================================================
cat("\n=== CREATING OLS COEFFICIENT PLOT ===\n")

p_ols_coef <- ggplot(ols_results, aes(x = estimate, y = fct_rev(specification))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "#2166AC") +
  geom_point(size = 3, color = "#2166AC") +
  labs(
    title = "OLS Estimates: Effect of Cantonal Energy Law on Referendum Support",
    subtitle = "95% confidence intervals (clustered at canton level)",
    x = "Treatment Effect (percentage points)",
    y = ""
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_ols_coefficients.pdf"), p_ols_coef, width = 10, height = 5)
cat("Saved fig_ols_coefficients.pdf\n")

# =============================================================================
# SUMMARY OUTPUT
# =============================================================================
cat("\n" , rep("=", 60), "\n")
cat("ANALYSIS COMPLETE\n")
cat(rep("=", 60), "\n")

cat("\nFigures saved to ../figures/:\n")
cat("  - fig_ols_coefficients.pdf\n")
cat("  - fig_distribution_treatment.pdf\n")
cat("  - fig_distribution_language.pdf\n")
cat("  - fig_language_comparison.pdf\n")
cat("  - fig_randomization_inference.pdf\n")
cat("  - fig_event_study.pdf\n")
if (!is.null(rdd_sample)) {
  cat("  - fig_rdd_main.pdf\n")
  cat("  - fig_rdd_specifications.pdf\n")
  cat("  - fig_bandwidth_sensitivity.pdf\n")
  cat("  - fig_donut_rdd.pdf\n")
  cat("  - fig_covariate_balance.pdf\n")
  if (has_rddensity) cat("  - fig_density_test.pdf\n")
}

cat("\nTables saved to ../tables/:\n")
cat("  - table_ols_results.csv\n")
cat("  - randomization_inference.csv\n")
cat("  - did_results.csv\n")
cat("  - panel_data_summary.csv\n")
if (!is.null(rdd_sample)) {
  cat("  - rdd_specifications.csv\n")
  cat("  - bandwidth_sensitivity.csv\n")
  cat("  - donut_rdd.csv\n")
  cat("  - covariate_balance.csv\n")
  if (has_rddensity) cat("  - mccrary_density.csv\n")
}

cat("\nKey Results:\n")
cat(paste("  OLS (raw):", round(ols_results$estimate[1], 2), "pp (SE =", round(ols_results$se[1], 2), ")\n"))
cat(paste("  OLS (+ language):", round(ols_results$estimate[2], 2), "pp (SE =", round(ols_results$se[2], 2), ")\n"))
cat(paste("  Randomization inference p-value:", round(ri_pvalue, 3), "\n"))
if (!is.null(rdd_sample) && exists("rdd1") && !is.null(rdd1)) {
  cat(paste("  Spatial RDD:", round(rdd1$coef[1], 2), "pp (SE =", round(rdd1$se[1], 2), ")\n"))
}
