# =============================================================================
# 11_didisc_analysis.R - Difference-in-Discontinuities Analysis
#
# This script implements a Difference-in-Discontinuities (DiDisc) design
# following Grembi, Nannicini & Troiano (2016). The DiDisc approach differences
# out time-invariant border effects by using multiple referendums over time.
#
# Key innovation: Cross-sectional border RDD cannot rule out permanent canton
# differences at borders. DiDisc uses the panel structure of multiple
# referendums to control for these fixed border effects.
#
# Formula: yes_share ~ treated_post + border_pair_FE + referendum_FE
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

# Additional packages
has_wcb <- requireNamespace("fwildclusterboot", quietly = TRUE)
if (has_wcb) library(fwildclusterboot)

cat("\n", rep("=", 70), "\n")
cat("DIFFERENCE-IN-DISCONTINUITIES ANALYSIS\n")
cat(rep("=", 70), "\n\n")

# =============================================================================
# SECTION 1: LOAD AND PREPARE DATA
# =============================================================================

cat("=== LOADING DATA ===\n\n")

# Load main datasets
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- tryCatch({
  readRDS(file.path(data_dir, "canton_treatment_verified.rds"))
}, error = function(e) {
  readRDS(file.path(data_dir, "canton_treatment.rds"))
})

# Load border-pair data if available
border_pair_data <- tryCatch({
  readRDS(file.path(data_dir, "border_pair_data.rds"))
}, error = function(e) {
  message("border_pair_data.rds not found. Run 02_clean_data.R first.")
  NULL
})

# Load spatial data for distance computation
gemeinde_sf <- tryCatch({
  readRDS(file.path(data_dir, "gemeinde_spatial.rds"))
}, error = function(e) {
  message("gemeinde_spatial.rds not found.")
  NULL
})

cat(paste("Voting data:", nrow(voting_data), "observations\n"))

# =============================================================================
# SECTION 2: FETCH MULTIPLE REFERENDUMS FOR PANEL
# =============================================================================

cat("\n=== FETCHING REFERENDUM PANEL DATA ===\n\n")

# Function to fetch and clean referendum data
fetch_referendum <- function(from_date, to_date, name_pattern, vote_type) {
  tryCatch({
    votes <- get_nationalvotes(
      from_date = from_date,
      to_date = to_date,
      geolevel = "municipality"
    )

    if (nrow(votes) == 0) return(NULL)

    # Filter by pattern if provided
    if (!is.null(name_pattern)) {
      votes <- votes %>%
        filter(str_detect(tolower(name), name_pattern))
    }

    if (nrow(votes) == 0) return(NULL)

    # Take first matching vote if multiple
    first_vote_id <- votes$id[1]
    votes <- votes %>% filter(id == first_vote_id)

    # Clean and standardize
    votes %>%
      transmute(
        mun_id = as.integer(mun_id),
        mun_name = mun_name,
        canton_id = as.integer(canton_id),
        canton_name = canton_name,
        yes_share = jaStimmenInProzent,
        turnout = stimmbeteiligungInProzent,
        votedate = votedate,
        vote_type = vote_type
      )
  }, error = function(e) {
    message(paste("Error fetching", vote_type, ":", e$message))
    NULL
  })
}

# Define referendums for DiDisc panel
# Energy/environment referendums spanning the treatment period
referendums <- list(
  # Pre-treatment (before 2010)
  list(from = "2003-05-01", to = "2003-05-31", pattern = "strom|nuclear|moratorium",
       type = "nuclear_2003", period = "pre"),

  # Post-treatment but before main outcome (2010-2016)
  list(from = "2016-09-01", to = "2016-09-30", pattern = "grüne|green|economy",
       type = "green_2016", period = "post"),
  list(from = "2016-11-01", to = "2016-11-30", pattern = "ausstieg|atom",
       type = "nuclear_2016", period = "post"),

  # Main outcome
  list(from = "2017-05-01", to = "2017-05-31", pattern = "energie|energy",
       type = "energy_2017", period = "post")
)

# Fetch all referendums
cat("Fetching referendum data...\n")
panel_list <- list()

for (ref in referendums) {
  cat(paste("  ", ref$type, "... "))
  ref_data <- fetch_referendum(ref$from, ref$to, ref$pattern, ref$type)
  if (!is.null(ref_data) && nrow(ref_data) > 0) {
    ref_data$period <- ref$period
    panel_list[[ref$type]] <- ref_data
    cat(paste(nrow(ref_data), "observations\n"))
  } else {
    cat("no data\n")
  }
}

# Add 2017 energy vote from existing data
if (!"energy_2017" %in% names(panel_list)) {
  cat("  Using existing energy_2017 data... ")
  energy_2017 <- voting_data %>%
    filter(vote_type == "energy_2017") %>%
    mutate(period = "post")
  panel_list[["energy_2017"]] <- energy_2017
  cat(paste(nrow(energy_2017), "observations\n"))
}

# Combine into panel
panel_df <- bind_rows(panel_list)
cat(paste("\nTotal panel observations:", nrow(panel_df), "\n"))
cat(paste("Unique municipalities:", n_distinct(panel_df$mun_id), "\n"))
cat(paste("Referendums:", n_distinct(panel_df$vote_type), "\n"))

# =============================================================================
# SECTION 3: MERGE WITH TREATMENT AND BORDER DATA
# =============================================================================

cat("\n=== MERGING WITH TREATMENT AND BORDER DATA ===\n\n")

# Add canton abbreviation
canton_lookup <- tibble(
  canton_id = 1:26,
  canton_abbr = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
                  "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
                  "TI", "VD", "VS", "NE", "GE", "JU")
)

panel_df <- panel_df %>%
  left_join(canton_lookup, by = "canton_id") %>%
  left_join(canton_treatment %>% select(canton_abbr, treated, lang), by = "canton_abbr")

# For DiDisc, we need:
# - treated_post: interaction of (canton adopted energy law) x (post-adoption period)
# - The "post" period depends on WHEN each canton adopted

# Create canton-specific staggered treatment timing
# In-force years: GR 2011, BE 2012, AG 2013, BL 2016, BS 2017
panel_df <- panel_df %>%
  mutate(
    year = year(votedate),
    treatment_year = case_when(
      canton_abbr == "GR" ~ 2011,
      canton_abbr == "BE" ~ 2012,
      canton_abbr == "AG" ~ 2013,
      canton_abbr == "BL" ~ 2016,
      canton_abbr == "BS" ~ 2017,
      TRUE ~ NA_real_
    ),
    treated_post = treated & !is.na(treatment_year) & (year >= treatment_year)
  )

# Merge with border distances if available
if (!is.null(border_pair_data)) {
  cat("Merging with border-pair data...\n")

  # Select available columns from border_pair_data
  bp_cols <- intersect(c("mun_id", "distance_to_border", "border_pair", "same_language"),
                       names(border_pair_data))
  panel_df <- panel_df %>%
    left_join(
      border_pair_data %>%
        select(all_of(bp_cols)) %>%
        distinct(),
      by = "mun_id"
    )

  # Create near-border sample
  panel_near_border <- panel_df %>%
    filter(!is.na(distance_to_border)) %>%
    filter(abs(distance_to_border) <= 20)  # 20km bandwidth

  cat(paste("Near-border panel:", nrow(panel_near_border), "observations\n"))
} else {
  panel_near_border <- panel_df
  cat("No border data - using full sample\n")
}

# =============================================================================
# SECTION 4: DIFFERENCE-IN-DISCONTINUITIES ESTIMATION
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("DIFFERENCE-IN-DISCONTINUITIES RESULTS\n")
cat(rep("=", 60), "\n")

# Model 1: Basic DiDisc with municipality and referendum FE
cat("\n--- Model 1: Basic DiDisc (Municipality + Referendum FE) ---\n")

didisc_basic <- tryCatch({
  feols(
    yes_share ~ treated_post | mun_id + vote_type,
    data = panel_near_border,
    cluster = ~canton_abbr
  )
}, error = function(e) {
  message(paste("Error:", e$message))
  NULL
})

if (!is.null(didisc_basic)) {
  cat(paste("Estimate:", round(coef(didisc_basic)[1], 2), "pp\n"))
  cat(paste("SE (canton clustered):", round(sqrt(vcov(didisc_basic)[1,1]), 2), "\n"))
  pval <- 2 * pnorm(abs(coef(didisc_basic)[1] / sqrt(vcov(didisc_basic)[1,1])), lower.tail = FALSE)
  cat(paste("p-value:", round(pval, 3), "\n"))
}

# Model 2: DiDisc with border-pair FE (controls for permanent border effects)
cat("\n--- Model 2: DiDisc with Border-Pair FE ---\n")

if (!is.null(border_pair_data) && "border_pair" %in% names(panel_near_border)) {
  # Remove observations without border pair assignment
  panel_bp <- panel_near_border %>%
    filter(!is.na(border_pair))

  didisc_borderpair <- tryCatch({
    feols(
      yes_share ~ treated_post | border_pair + vote_type,
      data = panel_bp,
      cluster = ~canton_abbr
    )
  }, error = function(e) {
    message(paste("Error:", e$message))
    NULL
  })

  if (!is.null(didisc_borderpair)) {
    cat(paste("Estimate:", round(coef(didisc_borderpair)[1], 2), "pp\n"))
    cat(paste("SE (canton clustered):", round(sqrt(vcov(didisc_borderpair)[1,1]), 2), "\n"))
    pval <- 2 * pnorm(abs(coef(didisc_borderpair)[1] / sqrt(vcov(didisc_borderpair)[1,1])), lower.tail = FALSE)
    cat(paste("p-value:", round(pval, 3), "\n"))
    cat(paste("N:", nobs(didisc_borderpair), "\n"))
  }
} else {
  cat("Border-pair data not available\n")
  didisc_borderpair <- NULL
}

# Model 3: DiDisc with border-pair FE and distance controls
cat("\n--- Model 3: DiDisc with Distance Controls ---\n")

if (!is.null(border_pair_data) && "distance_to_border" %in% names(panel_near_border)) {
  panel_bp_dist <- panel_near_border %>%
    filter(!is.na(border_pair), !is.na(distance_to_border))

  didisc_distance <- tryCatch({
    feols(
      yes_share ~ treated_post + distance_to_border + I(distance_to_border^2) | border_pair + vote_type,
      data = panel_bp_dist,
      cluster = ~canton_abbr
    )
  }, error = function(e) {
    message(paste("Error:", e$message))
    NULL
  })

  if (!is.null(didisc_distance)) {
    cat(paste("Estimate:", round(coef(didisc_distance)["treated_postTRUE"], 2), "pp\n"))
    cat(paste("SE (canton clustered):",
              round(sqrt(vcov(didisc_distance)["treated_postTRUE", "treated_postTRUE"]), 2), "\n"))
  }
} else {
  didisc_distance <- NULL
}

# Model 4: Same-language borders only
cat("\n--- Model 4: Same-Language Borders Only ---\n")

if ("same_language" %in% names(panel_near_border)) {
  panel_same_lang <- panel_near_border %>%
    filter(same_language == TRUE)

  didisc_samelang <- tryCatch({
    feols(
      yes_share ~ treated_post | mun_id + vote_type,
      data = panel_same_lang,
      cluster = ~canton_abbr
    )
  }, error = function(e) {
    message(paste("Error:", e$message))
    NULL
  })

  if (!is.null(didisc_samelang)) {
    cat(paste("Estimate:", round(coef(didisc_samelang)[1], 2), "pp\n"))
    cat(paste("SE:", round(sqrt(vcov(didisc_samelang)[1,1]), 2), "\n"))
    cat(paste("N:", nobs(didisc_samelang), "\n"))
  }
} else {
  didisc_samelang <- NULL
}

# =============================================================================
# SECTION 5: WILD CLUSTER BOOTSTRAP INFERENCE
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("INFERENCE: WILD CLUSTER BOOTSTRAP\n")
cat(rep("=", 60), "\n")

if (has_wcb && !is.null(didisc_basic)) {
  cat("\nRunning wild cluster bootstrap (1000 replications)...\n")

  # Prepare data for lm (fwildclusterboot works with lm objects)
  panel_for_wcb <- panel_near_border %>%
    filter(!is.na(yes_share), !is.na(treated_post)) %>%
    mutate(
      mun_factor = as.factor(mun_id),
      vote_factor = as.factor(vote_type),
      treated_post_num = as.numeric(treated_post)
    )

  # Simple model without absorbing FE (for WCB)
  wcb_model <- lm(yes_share ~ treated_post_num + vote_factor,
                  data = panel_for_wcb)

  wcb_result <- tryCatch({
    boottest(
      wcb_model,
      param = "treated_post_num",
      clustid = panel_for_wcb$canton_abbr,
      B = 1000,
      type = "rademacher"
    )
  }, error = function(e) {
    cat(paste("WCB error:", e$message, "\n"))
    NULL
  })

  if (!is.null(wcb_result)) {
    cat("\nWild Cluster Bootstrap Results:\n")
    cat(paste("  Point estimate:", round(wcb_result$point_estimate, 2), "pp\n"))
    cat(paste("  Bootstrap p-value:", round(wcb_result$p_val, 3), "\n"))
    cat(paste("  95% CI:", round(wcb_result$conf_int[1], 2), "to",
              round(wcb_result$conf_int[2], 2), "pp\n"))
  }
} else {
  cat("Wild cluster bootstrap not available or no model to test\n")
  wcb_result <- NULL
}

# =============================================================================
# SECTION 6: SAVE RESULTS
# =============================================================================

cat("\n=== SAVING RESULTS ===\n")

# Compile results table
didisc_results <- tibble(
  specification = c("Basic (Mun + Ref FE)",
                    "Border-Pair FE",
                    "Distance Controls",
                    "Same-Language Only"),
  estimate = c(
    if(!is.null(didisc_basic)) coef(didisc_basic)[1] else NA,
    if(!is.null(didisc_borderpair)) coef(didisc_borderpair)[1] else NA,
    if(!is.null(didisc_distance)) coef(didisc_distance)["treated_postTRUE"] else NA,
    if(!is.null(didisc_samelang)) coef(didisc_samelang)[1] else NA
  ),
  se = c(
    if(!is.null(didisc_basic)) sqrt(vcov(didisc_basic)[1,1]) else NA,
    if(!is.null(didisc_borderpair)) sqrt(vcov(didisc_borderpair)[1,1]) else NA,
    if(!is.null(didisc_distance)) sqrt(vcov(didisc_distance)["treated_postTRUE", "treated_postTRUE"]) else NA,
    if(!is.null(didisc_samelang)) sqrt(vcov(didisc_samelang)[1,1]) else NA
  ),
  n = c(
    if(!is.null(didisc_basic)) nobs(didisc_basic) else NA,
    if(!is.null(didisc_borderpair)) nobs(didisc_borderpair) else NA,
    if(!is.null(didisc_distance)) nobs(didisc_distance) else NA,
    if(!is.null(didisc_samelang)) nobs(didisc_samelang) else NA
  )
) %>%
  mutate(
    pvalue = 2 * pnorm(abs(estimate / se), lower.tail = FALSE),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

write_csv(didisc_results, file.path(tab_dir, "didisc_results.csv"))

# Save full results object
didisc_full <- list(
  basic = didisc_basic,
  borderpair = didisc_borderpair,
  distance = didisc_distance,
  samelang = didisc_samelang,
  wcb = wcb_result,
  panel_data = panel_near_border,
  results_table = didisc_results
)

saveRDS(didisc_full, file.path(data_dir, "didisc_results.rds"))

cat("Saved:\n")
cat(paste("  -", file.path(tab_dir, "didisc_results.csv"), "\n"))
cat(paste("  -", file.path(data_dir, "didisc_results.rds"), "\n"))

# =============================================================================
# SECTION 7: SUMMARY
# =============================================================================

cat("\n", rep("=", 70), "\n")
cat("DIFFERENCE-IN-DISCONTINUITIES SUMMARY\n")
cat(rep("=", 70), "\n\n")

cat("DiDisc Design:\n")
cat("  - Uses multiple referendums (2003, 2016, 2017) to difference out\n")
cat("    time-invariant border effects\n")
cat("  - Compares treated-control differences BEFORE and AFTER cantonal\n")
cat("    energy law adoption\n")
cat("  - Following Grembi, Nannicini & Troiano (2016)\n\n")

cat("Results Table:\n")
print(didisc_results %>% select(specification, estimate, se, pvalue, n))

cat("\nInterpretation:\n")
if (!is.null(didisc_borderpair) && !is.na(coef(didisc_borderpair)[1])) {
  est <- coef(didisc_borderpair)[1]
  pval <- 2 * pnorm(abs(est / sqrt(vcov(didisc_borderpair)[1,1])), lower.tail = FALSE)
  if (pval < 0.05) {
    cat(paste("  Border-pair FE estimate:", round(est, 2), "pp (p =", round(pval, 3), ")\n"))
    cat("  Statistically significant effect after controlling for permanent border differences.\n")
  } else {
    cat(paste("  Border-pair FE estimate:", round(est, 2), "pp (p =", round(pval, 3), ")\n"))
    cat("  Effect NOT significant after controlling for permanent border differences.\n")
    cat("  Cross-sectional RDD estimate may reflect pre-existing canton differences.\n")
  }
}

cat("\n", rep("=", 70), "\n")
cat("DIDISC ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n")
