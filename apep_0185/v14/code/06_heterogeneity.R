# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 06_heterogeneity.R - Subgroup analysis
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================\n")
cat("  06_heterogeneity.R\n")
cat("========================================\n\n")

# ==============================================================================
# 1. LOAD DATA AND MAIN RESULTS
# ==============================================================================
cat("=== Loading Data ===\n")

df <- arrow::read_parquet("data/analysis_panel.parquet")
load("data/cs_results.RData")

cat(sprintf("  Rows: %s\n", format(nrow(df), big.mark = ",")))
cat(sprintf("  Places: %s\n", format(n_distinct(df$place_id), big.mark = ",")))
cat(sprintf("  States (clusters): %d\n", n_distinct(df$state_fips)))

# Ensure output directories
dir.create("tables", showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE, recursive = TRUE)

# Ensure log variables exist
if (!"log_pop" %in% names(df) && "population" %in% names(df)) {
  df$log_pop <- log(df$population + 1)
}
if (!"log_income" %in% names(df) && "median_income" %in% names(df)) {
  df$log_income <- log(df$median_income + 1)
}

xformla <- ~ log_pop + log_income + pct_college + pct_white + median_age

n_clusters_total <- n_distinct(df$state_fips)

# ==============================================================================
# HELPER: Run C-S DiD on a subset
# ==============================================================================

run_cs_subset <- function(data, outcome, subset_name, biters = 500) {
  # Prepare data
  sub_data <- data %>%
    mutate(
      gname = ifelse(treated, treat_year, 0),
      id = as.numeric(factor(place_id))
    )

  n_places <- n_distinct(sub_data$place_id)
  n_treated <- n_distinct(sub_data$place_id[sub_data$treated])
  n_control <- n_distinct(sub_data$place_id[!sub_data$treated])
  n_clust <- n_distinct(sub_data$state_fips)
  n_cohorts <- n_distinct(sub_data$gname[sub_data$gname > 0])

  cat(sprintf("    Subset '%s': %d places (%d treated, %d control), %d clusters, %d cohorts\n",
              subset_name, n_places, n_treated, n_control, n_clust, n_cohorts))

  if (n_treated < 5 || n_control < 5 || n_cohorts < 2) {
    cat(sprintf("    SKIPPED: insufficient variation (treated=%d, control=%d, cohorts=%d)\n",
                n_treated, n_control, n_cohorts))
    return(list(
      att_row = tibble(
        outcome = outcome, subgroup = subset_name,
        ATT = NA, SE = NA, CI_lower = NA, CI_upper = NA,
        p_value = NA, N = nrow(sub_data), N_clusters = n_clust,
        N_treated = n_treated, N_control = n_control,
        note = "insufficient variation"
      ),
      es_data = tibble(),
      cs_obj = NULL
    ))
  }

  # Run C-S
  cs <- tryCatch({
    att_gt(
      yname = outcome,
      tname = "year",
      idname = "id",
      gname = "gname",
      data = sub_data,
      control_group = "nevertreated",
      est_method = "dr",
      xformla = xformla,
      clustervars = "state_fips",
      anticipation = 1,
      bstrap = TRUE,
      biters = biters,
      print_details = FALSE
    )
  }, error = function(e) {
    cat(sprintf("    C-S estimation failed: %s\n", e$message))
    # Retry without covariates
    tryCatch({
      att_gt(
        yname = outcome,
        tname = "year",
        idname = "id",
        gname = "gname",
        data = sub_data,
        control_group = "nevertreated",
        est_method = "reg",
        anticipation = 1,
        clustervars = "state_fips",
        bstrap = TRUE,
        biters = biters,
        print_details = FALSE
      )
    }, error = function(e2) {
      cat(sprintf("    Fallback also failed: %s\n", e2$message))
      NULL
    })
  })

  if (is.null(cs)) {
    return(list(
      att_row = tibble(
        outcome = outcome, subgroup = subset_name,
        ATT = NA, SE = NA, CI_lower = NA, CI_upper = NA,
        p_value = NA, N = nrow(sub_data), N_clusters = n_clust,
        N_treated = n_treated, N_control = n_control,
        note = "estimation failed"
      ),
      es_data = tibble(),
      cs_obj = NULL
    ))
  }

  # Aggregate: simple ATT
  att <- tryCatch(
    aggte(cs, type = "simple", na.rm = TRUE),
    error = function(e) NULL
  )

  # Aggregate: event study
  es <- tryCatch(
    aggte(cs, type = "dynamic", na.rm = TRUE),
    error = function(e) NULL
  )

  att_val <- if (!is.null(att)) att$overall.att else NA
  se_val <- if (!is.null(att)) att$overall.se else NA
  p_val <- if (!is.na(att_val) && !is.na(se_val) && se_val > 0) {
    2 * (1 - pnorm(abs(att_val / se_val)))
  } else NA

  # Event study data
  es_df <- if (!is.null(es)) {
    tibble(
      outcome = outcome,
      subgroup = subset_name,
      event_time = es$egt,
      att = es$att.egt,
      se = es$se.egt,
      ci_lower = es$att.egt - 1.96 * es$se.egt,
      ci_upper = es$att.egt + 1.96 * es$se.egt
    )
  } else {
    tibble()
  }

  list(
    att_row = tibble(
      outcome = outcome,
      subgroup = subset_name,
      ATT = att_val,
      SE = se_val,
      CI_lower = att_val - 1.96 * se_val,
      CI_upper = att_val + 1.96 * se_val,
      p_value = p_val,
      N = nrow(sub_data),
      N_clusters = n_clust,
      N_treated = n_treated,
      N_control = n_control,
      sig = case_when(
        is.na(p_val) ~ "",
        p_val < 0.01 ~ "***",
        p_val < 0.05 ~ "**",
        p_val < 0.10 ~ "*",
        TRUE ~ ""
      ),
      note = ""
    ),
    es_data = es_df,
    cs_obj = cs
  )
}

# ==============================================================================
# 2. HETEROGENEITY BY BASELINE PARTISANSHIP
# ==============================================================================
cat("\n=== Heterogeneity: Partisanship ===\n")

if ("republican_county" %in% names(df)) {
  cat("  Splitting by republican_county...\n")

  het_part_results <- list()
  het_part_es <- list()

  for (outcome in c("individualizing", "binding")) {
    # Republican counties
    rep_sub <- df %>% filter(republican_county == TRUE)
    res_rep <- run_cs_subset(rep_sub, outcome, "Republican")
    het_part_results[[paste0(outcome, "_rep")]] <- res_rep$att_row
    het_part_es[[paste0(outcome, "_rep")]] <- res_rep$es_data

    # Democrat counties
    dem_sub <- df %>% filter(republican_county == FALSE)
    res_dem <- run_cs_subset(dem_sub, outcome, "Democrat")
    het_part_results[[paste0(outcome, "_dem")]] <- res_dem$att_row
    het_part_es[[paste0(outcome, "_dem")]] <- res_dem$es_data

    if (!is.na(res_rep$att_row$ATT) && !is.na(res_dem$att_row$ATT)) {
      cat(sprintf("    %s: Republican ATT = %.5f, Democrat ATT = %.5f\n",
                  outcome, res_rep$att_row$ATT, res_dem$att_row$ATT))
    }
  }

  het_partisanship <- bind_rows(het_part_results)
  het_partisanship_es <- bind_rows(het_part_es)

  cat("\n  Partisanship Results:\n")
  het_partisanship %>%
    select(outcome, subgroup, ATT, SE, p_value, sig, N_treated) %>%
    mutate(ATT = round(ATT, 5), SE = round(SE, 5), p_value = round(p_value, 4)) %>%
    print(width = Inf)

  write_csv(het_partisanship, "tables/het_partisanship.csv")
  write_csv(het_partisanship_es, "data/het_partisanship_es.csv")
  cat("  Saved: tables/het_partisanship.csv, data/het_partisanship_es.csv\n")

} else {
  cat("  WARNING: 'republican_county' not found in data.\n")
  cat("  Attempting to construct from rep_share...\n")

  if ("rep_share" %in% names(df)) {
    # Use baseline (first year) rep_share to classify
    baseline_rep <- df %>%
      group_by(place_id) %>%
      summarise(rep_share_baseline = first(rep_share), .groups = "drop")

    df <- df %>%
      left_join(baseline_rep, by = "place_id") %>%
      mutate(republican_county = rep_share_baseline > 0.5)

    cat(sprintf("  Constructed: %d Republican places, %d Democrat places\n",
                n_distinct(df$place_id[df$republican_county == TRUE]),
                n_distinct(df$place_id[df$republican_county == FALSE])))

    het_part_results <- list()
    het_part_es <- list()

    for (outcome in c("individualizing", "binding")) {
      res_rep <- run_cs_subset(df %>% filter(republican_county == TRUE),
                               outcome, "Republican")
      res_dem <- run_cs_subset(df %>% filter(republican_county == FALSE),
                               outcome, "Democrat")

      het_part_results[[paste0(outcome, "_rep")]] <- res_rep$att_row
      het_part_results[[paste0(outcome, "_dem")]] <- res_dem$att_row
      het_part_es[[paste0(outcome, "_rep")]] <- res_rep$es_data
      het_part_es[[paste0(outcome, "_dem")]] <- res_dem$es_data
    }

    het_partisanship <- bind_rows(het_part_results)
    het_partisanship_es <- bind_rows(het_part_es)

    write_csv(het_partisanship, "tables/het_partisanship.csv")
    write_csv(het_partisanship_es, "data/het_partisanship_es.csv")
    cat("  Saved: tables/het_partisanship.csv, data/het_partisanship_es.csv\n")

  } else {
    cat("  WARNING: Neither 'republican_county' nor 'rep_share' found. Skipping.\n")
    het_partisanship <- tibble()
    het_partisanship_es <- tibble()
    write_csv(het_partisanship, "tables/het_partisanship.csv")
    write_csv(het_partisanship_es, "data/het_partisanship_es.csv")
  }
}

# ==============================================================================
# 3. HETEROGENEITY BY RURALITY (METRO VS NON-METRO)
# ==============================================================================
cat("\n=== Heterogeneity: Rurality ===\n")

# Find the metro variable (may be named differently)
metro_var <- NULL
for (candidate in c("metro", "is_metro", "metro_status", "cbsa_status")) {
  if (candidate %in% names(df)) {
    metro_var <- candidate
    break
  }
}

het_rurality <- tibble()
het_rurality_es <- tibble()

if (!is.null(metro_var)) {
  cat(sprintf("  Using metro variable: %s\n", metro_var))

  # Determine metro/non-metro split
  df$is_metro_flag <- as.logical(df[[metro_var]])

  het_rur_results <- list()
  het_rur_es <- list()

  for (outcome in c("individualizing", "binding")) {
    res_metro <- run_cs_subset(df %>% filter(is_metro_flag == TRUE),
                               outcome, "Metro")
    res_nonmetro <- run_cs_subset(df %>% filter(is_metro_flag == FALSE),
                                  outcome, "Non-Metro")

    het_rur_results[[paste0(outcome, "_metro")]] <- res_metro$att_row
    het_rur_results[[paste0(outcome, "_nonmetro")]] <- res_nonmetro$att_row
    het_rur_es[[paste0(outcome, "_metro")]] <- res_metro$es_data
    het_rur_es[[paste0(outcome, "_nonmetro")]] <- res_nonmetro$es_data

    if (!is.na(res_metro$att_row$ATT) && !is.na(res_nonmetro$att_row$ATT)) {
      cat(sprintf("    %s: Metro ATT = %.5f, Non-Metro ATT = %.5f\n",
                  outcome, res_metro$att_row$ATT, res_nonmetro$att_row$ATT))
    }
  }

  het_rurality <- bind_rows(het_rur_results)
  het_rurality_es <- bind_rows(het_rur_es)

  cat("\n  Rurality Results:\n")
  het_rurality %>%
    select(outcome, subgroup, ATT, SE, p_value, sig, N_treated) %>%
    mutate(ATT = round(ATT, 5), SE = round(SE, 5), p_value = round(p_value, 4)) %>%
    print(width = Inf)

} else {
  cat("  WARNING: No metro variable found in data.\n")
  cat("  Attempting population-based proxy: metro = population > 50000\n")

  # Use population as proxy for metro status
  df_proxy <- df %>%
    group_by(place_id) %>%
    mutate(
      baseline_pop = first(population)
    ) %>%
    ungroup() %>%
    mutate(is_metro_flag = baseline_pop > 50000)

  cat(sprintf("  Metro (pop > 50K): %d places, Non-Metro: %d places\n",
              n_distinct(df_proxy$place_id[df_proxy$is_metro_flag]),
              n_distinct(df_proxy$place_id[!df_proxy$is_metro_flag])))

  het_rur_results <- list()
  het_rur_es <- list()

  for (outcome in c("individualizing", "binding")) {
    res_metro <- run_cs_subset(df_proxy %>% filter(is_metro_flag == TRUE),
                               outcome, "Metro (pop>50K)")
    res_nonmetro <- run_cs_subset(df_proxy %>% filter(is_metro_flag == FALSE),
                                  outcome, "Non-Metro (pop<=50K)")

    het_rur_results[[paste0(outcome, "_metro")]] <- res_metro$att_row
    het_rur_results[[paste0(outcome, "_nonmetro")]] <- res_nonmetro$att_row
    het_rur_es[[paste0(outcome, "_metro")]] <- res_metro$es_data
    het_rur_es[[paste0(outcome, "_nonmetro")]] <- res_nonmetro$es_data
  }

  het_rurality <- bind_rows(het_rur_results)
  het_rurality_es <- bind_rows(het_rur_es)
}

write_csv(het_rurality, "tables/het_rurality.csv")
write_csv(het_rurality_es, "data/het_rurality_es.csv")
cat("  Saved: tables/het_rurality.csv, data/het_rurality_es.csv\n")

# ==============================================================================
# 4. HETEROGENEITY BY PRE-TREATMENT MORAL ORIENTATION
# ==============================================================================
cat("\n=== Heterogeneity: Pre-Treatment Moral Orientation ===\n")

het_moral <- tibble()

# Find or construct high_universalism variable
if ("high_universalism" %in% names(df)) {
  cat("  Using existing high_universalism variable\n")
} else {
  cat("  Constructing high_universalism from pre-treatment data...\n")

  # Compute baseline universalism for each place (pre-treatment mean)
  baseline_univ <- df %>%
    filter(!treated | year < treat_year) %>%
    group_by(place_id) %>%
    summarise(
      baseline_universalism = mean(individualizing - binding, na.rm = TRUE),
      .groups = "drop"
    )

  # Split at median
  median_univ <- median(baseline_univ$baseline_universalism, na.rm = TRUE)
  cat(sprintf("  Median baseline universalism: %.4f\n", median_univ))

  baseline_univ <- baseline_univ %>%
    mutate(high_universalism = baseline_universalism > median_univ)

  df <- df %>%
    left_join(baseline_univ %>% select(place_id, high_universalism),
              by = "place_id")

  cat(sprintf("  High universalism: %d places, Low: %d places\n",
              n_distinct(df$place_id[df$high_universalism == TRUE]),
              n_distinct(df$place_id[df$high_universalism == FALSE])))
}

het_moral_results <- list()

for (outcome in c("individualizing", "binding")) {
  res_high <- run_cs_subset(df %>% filter(high_universalism == TRUE),
                            outcome, "High Universalism")
  res_low <- run_cs_subset(df %>% filter(high_universalism == FALSE),
                           outcome, "Low Universalism")

  het_moral_results[[paste0(outcome, "_high")]] <- res_high$att_row
  het_moral_results[[paste0(outcome, "_low")]] <- res_low$att_row

  if (!is.na(res_high$att_row$ATT) && !is.na(res_low$att_row$ATT)) {
    cat(sprintf("    %s: High Univ ATT = %.5f, Low Univ ATT = %.5f\n",
                outcome, res_high$att_row$ATT, res_low$att_row$ATT))
  }
}

het_moral <- bind_rows(het_moral_results)

cat("\n  Moral Orientation Results:\n")
het_moral %>%
  select(outcome, subgroup, ATT, SE, p_value, sig, N_treated) %>%
  mutate(ATT = round(ATT, 5), SE = round(SE, 5), p_value = round(p_value, 4)) %>%
  print(width = Inf)

write_csv(het_moral, "tables/het_moral_orientation.csv")
cat("  Saved: tables/het_moral_orientation.csv\n")

# ==============================================================================
# 5. BROADBAND DOSAGE x PARTISANSHIP INTERACTION
# ==============================================================================
cat("\n=== Heterogeneity: Broadband x Partisanship Interaction ===\n")

het_interaction <- tibble()

# Ensure we have rep_share_baseline
if (!"rep_share_baseline" %in% names(df)) {
  if ("rep_share" %in% names(df)) {
    baseline_rep <- df %>%
      group_by(place_id) %>%
      summarise(rep_share_baseline = first(rep_share), .groups = "drop")
    df <- df %>%
      left_join(baseline_rep, by = "place_id")
    cat("  Constructed rep_share_baseline from first observation\n")
  } else {
    cat("  WARNING: No rep_share variable available for interaction\n")
  }
}

if ("rep_share_baseline" %in% names(df)) {
  interaction_results <- list()

  for (outcome in c("individualizing", "binding", "universalism_index", "log_univ_comm")) {
    cat(sprintf("  Interaction: %s... ", outcome))

    fml <- as.formula(paste0(
      outcome,
      " ~ broadband_rate:rep_share_baseline | place_id + year"
    ))

    interaction_results[[outcome]] <- tryCatch({
      m <- feols(fml, data = df, cluster = ~state_fips)
      cat("OK\n")
      m
    }, error = function(e) {
      cat(sprintf("FAILED: %s\n", e$message))
      NULL
    })
  }

  # Extract results
  het_interaction <- map_dfr(names(interaction_results), function(outcome) {
    m <- interaction_results[[outcome]]
    if (is.null(m)) return(tibble(outcome = outcome))

    coef_name <- names(coef(m))[1]  # interaction term

    tibble(
      outcome = outcome,
      estimator = "TWFE (interaction)",
      interaction_term = coef_name,
      coef = coef(m)[coef_name],
      SE = se(m)[coef_name],
      CI_lower = coef(m)[coef_name] - 1.96 * se(m)[coef_name],
      CI_upper = coef(m)[coef_name] + 1.96 * se(m)[coef_name],
      p_value = pvalue(m)[coef_name],
      N = m$nobs,
      N_clusters = n_clusters_total,
      R2_within = r2(m, type = "within")
    )
  })

  cat("\n  Interaction Results:\n")
  het_interaction %>%
    mutate(coef = round(coef, 5), SE = round(SE, 5), p_value = round(p_value, 4)) %>%
    print(width = Inf)

  # Also run with additional controls
  cat("\n  Extended interaction specification:\n")
  for (outcome in c("individualizing", "binding")) {
    cat(sprintf("    %s (extended)... ", outcome))
    tryCatch({
      fml_ext <- as.formula(paste0(
        outcome,
        " ~ broadband_rate + broadband_rate:rep_share_baseline + rep_share_baseline:factor(year) | place_id + year"
      ))
      m_ext <- feols(fml_ext, data = df, cluster = ~state_fips)
      int_coef <- coef(m_ext)["broadband_rate:rep_share_baseline"]
      int_se <- se(m_ext)["broadband_rate:rep_share_baseline"]
      cat(sprintf("coef = %.5f (SE = %.5f)\n", int_coef, int_se))
    }, error = function(e) {
      cat(sprintf("FAILED: %s\n", e$message))
    })
  }
} else {
  cat("  Skipping interaction analysis (no partisanship variable)\n")
}

write_csv(het_interaction, "tables/het_interaction.csv")
cat("  Saved: tables/het_interaction.csv\n")

# ==============================================================================
# 6. COMPILE ALL HETEROGENEITY RESULTS
# ==============================================================================
cat("\n=== Compiling All Heterogeneity Results ===\n")

all_het <- bind_rows(
  het_partisanship %>% mutate(dimension = "Partisanship"),
  het_rurality %>% mutate(dimension = "Rurality"),
  het_moral %>% mutate(dimension = "Moral Orientation")
)

if (nrow(all_het) > 0) {
  cat("\n  Full Heterogeneity Summary:\n")
  all_het %>%
    select(dimension, outcome, subgroup, ATT, SE, p_value, sig, N_treated, N_clusters) %>%
    mutate(ATT = round(ATT, 5), SE = round(SE, 5), p_value = round(p_value, 4)) %>%
    print(n = Inf, width = Inf)

  write_csv(all_het, "tables/heterogeneity_summary.csv")
  cat("  Saved: tables/heterogeneity_summary.csv\n")
}

# All event study data for heterogeneity figures
all_het_es <- bind_rows(
  het_partisanship_es %>% mutate(dimension = "Partisanship"),
  het_rurality_es %>% mutate(dimension = "Rurality")
)

if (nrow(all_het_es) > 0) {
  write_csv(all_het_es, "data/het_event_study_data.csv")
  cat("  Saved: data/het_event_study_data.csv\n")
}

# Save all R objects
save(
  het_partisanship, het_partisanship_es,
  het_rurality, het_rurality_es,
  het_moral,
  het_interaction,
  all_het, all_het_es,
  file = "data/heterogeneity_results.RData"
)
cat("  Saved: data/heterogeneity_results.RData\n")

cat("\n========================================\n")
cat("  06_heterogeneity.R COMPLETE\n")
cat("========================================\n")
