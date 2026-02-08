# =============================================================================
# 03_main_analysis.R - Spatial RDD Analysis at Canton Borders
# Swiss Cantonal Energy Laws and Federal Referendum Voting
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

library(SpatialRDD)

# Load data (using data_dir from 00_packages.R)
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

# Try to load spatial data
has_spatial <- file.exists(file.path(data_dir, "voting_sf.rds"))
if (has_spatial) {
  voting_sf <- readRDS(file.path(data_dir, "voting_sf.rds"))
  gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_boundaries.rds"))
  message("Spatial data loaded successfully")
} else {
  message("WARNING: No spatial data available, using non-spatial methods")
}

# Output directories (using paths from 00_packages.R)
tables_dir <- tab_dir
figures_dir <- fig_dir
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# =============================================================================
# SECTION 1: Descriptive Statistics (Gemeinde Level)
# =============================================================================

message("\n=== SECTION 1: DESCRIPTIVE STATISTICS ===")

# Summary by treatment status
summary_stats <- voting_data %>%
  group_by(treated) %>%
  summarise(
    n_gemeinden = n(),
    mean_yes = mean(yes_share, na.rm = TRUE),
    sd_yes = sd(yes_share, na.rm = TRUE),
    min_yes = min(yes_share, na.rm = TRUE),
    max_yes = max(yes_share, na.rm = TRUE),
    mean_turnout = mean(turnout, na.rm = TRUE),
    mean_eligible = mean(eligible_voters, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(status = ifelse(treated, "Treated", "Control"))

print(summary_stats)

# Save Table 1: Summary statistics
table1 <- summary_stats %>%
  select(status, n_gemeinden, mean_yes, sd_yes, min_yes, max_yes, mean_turnout) %>%
  rename(
    Status = status,
    N = n_gemeinden,
    `Mean Yes %` = mean_yes,
    `SD` = sd_yes,
    `Min` = min_yes,
    `Max` = max_yes,
    `Turnout %` = mean_turnout
  )

write_csv(table1, file.path(tables_dir, "table1_summary.csv"))

message(paste("\nRaw difference (gemeinde-level):",
              round(summary_stats$mean_yes[summary_stats$treated] -
                      summary_stats$mean_yes[!summary_stats$treated], 2), "pp"))

# Summary by canton
canton_summary <- voting_data %>%
  group_by(canton_abbr, treated, lang) %>%
  summarise(
    n_gemeinden = n(),
    mean_yes = mean(yes_share, na.rm = TRUE),
    mean_turnout = mean(turnout, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_yes))

write_csv(canton_summary, file.path(tables_dir, "table2_canton_summary.csv"))

# =============================================================================
# SECTION 2: OLS with Canton-Level Clustering
# =============================================================================

message("\n=== SECTION 2: OLS REGRESSIONS ===")

# Model 1: Raw comparison
model1 <- feols(yes_share ~ treated, data = voting_data, cluster = ~canton_id)

# Model 2: Add language controls
model2 <- feols(yes_share ~ treated + i(lang), data = voting_data, cluster = ~canton_id)

# Model 3: Add turnout control
model3 <- feols(yes_share ~ treated + i(lang) + turnout, data = voting_data, cluster = ~canton_id)

# Model 4: Canton fixed effects within language groups
# (Cannot include canton FE with canton-level treatment, so use language FE)
model4 <- feols(yes_share ~ treated | lang, data = voting_data, cluster = ~canton_id)

# Display results
message("\nModel 1: Raw comparison")
print(summary(model1))

message("\nModel 2: With language controls")
print(summary(model2))

message("\nModel 3: With language + turnout")
print(summary(model3))

# Create regression table
models <- list(
  "Raw" = model1,
  "+ Language" = model2,
  "+ Turnout" = model3,
  "Language FE" = model4
)

# Extract coefficients for treated
reg_table <- tibble(
  Specification = names(models),
  Estimate = sapply(models, function(m) coef(m)["treatedTRUE"]),
  SE = sapply(models, function(m) sqrt(vcov(m)["treatedTRUE", "treatedTRUE"])),
  N = sapply(models, function(m) nobs(m))
) %>%
  mutate(
    `t-stat` = Estimate / SE,
    `p-value` = 2 * pt(abs(`t-stat`), df = N - 2, lower.tail = FALSE)
  )

write_csv(reg_table, file.path(tables_dir, "table3_regression.csv"))

message("\nRegression results:")
print(reg_table)

# =============================================================================
# SECTION 3: Spatial RDD (if spatial data available)
# =============================================================================

if (has_spatial && nrow(voting_sf) > 0) {
  message("\n=== SECTION 3: SPATIAL RDD ===")

  # Check if we have necessary columns
  if ("geometry" %in% names(voting_sf) && !all(is.na(voting_sf$treated))) {

    # Compute centroids
    voting_sf <- voting_sf %>%
      mutate(centroid = st_centroid(geometry))

    # Extract canton boundaries for treated cantons
    treated_cantons <- c(2, 12, 13, 18, 19)  # BE, BS, BL, GR, AG

    # Get treated gemeinden centroids
    treated_points <- voting_sf %>%
      filter(treated == TRUE) %>%
      st_set_geometry("centroid")

    # Get control gemeinden centroids
    control_points <- voting_sf %>%
      filter(treated == FALSE) %>%
      st_set_geometry("centroid")

    # Attempt to use SpatialRDD functions
    # First, we need to create the border cutoff

    # Extract canton borders
    canton_borders <- voting_sf %>%
      group_by(canton_id) %>%
      summarise(.groups = "drop")  # Let sf handle geometry union automatically

    # CRITICAL FIX: Use get_policy_border() to compute ONLY internal canton borders
    # The original code used st_boundary() intersection which includes national
    # borders with France, Italy, Germany - invalidating the spatial RDD.
    message("Computing CORRECT policy border (internal canton boundaries only)...")
    border <- get_policy_border(canton_borders, treated_cantons, canton_id_col = "canton_id")

    if (length(border) > 0 && !st_is_empty(border)) {
      message("Canton border between treated and control areas identified")

      # Compute distance to border for each gemeinde
      voting_sf <- voting_sf %>%
        mutate(
          dist_to_border = as.numeric(st_distance(centroid, border)),
          # Sign the distance: negative for control, positive for treated
          running_var = ifelse(treated, dist_to_border, -dist_to_border)
        )

      message(paste("Running variable computed for", sum(!is.na(voting_sf$running_var)), "gemeinden"))

      # Restrict to gemeinden near the border (within 20km)
      bandwidth_km <- 20000  # 20 km
      border_sample <- voting_sf %>%
        filter(abs(running_var) <= bandwidth_km)

      message(paste("Border sample (within 20km):", nrow(border_sample), "gemeinden"))

      if (nrow(border_sample) >= 50) {
        # Run RD estimation
        message("\nRunning spatial RD estimation...")

        rd_data <- border_sample %>%
          st_drop_geometry() %>%
          filter(!is.na(yes_share) & !is.na(running_var))

        rd_result <- rdrobust(
          y = rd_data$yes_share,
          x = rd_data$running_var,
          c = 0,
          kernel = "triangular",
          bwselect = "mserd"
        )

        message("\nSpatial RD Results:")
        print(summary(rd_result))

        # Save RD results
        rd_table <- tibble(
          Method = "Spatial RDD",
          Estimate = rd_result$coef[1],
          SE = rd_result$se[1],
          `Bandwidth (km)` = rd_result$bws[1] / 1000,
          N_left = rd_result$N_h[1],
          N_right = rd_result$N_h[2],
          p_value = rd_result$pv[1]
        )

        write_csv(rd_table, file.path(tables_dir, "table4_spatial_rdd.csv"))

        # Also try SpatialRDD package's spatialrd function
        tryCatch({
          # Need to convert to proper format for SpatialRDD
          rd_sf <- border_sample %>%
            st_set_geometry("centroid") %>%
            mutate(
              treatment = as.numeric(treated),
              outcome = yes_share
            )

          # The spatialrd function expects specific inputs
          # Let's use it if the border is a proper linestring
          if (st_geometry_type(border) %in% c("LINESTRING", "MULTILINESTRING")) {
            message("\nUsing SpatialRDD package for estimation...")

            # Discretize border into points
            border_points <- discretise_border(border, n = 50)

            # Run spatial RD
            spatial_rd <- spatialrd(
              y = "outcome",
              data = rd_sf,
              cutoff = border,
              treated = "treatment",
              minobs = 10
            )

            message("\nSpatialRDD package results:")
            print(spatial_rd)
          }
        }, error = function(e) {
          message(paste("SpatialRDD package error:", e$message))
        })

      } else {
        message("Insufficient observations near border for spatial RDD")
      }
    } else {
      message("Could not identify canton border geometry")
    }
  }
} else {
  message("\n=== SECTION 3: SPATIAL RDD SKIPPED (no spatial data) ===")

  # Alternative: Use nearest neighbor matching by canton border
  message("Using canton-border proximity as running variable...")

  # Identify border cantons
  border_cantons <- c(
    # German control cantons adjacent to treated
    "ZH", "LU", "SO", "SG", "GL", "UR",
    # Treated cantons
    "AG", "BE", "GR", "BL", "BS"
  )

  border_sample <- voting_data %>%
    filter(canton_abbr %in% border_cantons)

  message(paste("Border canton sample:", nrow(border_sample), "gemeinden"))

  # Simple comparison
  border_summary <- border_sample %>%
    group_by(treated) %>%
    summarise(
      n = n(),
      mean_yes = mean(yes_share, na.rm = TRUE),
      .groups = "drop"
    )

  print(border_summary)

  rd_table <- tibble(
    Method = "Border Cantons Comparison",
    Estimate = border_summary$mean_yes[border_summary$treated] -
               border_summary$mean_yes[!border_summary$treated],
    SE = NA,
    N_treated = border_summary$n[border_summary$treated],
    N_control = border_summary$n[!border_summary$treated]
  )

  write_csv(rd_table, file.path(tables_dir, "table4_border_comparison.csv"))
}

# =============================================================================
# SECTION 4: Robustness Checks
# =============================================================================

message("\n=== SECTION 4: ROBUSTNESS CHECKS ===")

robustness_results <- list()

# 1. German-speaking cantons only
german_only <- voting_data %>% filter(lang == "German")
rob1 <- feols(yes_share ~ treated, data = german_only, cluster = ~canton_id)
robustness_results[["German-speaking only"]] <- c(
  coef(rob1)["treatedTRUE"],
  sqrt(vcov(rob1)["treatedTRUE", "treatedTRUE"]),
  nobs(rob1)
)

# 2. Exclude Basel (urban outlier)
no_basel <- voting_data %>% filter(!canton_abbr %in% c("BS", "BL"))
rob2 <- feols(yes_share ~ treated + i(lang), data = no_basel, cluster = ~canton_id)
robustness_results[["Exclude Basel"]] <- c(
  coef(rob2)["treatedTRUE"],
  sqrt(vcov(rob2)["treatedTRUE", "treatedTRUE"]),
  nobs(rob2)
)

# 3. Weight by eligible voters
rob3 <- feols(yes_share ~ treated + i(lang), data = voting_data,
              weights = ~eligible_voters, cluster = ~canton_id)
robustness_results[["Population weighted"]] <- c(
  coef(rob3)["treatedTRUE"],
  sqrt(vcov(rob3)["treatedTRUE", "treatedTRUE"]),
  nobs(rob3)
)

# 4. Rural gemeinden only (< 5000 eligible voters)
rural <- voting_data %>% filter(eligible_voters < 5000)
rob4 <- feols(yes_share ~ treated + i(lang), data = rural, cluster = ~canton_id)
robustness_results[["Rural gemeinden only"]] <- c(
  coef(rob4)["treatedTRUE"],
  sqrt(vcov(rob4)["treatedTRUE", "treatedTRUE"]),
  nobs(rob4)
)

# 5. Urban gemeinden only (>= 5000 eligible voters)
urban <- voting_data %>% filter(eligible_voters >= 5000)
rob5 <- feols(yes_share ~ treated + i(lang), data = urban, cluster = ~canton_id)
robustness_results[["Urban gemeinden only"]] <- c(
  coef(rob5)["treatedTRUE"],
  sqrt(vcov(rob5)["treatedTRUE", "treatedTRUE"]),
  nobs(rob5)
)

# Create robustness table
robustness_table <- tibble(
  Specification = names(robustness_results),
  Estimate = sapply(robustness_results, `[`, 1),
  SE = sapply(robustness_results, `[`, 2),
  N = sapply(robustness_results, `[`, 3)
) %>%
  mutate(
    `t-stat` = Estimate / SE,
    `Significant` = ifelse(abs(`t-stat`) > 1.96, "Yes", "No")
  )

write_csv(robustness_table, file.path(tables_dir, "table5_robustness.csv"))

message("\nRobustness results:")
print(robustness_table)

# =============================================================================
# SECTION 5: Full Canton Results (Appendix)
# =============================================================================

message("\n=== SECTION 5: CANTON RESULTS ===")

canton_results <- voting_data %>%
  group_by(canton_abbr, treated, lang) %>%
  summarise(
    n_gemeinden = n(),
    mean_yes = round(mean(yes_share, na.rm = TRUE), 1),
    sd_yes = round(sd(yes_share, na.rm = TRUE), 1),
    mean_turnout = round(mean(turnout, na.rm = TRUE), 1),
    total_voters = sum(eligible_voters, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_yes))

write_csv(canton_results, file.path(tables_dir, "table6_full_canton_results.csv"))

message("\nCanton-level results:")
print(canton_results)

# =============================================================================
# Save session info
# =============================================================================

message("\n=== ANALYSIS COMPLETE ===")
message(paste("Tables saved to:", tables_dir))

# Save key results for paper
key_results <- list(
  n_gemeinden = nrow(voting_data),
  n_treated = sum(voting_data$treated),
  n_control = sum(!voting_data$treated),
  raw_diff = summary_stats$mean_yes[summary_stats$treated] -
             summary_stats$mean_yes[!summary_stats$treated],
  ols_estimate = coef(model2)["treatedTRUE"],
  ols_se = sqrt(vcov(model2)["treatedTRUE", "treatedTRUE"])
)

saveRDS(key_results, file.path(data_dir, "key_results.rds"))

message(paste("\nKey finding: Treated gemeinden voted",
              round(key_results$raw_diff, 2),
              "pp higher for Energy Strategy 2050"))
message(paste("OLS estimate (language controls):",
              round(key_results$ols_estimate, 2), "±",
              round(1.96 * key_results$ols_se, 2), "pp"))
