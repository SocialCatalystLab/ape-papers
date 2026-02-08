# ============================================================================
# Paper 66: Automatic Voter Registration
# Script 05: Create All Figures
# ============================================================================

library(tidyverse)
library(sf)
library(viridis)

source("code/00_packages.R")

cat("============================================================\n")
cat("CREATING FIGURES\n")
cat("============================================================\n\n")

# Load results
results <- readRDS("data/did_results.rds")
df <- results$df_state_year
es_reg <- results$es_reg
es_vote <- results$es_vote

# ============================================================================
# Figure 1: AVR Adoption Map
# ============================================================================

cat("Creating Figure 1: AVR Adoption Map...\n")

# Load US states shapefile
states_sf <- st_as_sf(maps::map("state", plot = FALSE, fill = TRUE))
states_sf <- states_sf %>%
  mutate(state = str_to_title(ID))

# Merge with AVR data
avr_db <- read_csv("data/avr_treatment_database.csv", show_col_types = FALSE)
states_map <- states_sf %>%
  left_join(avr_db, by = "state") %>%
  mutate(
    cohort_cat = case_when(
      is.na(cohort) ~ "Never adopted",
      cohort <= 2016 ~ "2015-2016",
      cohort <= 2018 ~ "2017-2018",
      cohort <= 2020 ~ "2019-2020",
      cohort >= 2021 ~ "2021+"
    ),
    cohort_cat = factor(cohort_cat, levels = c("2015-2016", "2017-2018", "2019-2020", "2021+", "Never adopted"))
  )

fig1 <- ggplot(states_map) +
  geom_sf(aes(fill = cohort_cat), color = "white", size = 0.3) +
  scale_fill_viridis_d(option = "D", name = "AVR Adoption", na.value = "gray90") +
  labs(
    title = "Automatic Voter Registration Adoption by State",
    subtitle = "Staggered implementation 2015-2023",
    caption = "Source: State legislation. Alaska and Hawaii excluded."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30"),
    legend.position = "bottom"
  )

ggsave("figures/fig1_avr_map.pdf", fig1, width = 10, height = 7)
ggsave("figures/fig1_avr_map.png", fig1, width = 10, height = 7, dpi = 300)

cat("  ✓ Saved: figures/fig1_avr_map.pdf\n\n")

# ============================================================================
# Figure 2: Pre-Trends - Registration Rates
# ============================================================================

cat("Creating Figure 2: Pre-Trends Plot...\n")

df_pretrends <- df %>%
  filter(year <= 2014) %>%  # Pre-treatment only
  group_by(year, ever_treated) %>%
  summarize(
    mean_reg = mean(reg_rate, na.rm = TRUE),
    se_reg = sd(reg_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    group = if_else(ever_treated, "Eventually treated", "Never treated")
  )

fig2 <- ggplot(df_pretrends, aes(x = year, y = mean_reg, color = group, group = group)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_reg - 1.96*se_reg, ymax = mean_reg + 1.96*se_reg),
                width = 0.3, alpha = 0.5) +
  scale_color_manual(values = c("Eventually treated" = "#E74C3C", "Never treated" = "#2C3E50")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Pre-Treatment Trends in Voter Registration",
    subtitle = "Mean registration rates by treatment group, 2010-2014",
    x = "Year",
    y = "Registration Rate",
    color = NULL,
    caption = "Error bars show 95% confidence intervals."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/fig2_pretrends.pdf", fig2, width = 9, height = 6)
ggsave("figures/fig2_pretrends.png", fig2, width = 9, height = 6, dpi = 300)

cat("  ✓ Saved: figures/fig2_pretrends.pdf\n\n")

# ============================================================================
# Figure 3: Event Study - Registration
# ============================================================================

cat("Creating Figure 3: Event Study (Registration)...\n")

fig3 <- ggplot(es_reg, aes(x = event_time, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray30") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  size = 0.8, fatten = 3, color = "#2C3E50") +
  scale_x_continuous(breaks = seq(-3, 6, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Dynamic Treatment Effects on Voter Registration",
    subtitle = "Event study coefficients relative to AVR adoption (t=0)",
    x = "Years Relative to AVR Adoption",
    y = "Effect on Registration Rate",
    caption = "95% confidence intervals. t=-1 is reference period (normalized to zero).\nCluster-robust standard errors at state level."
  ) +
  annotate("text", x = -2, y = max(es_reg$ci_upper)*0.9,
           label = "Pre-treatment", hjust = 0.5, color = "gray40", size = 3.5) +
  annotate("text", x = 2, y = max(es_reg$ci_upper)*0.9,
           label = "Post-treatment", hjust = 0.5, color = "gray40", size = 3.5) +
  theme_apep()

ggsave("figures/fig3_event_study_reg.pdf", fig3, width = 10, height = 7)
ggsave("figures/fig3_event_study_reg.png", fig3, width = 10, height = 7, dpi = 300)

cat("  ✓ Saved: figures/fig3_event_study_reg.pdf\n\n")

# ============================================================================
# Figure 4: Event Study - Turnout
# ============================================================================

cat("Creating Figure 4: Event Study (Turnout)...\n")

fig4 <- ggplot(es_vote, aes(x = event_time, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray30") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  size = 0.8, fatten = 3, color = "#E74C3C") +
  scale_x_continuous(breaks = seq(-3, 6, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Dynamic Treatment Effects on Voter Turnout",
    subtitle = "Event study coefficients relative to AVR adoption (t=0)",
    x = "Years Relative to AVR Adoption",
    y = "Effect on Turnout Rate",
    caption = "95% confidence intervals. t=-1 is reference period (normalized to zero).\nCluster-robust standard errors at state level."
  ) +
  theme_apep()

ggsave("figures/fig4_event_study_vote.pdf", fig4, width = 10, height = 7)
ggsave("figures/fig4_event_study_vote.png", fig4, width = 10, height = 7, dpi = 300)

cat("  ✓ Saved: figures/fig4_event_study_vote.pdf\n\n")

# ============================================================================
# Figure 5: Registration and Turnout Over Time by Group
# ============================================================================

cat("Creating Figure 5: Time Series by Treatment Group...\n")

df_ts <- df %>%
  group_by(year, ever_treated) %>%
  summarize(
    mean_reg = mean(reg_rate, na.rm = TRUE),
    mean_vote = mean(vote_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c(mean_reg, mean_vote), names_to = "outcome", values_to = "rate") %>%
  mutate(
    outcome = if_else(outcome == "mean_reg", "Registration", "Turnout"),
    group = if_else(ever_treated, "AVR states", "Non-AVR states")
  )

fig5 <- ggplot(df_ts, aes(x = year, y = rate, color = group, linetype = outcome)) +
  geom_line(size = 1) +
  geom_vline(xintercept = 2015, linetype = "dotted", color = "gray40", alpha = 0.7) +
  scale_color_manual(values = c("AVR states" = "#E74C3C", "Non-AVR states" = "#2C3E50")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Voter Registration and Turnout Over Time",
    subtitle = "Mean rates by AVR adoption status, 2010-2022",
    x = "Year",
    y = "Rate",
    color = NULL,
    linetype = NULL,
    caption = "Vertical line indicates first AVR adoption (Oregon 2015)."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/fig5_timeseries.pdf", fig5, width = 10, height = 6)
ggsave("figures/fig5_timeseries.png", fig5, width = 10, height = 6, dpi = 300)

cat("  ✓ Saved: figures/fig5_timeseries.pdf\n\n")

# ============================================================================
# Figure 6: State-Specific Treatment Effects
# ============================================================================

cat("Creating Figure 6: State-Specific Effects...\n")

# Calculate state-specific treatment effects (simple pre-post)
df_state_effects <- df %>%
  filter(ever_treated) %>%
  group_by(state_abbr, cohort) %>%
  summarize(
    reg_pre = mean(reg_rate[year < cohort], na.rm = TRUE),
    reg_post = mean(reg_rate[year >= cohort], na.rm = TRUE),
    effect = reg_post - reg_pre,
    .groups = "drop"
  ) %>%
  arrange(effect)

fig6 <- ggplot(df_state_effects, aes(x = reorder(state_abbr, effect), y = effect)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_col(aes(fill = effect > 0), show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "#2ECC71", "FALSE" = "#E74C3C")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  coord_flip() +
  labs(
    title = "State-Specific Changes in Registration Rates",
    subtitle = "Pre-post comparison for AVR-adopting states",
    x = NULL,
    y = "Change in Registration Rate",
    caption = "Simple difference in means before vs after AVR adoption.\nGreen = increase, Red = decrease."
  ) +
  theme_apep()

ggsave("figures/fig6_state_effects.pdf", fig6, width = 8, height = 10)
ggsave("figures/fig6_state_effects.png", fig6, width = 8, height = 10, dpi = 300)

cat("  ✓ Saved: figures/fig6_state_effects.pdf\n\n")

# ============================================================================
# Summary
# ============================================================================

cat("============================================================\n")
cat("ALL FIGURES CREATED\n")
cat("============================================================\n\n")

cat("Figures saved:\n")
cat("  ✓ Figure 1: AVR Adoption Map\n")
cat("  ✓ Figure 2: Pre-Treatment Trends\n")
cat("  ✓ Figure 3: Event Study (Registration)\n")
cat("  ✓ Figure 4: Event Study (Turnout)\n")
cat("  ✓ Figure 5: Time Series by Group\n")
cat("  ✓ Figure 6: State-Specific Effects\n\n")
