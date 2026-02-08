# =============================================================================
# Paper 109: Geocoded Atlas of US Traffic Fatalities 2001-2019 (Revision)
# 09_border_figures.R - Policy border analysis figures (Section 6)
# =============================================================================

source(here::here("output/paper_109/code/00_packages.R"))

# Load data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy.rds"))
marijuana_policy <- readRDS(file.path(dir_data_policy, "marijuana_policy.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")

# =============================================================================
# Figure 24: Crash Density by Distance to Legal/Illegal Border
# =============================================================================

message("Creating Figure 24: Crash density by distance to border...")

# Filter to crashes with border distance
border_data <- fars %>%
  filter(!is.na(dist_to_border_km), dist_to_border_km < 200) %>%
  filter(year >= 2018)  # THC identification reliable 2018+

# Create distance bins
border_data <- border_data %>%
  mutate(
    dist_bin = cut(dist_sign,
                   breaks = c(-200, -150, -100, -75, -50, -25, -10, 0,
                              10, 25, 50, 75, 100, 150, 200),
                   labels = c("-175", "-125", "-87", "-62", "-37", "-17", "-5",
                              "5", "17", "37", "62", "87", "125", "175")),
    side = ifelse(dist_sign < 0, "Legal State", "Illegal State")
  )

# Count crashes by distance bin
border_counts <- border_data %>%
  group_by(dist_bin, side) %>%
  summarise(
    crashes = n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(dist_bin)) %>%
  mutate(dist_num = as.numeric(as.character(dist_bin)))

fig24 <- ggplot(border_counts, aes(x = dist_num, y = crashes, fill = side)) +
  geom_col(alpha = 0.8, width = 20) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 1) +
  annotate("text", x = -100, y = max(border_counts$crashes) * 0.9,
           label = "Legal State\n<--", hjust = 0.5, size = 4, fontface = "bold") +
  annotate("text", x = 100, y = max(border_counts$crashes) * 0.9,
           label = "Illegal State\n-->", hjust = 0.5, size = 4, fontface = "bold") +
  scale_fill_manual(values = c(
    "Legal State" = apep_colors["legal"],
    "Illegal State" = apep_colors["illegal"]
  )) +
  scale_x_continuous(breaks = seq(-150, 150, 50)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Distance to Legal/Illegal State Border",
    subtitle = "Western marijuana borders, 2018-2019",
    x = "Distance to Border (km, negative = legal side)",
    y = "Number of Crashes",
    fill = NULL,
    caption = "Source: FARS. Distance computed to nearest marijuana legalization border."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(file.path(dir_figs, "fig24_crash_density_border.pdf"), fig24,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig24_crash_density_border.png"), fig24,
       width = 10, height = 6, dpi = 300)

message("  Saved fig24_crash_density_border")

# =============================================================================
# Figure 25: THC-Positive Rate by Distance to Border
# =============================================================================

message("Creating Figure 25: THC rate by distance to border...")

thc_by_dist <- border_data %>%
  filter(!is.na(thc_positive), !is.na(dist_bin)) %>%
  group_by(dist_bin, side) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    se = sqrt(pct_thc * (100 - pct_thc) / tested),
    .groups = "drop"
  ) %>%
  filter(tested >= 20) %>%
  mutate(dist_num = as.numeric(as.character(dist_bin)))

fig25 <- ggplot(thc_by_dist, aes(x = dist_num, y = pct_thc, color = side)) +
  geom_point(size = 3) +
  geom_line(linewidth = 1) +
  geom_ribbon(aes(ymin = pct_thc - 1.96*se, ymax = pct_thc + 1.96*se, fill = side),
              alpha = 0.2, color = NA) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 1) +
  scale_color_manual(values = c(
    "Legal State" = apep_colors["legal"],
    "Illegal State" = apep_colors["illegal"]
  )) +
  scale_fill_manual(values = c(
    "Legal State" = apep_colors["legal"],
    "Illegal State" = apep_colors["illegal"]
  )) +
  scale_x_continuous(breaks = seq(-150, 150, 50)) +
  labs(
    title = "THC-Positive Rate by Distance to Legal/Illegal Border",
    subtitle = "Western marijuana borders, 2018-2019",
    x = "Distance to Border (km, negative = legal side)",
    y = "Percent THC-Positive",
    color = NULL,
    fill = NULL,
    caption = "Source: FARS drug test data. Shaded area = 95% CI. Minimum 20 tested crashes per bin."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig25_thc_rate_border.pdf"), fig25,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig25_thc_rate_border.png"), fig25,
       width = 10, height = 6, dpi = 300)

message("  Saved fig25_thc_rate_border")

# =============================================================================
# Figure 26: Event Study - THC Rates Around Legalization
# =============================================================================

message("Creating Figure 26: Event study around legalization...")

# Create event time relative to legalization
event_data <- fars %>%
  filter(ever_rec_legal, !is.na(rel_time_rec), !is.na(thc_positive)) %>%
  mutate(
    event_year = floor(rel_time_rec / 12)  # Convert months to years
  ) %>%
  filter(event_year >= -5, event_year <= 8)  # 5 years before to 8 years after

event_summary <- event_data %>%
  group_by(event_year) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    se = sqrt(pct_thc * (100 - pct_thc) / tested),
    .groups = "drop"
  ) %>%
  filter(tested >= 50)

fig26 <- ggplot(event_summary, aes(x = event_year, y = pct_thc)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  geom_ribbon(aes(ymin = pct_thc - 1.96*se, ymax = pct_thc + 1.96*se),
              fill = apep_colors["legal"], alpha = 0.3) +
  geom_line(color = apep_colors["legal"], linewidth = 1.2) +
  geom_point(color = apep_colors["legal"], size = 3) +
  annotate("text", x = 0.2, y = max(event_summary$pct_thc) * 0.95,
           label = "Legalization", hjust = 0, size = 3, color = "red") +
  scale_x_continuous(breaks = seq(-5, 8, 1)) +
  labs(
    title = "THC-Positive Rate Before and After Recreational Legalization",
    subtitle = "Event study for CO, WA, OR, CA, NV (pooled)",
    x = "Years Relative to Legalization",
    y = "Percent THC-Positive",
    caption = "Source: FARS drug test data. Event time = 0 is state's legalization effective date. 95% CI shown."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig26_event_study_thc.pdf"), fig26,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig26_event_study_thc.png"), fig26,
       width = 10, height = 6, dpi = 300)

message("  Saved fig26_event_study_thc")

# =============================================================================
# Figure 27: State-Specific Event Studies
# =============================================================================

message("Creating Figure 27: State-specific event studies...")

event_by_state <- fars %>%
  filter(state_abbr %in% c("CO", "WA", "OR", "CA", "NV"),
         !is.na(rel_time_rec), !is.na(thc_positive)) %>%
  mutate(
    event_year = floor(rel_time_rec / 12)
  ) %>%
  filter(event_year >= -4, event_year <= 6) %>%
  group_by(state_abbr, event_year) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    .groups = "drop"
  ) %>%
  filter(tested >= 20)

fig27 <- ggplot(event_by_state, aes(x = event_year, y = pct_thc, color = state_abbr)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(breaks = seq(-4, 6, 2)) +
  labs(
    title = "THC-Positive Rate: State-Specific Event Studies",
    subtitle = "Years relative to recreational marijuana legalization",
    x = "Years Relative to Legalization",
    y = "Percent THC-Positive",
    color = "State",
    caption = "Source: FARS. Minimum 20 tested crashes per state-year."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig27_event_study_by_state.pdf"), fig27,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig27_event_study_by_state.png"), fig27,
       width = 10, height = 6, dpi = 300)

message("  Saved fig27_event_study_by_state")

# =============================================================================
# Figure 28: Border Pair Comparison
# =============================================================================

message("Creating Figure 28: Border pair comparison...")

# Calculate THC rates by key border pairs
border_pairs <- tribble(
  ~legal, ~illegal, ~pair_name,
  "CO", "WY", "CO-WY",
  "WA", "ID", "WA-ID",
  "OR", "ID", "OR-ID",
  "NV", "UT", "NV-UT"
)

pair_data <- list()
for (i in 1:nrow(border_pairs)) {
  bp <- border_pairs[i, ]

  legal_data <- fars %>%
    filter(state_abbr == bp$legal, year >= 2018, !is.na(thc_positive)) %>%
    summarise(
      state = bp$legal,
      side = "Legal",
      tested = n(),
      thc_pos = sum(thc_positive),
      pct_thc = 100 * thc_pos / tested
    )

  illegal_data <- fars %>%
    filter(state_abbr == bp$illegal, year >= 2018, !is.na(thc_positive)) %>%
    summarise(
      state = bp$illegal,
      side = "Illegal",
      tested = n(),
      thc_pos = sum(thc_positive),
      pct_thc = 100 * thc_pos / tested
    )

  pair_data[[i]] <- bind_rows(legal_data, illegal_data) %>%
    mutate(pair = bp$pair_name)
}

pair_df <- bind_rows(pair_data)

fig28 <- ggplot(pair_df, aes(x = pair, y = pct_thc, fill = side)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  scale_fill_manual(values = c(
    "Legal" = apep_colors["legal"],
    "Illegal" = apep_colors["illegal"]
  )) +
  labs(
    title = "THC-Positive Rates by Border Pair",
    subtitle = "2018-2019, comparing adjacent legal vs illegal states",
    x = "Border Pair",
    y = "Percent THC-Positive",
    fill = "State Type",
    caption = "Source: FARS drug test data."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig28_border_pairs.pdf"), fig28,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig28_border_pairs.png"), fig28,
       width = 10, height = 6, dpi = 300)

message("  Saved fig28_border_pairs")

# =============================================================================
# Figure 29: RDD-Style Scatter at Border
# =============================================================================

message("Creating Figure 29: RDD-style scatter at border...")

# Focus on CO-WY border
co_wy_data <- fars %>%
  filter(state_abbr %in% c("CO", "WY"),
         year >= 2018,
         !is.na(thc_positive),
         !is.na(dist_to_border_km),
         dist_to_border_km < 150) %>%
  mutate(
    dist_signed = ifelse(state_abbr == "CO", -dist_to_border_km, dist_to_border_km)
  )

# Bin data for cleaner visualization
co_wy_binned <- co_wy_data %>%
  mutate(
    dist_bin = round(dist_signed / 10) * 10
  ) %>%
  group_by(dist_bin, state_abbr) %>%
  summarise(
    n = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / n,
    se = sqrt(pct_thc * (100 - pct_thc) / n),
    .groups = "drop"
  ) %>%
  filter(n >= 10)

fig29 <- ggplot(co_wy_binned, aes(x = dist_bin, y = pct_thc, color = state_abbr)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey30", linewidth = 1) +
  geom_point(aes(size = n), alpha = 0.7) +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.2) +
  scale_color_manual(values = c(
    "CO" = apep_colors["legal"],
    "WY" = apep_colors["illegal"]
  ), labels = c("CO" = "Colorado (Legal)", "WY" = "Wyoming (Illegal)")) +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  annotate("text", x = -75, y = max(co_wy_binned$pct_thc, na.rm = TRUE) * 0.9,
           label = "Colorado\n(Legal)", hjust = 0.5, size = 4, fontface = "bold") +
  annotate("text", x = 75, y = max(co_wy_binned$pct_thc, na.rm = TRUE) * 0.9,
           label = "Wyoming\n(Illegal)", hjust = 0.5, size = 4, fontface = "bold") +
  labs(
    title = "THC-Positive Rate at the Colorado-Wyoming Border",
    subtitle = "RDD-style plot, 2018-2019 (10km bins)",
    x = "Distance from Border (km, negative = Colorado side)",
    y = "Percent THC-Positive",
    color = NULL,
    caption = "Source: FARS. Point size proportional to sample size. LOESS fit with 95% CI."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig29_rdd_co_wy.pdf"), fig29,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig29_rdd_co_wy.png"), fig29,
       width = 10, height = 6, dpi = 300)

message("  Saved fig29_rdd_co_wy")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("Border figures complete!")
message("Figures saved to: ", dir_figs)
message(strrep("=", 60))

# List border figures
message("\nGenerated border figures:")
list.files(dir_figs, pattern = "^fig2[4-9]_") %>%
  unique() %>%
  sort() %>%
  walk(~ message("  ", .x))
