# =============================================================================
# Fix Figure 9 (fig20_polysubstance.pdf) - Poly-Substance Breakdown
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
THC_YEARS <- c(2018, 2019)

message("Regenerating Figure 9: Poly-substance breakdown...")

# Restrict to crashes with drug records AND known alcohol status
poly_data <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive), !is.na(alc_involved))

message("  Crashes with both drug record and alcohol status: ", nrow(poly_data))

# Compute breakdown by state type
breakdown <- poly_data %>%
  mutate(
    substance_cat = case_when(
      thc_positive & alc_involved ~ "Both THC + Alcohol",
      thc_positive & !alc_involved ~ "THC Only",
      !thc_positive & alc_involved ~ "Alcohol Only",
      TRUE ~ "Neither Detected"
    )
  ) %>%
  group_by(ever_rec_legal) %>%
  mutate(n_total = n()) %>%
  group_by(ever_rec_legal, substance_cat, n_total) %>%
  summarise(n = n(), .groups = "drop") %>%
  mutate(
    pct = round(100 * n / n_total, 1),
    state_type = ifelse(ever_rec_legal, "Legalized States", "Comparison States")
  )

# Order categories logically
breakdown$substance_cat <- factor(breakdown$substance_cat,
  levels = c("Neither Detected", "Alcohol Only", "THC Only", "Both THC + Alcohol"))

# Create figure
fig9 <- ggplot(breakdown, aes(x = state_type, y = pct, fill = substance_cat)) +
  geom_col(position = "stack", alpha = 0.9) +
  geom_text(aes(label = ifelse(pct >= 3, paste0(pct, "%"), "")),
            position = position_stack(vjust = 0.5), size = 3.5, color = "white") +
  scale_fill_manual(values = c(
    "Neither Detected" = "#999999",
    "Alcohol Only" = "#377EB8",
    "THC Only" = "#4DAF4A",
    "Both THC + Alcohol" = "#984EA3"
  )) +
  labs(
    title = "Substance Involvement Among Crashes with Drug Records",
    subtitle = "Western States, 2018-2019",
    x = "",
    y = "Percent of Crashes with Drug Record",
    fill = "Substance Category",
    caption = "Note: Denominator = crashes with any driver drug record in FARS and known alcohol status."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(dir_figs, "fig20_polysubstance.pdf"), fig9, width = 10, height = 6, dpi = 300)
message("  Saved fig20_polysubstance.pdf")

# Print summary for verification
message("\n=== BREAKDOWN VALUES ===")
print(breakdown %>% select(state_type, substance_cat, pct) %>% arrange(state_type, substance_cat))
