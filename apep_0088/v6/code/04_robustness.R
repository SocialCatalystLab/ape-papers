# =============================================================================
# 04_robustness.R - Robustness Checks and Placebo Tests
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

# Load data with error handling
analysis_df <- tryCatch({
  readRDS(file.path(data_dir, "analysis_data.rds"))
}, error = function(e) {
  stop("analysis_data.rds not found. Run 02_clean_data.R first.")
})

rd_results <- tryCatch({
  readRDS(file.path(data_dir, "rd_results.rds"))
}, error = function(e) {
  message("rd_results.rds not found. Creating empty structure.")
  list()
})

placebo_votes <- tryCatch({
  readRDS(file.path(data_dir, "placebo_votes_raw.rds"))
}, error = function(e) {
  message("placebo_votes_raw.rds not found. Placebo tests will be limited.")
  tibble()
})

canton_treatment <- tryCatch({
  # Try verified treatment first
  if (file.exists(file.path(data_dir, "canton_treatment_verified.rds"))) {
    readRDS(file.path(data_dir, "canton_treatment_verified.rds"))
  } else {
    readRDS(file.path(data_dir, "canton_treatment.rds"))
  }
}, error = function(e) {
  stop("canton_treatment.rds not found. Run 01_fetch_data.R first.")
})

near_border_df <- analysis_df %>% filter(near_border)

# -----------------------------------------------------------------------------
# 1. Placebo Tests: Pre-Treatment Environmental Referenda
# -----------------------------------------------------------------------------

message("Running placebo tests on pre-treatment referenda...")

# Identify energy/environment related votes before treatment
# Treatment starts in 2010 (GR)

placebo_energy <- placebo_votes %>%
  filter(
    votedate < "2010-01-01",  # Pre-treatment
    str_detect(tolower(name), "energie|energy|umwelt|environment|atom|nuclear|klima|co2")
  )

message(paste("Pre-treatment energy votes found:", length(unique(placebo_energy$id))))

# Run RDD on each placebo outcome
placebo_results <- list()

if (nrow(placebo_energy) > 0) {
  # For each unique vote
  unique_votes <- unique(placebo_energy[, c("id", "name", "votedate")])

  for (i in 1:min(nrow(unique_votes), 5)) {  # Limit to 5 placebos
    vote_id <- unique_votes$id[i]
    vote_name <- unique_votes$name[i]
    vote_date <- unique_votes$votedate[i]

    message(paste("  Placebo:", vote_name, "(", vote_date, ")"))

    # Get this vote's data
    vote_data <- placebo_energy %>%
      filter(id == vote_id) %>%
      transmute(
        mun_id = mun_id,
        canton_abbr = canton_abbr,
        yes_share = jaStimmenInProzent
      ) %>%
      left_join(canton_treatment, by = "canton_abbr")

    # Merge with distance data
    vote_analysis <- vote_data %>%
      left_join(
        analysis_df %>% select(mun_id, signed_distance_km),
        by = "mun_id"
      ) %>%
      filter(!is.na(signed_distance_km)) %>%
      filter(abs(signed_distance_km) < 30)

    if (nrow(vote_analysis) > 50) {
      rd_placebo <- tryCatch({
        rdrobust(
          y = vote_analysis$yes_share,
          x = vote_analysis$signed_distance_km,
          c = 0
        )
      }, error = function(e) NULL)

      if (!is.null(rd_placebo)) {
        placebo_results[[vote_name]] <- list(
          date = vote_date,
          estimate = rd_placebo$coef[1],
          se = rd_placebo$se[1],
          pval = rd_placebo$pv[1],
          n = nrow(vote_analysis)
        )

        message(paste("    RD estimate:", round(rd_placebo$coef[1], 3),
                      ", p =", round(rd_placebo$pv[1], 4)))
      }
    }
  }
}

rd_results$placebo <- placebo_results

# -----------------------------------------------------------------------------
# 2. Alternative Outcomes: Turnout
# -----------------------------------------------------------------------------

message("\nAnalyzing turnout effects...")

# RDD on turnout instead of yes share
rd_turnout_full <- rdrobust(
  y = near_border_df$turnout,
  x = near_border_df$signed_distance_km,
  c = 0
)

message(paste("Turnout RDD: estimate =", round(rd_turnout_full$coef[1], 3),
              ", SE =", round(rd_turnout_full$se[1], 3)))

rd_results$turnout_full <- rd_turnout_full

# -----------------------------------------------------------------------------
# 3. Heterogeneity by Language Region
# -----------------------------------------------------------------------------

message("\nHeterogeneity by language region...")

# Switzerland has German, French, Italian, and Romansh regions
# Most treated cantons are German-speaking (AG, BL, BS, BE partly)
# GR has Romansh speakers

# This would require language region data
# For now, we proxy using canton

german_cantons <- c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG",
                    "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG")
french_cantons <- c("VD", "NE", "GE", "JU")
# FR, VS are bilingual

near_border_df <- near_border_df %>%
  mutate(
    language_region = case_when(
      canton_abbr %in% german_cantons ~ "German",
      canton_abbr %in% french_cantons ~ "French",
      canton_abbr == "TI" ~ "Italian",
      TRUE ~ "Mixed"
    )
  )

# RDD for German-speaking regions only
german_df <- near_border_df %>% filter(language_region == "German")

if (nrow(german_df) > 50) {
  rd_german <- rdrobust(
    y = german_df$yes_share,
    x = german_df$signed_distance_km,
    c = 0
  )

  message(paste("German region RDD: estimate =", round(rd_german$coef[1], 3),
                ", SE =", round(rd_german$se[1], 3)))

  rd_results$german_only <- rd_german
}

# -----------------------------------------------------------------------------
# 4. Heterogeneity by Adoption Year (Dosage)
# -----------------------------------------------------------------------------

message("\nHeterogeneity by treatment dosage (years of exposure)...")

# Create dosage variable (years between canton adoption and May 2017 vote)
vote_date <- as.Date("2017-05-21")

near_border_df <- near_border_df %>%
  left_join(canton_treatment %>% select(canton_abbr, adoption_year), by = "canton_abbr") %>%
  mutate(
    years_exposure = case_when(
      treated & !is.na(adoption_year) ~ as.numeric(year(vote_date)) - adoption_year,
      TRUE ~ 0
    ),
    high_dosage = years_exposure >= 5  # 5+ years of exposure
  )

# Interaction: does effect increase with dosage?
# This requires more flexible RDD estimation

# Split by early vs late adopters
early_treated <- near_border_df %>%
  filter(treated, years_exposure >= 5)  # GR, BE, AG

late_treated <- near_border_df %>%
  filter(treated, years_exposure < 5)  # BL, BS (adopted 2016)

message(paste("Early adopters (5+ years):", nrow(early_treated)))
message(paste("Late adopters (<5 years):", nrow(late_treated)))

# -----------------------------------------------------------------------------
# 5. Placebo Cutoffs
# -----------------------------------------------------------------------------

message("\nPlacebo cutoff tests...")

# Run RDD at fake cutoffs where no discontinuity should exist
placebo_cutoffs <- c(-15, -10, -5, 5, 10, 15)  # km from true border

cutoff_results <- map_dfr(placebo_cutoffs, function(pc) {
  rd <- tryCatch({
    rdrobust(
      y = near_border_df$yes_share,
      x = near_border_df$signed_distance_km,
      c = pc
    )
  }, error = function(e) NULL)

  if (!is.null(rd)) {
    tibble(
      cutoff = pc,
      estimate = rd$coef[1],
      se = rd$se[1],
      pval = rd$pv[1]
    )
  } else {
    tibble(cutoff = pc, estimate = NA, se = NA, pval = NA)
  }
})

print(cutoff_results)

rd_results$placebo_cutoffs <- cutoff_results

# -----------------------------------------------------------------------------
# 6. Border-Pair Fixed Effects
# -----------------------------------------------------------------------------

message("\nBorder-pair analysis...")

# Identify which border segment each municipality is closest to
# This requires computing distance to each border pair separately

# For simplicity, we'll use the canton of treated/control pairs
# E.g., AG-ZH border, BE-FR border, etc.

# Create border pair indicator based on nearest canton pair
# This is a simplified version

near_border_df <- near_border_df %>%
  mutate(
    border_region = case_when(
      canton_abbr %in% c("AG", "ZH", "SO") ~ "AG_border",
      canton_abbr %in% c("BE", "FR", "NE", "JU") ~ "BE_border",
      canton_abbr %in% c("BL", "BS", "SO") ~ "BL_BS_border",
      canton_abbr %in% c("GR", "SG", "TI") ~ "GR_border",
      TRUE ~ "other"
    )
  )

# RDD with border-region fixed effects (using fixest)
fe_model <- feols(
  yes_share ~ signed_distance_km * treat | border_region,
  data = near_border_df,
  vcov = "hetero"
)

message("Border-region FE model:")
print(summary(fe_model))

rd_results$fe_model <- fe_model

# -----------------------------------------------------------------------------
# 7. Save Extended Results
# -----------------------------------------------------------------------------

# Save extended results
saveRDS(rd_results, file.path(data_dir, "rd_results_full.rds"))
message("Saved rd_results_full.rds")

message("\n=== ROBUSTNESS CHECKS COMPLETE ===")

# Summary of robustness with null checks
message("\nRobustness Summary:")

if (!is.null(rd_results$main)) {
  message(paste("1. Main RDD estimate:", round(rd_results$main$coef[1], 2), "pp"))
} else {
  message("1. Main RDD estimate: Not available (no spatial data)")
}

if (!is.null(rd_results$donut)) {
  message(paste("2. Donut RDD (exclude <2km):", round(rd_results$donut$coef[1], 2), "pp"))
} else {
  message("2. Donut RDD: Not available")
}

if (!is.null(rd_results$turnout_full)) {
  message(paste("3. Turnout effect:", round(rd_results$turnout_full$coef[1], 2), "pp"))
} else {
  message("3. Turnout effect: Not computed")
}

message(paste("4. Placebo tests run:", length(rd_results$placebo)))

if (!is.null(rd_results$density_test) && !is.null(rd_results$density_test$test)) {
  message(paste("5. McCrary density p-value:", round(rd_results$density_test$test$p_jk, 4)))
} else {
  message("5. McCrary density test: Not available")
}
