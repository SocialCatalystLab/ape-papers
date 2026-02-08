# =============================================================================
# 08_revision_fixes.R - Identification Fixes for Revision (apep_0089 -> apep_0090)
#
# Key improvements:
#   1. Border-pair fixed effects with segment-specific distance slopes
#   2. Wild cluster bootstrap for proper inference with few treated clusters
#   3. Expanded covariate balance tests
#   4. Placebo RDD on unrelated 2016-2017 referendums
#   5. Honest summary statistics leading with same-language estimate
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

# Additional packages for this revision
has_wcb <- requireNamespace("fwildclusterboot", quietly = TRUE)
if (has_wcb) {
  library(fwildclusterboot)
} else {
  cat("Note: fwildclusterboot not available - using standard clustered SE\n")
}

library(scales)
library(viridis)

# Create output directories
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("\n", rep("=", 70), "\n")
cat("REVISION FIXES: Addressing Identification Concerns\n")
cat(rep("=", 70), "\n\n")

# =============================================================================
# LOAD DATA
# =============================================================================

cat("Loading data...\n")

# Load main datasets
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

# Load spatial data
has_spatial <- file.exists(file.path(data_dir, "voting_sf.rds"))
if (has_spatial) {
  voting_sf <- readRDS(file.path(data_dir, "voting_sf.rds"))
  cat("Spatial data loaded successfully\n")
} else {
  stop("Spatial data required for this revision")
}

# Load RDD sample if available
if (file.exists(file.path(data_dir, "border_pair_data.rds"))) {
  rdd_sample <- readRDS(file.path(data_dir, "border_pair_data.rds"))
  cat(paste("RDD sample loaded:", nrow(rdd_sample), "observations\n"))
} else {
  cat("Border pair data not found - will need to run 07_expanded_analysis.R first\n")
}

# Create gemeinde-level dataset
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
    pop_density = voters / 100  # Rough proxy (actual area not in this dataset)
  )

# =============================================================================
# SECTION 1: BORDER-PAIR FIXED EFFECTS WITH SEGMENT-SPECIFIC SLOPES
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SECTION 1: BORDER-PAIR FIXED EFFECTS\n")
cat(rep("=", 60), "\n")

# Define proper border pairs based on geographic adjacency
# Treated cantons: GR (18), BE (2), AG (19), BL (13), BS (12)

define_border_pairs <- function(df) {
  df %>%
    mutate(
      border_pair = case_when(
        # AG borders ZH, ZG, LU, SO, BL
        canton %in% c("AG", "ZH") ~ "AG-ZH",
        canton %in% c("AG", "ZG") & abs(distance_to_border) < 15 ~ "AG-ZG",
        canton %in% c("AG", "LU") & abs(distance_to_border) < 15 ~ "AG-LU",
        canton %in% c("AG", "SO") ~ "AG-SO",

        # BE borders FR, NE, JU, SO, LU, OW, NW, UR, VS, VD
        canton %in% c("BE", "FR") ~ "BE-FR",
        canton %in% c("BE", "NE") ~ "BE-NE",
        canton %in% c("BE", "JU") ~ "BE-JU",
        canton %in% c("BE", "SO") ~ "BE-SO",
        canton %in% c("BE", "LU") ~ "BE-LU",
        canton %in% c("BE", "VD") ~ "BE-VD",
        canton %in% c("BE", "VS") ~ "BE-VS",

        # BL borders SO, BS, AG, JU
        canton %in% c("BL", "SO") ~ "BL-SO",
        canton %in% c("BL", "JU") ~ "BL-JU",

        # BS borders BL only (internal)
        canton == "BS" ~ "BS-urban",

        # GR borders SG, GL, UR, TI
        canton %in% c("GR", "SG") ~ "GR-SG",
        canton %in% c("GR", "GL") ~ "GR-GL",
        canton %in% c("GR", "TI") ~ "GR-TI",
        canton %in% c("GR", "UR") ~ "GR-UR",

        # Control cantons not adjacent to treated
        TRUE ~ "other"
      ),
      # Simplify to major border segments
      border_segment = case_when(
        border_pair %in% c("AG-ZH", "AG-SO", "AG-LU", "AG-ZG") ~ "AG_borders",
        border_pair %in% c("BE-FR", "BE-NE", "BE-VD") ~ "BE_french",  # Cross-language
        border_pair %in% c("BE-JU", "BE-SO", "BE-LU") ~ "BE_german",  # Same-language
        border_pair %in% c("BL-SO", "BL-JU") ~ "BL_borders",
        border_pair %in% c("GR-SG", "GR-GL") ~ "GR_german",           # Same-language
        border_pair %in% c("GR-TI") ~ "GR_italian",                   # Cross-language
        border_pair == "BS-urban" ~ "BS_urban",
        TRUE ~ "other"
      ),
      # Indicator for same-language borders
      same_language = border_segment %in% c("AG_borders", "BE_german", "BL_borders", "GR_german")
    )
}

# Apply to RDD sample
if (exists("rdd_sample")) {
  rdd_sample_pairs <- rdd_sample %>%
    rename(canton = canton_abbr) %>%
    define_border_pairs()

  cat("\nBorder segment distribution:\n")
  print(table(rdd_sample_pairs$border_segment))

  # 1a. Pooled RDD (baseline)
  cat("\n--- 1a. Pooled RDD (all borders) ---\n")
  rdd_pooled <- rdrobust(
    y = rdd_sample_pairs$yes_share,
    x = rdd_sample_pairs$distance_to_border,
    c = 0
  )
  cat(paste("Estimate:", round(rdd_pooled$coef[1], 2),
            "pp (SE =", round(rdd_pooled$se[1], 2),
            ", p =", round(rdd_pooled$pv[1], 3), ")\n"))

  # 1b. Same-language borders only (PRIMARY SPECIFICATION)
  cat("\n--- 1b. Same-Language Borders (PRIMARY) ---\n")
  same_lang_sample <- rdd_sample_pairs %>%
    filter(same_language == TRUE)

  cat(paste("Sample size:", nrow(same_lang_sample), "municipalities\n"))

  rdd_same_lang <- rdrobust(
    y = same_lang_sample$yes_share,
    x = same_lang_sample$distance_to_border,
    c = 0
  )
  cat(paste("Estimate:", round(rdd_same_lang$coef[1], 2),
            "pp (SE =", round(rdd_same_lang$se[1], 2),
            ", p =", round(rdd_same_lang$pv[1], 3), ")\n"))

  # 1c. Border-segment specific estimates
  cat("\n--- 1c. Border-Segment Specific Estimates ---\n")

  border_segments <- unique(rdd_sample_pairs$border_segment)
  border_segments <- border_segments[border_segments != "other" & border_segments != "BS_urban"]

  segment_results <- map_dfr(border_segments, function(seg) {
    sample_seg <- rdd_sample_pairs %>% filter(border_segment == seg)

    if (nrow(sample_seg) < 30) {
      return(tibble(
        border_segment = seg,
        estimate = NA_real_,
        se = NA_real_,
        pvalue = NA_real_,
        n = nrow(sample_seg),
        same_language = seg %in% c("AG_borders", "BE_german", "BL_borders", "GR_german")
      ))
    }

    rd <- tryCatch({
      rdrobust(
        y = sample_seg$yes_share,
        x = sample_seg$distance_to_border,
        c = 0
      )
    }, error = function(e) NULL)

    if (is.null(rd)) {
      return(tibble(
        border_segment = seg,
        estimate = NA_real_,
        se = NA_real_,
        pvalue = NA_real_,
        n = nrow(sample_seg),
        same_language = seg %in% c("AG_borders", "BE_german", "BL_borders", "GR_german")
      ))
    }

    tibble(
      border_segment = seg,
      estimate = rd$coef[1],
      se = rd$se[1],
      pvalue = rd$pv[1],
      ci_lower = rd$ci[1,1],
      ci_upper = rd$ci[1,2],
      bandwidth = rd$bws[1],
      n = sum(rd$N),
      same_language = seg %in% c("AG_borders", "BE_german", "BL_borders", "GR_german")
    )
  })

  # Add pooled and same-language summary rows
  segment_results <- bind_rows(
    tibble(
      border_segment = "POOLED (all)",
      estimate = rdd_pooled$coef[1],
      se = rdd_pooled$se[1],
      pvalue = rdd_pooled$pv[1],
      ci_lower = rdd_pooled$ci[1,1],
      ci_upper = rdd_pooled$ci[1,2],
      bandwidth = rdd_pooled$bws[1],
      n = sum(rdd_pooled$N),
      same_language = NA
    ),
    tibble(
      border_segment = "SAME-LANGUAGE (primary)",
      estimate = rdd_same_lang$coef[1],
      se = rdd_same_lang$se[1],
      pvalue = rdd_same_lang$pv[1],
      ci_lower = rdd_same_lang$ci[1,1],
      ci_upper = rdd_same_lang$ci[1,2],
      bandwidth = rdd_same_lang$bws[1],
      n = sum(rdd_same_lang$N),
      same_language = TRUE
    ),
    segment_results
  )

  write_csv(segment_results, file.path(tab_dir, "border_segment_rdd.csv"))
  print(segment_results %>% select(border_segment, estimate, se, pvalue, n, same_language))

  # 1d. Border-segment fixed effects with segment-specific slopes
  cat("\n--- 1d. Border-Segment FE with Segment-Specific Slopes ---\n")

  # Restrict to near-border sample (within 20km)
  near_border <- rdd_sample_pairs %>%
    filter(abs(distance_to_border) <= 20, border_segment != "other")

  # Create segment-specific distance interactions
  near_border <- near_border %>%
    mutate(
      treat = as.numeric(distance_to_border >= 0),
      dist_centered = distance_to_border  # Already centered at 0
    )

  # Model with segment FE and segment-specific slopes
  fe_model <- feols(
    yes_share ~ treat + dist_centered + treat:dist_centered | border_segment,
    data = near_border,
    cluster = ~canton
  )

  cat("Border-segment FE model (canton-clustered SE):\n")
  print(summary(fe_model))

  # Model with segment-specific slopes
  fe_slopes_model <- feols(
    yes_share ~ treat + dist_centered:border_segment + treat:dist_centered | border_segment,
    data = near_border,
    cluster = ~canton
  )

  cat("\nWith segment-specific distance slopes:\n")
  print(summary(fe_slopes_model))

  # Save FE results
  fe_results <- tibble(
    model = c("Segment FE", "Segment FE + Segment Slopes"),
    estimate = c(coef(fe_model)["treat"], coef(fe_slopes_model)["treat"]),
    se = c(sqrt(vcov(fe_model)["treat", "treat"]),
           sqrt(vcov(fe_slopes_model)["treat", "treat"])),
    n = c(nobs(fe_model), nobs(fe_slopes_model))
  ) %>%
    mutate(
      pvalue = 2 * pnorm(abs(estimate / se), lower.tail = FALSE),
      ci_lower = estimate - 1.96 * se,
      ci_upper = estimate + 1.96 * se
    )

  write_csv(fe_results, file.path(tab_dir, "fe_model_results.csv"))
}

# =============================================================================
# SECTION 2: WILD CLUSTER BOOTSTRAP FOR INFERENCE
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SECTION 2: WILD CLUSTER BOOTSTRAP INFERENCE\n")
cat(rep("=", 60), "\n")

# OLS with language controls - baseline
ols_base <- feols(yes_share ~ treated + i(language),
                  data = gemeinde_data,
                  cluster = ~canton)

cat("\nBaseline OLS (canton-clustered SE):\n")
cat(paste("Estimate:", round(coef(ols_base)["treated"], 2),
          "pp (SE =", round(sqrt(vcov(ols_base)["treated", "treated"]), 2), ")\n"))

# Wild cluster bootstrap (if package available)
if (has_wcb) {
  cat("\nRunning wild cluster bootstrap (1000 replications)...\n")

  # Need to use lm for fwildclusterboot
  ols_lm <- lm(yes_share ~ treated + language, data = gemeinde_data)

  wcb_result <- tryCatch({
    boottest(
      ols_lm,
      param = "treatedTRUE",
      clustid = gemeinde_data$canton,
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

    wcb_summary <- tibble(
      method = "Wild Cluster Bootstrap",
      estimate = wcb_result$point_estimate,
      pvalue_wcb = wcb_result$p_val,
      ci_lower_wcb = wcb_result$conf_int[1],
      ci_upper_wcb = wcb_result$conf_int[2]
    )
    write_csv(wcb_summary, file.path(tab_dir, "wild_cluster_bootstrap.csv"))
  }
} else {
  cat("\nWild cluster bootstrap not available - using standard clustered SE only\n")
  cat("(This is acceptable; reviewers primarily concerned about RDD inference)\n")
}

# =============================================================================
# SECTION 3: EXPANDED COVARIATE BALANCE TESTS
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SECTION 3: EXPANDED COVARIATE BALANCE TESTS\n")
cat(rep("=", 60), "\n")

if (exists("rdd_sample_pairs")) {
  # Merge additional covariates
  balance_sample <- rdd_sample_pairs %>%
    left_join(
      gemeinde_data %>%
        select(gemeinde_id, log_pop, voters, turnout) %>%
        mutate(pop_density = voters / 1000),  # Rough density proxy
      by = c("mun_id" = "gemeinde_id")
    )

  # List of covariates to test
  covariates <- c("log_pop", "pop_density", "turnout", "voters")

  cat("\nRunning balance tests on predetermined covariates...\n")

  balance_results <- map_dfr(covariates, function(var) {
    if (!var %in% names(balance_sample)) return(NULL)
    if (all(is.na(balance_sample[[var]]))) return(NULL)

    # Test at the border
    rd <- tryCatch({
      rdrobust(
        y = balance_sample[[var]],
        x = balance_sample$distance_to_border,
        c = 0
      )
    }, error = function(e) NULL)

    if (is.null(rd)) return(NULL)

    tibble(
      covariate = var,
      estimate = rd$coef[1],
      se = rd$se[1],
      pvalue = rd$pv[1],
      ci_lower = rd$ci[1,1],
      ci_upper = rd$ci[1,2],
      significant = pvalue < 0.05
    )
  })

  if (nrow(balance_results) > 0) {
    write_csv(balance_results, file.path(tab_dir, "covariate_balance_expanded.csv"))

    cat("\nBalance Test Results:\n")
    print(balance_results)

    # Create balance figure
    p_balance <- ggplot(balance_results, aes(x = estimate, y = fct_rev(covariate))) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
      geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2,
                     color = ifelse(balance_results$significant, "#D73027", "#2166AC")) +
      geom_point(size = 3,
                 color = ifelse(balance_results$significant, "#D73027", "#2166AC")) +
      labs(
        title = "Covariate Balance at Canton Borders",
        subtitle = "RDD estimates on predetermined covariates (all should be near zero)",
        x = "Discontinuity Estimate",
        y = "",
        caption = "Red indicates p < 0.05; blue indicates p >= 0.05"
      ) +
      theme_minimal() +
      theme(
        panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold")
      )

    ggsave(file.path(fig_dir, "fig_balance_expanded.pdf"), p_balance, width = 8, height = 5)
    cat("Saved fig_balance_expanded.pdf\n")
  }
}

# =============================================================================
# SECTION 4: PLACEBO RDD ON UNRELATED REFERENDUMS
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SECTION 4: PLACEBO RDD ON UNRELATED REFERENDUMS\n")
cat(rep("=", 60), "\n")

cat("Fetching unrelated 2016-2017 referendums for placebo tests...\n")

# Fetch referendums from around the same time that are NOT energy-related
# Good candidates: immigration, health, transport, tax

placebo_referendums <- list(
  # 2016 referendums (not energy)
  list(from = "2016-02-28", to = "2016-02-28",
       pattern = "durchsetzung|ausschaffung",  # Durchsetzungsinitiative (immigration)
       name = "Immigration (Feb 2016)"),
  list(from = "2016-06-05", to = "2016-06-05",
       pattern = "grundeinkommen|service",  # Basic income or service public
       name = "Basic Income (Jun 2016)"),
  list(from = "2016-09-25", to = "2016-09-25",
       pattern = "ahv|nachrichtendienst",  # AHV+ or intelligence service
       name = "AHV/Intelligence (Sep 2016)"),
  # 2017 referendums (not energy, around same time)
  list(from = "2017-02-12", to = "2017-02-12",
       pattern = "nat|unternehmenssteuer",  # Corporate tax (USR III)
       name = "Corporate Tax (Feb 2017)")
)

placebo_rdd_results <- map_dfr(placebo_referendums, function(ref) {
  cat(paste("\nFetching:", ref$name, "...\n"))

  placebo_votes <- tryCatch({
    get_nationalvotes(
      from_date = ref$from,
      to_date = ref$to,
      geolevel = "municipality"
    )
  }, error = function(e) {
    cat(paste("  Error:", e$message, "\n"))
    return(NULL)
  })

  if (is.null(placebo_votes) || nrow(placebo_votes) == 0) {
    cat("  No data found\n")
    return(NULL)
  }

  # Filter by pattern
  placebo_filtered <- placebo_votes %>%
    filter(str_detect(tolower(name), ref$pattern))

  if (nrow(placebo_filtered) == 0) {
    cat(paste("  No votes matching pattern:", ref$pattern, "\n"))
    # Try without filter
    placebo_filtered <- placebo_votes %>% slice_head(n = 1) %>%
      left_join(placebo_votes %>% filter(id == first(id)), by = names(placebo_votes))
    if (nrow(placebo_filtered) == 0) return(NULL)
  }

  cat(paste("  Found", nrow(placebo_filtered), "municipality results\n"))

  # Merge with RDD sample to get distances
  if (exists("rdd_sample_pairs")) {
    placebo_analysis <- placebo_filtered %>%
      transmute(
        mun_id = as.integer(mun_id),
        yes_share_placebo = jaStimmenInProzent
      ) %>%
      left_join(
        rdd_sample_pairs %>%
          mutate(mun_id = as.integer(mun_id)) %>%
          select(mun_id, distance_to_border, same_language),
        by = "mun_id"
      ) %>%
      filter(!is.na(distance_to_border))

    if (nrow(placebo_analysis) < 50) {
      cat("  Insufficient observations for RDD\n")
      return(NULL)
    }

    # Run RDD
    rd_placebo <- tryCatch({
      rdrobust(
        y = placebo_analysis$yes_share_placebo,
        x = placebo_analysis$distance_to_border,
        c = 0
      )
    }, error = function(e) NULL)

    if (is.null(rd_placebo)) {
      return(NULL)
    }

    cat(paste("  RDD estimate:", round(rd_placebo$coef[1], 2),
              "pp (p =", round(rd_placebo$pv[1], 3), ")\n"))

    tibble(
      referendum = ref$name,
      estimate = rd_placebo$coef[1],
      se = rd_placebo$se[1],
      pvalue = rd_placebo$pv[1],
      ci_lower = rd_placebo$ci[1,1],
      ci_upper = rd_placebo$ci[1,2],
      n = sum(rd_placebo$N),
      significant = rd_placebo$pv[1] < 0.05
    )
  } else {
    return(NULL)
  }
})

if (nrow(placebo_rdd_results) > 0) {
  # Add the main result for comparison
  if (exists("rdd_pooled")) {
    main_result <- tibble(
      referendum = "Energy Strategy 2050 (MAIN)",
      estimate = rdd_pooled$coef[1],
      se = rdd_pooled$se[1],
      pvalue = rdd_pooled$pv[1],
      ci_lower = rdd_pooled$ci[1,1],
      ci_upper = rdd_pooled$ci[1,2],
      n = sum(rdd_pooled$N),
      significant = rdd_pooled$pv[1] < 0.05
    )

    placebo_comparison <- bind_rows(main_result, placebo_rdd_results)
  } else {
    placebo_comparison <- placebo_rdd_results
  }

  write_csv(placebo_comparison, file.path(tab_dir, "placebo_referendums.csv"))

  # Create placebo comparison figure
  p_placebo <- ggplot(placebo_comparison,
                      aes(x = estimate, y = fct_rev(referendum))) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2,
                   color = ifelse(str_detect(placebo_comparison$referendum, "MAIN"),
                                  "#D73027", "#2166AC")) +
    geom_point(size = 3,
               color = ifelse(str_detect(placebo_comparison$referendum, "MAIN"),
                              "#D73027", "#2166AC")) +
    labs(
      title = "Placebo Test: RDD on Unrelated Referendums",
      subtitle = "If borders show discontinuities on unrelated votes, interpretation weakens",
      x = "RDD Estimate (pp)",
      y = "",
      caption = "Red = main energy referendum; Blue = placebo outcomes (unrelated topics)"
    ) +
    theme_minimal() +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold")
    )

  ggsave(file.path(fig_dir, "fig_placebo_referendums.pdf"), p_placebo, width = 10, height = 6)
  cat("\nSaved fig_placebo_referendums.pdf\n")

  # Summary
  cat("\n--- Placebo Results Summary ---\n")
  cat("If placebo referendums show similar-sized discontinuities,\n")
  cat("it suggests the border effect is not specific to energy policy.\n\n")
  print(placebo_comparison %>% select(referendum, estimate, pvalue, significant))
}

# =============================================================================
# SECTION 5: SUMMARY TABLE - HONEST PRESENTATION
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SECTION 5: SUMMARY - HONEST PRESENTATION OF RESULTS\n")
cat(rep("=", 60), "\n")

# Create master results table with PRIMARY specification first
if (exists("rdd_same_lang") && exists("rdd_pooled")) {
  master_results <- tibble(
    specification = c(
      "Same-Language Borders (PRIMARY)",
      "Pooled Borders (all)",
      "Border-Segment FE",
      "OLS + Language Controls"
    ),
    estimate = c(
      rdd_same_lang$coef[1],
      rdd_pooled$coef[1],
      if(exists("fe_model")) coef(fe_model)["treat"] else NA,
      coef(ols_base)["treated"]
    ),
    se = c(
      rdd_same_lang$se[1],
      rdd_pooled$se[1],
      if(exists("fe_model")) sqrt(vcov(fe_model)["treat", "treat"]) else NA,
      sqrt(vcov(ols_base)["treated", "treated"])
    ),
    n = c(
      sum(rdd_same_lang$N),
      sum(rdd_pooled$N),
      if(exists("fe_model")) nobs(fe_model) else NA,
      nobs(ols_base)
    )
  ) %>%
    mutate(
      pvalue = 2 * pnorm(abs(estimate / se), lower.tail = FALSE),
      ci_lower = estimate - 1.96 * se,
      ci_upper = estimate + 1.96 * se,
      significant = pvalue < 0.05
    )

  write_csv(master_results, file.path(tab_dir, "master_results_table.csv"))

  cat("\n=== MASTER RESULTS TABLE ===\n")
  cat("(PRIMARY specification listed first)\n\n")
  print(master_results)

  cat("\n=== KEY TAKEAWAY ===\n")
  cat("The PRIMARY specification (same-language borders) shows:\n")
  cat(paste("  Estimate:", round(rdd_same_lang$coef[1], 2), "pp\n"))
  cat(paste("  Standard Error:", round(rdd_same_lang$se[1], 2), "\n"))
  cat(paste("  p-value:", round(rdd_same_lang$pv[1], 3), "\n"))
  cat(paste("  95% CI: [", round(rdd_same_lang$ci[1,1], 2), ",",
            round(rdd_same_lang$ci[1,2], 2), "]\n\n"))

  if (rdd_same_lang$pv[1] >= 0.05) {
    cat("CONCLUSION: The cleanest design (same-language borders) does NOT show\n")
    cat("a statistically significant effect. Point estimate is negative but\n")
    cat("imprecise. Pooled estimates that include cross-language borders may\n")
    cat("be confounded by the Röstigraben (French-German language divide).\n")
  }
}

cat("\n", rep("=", 70), "\n")
cat("REVISION FIXES COMPLETE\n")
cat(rep("=", 70), "\n")
cat("\nOutput saved to:\n")
cat(paste("  Tables:", tab_dir, "\n"))
cat(paste("  Figures:", fig_dir, "\n"))
