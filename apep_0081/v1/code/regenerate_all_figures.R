# =============================================================================
# Paper 108: Regenerate ALL figures with cleaned data
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load CLEANED and FIXED data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")
message("Years available: ", paste(unique(fars$year), collapse=", "))

# =============================================================================
# Figure 2: Annual Crashes Time Series
# =============================================================================

message("Creating Figure 2: Annual crashes time series...")

annual_crashes <- fars %>%
  group_by(year) %>%
  summarise(
    total_crashes = n(),
    .groups = "drop"
  )

fig2 <- ggplot(annual_crashes, aes(x = year, y = total_crashes)) +
  geom_line(color = "#1a9641", linewidth = 1) +
  geom_point(color = "#1a9641", size = 3) +
  scale_x_continuous(breaks = unique(annual_crashes$year)) +
  scale_y_continuous(labels = scales::comma, limits = c(0, 10000)) +
  labs(
    title = "Fatal Traffic Crashes by Year, Western States",
    subtitle = "Sample periods: 2001-2005, 2016-2019",
    x = "Year",
    y = "Number of Fatal Crashes",
    caption = "Source: FARS (NHTSA). Western states: CO, WA, OR, CA, NV, AK, WY, NE, KS, ID, UT, AZ, NM, MT."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig02_annual_crashes.pdf"), fig2, width = 10, height = 6, dpi = 300)
message("  Saved fig02_annual_crashes")

# =============================================================================
# Figure 3: THC-Positive Rate (2018-2019 only)
# =============================================================================

message("Creating Figure 3: THC-positive rate (2018-2019)...")

thc_by_state_type <- fars %>%
  filter(year >= 2018) %>%
  group_by(ever_rec_legal) %>%
  summarise(
    crashes = n(),
    thc_pos = sum(thc_positive_fixed, na.rm = TRUE),
    pct_thc = 100 * thc_pos / crashes,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized States", "Never-Legal States")
  )

fig3 <- ggplot(thc_by_state_type, aes(x = state_type, y = pct_thc, fill = state_type)) +
  geom_col(alpha = 0.8, width = 0.6) +
  geom_text(aes(label = paste0(round(pct_thc, 1), "%")), vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("Legalized States" = "#1a9641", "Never-Legal States" = "#d7191c")) +
  scale_y_continuous(limits = c(0, 25), breaks = seq(0, 25, 5)) +
  labs(
    title = "THC-Positive Rate by State Legalization Status",
    subtitle = "Western States, 2018-2019 (drug test data available)",
    x = NULL,
    y = "Percent THC-Positive",
    caption = "Source: FARS drug test data. THC identified via drug name field."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.pdf"), fig3, width = 8, height = 6, dpi = 300)
message("  Saved fig03_thc_rate_over_time")

# =============================================================================
# Figure 4: Alcohol-Involved Rate Over Time
# =============================================================================

message("Creating Figure 4: Alcohol-involved rate over time...")

alc_by_year <- fars %>%
  group_by(year) %>%
  summarise(
    crashes = n(),
    alc_inv = sum(alc_involved, na.rm = TRUE),
    pct_alc = 100 * alc_inv / crashes,
    .groups = "drop"
  )

fig4 <- ggplot(alc_by_year, aes(x = year, y = pct_alc)) +
  geom_line(color = "#1a9641", linewidth = 1) +
  geom_point(color = "#1a9641", size = 3) +
  scale_x_continuous(breaks = unique(alc_by_year$year)) +
  scale_y_continuous(limits = c(20, 45), breaks = seq(20, 45, 5)) +
  labs(
    title = "Alcohol-Involved Fatal Crashes Over Time",
    subtitle = "Western States, 2001-2005 and 2016-2019",
    x = "Year",
    y = "Percent with Alcohol-Impaired Driver",
    caption = "Source: FARS. Alcohol-involved = drunk_dr >= 1."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.pdf"), fig4, width = 10, height = 6, dpi = 300)
message("  Saved fig04_alcohol_rate_over_time")

# =============================================================================
# Figure 8: Drug Testing Rate by State (2018-2019 only)
# =============================================================================

message("Creating Figure 8: Drug testing rate by state...")

testing_by_state <- fars %>%
  filter(year >= 2018) %>%
  group_by(state_abbr) %>%
  summarise(
    total_crashes = n(),
    has_drug_test = sum(any_drug_test, na.rm = TRUE),
    pct_tested = 100 * has_drug_test / total_crashes,
    .groups = "drop"
  ) %>%
  arrange(desc(pct_tested))

fig8 <- ggplot(testing_by_state, aes(x = reorder(state_abbr, pct_tested), y = pct_tested)) +
  geom_col(fill = "#1a9641", alpha = 0.8) +
  geom_hline(yintercept = mean(testing_by_state$pct_tested), linetype = "dashed", color = "red") +
  annotate("text", x = 1, y = mean(testing_by_state$pct_tested) + 3,
           label = paste0("Mean: ", round(mean(testing_by_state$pct_tested), 1), "%"),
           hjust = 0, size = 3, color = "red") +
  coord_flip() +
  labs(
    title = "Drug Testing Rate by State",
    subtitle = "Percent of fatal crashes with drug test results (2018-2019)",
    x = NULL,
    y = "Percent with Drug Test Results",
    caption = "Source: FARS drug test data."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8, width = 8, height = 8, dpi = 300)
message("  Saved fig08_testing_rate_by_state")

# =============================================================================
# Figure 18: BAC Distribution
# =============================================================================

message("Creating Figure 18: BAC distribution...")

# Load person data
person <- readRDS(file.path(dir_data_raw, "fars_person_west.rds"))

# Filter to drivers with valid BAC (exclude codes 96, 97)
bac_data <- person %>%
  filter(per_typ == 1) %>%
  mutate(bac = as.numeric(alc_res)) %>%
  filter(!is.na(bac) & bac > 0 & bac < 95)

# Check scale and convert if needed
if (max(bac_data$bac, na.rm = TRUE) > 1) {
  bac_data <- bac_data %>% mutate(bac = bac / 100)
}

message("  BAC records: ", nrow(bac_data))

fig18 <- ggplot(bac_data, aes(x = bac)) +
  geom_histogram(binwidth = 0.02, fill = "#1a9641", alpha = 0.8, color = "white") +
  geom_vline(xintercept = 0.08, linetype = "dashed", color = "red", linewidth = 1) +
  annotate("text", x = 0.09, y = Inf, label = "Legal limit (0.08)",
           hjust = 0, vjust = 2, size = 3, color = "red") +
  scale_x_continuous(limits = c(0, 0.40), breaks = seq(0, 0.40, 0.05)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Blood Alcohol Concentration Distribution",
    subtitle = "Drivers with BAC > 0 in fatal crashes, Western States",
    x = "Blood Alcohol Concentration (BAC)",
    y = "Number of Drivers",
    caption = "Source: FARS person file."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig18_bac_distribution.pdf"), fig18, width = 10, height = 6, dpi = 300)
message("  Saved fig18_bac_distribution")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("All key figures regenerated with cleaned data!")
message("Figures saved to: ", dir_figs)
message(strrep("=", 60))
