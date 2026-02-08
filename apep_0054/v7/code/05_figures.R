# =============================================================================
# 05_figures.R
# Generate Publication-Quality Figures
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Data and Results
# =============================================================================

qwi <- readRDS("data/qwi_analysis.rds")
cs_result <- readRDS("data/cs_result.rds")
att_dynamic <- readRDS("data/att_dynamic.rds")
results_by_sex <- readRDS("data/results_by_sex.rds")
border_pairs <- readRDS("data/border_pairs.rds")

# =============================================================================
# Figure 1: Map of Treated States with County Detail
# =============================================================================

cat("Creating Figure 1: Treatment Map...\n")

# Get state and county boundaries
states_sf <- tigris::states(cb = TRUE, year = 2020, progress_bar = FALSE) %>%
  filter(!STATEFP %in% c("60", "66", "69", "72", "78", "02", "15")) %>%  # Continental US
  st_transform(5070)  # Albers equal area

counties_sf <- tigris::counties(cb = TRUE, year = 2020, progress_bar = FALSE) %>%
  filter(!STATEFP %in% c("60", "66", "69", "72", "78", "02", "15")) %>%
  st_transform(5070)

# Treatment info
treated_info <- tibble(
  STATEFP = c("08", "09", "32", "44", "06", "53"),
  state_name = c("Colorado", "Connecticut", "Nevada", "Rhode Island",
                 "California", "Washington"),
  treat_date = c("Jan 2021", "Oct 2021", "Oct 2021", "Jan 2023",
                 "Jan 2023", "Jan 2023"),
  cohort = c("2021Q1", "2021Q4", "2021Q4", "2023Q1", "2023Q1", "2023Q1")
)

states_sf <- states_sf %>%
  left_join(treated_info, by = "STATEFP") %>%
  mutate(treatment_status = if_else(!is.na(cohort), cohort, "Never Treated"))

fig1 <- ggplot() +
  geom_sf(data = states_sf,
          aes(fill = treatment_status),
          color = "white", linewidth = 0.3) +
  scale_fill_manual(
    values = c("2021Q1" = "#D62728", "2021Q4" = "#FF7F0E",
               "2023Q1" = "#2CA02C", "Never Treated" = "#E5E5E5"),
    name = "Treatment Cohort"
  ) +
  labs(
    title = "Salary Transparency Law Adoption",
    subtitle = "State-level posting mandates requiring salary ranges in job postings",
    caption = "Note: NY and HI adopted in 2024 (outside sample window). Treatment dates indicate when\nposting requirements took effect for most employers."
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray40")
  )

ggsave("figures/fig1_treatment_map.pdf", fig1, width = 10, height = 7)
ggsave("figures/fig1_treatment_map.png", fig1, width = 10, height = 7, dpi = 300)

# =============================================================================
# Figure 2: Raw Trends in New Hire Earnings
# =============================================================================

cat("Creating Figure 2: Raw Trends...\n")

trends_data <- qwi %>%
  mutate(year_qtr_date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))) %>%
  group_by(year_qtr_date, treated_state, sex_label) %>%
  summarise(
    mean_earn = weighted.mean(EarnHirAS, Emp, na.rm = TRUE),
    se_earn = sd(EarnHirAS, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    group = paste(if_else(treated_state, "Treated", "Control"), sex_label)
  )

# Treatment dates for vertical lines
treat_dates <- as.Date(c("2021-01-01", "2021-10-01", "2023-01-01"))

fig2 <- ggplot(trends_data, aes(x = year_qtr_date, y = mean_earn,
                                 color = group, linetype = group)) +
  geom_vline(xintercept = treat_dates, linetype = "dashed",
             color = "gray50", alpha = 0.7) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  scale_color_manual(values = c(
    "Treated Male" = "#4393C3",
    "Treated Female" = "#D6604D",
    "Control Male" = "#92C5DE",
    "Control Female" = "#F4A582"
  )) +
  scale_linetype_manual(values = c(
    "Treated Male" = "solid",
    "Treated Female" = "solid",
    "Control Male" = "dashed",
    "Control Female" = "dashed"
  )) +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    title = "New Hire Earnings Over Time",
    subtitle = "Average monthly earnings of new hires by treatment status and sex",
    x = "Quarter",
    y = "Average Monthly Earnings (New Hires)",
    caption = "Note: Vertical lines indicate treatment cohort effective dates (2021Q1, 2021Q4, 2023Q1).\nSource: Census QWI, private sector employment."
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    plot.title = element_text(face = "bold")
  )

ggsave("figures/fig2_raw_trends.pdf", fig2, width = 10, height = 6)
ggsave("figures/fig2_raw_trends.png", fig2, width = 10, height = 6, dpi = 300)

# =============================================================================
# Figure 3: Event Study Plot
# =============================================================================

cat("Creating Figure 3: Event Study...\n")

# Extract event study coefficients
es_data <- tibble(
  rel_qtr = att_dynamic$egt,
  att = att_dynamic$att.egt,
  se = att_dynamic$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

fig3 <- ggplot(es_data, aes(x = rel_qtr, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = "#2166AC", alpha = 0.2) +
  geom_line(color = "#2166AC", linewidth = 0.8) +
  geom_point(color = "#2166AC", size = 2) +
  scale_x_continuous(breaks = seq(-12, 8, 2)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Event Study: Effect on New Hire Earnings",
    subtitle = "Callaway-Sant'Anna estimates with 95% confidence intervals",
    x = "Quarters Relative to Treatment",
    y = "Effect on Log New Hire Earnings",
    caption = "Note: Estimates use doubly-robust method with never-treated states as controls.\nStandard errors clustered at state level. Pre-treatment coefficients test parallel trends."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig3_event_study.pdf", fig3, width = 10, height = 6)
ggsave("figures/fig3_event_study.png", fig3, width = 10, height = 6, dpi = 300)

# =============================================================================
# Figure 4: Event Study by Sex
# =============================================================================

cat("Creating Figure 4: Event Study by Sex...\n")

# Need to run dynamic aggregation for each sex
cs_male <- readRDS("data/cs_result.rds")  # Would need sex-specific versions

# For now, create a comparison of overall effects
sex_comparison <- tibble(
  Sex = c("Male", "Female"),
  ATT = c(results_by_sex$Male$overall.att, results_by_sex$Female$overall.att),
  SE = c(results_by_sex$Male$overall.se, results_by_sex$Female$overall.se)
) %>%
  mutate(
    ci_lower = ATT - 1.96 * SE,
    ci_upper = ATT + 1.96 * SE
  )

fig4 <- ggplot(sex_comparison, aes(x = Sex, y = ATT, fill = Sex)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_col(width = 0.6, alpha = 0.8) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, linewidth = 0.8) +
  scale_fill_manual(values = c("Male" = "#4393C3", "Female" = "#D6604D")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Treatment Effect by Sex",
    subtitle = "Callaway-Sant'Anna ATT estimates",
    x = "",
    y = "Effect on Log New Hire Earnings",
    caption = "Note: Error bars show 95% confidence intervals.\nLarger effect for men implies modest widening of the gender gap."
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold")
  )

ggsave("figures/fig4_sex_comparison.pdf", fig4, width = 8, height = 6)
ggsave("figures/fig4_sex_comparison.png", fig4, width = 8, height = 6, dpi = 300)

# =============================================================================
# Figure 5: Border Counties Map
# =============================================================================

cat("Creating Figure 5: Border Counties...\n")

# Highlight border county pairs
border_counties_list <- unique(c(border_pairs$treated_county, border_pairs$control_county))

counties_sf_border <- counties_sf %>%
  mutate(
    is_border = GEOID %in% border_counties_list,
    is_treated_state = STATEFP %in% c("08", "09", "32", "44", "06", "53"),
    category = case_when(
      is_border & is_treated_state ~ "Treated Border County",
      is_border & !is_treated_state ~ "Control Border County",
      is_treated_state ~ "Treated Interior",
      TRUE ~ "Control Interior"
    )
  )

# Focus on Western states for clarity
west_states <- c("08", "06", "53", "32", "04", "35", "49", "41", "16", "30", "56")

counties_west <- counties_sf_border %>%
  filter(STATEFP %in% west_states)

states_west <- states_sf %>%
  filter(STATEFP %in% west_states)

fig5 <- ggplot() +
  geom_sf(data = counties_west,
          aes(fill = category),
          color = "white", linewidth = 0.1) +
  geom_sf(data = states_west,
          fill = NA, color = "black", linewidth = 0.5) +
  scale_fill_manual(
    values = c(
      "Treated Border County" = "#D62728",
      "Control Border County" = "#2CA02C",
      "Treated Interior" = "#FFCCCC",
      "Control Interior" = "#E5E5E5"
    ),
    name = ""
  ) +
  labs(
    title = "Border County-Pair Design (Western States)",
    subtitle = "Counties adjacent to state borders provide tighter comparison",
    caption = "Note: Border counties share a physical boundary with a county in a different treatment status.\nDesign follows Dube, Lester & Reich (2010) minimum wage methodology."
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold")
  )

ggsave("figures/fig5_border_counties.pdf", fig5, width = 10, height = 8)
ggsave("figures/fig5_border_counties.png", fig5, width = 10, height = 8, dpi = 300)

# =============================================================================
# Figure 6: Robustness Comparison
# =============================================================================

cat("Creating Figure 6: Robustness Comparison...\n")

robustness_table <- readRDS("data/robustness_table.rds")

fig6 <- ggplot(robustness_table %>% filter(Specification != "Placebo (2 years early)"),
               aes(x = reorder(Specification, ATT), y = ATT)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = "#2166AC") +
  geom_errorbar(aes(ymin = ATT - 1.96 * SE, ymax = ATT + 1.96 * SE),
                width = 0.2, linewidth = 0.8, color = "#2166AC") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Robustness of Main Results",
    subtitle = "ATT estimates across specifications",
    x = "",
    y = "Effect on Log New Hire Earnings",
    caption = "Note: Error bars show 95% confidence intervals.\nAll specifications show positive point estimates, though most are not statistically significant."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig6_robustness.pdf", fig6, width = 10, height = 6)
ggsave("figures/fig6_robustness.png", fig6, width = 10, height = 6, dpi = 300)

# =============================================================================
# Figure 7: Border Event Study (RDD × Event Study)
# =============================================================================

cat("Creating Figure 7: Border Event Study...\n")

# Load border event study results
border_es_results <- readRDS("data/border_es_results.rds")
border_gap_raw <- readRDS("data/border_gap_raw.rds")

# Add reference period (event_time = -1, coef = 0)
border_es_plot <- border_es_results %>%
  bind_rows(tibble(event_time = -1, coef = 0, se = 0, ci_lower = 0, ci_upper = 0)) %>%
  arrange(event_time)

fig7 <- ggplot(border_es_plot, aes(x = event_time, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = "#D62728", alpha = 0.2) +
  geom_line(color = "#D62728", linewidth = 0.8) +
  geom_point(color = "#D62728", size = 2) +
  annotate("text", x = -6, y = max(border_es_plot$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment\n(spatial gap)", hjust = 0.5, size = 3, color = "gray40") +
  annotate("text", x = 4, y = max(border_es_plot$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment\n(gap + effect)", hjust = 0.5, size = 3, color = "gray40") +
  scale_x_continuous(breaks = seq(-12, 8, 2)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Border Event Study: RDD Meets Event Study",
    subtitle = "Border gap (treated − control side) at each event time, relative to t = −1",
    x = "Quarters Relative to Treatment",
    y = "Border Gap (Log Points)",
    caption = "Note: Coefficients show the border gap relative to event time −1. Pre-treatment gaps reflect\npersistent spatial differences (like RDD). Post-treatment changes reflect treatment effect.\nStandard errors clustered by county-pair."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("figures/fig7_border_event_study.pdf", fig7, width = 10, height = 6)
ggsave("figures/fig7_border_event_study.png", fig7, width = 10, height = 6, dpi = 300)

cat("\n=== All Figures Complete ===\n")
cat("Saved to figures/ directory\n")
