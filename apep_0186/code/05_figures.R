################################################################################
# 05_figures.R
# Social Network Minimum Wage Exposure: Descriptive Paper
#
# Input:  data/analysis_panel.rds, data/raw_counties_sf.rds
# Output: figures/fig*.pdf (6 publication-quality figures)
################################################################################

source("00_packages.R")

cat("=== Generating Descriptive Figures ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")
counties_sf <- readRDS("../data/raw_counties_sf.rds")

# Convert exposure from log to levels for interpretable units
panel <- panel %>%
  mutate(
    network_mw = exp(social_exposure),
    geo_mw = exp(geo_exposure),
    own_mw = own_min_wage,
    network_gap = network_mw - own_mw
  )

# Filter out counties with anomalous exposure values (data issues)
# Remove clear outliers but retain observations near $7.25 threshold
# Values slightly below $7.25 may reflect timing of quarterly averaging or territorial data
valid_exposure_threshold <- log(7.00)  # Remove clear outliers below $7.00
n_before <- nrow(panel)
panel <- panel %>%
  filter(social_exposure >= valid_exposure_threshold)
cat("Filtered", n_before - nrow(panel), "observations with anomalous exposure values.\n")

cat("Panel loaded:", nrow(panel), "observations,",
    length(unique(panel$county_fips)), "counties,",
    length(unique(paste(panel$year, panel$quarter))), "quarters\n")

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

# Create figures directory if needed
dir.create("../figures", showWarnings = FALSE)

# ============================================================================
# Figure 1: Map of Average Network Minimum Wage Exposure
# ============================================================================

cat("\nFigure 1: Map of average network MW exposure...\n")

# Compute time-averaged exposure per county
avg_exposure <- panel %>%
  group_by(county_fips) %>%
  summarise(
    mean_network_mw = mean(network_mw, na.rm = TRUE),
    mean_geo_mw = mean(geo_mw, na.rm = TRUE),
    mean_own_mw = mean(own_mw, na.rm = TRUE),
    mean_gap = mean(network_gap, na.rm = TRUE),
    .groups = "drop"
  )

# Merge with county geography
map_data <- counties_sf %>%
  left_join(avg_exposure, by = c("fips" = "county_fips"))

# Filter to continental US (exclude AK=02, HI=15)
map_cont <- map_data %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

fig1 <- ggplot(map_cont) +
  geom_sf(aes(fill = mean_network_mw), color = NA, size = 0) +
  scale_fill_viridis_c(
    option = "plasma",
    name = "Network\nMW ($)",
    breaks = c(7.5, 8, 8.5, 9, 9.5, 10),
    labels = scales::dollar_format(accuracy = 0.5),
    na.value = "gray90"
  ) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  labs(
    title = "Average Network Minimum Wage Exposure by County",
    subtitle = "SCI-weighted mean of out-of-state minimum wages, 2010-2023"
  ) +
  theme_void(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "gray30"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig1_network_mw_map.pdf", fig1, width = 10, height = 6, device = cairo_pdf)
cat("  Saved fig1_network_mw_map.pdf\n")


# ============================================================================
# Figure 2: Map of Network-Own Minimum Wage Gap
# ============================================================================

cat("\nFigure 2: Map of network-own MW gap...\n")

fig2 <- ggplot(map_cont) +
  geom_sf(aes(fill = mean_gap), color = NA, size = 0) +
  scale_fill_gradient2(
    low = "#d73027",      # Red for negative (own > network)
    mid = "white",
    high = "#4575b4",     # Blue for positive (network > own)
    midpoint = 0,
    name = "Gap ($)",
    labels = scales::dollar_format(accuracy = 0.5),
    na.value = "gray90",
    limits = c(-3, 3),
    oob = scales::squish
  ) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50), expand = FALSE) +
  labs(
    title = "Network-Own Minimum Wage Gap by County",
    subtitle = "Positive (blue) = network exposure exceeds own-state MW; Negative (red) = own-state exceeds network"
  ) +
  theme_void(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 9, color = "gray30"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig2_gap_map.pdf", fig2, width = 10, height = 6, device = cairo_pdf)
cat("  Saved fig2_gap_map.pdf\n")


# ============================================================================
# Figure 3: Time Series of Network MW by Tercile
# ============================================================================

cat("\nFigure 3: Time series by exposure tercile...\n")

# Create baseline tercile (using 2010 average)
baseline_tercile <- panel %>%
  filter(year == 2010) %>%
  group_by(county_fips) %>%
  summarise(baseline_exposure = mean(network_mw, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    tercile = cut(baseline_exposure,
                  breaks = quantile(baseline_exposure, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                  labels = c("Low", "Medium", "High"),
                  include.lowest = TRUE)
  )

# Merge back and compute time series
ts_data <- panel %>%
  left_join(baseline_tercile %>% select(county_fips, tercile), by = "county_fips") %>%
  filter(!is.na(tercile)) %>%
  group_by(yearq, tercile) %>%
  summarise(
    mean_mw = mean(network_mw, na.rm = TRUE),
    se = sd(network_mw, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig3 <- ggplot(ts_data, aes(x = yearq, y = mean_mw, color = tercile, fill = tercile)) +
  geom_ribbon(aes(ymin = mean_mw - 1.96*se, ymax = mean_mw + 1.96*se),
              alpha = 0.2, color = NA) +
  geom_line(size = 1) +
  scale_color_manual(values = c("Low" = "#4575b4", "Medium" = "#fee090", "High" = "#d73027"),
                     name = "Baseline\nExposure\nTercile") +
  scale_fill_manual(values = c("Low" = "#4575b4", "Medium" = "#fee090", "High" = "#d73027"),
                    guide = "none") +
  scale_x_continuous(breaks = seq(2010, 2023, 2)) +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    title = "Network Minimum Wage Over Time by Baseline Exposure Tercile",
    subtitle = "Counties grouped by 2010 network exposure level; shaded bands = 95% CI",
    x = "Year",
    y = "Mean Network Minimum Wage ($)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig3_tercile_ts.pdf", fig3, width = 9, height = 5)
cat("  Saved fig3_tercile_ts.pdf\n")


# ============================================================================
# Figure 4: Time Series for Selected States
# ============================================================================

cat("\nFigure 4: Time series for selected states...\n")

# Select states with contrasting patterns
selected_states <- c("TX", "MS", "AL",   # Low exposure, low own MW
                     "NV", "AZ", "FL",   # High exposure, varying own MW
                     "CA", "NY")          # High own MW states

state_ts <- panel %>%
  filter(state_abbr %in% selected_states) %>%
  group_by(yearq, state_abbr) %>%
  summarise(
    mean_network = mean(network_mw, na.rm = TRUE),
    mean_own = mean(own_mw, na.rm = TRUE),
    .groups = "drop"
  )

# Order states by final period network exposure
state_order <- state_ts %>%
  filter(yearq == max(yearq)) %>%
  arrange(mean_network) %>%
  pull(state_abbr)

state_ts <- state_ts %>%
  mutate(state_abbr = factor(state_abbr, levels = state_order))

fig4 <- ggplot(state_ts, aes(x = yearq, y = mean_network, color = state_abbr)) +
  geom_line(size = 1) +
  geom_point(size = 1.5, alpha = 0.7) +
  scale_color_viridis_d(option = "turbo", name = "State") +
  scale_x_continuous(breaks = seq(2010, 2023, 2)) +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    title = "Network Minimum Wage Over Time: Selected States",
    subtitle = "Counties averaged within state; states ordered by 2023 network exposure",
    x = "Year",
    y = "Mean Network Minimum Wage ($)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig4_state_ts.pdf", fig4, width = 9, height = 5)
cat("  Saved fig4_state_ts.pdf\n")


# ============================================================================
# Figure 5: Scatter of Network vs. Geographic Exposure
# ============================================================================

cat("\nFigure 5: Network vs. geographic exposure scatter...\n")

# Use county averages for visualization
scatter_data <- avg_exposure %>%
  filter(!is.na(mean_network_mw) & !is.na(mean_geo_mw))

# Use PANEL correlation (more meaningful than cross-sectional)
corr_val <- cor(panel$network_mw, panel$geo_mw, use = "complete.obs")

fig5 <- ggplot(scatter_data, aes(x = mean_geo_mw, y = mean_network_mw)) +
  geom_point(alpha = 0.3, size = 0.8, color = "#4575b4") +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50", size = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "#d73027", fill = "#d73027", alpha = 0.2) +
  annotate("text", x = min(scatter_data$mean_geo_mw) + 0.1,
           y = max(scatter_data$mean_network_mw) - 0.1,
           label = paste0("Correlation = ", round(corr_val, 2)),
           hjust = 0, vjust = 1, size = 4, fontface = "italic") +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    title = "Network vs. Geographic Minimum Wage Exposure",
    subtitle = "Each point = one county (time-averaged); dashed line = 45-degree line",
    x = "Geographic Exposure (Distance-Weighted, $)",
    y = "Network Exposure (SCI-Weighted, $)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig5_scatter.pdf", fig5, width = 7, height = 6)
cat("  Saved fig5_scatter.pdf\n")


# ============================================================================
# Figure 6: Histogram of Network-Own Gap
# ============================================================================

cat("\nFigure 6: Distribution of network-own gap...\n")

gap_data <- panel %>%
  filter(!is.na(network_gap))

mean_gap <- mean(gap_data$network_gap, na.rm = TRUE)
median_gap <- median(gap_data$network_gap, na.rm = TRUE)

fig6 <- ggplot(gap_data, aes(x = network_gap)) +
  geom_histogram(aes(y = after_stat(density)), bins = 60,
                 fill = "#4575b4", color = "white", alpha = 0.8) +
  geom_density(color = "#d73027", size = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray30", size = 0.8) +
  geom_vline(xintercept = mean_gap, linetype = "solid", color = "#d73027", size = 0.8) +
  annotate("text", x = mean_gap + 0.1, y = Inf,
           label = paste0("Mean = $", round(mean_gap, 2)),
           hjust = 0, vjust = 2, size = 3.5, color = "#d73027") +
  scale_x_continuous(labels = scales::dollar_format(),
                     breaks = seq(-6, 4, 1),
                     limits = c(-6, 4)) +
  labs(
    title = "Distribution of Network-Own Minimum Wage Gap",
    subtitle = "All county-quarter observations; positive = network > own-state",
    x = "Network MW - Own-State MW ($)",
    y = "Density"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig6_histogram.pdf", fig6, width = 8, height = 5)
cat("  Saved fig6_histogram.pdf\n")


# ============================================================================
# Summary Statistics for Paper
# ============================================================================

cat("\n=== Summary Statistics ===\n")

cat("\nPanel-level statistics (N =", nrow(panel), "county-quarters):\n")
cat("Own-State MW: Mean =", round(mean(panel$own_mw, na.rm=TRUE), 2),
    ", SD =", round(sd(panel$own_mw, na.rm=TRUE), 2),
    ", Min =", round(min(panel$own_mw, na.rm=TRUE), 2),
    ", Max =", round(max(panel$own_mw, na.rm=TRUE), 2), "\n")
cat("Network MW: Mean =", round(mean(panel$network_mw, na.rm=TRUE), 2),
    ", SD =", round(sd(panel$network_mw, na.rm=TRUE), 2),
    ", Min =", round(min(panel$network_mw, na.rm=TRUE), 2),
    ", Max =", round(max(panel$network_mw, na.rm=TRUE), 2), "\n")
cat("Geographic MW: Mean =", round(mean(panel$geo_mw, na.rm=TRUE), 2),
    ", SD =", round(sd(panel$geo_mw, na.rm=TRUE), 2),
    ", Min =", round(min(panel$geo_mw, na.rm=TRUE), 2),
    ", Max =", round(max(panel$geo_mw, na.rm=TRUE), 2), "\n")
cat("Network-Own Gap: Mean =", round(mean(panel$network_gap, na.rm=TRUE), 2),
    ", SD =", round(sd(panel$network_gap, na.rm=TRUE), 2),
    ", Min =", round(min(panel$network_gap, na.rm=TRUE), 2),
    ", Max =", round(max(panel$network_gap, na.rm=TRUE), 2), "\n")

cat("\nCross-sectional statistics (N =", nrow(avg_exposure), "counties):\n")
cat("Mean Network MW: Mean =", round(mean(avg_exposure$mean_network_mw, na.rm=TRUE), 2),
    ", SD =", round(sd(avg_exposure$mean_network_mw, na.rm=TRUE), 2),
    ", Min =", round(min(avg_exposure$mean_network_mw, na.rm=TRUE), 2),
    ", Max =", round(max(avg_exposure$mean_network_mw, na.rm=TRUE), 2), "\n")

cat("\nCorrelations:\n")
cat("Own-State vs Network:", round(cor(panel$own_mw, panel$network_mw, use="complete.obs"), 2), "\n")
cat("Own-State vs Geographic:", round(cor(panel$own_mw, panel$geo_mw, use="complete.obs"), 2), "\n")
cat("Network vs Geographic:", round(cor(panel$network_mw, panel$geo_mw, use="complete.obs"), 2), "\n")

cat("\n=== All 6 Figures Generated ===\n")
