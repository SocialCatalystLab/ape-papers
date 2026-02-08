# =============================================================================
# Paper 110: The Price of Distance
# 06_figures.R - Generate all figures for the paper
# =============================================================================

source(here::here("output/paper_110/code/00_packages.R"))

# =============================================================================
# Load Data
# =============================================================================

analysis_data <- readRDS(file.path(data_dir, "analysis_data.rds"))
dispensaries <- fread(file.path(data_dir, "dispensaries_osm.csv"))

# Try to load regression results
results_file <- file.path(data_dir, "regression_results.rds")
if (file.exists(results_file)) {
  results <- readRDS(results_file)
}

# =============================================================================
# Figure 1: Study Region Map
# =============================================================================

message("Creating Figure 1: Study Region Map...")

# Get state boundaries
states_sf <- tigris::states(cb = TRUE, year = 2020) %>%
  filter(STUSPS %in% c("CO", "WA", "OR", "NV", "CA", "AK",
                       "ID", "WY", "NE", "KS", "UT", "AZ", "MT", "NM")) %>%
  st_transform(5070)

# Classify states
states_sf <- states_sf %>%
  mutate(
    legal_status = ifelse(STUSPS %in% c("CO", "WA", "OR", "NV", "CA", "AK"),
                          "Legal (Rec.)", "Illegal (2016-2019)")
  )

# Create map (excluding Alaska for main view)
states_continental <- states_sf %>%
  filter(STUSPS != "AK")

# Convert dispensaries to sf
disp_sf <- dispensaries %>%
  filter(!is.na(latitude), !is.na(longitude), state != "AK") %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(5070)

fig1 <- ggplot() +
  geom_sf(data = states_continental,
          aes(fill = legal_status),
          color = "white", linewidth = 0.5) +
  geom_sf(data = disp_sf,
          color = "black", size = 0.3, alpha = 0.5) +
  scale_fill_manual(
    values = c("Legal (Rec.)" = "#4DAF4A", "Illegal (2016-2019)" = "#984EA3"),
    name = "Legal Status"
  ) +
  labs(
    title = "Study Region: Cannabis Legalization in the Western United States",
    subtitle = "Black points indicate cannabis dispensary locations (OpenStreetMap)",
    caption = "Legal states: CO (2014), WA (2014), OR (2015), AK (2016), NV (2017), CA (2018)\nIllegal states: ID, WY, NE, KS, UT, AZ, MT, NM"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "bottom"
  )

ggsave(file.path(fig_dir, "fig01_study_region.pdf"),
       fig1, width = 10, height = 8)
message("  Saved fig01_study_region.pdf")

# =============================================================================
# Figure 2: Treatment Intensity Map (Drive Time to Dispensary)
# =============================================================================

message("Creating Figure 2: Treatment Intensity Map...")

# Aggregate to state-level for visualization (or county if we have FIPS)
state_drive_time <- analysis_data %>%
  filter(!is.na(drive_time_min)) %>%
  group_by(state_abbr) %>%
  summarize(
    mean_drive_time = mean(drive_time_min, na.rm = TRUE),
    median_drive_time = median(drive_time_min, na.rm = TRUE),
    .groups = "drop"
  )

# Debug: print state drive times
message("  States in analysis data: ", paste(unique(state_drive_time$state_abbr), collapse = ", "))
message("  Drive times: ")
print(state_drive_time)

# Merge with spatial data
states_treatment <- states_continental %>%
  left_join(state_drive_time, by = c("STUSPS" = "state_abbr"))

# Get state centroids for labels
state_centroids <- states_treatment %>%
  st_centroid() %>%
  mutate(
    x = st_coordinates(.)[,1],
    y = st_coordinates(.)[,2]
  ) %>%
  st_drop_geometry()

fig2 <- ggplot() +
  geom_sf(data = filter(states_treatment, is.na(mean_drive_time)),
          fill = "#4DAF4A", color = "white", linewidth = 0.5) +
  geom_sf(data = filter(states_treatment, !is.na(mean_drive_time)),
          aes(fill = mean_drive_time),
          color = "white", linewidth = 0.5) +
  geom_text(data = filter(state_centroids, !is.na(mean_drive_time)),
            aes(x = x, y = y, label = paste0(STUSPS, "\n", round(mean_drive_time))),
            size = 2.5, color = "white", fontface = "bold") +
  scale_fill_viridis_c(
    option = "plasma",
    name = "Mean Drive Time\nto Dispensary (min)",
    limits = c(100, 600),
    na.value = "#FFFFFF00",
    oob = scales::squish
  ) +
  labs(
    title = "Treatment Intensity: Driving Time to Nearest Legal Dispensary",
    subtitle = "Illegal states colored by mean driving time (minutes); legal states in green",
    caption = "Drive times computed via great-circle distance with routing adjustment"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right"
  )

ggsave(file.path(fig_dir, "fig02_treatment_intensity.pdf"),
       fig2, width = 10, height = 8)
message("  Saved fig02_treatment_intensity.pdf")

# =============================================================================
# Figure 3: Binscatter - Alcohol Crash Rate vs Drive Time
# =============================================================================

message("Creating Figure 3: Binscatter...")

# Create bins
binscatter_data <- analysis_data %>%
  filter(!is.na(drive_time_min), !is.na(alcohol_involved),
         drive_time_min > 0, drive_time_min < 400) %>%
  mutate(
    log_drive_time = log(drive_time_min),
    bin = cut(log_drive_time, breaks = 20)
  ) %>%
  group_by(bin) %>%
  summarize(
    mean_drive_time = exp(mean(log_drive_time)),
    mean_alcohol = mean(alcohol_involved, na.rm = TRUE) * 100,
    se = sd(alcohol_involved, na.rm = TRUE) / sqrt(n()) * 100,
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n >= 50)

fig3 <- ggplot(binscatter_data, aes(x = mean_drive_time, y = mean_alcohol)) +
  geom_point(aes(size = n), alpha = 0.7, color = "#377EB8") +
  geom_smooth(method = "lm", se = TRUE, color = "#E41A1C", linewidth = 1) +
  scale_x_log10(
    breaks = c(30, 60, 120, 240, 360),
    labels = c("30", "60", "120", "240", "360")
  ) +
  scale_size_continuous(range = c(2, 8), name = "N Crashes") +
  labs(
    x = "Drive Time to Nearest Dispensary (minutes, log scale)",
    y = "Alcohol-Involved Crash Rate (%)",
    title = "Alcohol-Involved Crashes by Distance to Legal Cannabis",
    subtitle = "Each point is a vingtile of drive time; line is OLS fit",
    caption = "Sample: Fatal crashes in illegal states (ID, WY, NE, KS, UT, AZ, MT, NM), 2016-2019"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig03_binscatter.pdf"),
       fig3, width = 8, height = 6)
message("  Saved fig03_binscatter.pdf")

# =============================================================================
# Figure 4: Time Series - Alcohol Crashes Over Time
# =============================================================================

message("Creating Figure 4: Time Series...")

time_series <- analysis_data %>%
  filter(!is.na(alcohol_involved)) %>%
  group_by(year) %>%
  summarize(
    n_crashes = n(),
    alcohol_rate = mean(alcohol_involved, na.rm = TRUE) * 100,
    .groups = "drop"
  )

fig4 <- ggplot(time_series, aes(x = year, y = alcohol_rate)) +
  geom_line(linewidth = 1, color = "#E41A1C") +
  geom_point(size = 2, color = "#E41A1C") +
  geom_vline(xintercept = 2014, linetype = "dashed", alpha = 0.5) +
  annotate("text", x = 2014.2, y = max(time_series$alcohol_rate) * 0.95,
           label = "CO/WA Retail Opens", hjust = 0, size = 3, color = "gray40") +
  labs(
    x = "Year",
    y = "Alcohol-Involved Crash Rate (%)",
    title = "Alcohol Involvement in Fatal Crashes Over Time",
    subtitle = "Illegal states in the Western US",
    caption = "Vertical line marks first recreational dispensary openings (CO/WA, 2014)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig04_time_series.pdf"),
       fig4, width = 8, height = 6)
message("  Saved fig04_time_series.pdf")

# =============================================================================
# Figure 5: Border Region Zoom (Example: Wyoming-Colorado)
# =============================================================================

message("Creating Figure 5: Border Zoom...")

# Get Wyoming and Colorado borders
wy_co <- states_sf %>%
  filter(STUSPS %in% c("WY", "CO"))

# Get crashes in border region
border_crashes <- analysis_data %>%
  filter(
    state_abbr %in% c("WY"),
    !is.na(latitude), !is.na(longitude),
    year >= 2016, year <= 2019  # Main analysis period
  ) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(5070)

# Colorado dispensaries
co_disp <- dispensaries %>%
  filter(state == "CO", !is.na(latitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(5070)

# Convert alcohol_involved to factor for proper coloring
border_crashes <- border_crashes %>%
  mutate(alcohol_factor = factor(ifelse(alcohol_involved == 1, "Yes", "No"), levels = c("No", "Yes")))

fig5 <- ggplot() +
  geom_sf(data = wy_co, aes(fill = STUSPS),
          color = "black", linewidth = 0.5) +
  geom_sf(data = co_disp, color = "darkgreen", size = 1, alpha = 0.5) +
  geom_sf(data = border_crashes,
          aes(color = alcohol_factor),
          size = 1.5, alpha = 0.7) +
  scale_fill_manual(
    values = c("WY" = "#FFCCCC", "CO" = "#CCFFCC"),
    name = "State",
    labels = c("Colorado (Legal)", "Wyoming (Illegal)")
  ) +
  scale_color_manual(
    values = c("No" = "#377EB8", "Yes" = "#E41A1C"),
    name = "Alcohol Involved"
  ) +
  coord_sf(xlim = c(-750000, -450000), ylim = c(1600000, 2100000)) +
  labs(
    title = "Fatal Crashes at the Wyoming-Colorado Border",
    subtitle = "Wyoming crashes (2016-2019) and Colorado dispensaries (green)",
    caption = "Wyoming remained illegal throughout study period; Colorado legalized in 2014"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right"
  )

ggsave(file.path(fig_dir, "fig05_border_zoom_wy_co.pdf"),
       fig5, width = 10, height = 8)
message("  Saved fig05_border_zoom_wy_co.pdf")

# =============================================================================
# Figure 6: Coefficient Plot - Main Results
# =============================================================================

if (exists("results") && !is.null(results$main)) {
  message("Creating Figure 6: Coefficient Plot...")

  # Extract coefficients
  coef_data <- map_dfr(names(results$main), function(nm) {
    mod <- results$main[[nm]]
    tidy_mod <- broom::tidy(mod, conf.int = TRUE)
    tidy_mod$model <- nm
    tidy_mod
  }) %>%
    filter(term == "log(drive_time_min)") %>%
    mutate(
      model = factor(model, levels = c("Full Sample", "Year-Month FE",
                                        "Quadratic", "Border Only"))
    )

  fig6 <- ggplot(coef_data, aes(x = model, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                    color = "#377EB8", size = 0.8) +
    coord_flip() +
    labs(
      x = "",
      y = "Coefficient on log(Drive Time)",
      title = "Effect of Drive Time to Dispensary on Alcohol-Involved Crashes",
      subtitle = "Positive coefficient: longer drive time → more alcohol crashes",
      caption = "95% confidence intervals shown; SEs clustered at state level"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig06_coefficient_plot.pdf"),
         fig6, width = 8, height = 5)
  message("  Saved fig06_coefficient_plot.pdf")
}

# =============================================================================
# Figure 7: Heterogeneity by Distance Band
# =============================================================================

if (exists("results") && !is.null(results$hetero_distance)) {
  message("Creating Figure 7: Heterogeneity by Distance...")

  hetero_data <- map_dfr(names(results$hetero_distance), function(nm) {
    mod <- results$hetero_distance[[nm]]
    tidy_mod <- broom::tidy(mod, conf.int = TRUE)
    tidy_mod$dist_band <- nm
    tidy_mod
  }) %>%
    filter(term == "log(drive_time_min)") %>%
    mutate(
      dist_band = factor(dist_band,
                         levels = c("0-50km", "50-100km", "100-200km", ">200km"))
    )

  fig7 <- ggplot(hetero_data, aes(x = dist_band, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                    color = "#E41A1C", size = 0.8) +
    labs(
      x = "Distance to Legal State Border",
      y = "Coefficient on log(Drive Time)",
      title = "Effect Heterogeneity by Distance to Border",
      subtitle = "Effects should be larger closer to border (where cross-border purchasing is feasible)",
      caption = "95% confidence intervals; SEs clustered at state level"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig07_heterogeneity_distance.pdf"),
         fig7, width = 8, height = 5)
  message("  Saved fig07_heterogeneity_distance.pdf")
}

# =============================================================================
# Summary
# =============================================================================

message("\n=== Figures Complete ===")
message("Saved to: ", fig_dir)
list.files(fig_dir, pattern = "\\.pdf$")
