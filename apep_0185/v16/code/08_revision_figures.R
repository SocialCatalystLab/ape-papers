################################################################################
# 08_revision_figures.R
# Social Network Minimum Wage Exposure - REVISION FIGURES
#
# Creates two instrument residual maps showing within-state variation:
#   Map A: Unconstrained out-of-state instrument (residualized from state FE)
#   Map B: Distance-constrained instrument (>=500 km, residualized from state FE)
#
# Input:  ../data/analysis_panel.rds, ../data/raw_counties_sf.rds
# Output: ../figures/fig_iv_residuals.pdf (side-by-side)
#         ../figures/fig_iv_residual_unconstrained.pdf
#         ../figures/fig_iv_residual_constrained.pdf
################################################################################

source("00_packages.R")

# Ensure spatial and composition packages are loaded
if (!require("sf")) install.packages("sf")
if (!require("patchwork")) install.packages("patchwork")
library(sf)
library(patchwork)

cat("=== Revision Figures: Instrument Residual Maps ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading analysis panel and county shapefiles...\n")

panel <- readRDS("../data/analysis_panel.rds")

# Load county shapefile
if (file.exists("../data/raw_counties_sf.rds")) {
  counties_sf <- readRDS("../data/raw_counties_sf.rds")
} else {
  cat("  Downloading county shapefiles from tigris...\n")
  if (!require("tigris")) install.packages("tigris")
  library(tigris)
  options(tigris_use_cache = TRUE)
  counties_sf <- counties(cb = TRUE, year = 2020)
  counties_sf <- counties_sf %>%
    mutate(fips = paste0(STATEFP, COUNTYFP))
  saveRDS(counties_sf, "../data/raw_counties_sf.rds")
}

cat("  Panel:", format(nrow(panel), big.mark = ","), "observations\n")
cat("  Counties in shapefile:", nrow(counties_sf), "\n\n")

# Create figures directory
dir.create("../figures", showWarnings = FALSE)

# ============================================================================
# 2. Compute Residual Instrument Variation (Within-State)
# ============================================================================

cat("2. Computing within-state residual IV variation...\n\n")

# For each county, compute mean IV across all time periods
# Then subtract the state mean to get within-state residual

# --- Map A: Unconstrained out-of-state instrument ---
cat("  Map A: Unconstrained out-of-state instrument...\n")

county_iv_unconstrained <- panel %>%
  filter(!is.na(network_mw_pop_out_state) & !is.na(state_fips)) %>%
  group_by(county_fips, state_fips) %>%
  summarise(
    county_mean_iv = mean(network_mw_pop_out_state, na.rm = TRUE),
    .groups = "drop"
  )

# Compute state means
state_means_unconstrained <- county_iv_unconstrained %>%
  group_by(state_fips) %>%
  summarise(
    state_mean_iv = mean(county_mean_iv, na.rm = TRUE),
    .groups = "drop"
  )

# Residualize: county mean minus state mean
county_iv_unconstrained <- county_iv_unconstrained %>%
  left_join(state_means_unconstrained, by = "state_fips") %>%
  mutate(iv_residual = county_mean_iv - state_mean_iv)

cat("    Counties:", nrow(county_iv_unconstrained), "\n")
cat("    Residual range:", round(min(county_iv_unconstrained$iv_residual, na.rm = TRUE), 4),
    "to", round(max(county_iv_unconstrained$iv_residual, na.rm = TRUE), 4), "\n")
cat("    Residual SD:", round(sd(county_iv_unconstrained$iv_residual, na.rm = TRUE), 4), "\n")

# --- Map B: Distance-constrained instrument (>=500 km) ---
cat("  Map B: Distance-constrained instrument (>=500 km)...\n")

iv_500_col <- "iv_pop_dist_500"

if (iv_500_col %in% names(panel)) {
  county_iv_constrained <- panel %>%
    filter(!is.na(.data[[iv_500_col]]) & !is.na(state_fips)) %>%
    group_by(county_fips, state_fips) %>%
    summarise(
      county_mean_iv = mean(.data[[iv_500_col]], na.rm = TRUE),
      .groups = "drop"
    )

  # Compute state means
  state_means_constrained <- county_iv_constrained %>%
    group_by(state_fips) %>%
    summarise(
      state_mean_iv = mean(county_mean_iv, na.rm = TRUE),
      .groups = "drop"
    )

  # Residualize
  county_iv_constrained <- county_iv_constrained %>%
    left_join(state_means_constrained, by = "state_fips") %>%
    mutate(iv_residual = county_mean_iv - state_mean_iv)

  cat("    Counties:", nrow(county_iv_constrained), "\n")
  cat("    Residual range:", round(min(county_iv_constrained$iv_residual, na.rm = TRUE), 4),
      "to", round(max(county_iv_constrained$iv_residual, na.rm = TRUE), 4), "\n")
  cat("    Residual SD:", round(sd(county_iv_constrained$iv_residual, na.rm = TRUE), 4), "\n")
} else {
  cat("    WARNING: iv_pop_dist_500 not found in panel. Skipping constrained map.\n")
  county_iv_constrained <- NULL
}

# ============================================================================
# 3. Merge with County Geography
# ============================================================================

cat("\n3. Merging with county geography...\n")

# Determine the FIPS join column in the shapefile
fips_col <- if ("fips" %in% names(counties_sf)) "fips" else
            if ("GEOID" %in% names(counties_sf)) "GEOID" else
            stop("Cannot find FIPS column in counties_sf")

cat("  Using shapefile FIPS column:", fips_col, "\n")

# Filter to continental US (exclude AK=02, HI=15, territories)
territory_fips <- c("02", "15", "72", "78", "60", "66", "69")

counties_cont <- counties_sf %>%
  filter(!STATEFP %in% territory_fips)

cat("  Continental US counties:", nrow(counties_cont), "\n")

# Merge unconstrained residuals
map_unconstrained <- counties_cont %>%
  left_join(
    county_iv_unconstrained %>% select(county_fips, iv_residual),
    by = setNames("county_fips", fips_col)
  )

# Merge constrained residuals
if (!is.null(county_iv_constrained)) {
  map_constrained <- counties_cont %>%
    left_join(
      county_iv_constrained %>% select(county_fips, iv_residual),
      by = setNames("county_fips", fips_col)
    )
}

# ============================================================================
# 4. Determine Common Color Scale
# ============================================================================

cat("\n4. Setting up diverging color scale...\n")

# Use a symmetric scale centered at 0
all_residuals <- county_iv_unconstrained$iv_residual
if (!is.null(county_iv_constrained)) {
  all_residuals <- c(all_residuals, county_iv_constrained$iv_residual)
}

# Use 95th percentile to set limits (avoid outlier distortion)
q_abs <- quantile(abs(all_residuals), 0.95, na.rm = TRUE)
scale_limit <- ceiling(q_abs * 100) / 100  # round up to nearest 0.01

cat("  95th percentile |residual|:", round(q_abs, 4), "\n")
cat("  Color scale limits: [-", scale_limit, ",", scale_limit, "]\n")

# ============================================================================
# 5. Create Maps
# ============================================================================

cat("\n5. Creating instrument residual maps...\n")

# Common theme for maps
map_theme <- theme_void(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 11, hjust = 0.5),
    plot.subtitle = element_text(size = 9, color = "gray30", hjust = 0.5),
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    legend.key.height = unit(0.3, "cm"),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    plot.margin = margin(5, 5, 5, 5)
  )

# --- Map A: Unconstrained ---
cat("  Creating Map A (unconstrained)...\n")

map_a <- ggplot(map_unconstrained) +
  geom_sf(aes(fill = iv_residual), color = NA, size = 0) +
  scale_fill_gradient2(
    low = "#d73027",       # Red for below state average
    mid = "white",
    high = "#4575b4",      # Blue for above state average
    midpoint = 0,
    name = "Residual IV",
    limits = c(-scale_limit, scale_limit),
    oob = scales::squish,
    na.value = "gray90"
  ) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  labs(
    title = "Panel A: Unconstrained Out-of-State Instrument"
  ) +
  map_theme

# --- Map B: Constrained (>=500 km) ---
map_b <- NULL
if (!is.null(county_iv_constrained)) {
  cat("  Creating Map B (constrained >=500 km)...\n")

  map_b <- ggplot(map_constrained) +
    geom_sf(aes(fill = iv_residual), color = NA, size = 0) +
    scale_fill_gradient2(
      low = "#d73027",
      mid = "white",
      high = "#4575b4",
      midpoint = 0,
      name = "Residual IV",
      limits = c(-scale_limit, scale_limit),
      oob = scales::squish,
      na.value = "gray90"
    ) +
    coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
    labs(
      title = "Panel B: Distance-Constrained Instrument (>=500 km)"
    ) +
    map_theme
}

# ============================================================================
# 6. Compose and Save
# ============================================================================

cat("\n6. Saving figures...\n")

# Save individual maps
ggsave("../figures/fig_iv_residual_unconstrained.pdf", map_a,
       width = 10, height = 6, device = cairo_pdf)
cat("  Saved fig_iv_residual_unconstrained.pdf\n")

if (!is.null(map_b)) {
  ggsave("../figures/fig_iv_residual_constrained.pdf", map_b,
         width = 10, height = 6, device = cairo_pdf)
  cat("  Saved fig_iv_residual_constrained.pdf\n")

  # Compose side-by-side with patchwork
  fig_combined <- map_a + map_b +
    plot_annotation(
      title = "Within-State Residual Variation in the Instrumental Variable",
      subtitle = "Residuals from state fixed effects. Blue = above-state-average IV exposure; Red = below. N = 3,108 counties.",
      theme = theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
        plot.subtitle = element_text(size = 10, color = "gray30", hjust = 0.5),
        plot.margin = margin(10, 10, 10, 10)
      )
    )

  ggsave("../figures/fig_iv_residuals.pdf", fig_combined,
         width = 14, height = 6, device = cairo_pdf)
  cat("  Saved fig_iv_residuals.pdf (side-by-side, 14 x 6 inches)\n")
} else {
  cat("  Skipping combined figure (constrained map not available)\n")
}

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Revision Figures Complete ===\n\n")
cat("Generated files:\n")
cat("  ../figures/fig_iv_residual_unconstrained.pdf\n")
if (!is.null(map_b)) {
  cat("  ../figures/fig_iv_residual_constrained.pdf\n")
  cat("  ../figures/fig_iv_residuals.pdf (combined)\n")
}
cat("\nThese maps show within-state variation in the instrument,\n")
cat("demonstrating that the IV exploits WITHIN-state differences\n")
cat("in network connections to high-MW areas, not just across-state\n")
cat("differences absorbed by state fixed effects.\n")
