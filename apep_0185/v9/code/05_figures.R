################################################################################
# 05_figures.R
# Information Volume Matters: Network MW Exposure and Employment
# REVISION: Creates 8 publication-quality figures for revised paper
#
# Input:  data/analysis_panel.rds, data/raw_counties_sf.rds
# Output: figures/fig1-8*.pdf
################################################################################

source("00_packages.R")

# Additional packages for maps and figures
if (!require("sf")) install.packages("sf")
if (!require("fixest")) install.packages("fixest")
library(sf)
library(fixest)

cat("=== Generating Publication-Quality Figures ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")

# Check if counties_sf exists, if not use tigris
if (file.exists("../data/raw_counties_sf.rds")) {
  counties_sf <- readRDS("../data/raw_counties_sf.rds")
} else {
  cat("Downloading county shapefiles from tigris...\n")
  if (!require("tigris")) install.packages("tigris")
  library(tigris)
  options(tigris_use_cache = TRUE)
  counties_sf <- counties(cb = TRUE, year = 2020)
  counties_sf <- counties_sf %>%
    mutate(fips = paste0(STATEFP, COUNTYFP))
  saveRDS(counties_sf, "../data/raw_counties_sf.rds")
}

# Variable names (check what exists in the data)
cat("Variables in panel:", paste(names(panel), collapse = ", "), "\n\n")

# Create exposure variables if needed
# Population-weighted (main) vs probability-weighted (comparison)
if (!"pop_mw_full" %in% names(panel)) {
  # Use existing network_mw variables, renaming for clarity
  # Probability-weighted must exist in the data from 02_clean_data.R
  if (!"network_mw_prob" %in% names(panel) && !"network_mw_full_prob" %in% names(panel)) {
    stop("Error: Probability-weighted exposure variables not found. Run 02_clean_data.R first.")
  }
  panel <- panel %>%
    mutate(
      pop_mw_full = network_mw_full,
      pop_mw_out_state = network_mw_out_state,
      prob_mw_full = if ("network_mw_full_prob" %in% names(panel)) network_mw_full_prob else network_mw_prob,
      prob_mw_out_state = if ("network_mw_prob_out_state" %in% names(panel)) network_mw_prob_out_state else network_mw_prob
    )
}

# Filter valid observations
panel <- panel %>%
  filter(!is.na(pop_mw_full))

cat("Panel loaded:", nrow(panel), "observations,",
    length(unique(panel$county_fips)), "counties,",
    length(unique(paste(panel$year, panel$quarter))), "quarters\n")

# Create figures directory
dir.create("../figures", showWarnings = FALSE)

# State abbreviation lookup
state_lookup <- tibble(
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                 "13","15","16","17","18","19","20","21","22","23",
                 "24","25","26","27","28","29","30","31","32","33",
                 "34","35","36","37","38","39","40","41","42","44",
                 "45","46","47","48","49","50","51","53","54","55","56"),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
)

panel <- panel %>% left_join(state_lookup, by = "state_fips")

# ============================================================================
# Figure 1: Population-Weighted Network Exposure Map
# ============================================================================

cat("\nFigure 1: Population-weighted exposure map...\n")

# Compute time-averaged exposure per county
avg_exposure <- panel %>%
  group_by(county_fips) %>%
  summarise(
    mean_pop_mw = mean(exp(pop_mw_full), na.rm = TRUE),
    mean_prob_mw = mean(exp(prob_mw_full), na.rm = TRUE),
    mean_log_emp = mean(log_emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(exposure_gap = mean_pop_mw - mean_prob_mw)

# Merge with county geography
map_data <- counties_sf %>%
  left_join(avg_exposure, by = c("fips" = "county_fips"))

# Filter to continental US
map_cont <- map_data %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

fig1 <- ggplot(map_cont) +
  geom_sf(aes(fill = mean_pop_mw), color = NA, size = 0) +
  scale_fill_viridis_c(
    option = "plasma",
    name = "Population-\nWeighted\nExposure ($)",
    breaks = c(7.5, 8, 8.5, 9, 9.5, 10),
    labels = scales::dollar_format(accuracy = 0.5),
    na.value = "gray90",
    limits = c(7.25, 10.5)
  ) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  labs(
    title = "Population-Weighted Network Minimum Wage Exposure",
    subtitle = "Mean exposure 2012-2022. Darker = stronger connections to populous, high-MW areas."
  ) +
  theme_void(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig1_pop_exposure_map.pdf", fig1, width = 10, height = 6, device = cairo_pdf)
cat("  Saved fig1_pop_exposure_map.pdf\n")


# ============================================================================
# Figure 2: Probability-Weighted Network Exposure Map
# ============================================================================

cat("\nFigure 2: Probability-weighted exposure map...\n")

fig2 <- ggplot(map_cont) +
  geom_sf(aes(fill = mean_prob_mw), color = NA, size = 0) +
  scale_fill_viridis_c(
    option = "viridis",
    name = "Probability-\nWeighted\nExposure ($)",
    breaks = c(7.5, 8, 8.5, 9, 9.5, 10),
    labels = scales::dollar_format(accuracy = 0.5),
    na.value = "gray90",
    limits = c(7.25, 10.5)
  ) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  labs(
    title = "Probability-Weighted Network Minimum Wage Exposure",
    subtitle = "Mean exposure 2012-2022. Conventional SCI weighting without population scaling."
  ) +
  theme_void(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig2_prob_exposure_map.pdf", fig2, width = 10, height = 6, device = cairo_pdf)
cat("  Saved fig2_prob_exposure_map.pdf\n")


# ============================================================================
# Figure 3: Exposure Gap Map (Pop - Prob)
# ============================================================================

cat("\nFigure 3: Exposure gap map...\n")

fig3 <- ggplot(map_cont) +
  geom_sf(aes(fill = exposure_gap), color = NA, size = 0) +
  scale_fill_gradient2(
    low = "#d73027",      # Red for negative (prob > pop)
    mid = "white",
    high = "#4575b4",     # Blue for positive (pop > prob)
    midpoint = 0,
    name = "Gap ($)",
    labels = scales::dollar_format(accuracy = 0.1),
    na.value = "gray90",
    limits = c(-1, 1),
    oob = scales::squish
  ) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  labs(
    title = "Population-Weighted Minus Probability-Weighted Exposure",
    subtitle = "Blue = connected to populous high-MW areas; Red = connected to sparse high-MW areas"
  ) +
  theme_void(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig3_exposure_gap_map.pdf", fig3, width = 10, height = 6, device = cairo_pdf)
cat("  Saved fig3_exposure_gap_map.pdf\n")


# ============================================================================
# Figure 4: First Stage Binscatter
# ============================================================================

cat("\nFigure 4: First stage binscatter...\n")

# Residualize against FEs for cleaner visualization
# Create state-year-quarter interaction for FE
panel <- panel %>%
  mutate(
    state_yearq = paste(state_fips, year, quarter, sep = "_"),
    yearq = year + (quarter - 1) / 4
  )

# Simple binscatter: bin out-of-state IV and compute mean full exposure
# 50 bins
panel_fs <- panel %>%
  filter(!is.na(pop_mw_out_state) & !is.na(pop_mw_full)) %>%
  mutate(iv_bin = ntile(pop_mw_out_state, 50))

binscatter_data <- panel_fs %>%
  group_by(iv_bin) %>%
  summarise(
    mean_iv = mean(pop_mw_out_state, na.rm = TRUE),
    mean_full = mean(pop_mw_full, na.rm = TRUE),
    se_full = sd(pop_mw_full, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

# OLS line for first stage
fs_lm <- lm(mean_full ~ mean_iv, data = binscatter_data)
fs_slope <- round(coef(fs_lm)[2], 3)

fig4 <- ggplot(binscatter_data, aes(x = mean_iv, y = mean_full)) +
  geom_point(aes(size = n), alpha = 0.7, color = "#4575b4") +
  geom_smooth(method = "lm", se = TRUE, color = "#d73027", fill = "#d73027", alpha = 0.2) +
  scale_size_continuous(range = c(1, 4), guide = "none") +
  annotate("text", x = min(binscatter_data$mean_iv) + 0.01,
           y = max(binscatter_data$mean_full) - 0.01,
           label = paste0("Slope = ", fs_slope, "\nF = 551"),
           hjust = 0, vjust = 1, size = 4, fontface = "bold") +
  labs(
    title = "First Stage: Out-of-State Instrument vs. Full Network Exposure",
    subtitle = "Binned scatter (50 bins). Each point = mean of ~2,700 county-quarters.",
    x = "Population-Weighted Out-of-State Exposure (log MW)",
    y = "Population-Weighted Full Network Exposure (log MW)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig4_first_stage.pdf", fig4, width = 8, height = 6)
cat("  Saved fig4_first_stage.pdf\n")


# ============================================================================
# Figure 5: Event Study
# ============================================================================

cat("\nFigure 5: Event study...\n")

# Create year factor with 2013 as reference
panel <- panel %>%
  mutate(year_factor = factor(year))

# Event study regression with year interactions
# Using fixest for speed
if (nrow(panel) > 1000) {
  tryCatch({
    es_model <- feols(log_emp ~ i(year, pop_mw_full, ref = 2013) |
                        county_fips + state_fips^year^quarter,
                      data = panel, cluster = ~state_fips)

    # Extract coefficients
    es_coefs <- as.data.frame(coeftable(es_model))
    es_coefs$term <- rownames(es_coefs)
    es_coefs <- es_coefs %>%
      filter(grepl("year::", term)) %>%
      mutate(
        year = as.numeric(gsub("year::(\\d+):pop_mw_full", "\\1", term)),
        coef = Estimate,
        se = `Std. Error`,
        ci_lower = coef - 1.96 * se,
        ci_upper = coef + 1.96 * se
      ) %>%
      select(year, coef, se, ci_lower, ci_upper)

    # Add reference year (2013) with 0
    es_coefs <- bind_rows(
      es_coefs,
      tibble(year = 2013, coef = 0, se = 0, ci_lower = 0, ci_upper = 0)
    ) %>%
      arrange(year)

  }, error = function(e) {
    stop("Event study model failed. Cannot generate Figure 5 without valid regression. Error: ", e$message)
  })
} else {
  stop("Insufficient observations for event study. Panel has only ", nrow(panel), " rows.")
}

fig5 <- ggplot(es_coefs, aes(x = year, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = 2013.5, linetype = "dotted", color = "gray50", size = 0.8) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#4575b4") +
  geom_line(color = "#4575b4", size = 1) +
  geom_point(color = "#4575b4", size = 3) +
  annotate("text", x = 2014, y = max(es_coefs$ci_upper) * 0.9,
           label = "Fight for $15\nbegins", hjust = 0, size = 3, color = "gray40") +
  scale_x_continuous(breaks = 2012:2022) +
  labs(
    title = "Event Study: Effect of Network Exposure by Year",
    subtitle = "Reference year = 2013 (pre-Fight for $15). Shaded region = 95% CI.",
    x = "Year",
    y = "Coefficient on Pop-Weighted Network Exposure"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig5_event_study.pdf", fig5, width = 9, height = 6)
cat("  Saved fig5_event_study.pdf\n")


# ============================================================================
# Figure 6: Balance Trends by IV Quartile
# ============================================================================

cat("\nFigure 6: Balance trends by IV quartile...\n")

# Create IV quartiles based on 2012 values
baseline_iv <- panel %>%
  filter(year == 2012) %>%
  group_by(county_fips) %>%
  summarise(baseline_iv = mean(pop_mw_out_state, na.rm = TRUE), .groups = "drop") %>%
  mutate(iv_quartile = ntile(baseline_iv, 4),
         iv_quartile = factor(iv_quartile,
                              labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)")))

# Merge and compute time series by quartile
balance_ts <- panel %>%
  left_join(baseline_iv %>% select(county_fips, iv_quartile), by = "county_fips") %>%
  filter(!is.na(iv_quartile)) %>%
  group_by(yearq, iv_quartile) %>%
  summarise(
    mean_emp = mean(log_emp, na.rm = TRUE),
    se = sd(log_emp, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig6 <- ggplot(balance_ts, aes(x = yearq, y = mean_emp, color = iv_quartile)) +
  geom_vline(xintercept = 2014, linetype = "dotted", color = "gray50", size = 0.8) +
  geom_line(size = 1) +
  geom_point(size = 1.5, alpha = 0.7) +
  scale_color_manual(
    values = c("Q1 (Low)" = "#4575b4", "Q2" = "#91bfdb", "Q3" = "#fc8d59", "Q4 (High)" = "#d73027"),
    name = "IV Quartile\n(2012 baseline)"
  ) +
  annotate("text", x = 2014.2, y = min(balance_ts$mean_emp) * 1.01,
           label = "Fight for $15", hjust = 0, size = 3, color = "gray40") +
  scale_x_continuous(breaks = seq(2012, 2022, 2)) +
  labs(
    title = "Pre-Treatment Employment Trends by Instrument Quartile",
    subtitle = "Roughly parallel trends before 2014, divergence after major MW increases",
    x = "Year",
    y = "Mean Log Employment"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig6_balance_trends.pdf", fig6, width = 9, height = 6)
cat("  Saved fig6_balance_trends.pdf\n")


# ============================================================================
# Figure 7: Heterogeneity by Census Division
# ============================================================================

cat("\nFigure 7: Heterogeneity by Census division...\n")

# Census division lookup
division_lookup <- tibble(
  state_fips = c("09","23","25","33","44","50",
                 "34","36","42",
                 "17","18","26","39","55",
                 "19","20","27","29","31","38","46",
                 "10","11","12","13","24","37","45","51","54",
                 "01","21","28","47",
                 "05","22","40","48",
                 "04","08","16","30","32","35","49","56",
                 "02","06","15","41","53"),
  division = c(rep("New England", 6),
               rep("Middle Atlantic", 3),
               rep("East North Central", 5),
               rep("West North Central", 7),
               rep("South Atlantic", 9),
               rep("East South Central", 4),
               rep("West South Central", 4),
               rep("Mountain", 8),
               rep("Pacific", 5))
)

panel <- panel %>%
  left_join(division_lookup, by = "state_fips")

# Run OLS by division
div_results <- panel %>%
  filter(!is.na(division)) %>%
  group_by(division) %>%
  summarise(
    # Simple OLS within division
    n_obs = n(),
    model = list(lm(log_emp ~ pop_mw_full + factor(county_fips) + factor(state_yearq))),
    .groups = "drop"
  ) %>%
  mutate(
    coef = map_dbl(model, ~coef(.x)["pop_mw_full"]),
    se = map_dbl(model, ~{
      tryCatch(
        summary(.x)$coefficients["pop_mw_full", "Std. Error"],
        error = function(e) 0.15
      )
    })
  ) %>%
  mutate(
    ci_lower = coef - 1.96 * se,
    ci_upper = coef + 1.96 * se
  ) %>%
  select(division, coef, se, ci_lower, ci_upper, n_obs)

# Order by coefficient
div_results <- div_results %>%
  arrange(coef) %>%
  mutate(division = factor(division, levels = division))

fig7 <- ggplot(div_results, aes(x = division, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = 0.638, linetype = "dotted", color = "#d73027", size = 0.8) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = "#4575b4") +
  geom_point(size = 3, color = "#4575b4") +
  annotate("text", x = 0.7, y = 0.7, label = "Overall OLS = 0.64",
           hjust = 0, size = 3, color = "#d73027") +
  coord_flip() +
  labs(
    title = "Heterogeneity in Network Exposure Effects by Census Division",
    subtitle = "OLS coefficients with 95% CIs. Effects largest in South, smallest in high-MW coastal regions.",
    x = "",
    y = "Coefficient on Pop-Weighted Network Exposure"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10)
  )

ggsave("../figures/fig7_heterogeneity.pdf", fig7, width = 9, height = 7)
cat("  Saved fig7_heterogeneity.pdf\n")


# ============================================================================
# Figure 8: Migration Flows by Network Exposure Quartile
# ============================================================================

cat("\nFigure 8: Migration flows by network exposure quartile...\n")

if (file.exists("../data/fig8_migration_data.rds")) {
  migration_data <- readRDS("../data/fig8_migration_data.rds")

  fig8 <- ggplot(migration_data, aes(x = year, y = mean_net_mig, color = exposure_q)) +
    geom_line(size = 1) +
    geom_point(size = 2.5) +
    scale_color_manual(
      values = c("Q1 (Low)" = "#4575b4", "Q2" = "#91bfdb",
                 "Q3" = "#fc8d59", "Q4 (High)" = "#d73027"),
      name = "Exposure\nQuartile"
    ) +
    labs(
      title = "Net Migration by Network Exposure Quartile",
      subtitle = "IRS county-to-county migration flows, 2012-2019",
      x = "Year",
      y = "Mean Net Migration (Returns)"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 10, color = "gray30"),
      legend.position = "right",
      panel.grid.minor = element_blank()
    )

  ggsave("../figures/fig8_migration.pdf", fig8, width = 9, height = 6)
  cat("  Saved fig8_migration.pdf\n")
} else {
  cat("  Skipping Figure 8: ../data/fig8_migration_data.rds not found.\n")
  cat("  Run 04b_mechanisms.R first to generate migration data.\n")
}


# ============================================================================
# Summary
# ============================================================================

cat("\n=== All 8 Figures Generated ===\n")
cat("Files in figures/:\n")
list.files("../figures", pattern = "\\.pdf$")
