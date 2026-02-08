# =============================================================================
# Fix ALL Figure Labels for Correct Terminology
# Key change: "tested" -> "with any drug finding reported"
#             "THC Negative" -> "No THC finding recorded"
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load clean data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))

THC_YEARS <- c(2018, 2019)
THC_YEAR_LABEL <- "2018-2019"

message("Fixing ALL figure labels with correct terminology...")

# =============================================================================
# Figure 3: THC rate - FIXED TITLE
# =============================================================================

message("Fixing Figure 3: THC rate...")

thc_by_year <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive)) %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    n_with_record = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / n_with_record,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized States", "Comparison States")
  )

fig3 <- ggplot(thc_by_year, aes(x = factor(year), y = pct_thc, fill = state_type)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  geom_text(aes(label = paste0(round(pct_thc, 1), "%")),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  scale_fill_manual(values = c(
    "Legalized States" = "#4DAF4A",
    "Comparison States" = "#FF7F00"
  )) +
  labs(
    title = "THC-Positive Rate Among Crashes with Any Drug Finding Reported",
    subtitle = paste0("Western States, ", THC_YEAR_LABEL, " (FARS drugs file)"),
    x = "Year",
    y = "Percent with THC Finding",
    fill = "State Type",
    caption = "Note: Denominator = crashes with any driver drug record in FARS. Comparison = illegal during study period."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.pdf"), fig3, width = 10, height = 6, dpi = 300)
message("  Saved fig03")

# =============================================================================
# Figure 8: Drug Record Rate by State - FIXED TITLE (was "Drug Testing Rate")
# =============================================================================

message("Fixing Figure 8 (was Drug Testing Rate, now Drug Record Rate)...")

drug_record_rate <- fars %>%
  filter(year %in% THC_YEARS) %>%
  group_by(state_abbr) %>%
  summarise(
    total = n(),
    has_drug_record = sum(!is.na(thc_positive)),
    pct_record = 100 * has_drug_record / total,
    .groups = "drop"
  ) %>%
  arrange(desc(pct_record))

fig8 <- ggplot(drug_record_rate, aes(x = pct_record, y = reorder(state_abbr, pct_record))) +
  geom_col(fill = "#377EB8", alpha = 0.8) +
  geom_text(aes(label = paste0(round(pct_record, 1), "%")), hjust = -0.1, size = 3) +
  labs(
    title = "Share of Crashes with Any Driver Drug Record",
    subtitle = paste0("By State, ", THC_YEAR_LABEL),
    x = "Percent of Crashes with Any Drug Finding Reported",
    y = "State",
    caption = "Note: Measures presence of any record in FARS drugs file, not comprehensive drug testing."
  ) +
  theme_apep() +
  scale_x_continuous(limits = c(0, 45)) +
  theme(axis.text.y = element_text(size = 9))

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8, width = 8, height = 8, dpi = 300)
message("  Saved fig08")

# =============================================================================
# Figure 10: CO-WY Border Map - FIXED LEGEND
# =============================================================================

message("Fixing Figure 10: CO-WY border map...")

# Load state boundaries
states <- tigris::states(cb = TRUE) %>%
  st_transform(5070) %>%
  filter(STUSPS %in% c("CO", "WY"))

border_crashes <- fars %>%
  filter(
    year %in% THC_YEARS,
    state_abbr %in% c("CO", "WY"),
    !is.na(x_albers), !is.na(y_albers),
    !is.na(thc_positive)
  ) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

# Create proper categories with CORRECT terminology
border_crashes <- border_crashes %>%
  mutate(
    thc_category = case_when(
      thc_positive == TRUE ~ "THC Finding Present",
      TRUE ~ "No THC Finding (Drug Record Present)"
    )
  )

n_crashes <- nrow(border_crashes)

fig10 <- ggplot() +
  geom_sf(data = states, fill = "gray95", color = "gray30", linewidth = 0.5) +
  geom_sf(data = border_crashes, aes(color = thc_category), size = 1.5, alpha = 0.7) +
  scale_color_manual(
    values = c(
      "THC Finding Present" = "#E41A1C",
      "No THC Finding (Drug Record Present)" = "#999999"
    ),
    name = "THC Status"
  ) +
  labs(
    title = "Fatal Crashes at the Colorado-Wyoming Border",
    subtitle = paste0(THC_YEAR_LABEL, " | N = ", n_crashes, " crashes with any drug record"),
    caption = "Note: Only crashes with any driver drug record shown. 'No THC Finding' means no THC detected\namong crashes where some drug finding was reported (not necessarily THC-tested negative)."
  ) +
  theme_apep() +
  theme(
    legend.position = "bottom",
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

ggsave(file.path(dir_figs, "fig10_co_wy_border.pdf"), fig10, width = 10, height = 8, dpi = 300)
message("  Saved fig10")

# =============================================================================
# Figure 20: Poly-substance - FIXED AXIS LABEL
# =============================================================================

message("Fixing Figure 20: Poly-substance...")

poly_data <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive)) %>%
  mutate(
    substance_cat = case_when(
      thc_positive & alc_involved ~ "Both THC + Alcohol",
      thc_positive & !alc_involved ~ "THC Only",
      !thc_positive & alc_involved ~ "Alcohol Only",
      TRUE ~ "Neither (Drug Record, No THC/Alcohol)"
    )
  ) %>%
  group_by(ever_rec_legal) %>%
  count(substance_cat) %>%
  mutate(
    pct = 100 * n / sum(n),
    state_type = ifelse(ever_rec_legal, "Legalized States", "Comparison States")
  ) %>%
  ungroup()

# Order categories
poly_data$substance_cat <- factor(poly_data$substance_cat, levels = c(
  "Neither (Drug Record, No THC/Alcohol)", "Alcohol Only", "THC Only", "Both THC + Alcohol"
))

fig20 <- ggplot(poly_data, aes(x = substance_cat, y = pct, fill = state_type)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  scale_fill_manual(values = c(
    "Legalized States" = "#4DAF4A",
    "Comparison States" = "#FF7F00"
  )) +
  labs(
    title = "Substance Involvement Among Crashes with Drug Findings",
    subtitle = paste0("Western States, ", THC_YEAR_LABEL),
    x = "Substance Category",
    y = "Percent of Crashes with Any Drug Record",
    fill = "State Type",
    caption = "Note: Denominator = crashes with any driver drug record in FARS."
  ) +
  theme_apep() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 15, hjust = 1)
  )

ggsave(file.path(dir_figs, "fig20_polysubstance.pdf"), fig20, width = 10, height = 6, dpi = 300)
message("  Saved fig20")

# =============================================================================
# Figure 25: THC Rate by Distance to Border - FIXED AXIS
# =============================================================================

message("Fixing Figure 25: THC rate by distance to border...")

border_dist_data <- fars %>%
  filter(
    year %in% THC_YEARS,
    !is.na(thc_positive),
    !is.na(dist_to_border_km),
    abs(dist_to_border_km) <= 100
  ) %>%
  mutate(
    side = ifelse(dist_to_border_km >= 0, "Legal Side", "Illegal Side"),
    dist_bin = cut(abs(dist_to_border_km), breaks = seq(0, 100, 20), include.lowest = TRUE)
  ) %>%
  group_by(side, dist_bin) %>%
  summarise(
    n = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / n,
    .groups = "drop"
  ) %>%
  filter(n >= 10)

if (nrow(border_dist_data) > 0) {
  fig25 <- ggplot(border_dist_data, aes(x = dist_bin, y = pct_thc, fill = side)) +
    geom_col(position = position_dodge(width = 0.8), alpha = 0.8) +
    scale_fill_manual(values = c("Legal Side" = "#4DAF4A", "Illegal Side" = "#E41A1C")) +
    labs(
      title = "THC-Positive Rate by Distance to Legal/Illegal Border",
      subtitle = paste0(THC_YEAR_LABEL, " (Among Crashes with Any Drug Record)"),
      x = "Distance to Border (km)",
      y = "Percent with THC Finding",
      fill = "Border Side",
      caption = "Note: Denominator = crashes with any driver drug record. Bins with <10 crashes excluded."
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  ggsave(file.path(dir_figs, "fig25_thc_rate_border.pdf"), fig25, width = 10, height = 6, dpi = 300)
  message("  Saved fig25")
} else {
  message("  Skipping fig25 - insufficient data")
}

message("\n=== ALL FIGURE LABELS FIXED ===")
message("Key terminology changes:")
message("  - 'Tested' -> 'with any drug finding reported' / 'with any drug record'")
message("  - 'THC Negative' -> 'No THC Finding (Drug Record Present)'")
message("  - 'Drug Testing Rate' -> 'Share with Any Drug Record'")
