# =============================================================================
# 09_fix_rdd_sample.R - Fix RDD Sample Construction
#
# This script addresses the methodological concern that the original RDD sample
# included municipalities from cantons that don't directly border an opposite-
# status canton. For a valid geographic boundary RDD, we need:
#   1. Only municipalities whose canton shares a border with opposite-status canton
#   2. Distance measured to the specific border segment between adjacent cantons
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
cat("FIXING RDD SAMPLE CONSTRUCTION\n")
cat(rep("=", 70), "\n\n")

# =============================================================================
# LOAD DATA
# =============================================================================

cat("Loading data...\n")

voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))
gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_spatial.rds"))

# Ensure gemeinde_sf has treatment status
if (!"treated" %in% names(gemeinde_sf)) {
  cat("Adding treatment status to gemeinde_sf...\n")
  gemeinde_sf <- gemeinde_sf %>%
    left_join(canton_treatment, by = "canton_abbr")
}

# Replace NA treatment with FALSE (control)
if (any(is.na(gemeinde_sf$treated))) {
  cat("Fixing NA treatment values in gemeinde_sf...\n")
  gemeinde_sf$treated <- coalesce(gemeinde_sf$treated, FALSE)
}

# Load or create canton boundaries
kanton_sf <- tryCatch({
  readRDS(file.path(data_dir, "canton_boundaries.rds"))
}, error = function(e) {
  cat("Creating canton boundaries from gemeinde...\n")
  gemeinde_sf %>%
    group_by(KTNR) %>%
    summarise(.groups = "drop")
})

# Canton lookup
canton_lookup <- tibble(
  KTNR = 1:26,
  canton_abbr = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
                  "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
                  "TI", "VD", "VS", "NE", "GE", "JU")
)

# Add canton info
kanton_sf <- kanton_sf %>%
  left_join(canton_lookup, by = "KTNR") %>%
  left_join(canton_treatment, by = "canton_abbr")

# Ensure treatment status is defined for all cantons
# Cantons not in canton_treatment are controls (treated = FALSE)
if (any(is.na(kanton_sf$treated))) {
  cat("WARNING: Some cantons missing treatment status, defaulting to control:\n")
  cat(paste(kanton_sf$canton_abbr[is.na(kanton_sf$treated)], collapse = ", "), "\n")
  kanton_sf$treated <- coalesce(kanton_sf$treated, FALSE)
}

# Debug: show treatment status
cat("\nCanton treatment status:\n")
kanton_sf %>%
  st_drop_geometry() %>%
  select(canton_abbr, treated) %>%
  arrange(desc(treated), canton_abbr) %>%
  print(n = 26)

# =============================================================================
# STEP 1: IDENTIFY CANTON ADJACENCIES
# =============================================================================

cat("\nStep 1: Identifying canton adjacencies...\n")

# Find which cantons share borders (touch each other)
canton_touches <- st_touches(kanton_sf)

# Create adjacency table
adjacency_list <- list()

for (i in seq_len(nrow(kanton_sf))) {
  canton_i <- kanton_sf$canton_abbr[i]
  treated_i <- kanton_sf$treated[i]
  neighbors <- canton_touches[[i]]

  for (j in neighbors) {
    canton_j <- kanton_sf$canton_abbr[j]
    treated_j <- kanton_sf$treated[j]

    # Only keep treated-control pairs (not treated-treated or control-control)
    if (treated_i != treated_j) {
      adjacency_list[[length(adjacency_list) + 1]] <- tibble(
        canton_treated = if(treated_i) canton_i else canton_j,
        canton_control = if(treated_i) canton_j else canton_i,
        border_pair = paste(sort(c(canton_i, canton_j)), collapse = "-")
      )
    }
  }
}

border_pairs <- bind_rows(adjacency_list) %>% distinct()

cat("\nTreated-Control Border Pairs:\n")
print(border_pairs)

# =============================================================================
# STEP 2: IDENTIFY WHICH CANTONS HAVE TREATED-CONTROL BORDERS
# =============================================================================

cat("\nStep 2: Cantons with treated-control borders...\n")

cantons_with_tc_border <- unique(c(border_pairs$canton_treated, border_pairs$canton_control))
cat("Cantons that can contribute to RDD:\n")
cat(paste(sort(cantons_with_tc_border), collapse = ", "), "\n")

# Basel-Stadt (BS) check
if ("BS" %in% cantons_with_tc_border) {
  cat("\nWARNING: Basel-Stadt appears in border list\n")
} else {
  cat("\nConfirmed: Basel-Stadt (BS) has NO treated-control border\n")
  cat("BS is surrounded by Basel-Landschaft (BL) which is also treated\n")
}

# =============================================================================
# STEP 3: COMPUTE BORDER-SPECIFIC DISTANCES
# =============================================================================

cat("\nStep 3: Computing border-specific distances...\n")

# For each border pair, extract the actual shared border geometry
border_geometries <- list()

# Get common CRS for all geometries
base_crs <- st_crs(kanton_sf)

for (i in seq_len(nrow(border_pairs))) {
  pair <- border_pairs[i, ]

  # Get the two canton polygons
  canton_a <- kanton_sf %>% filter(canton_abbr == pair$canton_treated)
  canton_b <- kanton_sf %>% filter(canton_abbr == pair$canton_control)

  # Find shared border (intersection of boundaries)
  border_line <- tryCatch({
    result <- st_intersection(st_boundary(canton_a), st_boundary(canton_b))
    # Drop Z coordinate if present (st_zm drops Z and M dimensions)
    st_zm(result, drop = TRUE, what = "ZM")
  }, error = function(e) {
    # Alternative: use st_intersection of the polygons themselves
    result <- st_cast(st_intersection(canton_a, canton_b), "MULTILINESTRING")
    st_zm(result, drop = TRUE, what = "ZM")
  })

  if (length(st_geometry(border_line)) > 0) {
    # Store just the geometry, not the sf object
    border_geometries[[pair$border_pair]] <- st_geometry(border_line)
    cat(paste("  ", pair$border_pair, ": border extracted\n"))
  } else {
    cat(paste("  ", pair$border_pair, ": NO BORDER FOUND\n"))
  }
}

# =============================================================================
# STEP 4: RESTRICT GEMEINDE SAMPLE
# =============================================================================

cat("\nStep 4: Restricting sample to eligible cantons...\n")

# Only keep gemeinden in cantons that have a treated-control border
gemeinde_eligible <- gemeinde_sf %>%
  filter(canton_abbr %in% cantons_with_tc_border)

cat(paste("Total gemeinden:", nrow(gemeinde_sf), "\n"))
cat(paste("Eligible gemeinden (in cantons with TC border):", nrow(gemeinde_eligible), "\n"))

# How many were excluded?
excluded <- gemeinde_sf %>%
  filter(!canton_abbr %in% cantons_with_tc_border) %>%
  group_by(canton_abbr, treated) %>%
  summarise(n = n(), .groups = "drop")

cat("\nExcluded cantons (no TC border):\n")
print(excluded)

# =============================================================================
# STEP 5: COMPUTE DISTANCE TO OWN CANTON'S BORDER
# =============================================================================

cat("\nStep 5: Computing distance to own canton's border...\n")

# For each eligible gemeinde, compute distance only to borders that
# involve its own canton

compute_border_distance <- function(gemeinde_row, border_geometries, border_pairs) {
  canton <- gemeinde_row$canton_abbr
  treated <- gemeinde_row$treated
  centroid <- st_point(c(gemeinde_row$centroid_x, gemeinde_row$centroid_y))
  centroid <- st_sfc(centroid, crs = st_crs(gemeinde_row$geometry))

  # Find border pairs involving this canton
  if (treated) {
    relevant_pairs <- border_pairs %>%
      filter(canton_treated == canton) %>%
      pull(border_pair)
  } else {
    relevant_pairs <- border_pairs %>%
      filter(canton_control == canton) %>%
      pull(border_pair)
  }

  if (length(relevant_pairs) == 0) {
    return(list(dist = NA, border_pair = NA))
  }

  # Compute distance to each relevant border
  distances <- map_dbl(relevant_pairs, function(bp) {
    if (!bp %in% names(border_geometries)) return(Inf)
    border <- border_geometries[[bp]]
    as.numeric(st_distance(centroid, border))
  })

  # Return minimum distance and corresponding border
  min_idx <- which.min(distances)
  list(
    dist = distances[min_idx],
    border_pair = relevant_pairs[min_idx]
  )
}

# Apply to all eligible gemeinden
cat("Computing distances (this may take a moment)...\n")

# For efficiency, do this in a vectorized way where possible
# First, create a lookup of which borders each canton has

canton_to_borders <- border_pairs %>%
  pivot_longer(cols = c(canton_treated, canton_control),
               names_to = "type", values_to = "canton") %>%
  group_by(canton) %>%
  summarise(borders = list(unique(border_pair)), .groups = "drop")

# Get common CRS from kanton_sf (used for border geometries)
common_crs <- st_crs(kanton_sf)
cat(paste("Using CRS:", common_crs$input, "\n"))

# Process each gemeinde
results <- list()
pb <- txtProgressBar(min = 0, max = nrow(gemeinde_eligible), style = 3)

for (i in seq_len(nrow(gemeinde_eligible))) {
  row <- gemeinde_eligible[i, ]
  canton <- row$canton_abbr

  # Get borders for this canton
  canton_borders <- canton_to_borders %>%
    filter(canton == !!canton) %>%
    pull(borders) %>%
    unlist()

  if (length(canton_borders) == 0 || is.null(canton_borders)) {
    results[[i]] <- tibble(
      mun_id = row$mun_id,
      dist_to_own_border = NA_real_,
      nearest_border_pair = NA_character_
    )
  } else {
    # Compute distance to each border using gemeinde centroid
    # Drop Z coordinates and use 2D geometry for distance computation
    gemeinde_geom <- st_geometry(row)
    gemeinde_geom <- st_zm(gemeinde_geom, drop = TRUE, what = "ZM")
    gemeinde_geom <- st_set_crs(gemeinde_geom, common_crs)
    centroid_sf <- st_centroid(gemeinde_geom)

    dists <- map_dbl(canton_borders, function(bp) {
      if (!bp %in% names(border_geometries)) return(Inf)
      as.numeric(st_distance(centroid_sf, border_geometries[[bp]]))
    })

    min_idx <- which.min(dists)

    results[[i]] <- tibble(
      mun_id = row$mun_id,
      dist_to_own_border = dists[min_idx] / 1000,  # Convert to km
      nearest_border_pair = canton_borders[min_idx]
    )
  }

  setTxtProgressBar(pb, i)
}
close(pb)

border_distances <- bind_rows(results)

cat(paste("\nComputed distances for", sum(!is.na(border_distances$dist_to_own_border)),
          "gemeinden\n"))

# =============================================================================
# STEP 6: CREATE CORRECTED RDD SAMPLE
# =============================================================================

cat("\nStep 6: Creating corrected RDD sample...\n")

# Merge with voting data
voting_eligible <- voting_data %>%
  filter(vote_type == "energy_2017") %>%
  filter(canton_abbr %in% cantons_with_tc_border) %>%
  left_join(border_distances, by = "mun_id") %>%
  filter(!is.na(dist_to_own_border))

# Sign the distance
voting_eligible <- voting_eligible %>%
  mutate(
    signed_distance_km = if_else(treated, dist_to_own_border, -dist_to_own_border),
    treat = treated
  )

cat(paste("Corrected RDD sample size:", nrow(voting_eligible), "\n"))

# Summary by treatment
cat("\nSample distribution:\n")
voting_eligible %>%
  group_by(treated) %>%
  summarise(
    n = n(),
    mean_dist_km = mean(dist_to_own_border),
    mean_yes = mean(yes_share, na.rm = TRUE)
  ) %>%
  print()

# Summary by border pair
cat("\nBy border pair:\n")
voting_eligible %>%
  group_by(nearest_border_pair, treated) %>%
  summarise(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = treated, values_from = n, names_prefix = "treated_") %>%
  print()

# =============================================================================
# STEP 7: RUN CORRECTED RDD
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("CORRECTED RDD RESULTS\n")
cat(rep("=", 60), "\n")

# Define bandwidth for near-border sample
bandwidth <- 20  # km

near_border_corrected <- voting_eligible %>%
  filter(dist_to_own_border <= bandwidth)

cat(paste("\nNear-border sample (within", bandwidth, "km):",
          nrow(near_border_corrected), "\n"))

# RDD with rdrobust
cat("\n--- Corrected Pooled RDD ---\n")
rdd_corrected <- rdrobust(
  y = near_border_corrected$yes_share,
  x = near_border_corrected$signed_distance_km,
  c = 0
)

cat(paste("Estimate:", round(rdd_corrected$coef[1], 2), "pp\n"))
cat(paste("SE:", round(rdd_corrected$se[1], 2), "\n"))
cat(paste("p-value:", round(rdd_corrected$pv[1], 3), "\n"))
cat(paste("95% CI: [", round(rdd_corrected$ci[1,1], 2), ",",
          round(rdd_corrected$ci[1,2], 2), "]\n"))
cat(paste("Bandwidth:", round(rdd_corrected$bws[1], 1), "km\n"))
cat(paste("N (left, right):", rdd_corrected$N[1], ",", rdd_corrected$N[2], "\n"))

# Same-language borders
cat("\n--- Corrected Same-Language RDD ---\n")

# Identify same-language border pairs (German-German)
german_cantons <- c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG",
                    "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG")

same_lang_pairs <- border_pairs %>%
  filter(
    canton_treated %in% german_cantons,
    canton_control %in% german_cantons
  ) %>%
  pull(border_pair)

cat("Same-language border pairs:\n")
cat(paste(same_lang_pairs, collapse = ", "), "\n\n")

same_lang_sample <- near_border_corrected %>%
  filter(nearest_border_pair %in% same_lang_pairs)

cat(paste("Same-language sample size:", nrow(same_lang_sample), "\n"))

if (nrow(same_lang_sample) >= 50) {
  rdd_same_lang <- rdrobust(
    y = same_lang_sample$yes_share,
    x = same_lang_sample$signed_distance_km,
    c = 0
  )

  cat(paste("Estimate:", round(rdd_same_lang$coef[1], 2), "pp\n"))
  cat(paste("SE:", round(rdd_same_lang$se[1], 2), "\n"))
  cat(paste("p-value:", round(rdd_same_lang$pv[1], 3), "\n"))
  cat(paste("95% CI: [", round(rdd_same_lang$ci[1,1], 2), ",",
            round(rdd_same_lang$ci[1,2], 2), "]\n"))
  cat(paste("Bandwidth:", round(rdd_same_lang$bws[1], 1), "km\n"))
  cat(paste("N (left, right):", rdd_same_lang$N[1], ",", rdd_same_lang$N[2], "\n"))
} else {
  cat("Insufficient sample for same-language RDD\n")
  rdd_same_lang <- NULL
}

# =============================================================================
# STEP 8: BORDER-PAIR SPECIFIC ESTIMATES
# =============================================================================

cat("\n--- Border-Pair Specific Estimates ---\n")

border_pair_results <- map_dfr(unique(voting_eligible$nearest_border_pair), function(bp) {
  if (is.na(bp)) return(NULL)

  sample_bp <- near_border_corrected %>%
    filter(nearest_border_pair == bp)

  if (nrow(sample_bp) < 30) {
    return(tibble(
      border_pair = bp,
      estimate = NA_real_,
      se = NA_real_,
      pvalue = NA_real_,
      n = nrow(sample_bp)
    ))
  }

  rd <- tryCatch({
    rdrobust(
      y = sample_bp$yes_share,
      x = sample_bp$signed_distance_km,
      c = 0
    )
  }, error = function(e) NULL)

  if (is.null(rd)) {
    return(tibble(
      border_pair = bp,
      estimate = NA_real_,
      se = NA_real_,
      pvalue = NA_real_,
      n = nrow(sample_bp)
    ))
  }

  tibble(
    border_pair = bp,
    estimate = rd$coef[1],
    se = rd$se[1],
    pvalue = rd$pv[1],
    n = sum(rd$N),
    bandwidth = rd$bws[1]
  )
})

print(border_pair_results)

# =============================================================================
# STEP 9: SAVE CORRECTED DATA
# =============================================================================

cat("\nSaving corrected data...\n")

# Save corrected RDD sample
saveRDS(voting_eligible, file.path(data_dir, "rdd_sample_corrected.rds"))
saveRDS(border_pairs, file.path(data_dir, "border_pairs_verified.rds"))
saveRDS(border_distances, file.path(data_dir, "border_distances_corrected.rds"))

# Save results summary
corrected_results <- list(
  pooled = list(
    estimate = rdd_corrected$coef[1],
    se = rdd_corrected$se[1],
    pvalue = rdd_corrected$pv[1],
    ci = rdd_corrected$ci[1,],
    n = sum(rdd_corrected$N),
    bandwidth = rdd_corrected$bws[1]
  ),
  same_language = if(!is.null(rdd_same_lang)) list(
    estimate = rdd_same_lang$coef[1],
    se = rdd_same_lang$se[1],
    pvalue = rdd_same_lang$pv[1],
    ci = rdd_same_lang$ci[1,],
    n = sum(rdd_same_lang$N),
    bandwidth = rdd_same_lang$bws[1]
  ) else NULL,
  border_pairs = border_pair_results,
  sample_construction = list(
    total_gemeinden = nrow(gemeinde_sf),
    eligible_gemeinden = nrow(gemeinde_eligible),
    excluded_cantons = excluded,
    cantons_with_tc_border = cantons_with_tc_border
  )
)

saveRDS(corrected_results, file.path(data_dir, "rdd_results_corrected.rds"))

# Save summary table for paper
write_csv(
  tibble(
    specification = c("Corrected Pooled", "Corrected Same-Language"),
    estimate = c(rdd_corrected$coef[1],
                 if(!is.null(rdd_same_lang)) rdd_same_lang$coef[1] else NA),
    se = c(rdd_corrected$se[1],
           if(!is.null(rdd_same_lang)) rdd_same_lang$se[1] else NA),
    pvalue = c(rdd_corrected$pv[1],
               if(!is.null(rdd_same_lang)) rdd_same_lang$pv[1] else NA),
    n = c(sum(rdd_corrected$N),
          if(!is.null(rdd_same_lang)) sum(rdd_same_lang$N) else NA),
    bandwidth = c(rdd_corrected$bws[1],
                  if(!is.null(rdd_same_lang)) rdd_same_lang$bws[1] else NA)
  ),
  file.path(tab_dir, "rdd_corrected_results.csv")
)

write_csv(border_pair_results, file.path(tab_dir, "border_pair_estimates.csv"))

# =============================================================================
# STEP 10: ACCOUNTING TABLE
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SAMPLE ACCOUNTING TABLE\n")
cat(rep("=", 60), "\n")

accounting <- voting_eligible %>%
  group_by(canton_abbr, treated) %>%
  summarise(
    n_gemeinden = n(),
    n_in_bandwidth = sum(dist_to_own_border <= rdd_corrected$bws[1]),
    .groups = "drop"
  ) %>%
  arrange(desc(treated), canton_abbr)

cat("\nGemeinden in RDD sample by canton:\n")
print(accounting)

write_csv(accounting, file.path(tab_dir, "rdd_sample_accounting.csv"))

cat("\n", rep("=", 70), "\n")
cat("CORRECTED RDD ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n")

cat("\nKey findings:\n")
cat(paste("1. Basel-Stadt correctly excluded (no TC border)\n"))
cat(paste("2. Sample restricted to", length(cantons_with_tc_border),
          "cantons with TC borders\n"))
cat(paste("3. Distance computed to each gemeinde's OWN canton border\n"))
cat(paste("4. Pooled estimate:", round(rdd_corrected$coef[1], 2),
          "pp (p =", round(rdd_corrected$pv[1], 3), ")\n"))
if (!is.null(rdd_same_lang)) {
  cat(paste("5. Same-language estimate:", round(rdd_same_lang$coef[1], 2),
            "pp (p =", round(rdd_same_lang$pv[1], 3), ")\n"))
}
