# =============================================================================
# 10_placebo_corrected.R - Run Placebo RDD on Corrected Sample
#
# This script runs the placebo RDD (unrelated referendums) using the same
# corrected sample construction as the main RDD, ensuring diagnostics
# match the identification strategy.
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

cat("\n", rep("=", 70), "\n")
cat("PLACEBO RDD ON CORRECTED SAMPLE\n")
cat(rep("=", 70), "\n\n")

# =============================================================================
# LOAD CORRECTED SAMPLE AND VOTING DATA
# =============================================================================

cat("Loading corrected sample...\n")

# Load the corrected RDD sample from 09_fix_rdd_sample.R
corrected_sample <- tryCatch({
  readRDS(file.path(data_dir, "rdd_sample_corrected.rds"))
}, error = function(e) {
  stop("Corrected sample not found. Run 09_fix_rdd_sample.R first.")
})

# Load all voting data (includes multiple referendums)
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))

# Get the unique municipality IDs from the corrected sample
corrected_mun_ids <- unique(corrected_sample$mun_id)
cat(paste("Corrected sample has", length(corrected_mun_ids), "unique municipalities\n"))

# Get the border distances from the corrected sample
border_distances <- corrected_sample %>%
  select(mun_id, dist_to_own_border, nearest_border_pair, signed_distance_km, treated) %>%
  distinct()

# =============================================================================
# FETCH PLACEBO REFERENDUMS DIRECTLY FROM SWISSDD
# =============================================================================

cat("\nFetching placebo referendums from swissdd API...\n")
cat("(Non-energy referendums unrelated to cantonal energy policy)\n\n")

# Define placebo referendums: non-energy Swiss votes near the study period.
# These should have NO relationship to cantonal energy laws.
# Selection rule: major non-energy referendums from 2016-2017 period.
#
# Swiss Federal Chancellery referendum details:
#   - 2016-02-28: Durchsetzungsinitiative (enforcement initiative, immigration)
#   - 2016-09-25: AHVplus (pension increase initiative) — same day as green economy
#   - 2017-02-12: USR III (corporate tax reform)
placebo_defs <- list(
  list(from = "2016-02-01", to = "2016-02-29",
       pattern = "durchsetzung",
       type = "durchsetzung_2016"),
  list(from = "2016-09-01", to = "2016-09-30",
       pattern = "ahvplus|ahv",
       type = "ahvplus_2016"),
  list(from = "2017-02-01", to = "2017-02-28",
       pattern = "unternehmenssteuer|usr",
       type = "usr_iii_2017")
)

# Fetch each placebo referendum
placebo_list <- list()
for (pdef in placebo_defs) {
  cat(paste("  Fetching", pdef$type, "... "))
  pdata <- tryCatch({
    votes <- get_nationalvotes(
      from_date = pdef$from,
      to_date = pdef$to,
      geolevel = "municipality"
    )

    if (nrow(votes) == 0) {
      cat("no data in date range\n")
      next
    }

    # Filter by pattern
    matched <- votes %>%
      filter(str_detect(tolower(name), pdef$pattern))

    if (nrow(matched) == 0) {
      cat("no pattern match\n")
      next
    }

    # Verify unique vote
    unique_ids <- unique(matched$id)
    if (length(unique_ids) > 1) {
      cat(paste("multiple matches (", length(unique_ids), "), selecting first by date\n"))
      first_id <- matched %>%
        group_by(id) %>%
        summarise(votedate = first(votedate), .groups = "drop") %>%
        arrange(votedate) %>%
        pull(id) %>%
        first()
      matched <- matched %>% filter(id == first_id)
    }

    cat(paste(nrow(matched), "observations (vote ID:", unique(matched$id), ")\n"))

    matched %>%
      transmute(
        mun_id = as.integer(mun_id),
        mun_name = mun_name,
        canton_id = as.integer(canton_id),
        canton_name = canton_name,
        yes_share = jaStimmenInProzent,
        turnout = stimmbeteiligungInProzent,
        votedate = votedate,
        vote_type = pdef$type
      )
  }, error = function(e) {
    cat(paste("error:", e$message, "\n"))
    NULL
  })

  if (!is.null(pdata) && nrow(pdata) > 0) {
    placebo_list[[pdef$type]] <- pdata
  }
}

if (length(placebo_list) == 0) {
  stop("Failed to fetch any placebo referendums. Check network/API access.")
}

placebo_data <- bind_rows(placebo_list)
cat(paste("\nTotal placebo observations:", nrow(placebo_data), "\n"))
cat(paste("Placebo referendums fetched:", length(placebo_list), "\n"))

# Add canton abbreviation and treatment status
canton_lookup <- tibble(
  canton_id = 1:26,
  canton_abbr = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
                  "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
                  "TI", "VD", "VS", "NE", "GE", "JU")
)

placebo_data <- placebo_data %>%
  left_join(canton_lookup, by = "canton_id")

# =============================================================================
# MERGE WITH CORRECTED BORDER DISTANCES
# =============================================================================

cat("\nMerging with corrected border distances...\n")

# Merge placebo voting data with corrected border distances
placebo_corrected <- placebo_data %>%
  inner_join(border_distances, by = "mun_id") %>%
  filter(!is.na(dist_to_own_border))

cat(paste("Placebo sample size after merge:", nrow(placebo_corrected), "\n"))

if (nrow(placebo_corrected) == 0) {
  stop("No matching placebo data after merging with border distances. Check municipality ID alignment.")
}

# =============================================================================
# RUN PLACEBO RDD ON CORRECTED SAMPLE
# =============================================================================

cat("\nRunning placebo RDDs on corrected sample...\n")

placebo_results <- map_dfr(unique(placebo_corrected$vote_type), function(vt) {
  cat(paste("\nProcessing:", vt, "\n"))

  sample_vt <- placebo_corrected %>%
    filter(vote_type == vt)

  if (nrow(sample_vt) < 100) {
    cat(paste("  Too few observations:", nrow(sample_vt), "\n"))
    return(tibble(
      referendum = vt,
      estimate = NA_real_,
      se = NA_real_,
      pvalue = NA_real_,
      n = nrow(sample_vt),
      bandwidth = NA_real_,
      sample = "corrected"
    ))
  }

  rd <- tryCatch({
    rdrobust(
      y = sample_vt$yes_share,
      x = sample_vt$signed_distance_km,
      c = 0
    )
  }, error = function(e) {
    cat(paste("  Error:", e$message, "\n"))
    NULL
  })

  if (is.null(rd)) {
    return(tibble(
      referendum = vt,
      estimate = NA_real_,
      se = NA_real_,
      pvalue = NA_real_,
      n = nrow(sample_vt),
      bandwidth = NA_real_,
      sample = "corrected"
    ))
  }

  cat(paste("  Estimate:", round(rd$coef[1], 2), "pp (p =", round(rd$pv[1], 3), ")\n"))

  tibble(
    referendum = vt,
    estimate = rd$coef[1],
    se = rd$se[1],
    pvalue = rd$pv[1],
    n = sum(rd$N),
    bandwidth = rd$bws[1],
    sample = "corrected"
  )
})

cat("\n", rep("=", 60), "\n")
cat("PLACEBO RDD RESULTS (Corrected Sample)\n")
cat(rep("=", 60), "\n\n")

print(placebo_results)

# Save results
write_csv(placebo_results, file.path(tab_dir, "placebo_rdd_corrected.csv"))
saveRDS(placebo_results, file.path(data_dir, "placebo_results_corrected.rds"))

cat("\nResults saved.\n")

cat("\n", rep("=", 70), "\n")
cat("PLACEBO RDD ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n")
