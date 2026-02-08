# ==============================================================================
# 05_figures.R
# Universal School Meals and Household Food Security
# Generate all figures
# ==============================================================================

source("output/paper_106/code/00_packages.R")

# ------------------------------------------------------------------------------
# Load data
# ------------------------------------------------------------------------------

df <- read_csv(file.path(DATA_DIR, "cps_fss_analysis_school.csv"), show_col_types = FALSE)

# ------------------------------------------------------------------------------
# Figure 1: Food Insecurity Trends by Treatment Status
# ------------------------------------------------------------------------------

fig1_data <- df %>%
  mutate(treated_ever = if_else(treatment_group > 0, "Treatment States", "Control States")) %>%
  group_by(year, treated_ever) %>%
  summarize(
    mean_fi = weighted.mean(food_insecure, weight, na.rm = TRUE),
    se_fi = sqrt(sum(weight^2 * (food_insecure - weighted.mean(food_insecure, weight, na.rm = TRUE))^2, na.rm = TRUE)) /
            sum(weight, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

fig1 <- ggplot(fig1_data, aes(x = year, y = mean_fi * 100, color = treated_ever, shape = treated_ever)) +
  geom_point(size = 3) +
  geom_line(linewidth = 1) +
  geom_errorbar(aes(ymin = (mean_fi - 1.96 * se_fi) * 100,
                    ymax = (mean_fi + 1.96 * se_fi) * 100),
                width = 0.1) +
  # Add vertical line at treatment
  geom_vline(xintercept = 2022.5, linetype = "dashed", color = "gray50", alpha = 0.7) +
  annotate("text", x = 2022.6, y = 20, label = "2022 cohort\ntreatment begins",
           hjust = 0, size = 3, color = "gray50") +
  scale_color_manual(values = c("Control States" = apep_colors["primary"],
                                "Treatment States" = apep_colors["secondary"])) +
  scale_x_continuous(breaks = c(2022, 2023, 2024)) +
  scale_y_continuous(limits = c(10, 22)) +
  labs(
    title = "Household Food Insecurity Among Families with School-Age Children",
    subtitle = "CPS Food Security Supplement, 2022-2024",
    x = "Survey Year",
    y = "Food Insecurity Rate (%)",
    color = NULL,
    shape = NULL,
    caption = "Notes: Treatment states adopted universal free school meals in 2022 (CA, ME, MA, NV, VT) or 2023 (CO, MI, MN, NM).\nSample restricted to households with at least one child aged 5-17. Weighted estimates."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig1_trends.pdf"), fig1, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig1_trends.png"), fig1, width = 8, height = 6, dpi = 300)

cat("Figure 1 saved\n")

# ------------------------------------------------------------------------------
# Figure 2: Treatment Cohort Comparison
# ------------------------------------------------------------------------------

fig2_data <- df %>%
  filter(treatment_group > 0) %>%
  mutate(
    cohort = factor(treatment_group,
                    labels = c("2022 Adopters\n(CA, ME, MA, NV, VT)",
                               "2023 Adopters\n(CO, MI, MN, NM)"))
  ) %>%
  group_by(year, cohort) %>%
  summarize(
    mean_fi = weighted.mean(food_insecure, weight, na.rm = TRUE),
    se_fi = sqrt(sum(weight^2 * (food_insecure - weighted.mean(food_insecure, weight, na.rm = TRUE))^2, na.rm = TRUE)) /
            sum(weight, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# Add control group
fig2_control <- df %>%
  filter(treatment_group == 0) %>%
  group_by(year) %>%
  summarize(
    mean_fi = weighted.mean(food_insecure, weight, na.rm = TRUE),
    se_fi = sqrt(sum(weight^2 * (food_insecure - weighted.mean(food_insecure, weight, na.rm = TRUE))^2, na.rm = TRUE)) /
            sum(weight, na.rm = TRUE),
    cohort = "Never Treated\n(Control)",
    .groups = "drop"
  )

fig2_combined <- bind_rows(fig2_data, fig2_control)

fig2 <- ggplot(fig2_combined, aes(x = year, y = mean_fi * 100, color = cohort, shape = cohort)) +
  geom_point(size = 3) +
  geom_line(linewidth = 1) +
  geom_errorbar(aes(ymin = (mean_fi - 1.96 * se_fi) * 100,
                    ymax = (mean_fi + 1.96 * se_fi) * 100),
                width = 0.1) +
  scale_color_manual(values = c(
    "2022 Adopters\n(CA, ME, MA, NV, VT)" = apep_colors["secondary"],
    "2023 Adopters\n(CO, MI, MN, NM)" = apep_colors["tertiary"],
    "Never Treated\n(Control)" = apep_colors["gray"]
  )) +
  scale_x_continuous(breaks = c(2022, 2023, 2024)) +
  scale_y_continuous(limits = c(10, 22)) +
  labs(
    title = "Food Insecurity by Treatment Cohort",
    subtitle = "CPS Food Security Supplement, 2022-2024",
    x = "Survey Year",
    y = "Food Insecurity Rate (%)",
    color = NULL,
    shape = NULL,
    caption = "Notes: Sample restricted to households with at least one child aged 5-17. Weighted estimates."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig2_cohorts.pdf"), fig2, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig2_cohorts.png"), fig2, width = 8, height = 6, dpi = 300)

cat("Figure 2 saved\n")

# ------------------------------------------------------------------------------
# Figure 3: State-Level Heterogeneity
# ------------------------------------------------------------------------------

# Load treatment info
treatment <- read_csv(file.path(DATA_DIR, "treatment_timing.csv"), show_col_types = FALSE)

fig3_data <- df %>%
  filter(treatment_group > 0) %>%
  left_join(treatment %>% select(state_fips, state_abbr), by = "state_fips") %>%
  group_by(state_abbr, year, first_treat_year = treatment_group) %>%
  summarize(
    mean_fi = weighted.mean(food_insecure, weight, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    cohort = if_else(first_treat_year == 2022, "2022", "2023")
  )

fig3 <- ggplot(fig3_data, aes(x = year, y = mean_fi * 100, color = state_abbr)) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~cohort, labeller = labeller(cohort = c("2022" = "2022 Adopters", "2023" = "2023 Adopters"))) +
  scale_x_continuous(breaks = c(2022, 2023, 2024)) +
  scale_y_continuous(limits = c(0, 30)) +
  labs(
    title = "Food Insecurity Trends by Treatment State",
    subtitle = "CPS Food Security Supplement, 2022-2024",
    x = "Survey Year",
    y = "Food Insecurity Rate (%)",
    color = "State",
    caption = "Notes: Sample restricted to households with at least one child aged 5-17. Weighted estimates."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig3_state_hetero.pdf"), fig3, width = 10, height = 5)
ggsave(file.path(FIG_DIR, "fig3_state_hetero.png"), fig3, width = 10, height = 5, dpi = 300)

cat("Figure 3 saved\n")

# ------------------------------------------------------------------------------
# Figure 4: Map of Treatment States (skipped - tigris/sf not available)
# ------------------------------------------------------------------------------
cat("Figure 4 (map) skipped - tigris/sf packages not available\n")

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

cat("\n=== All figures saved to", FIG_DIR, "===\n")
list.files(FIG_DIR, pattern = "\\.(pdf|png)$")
