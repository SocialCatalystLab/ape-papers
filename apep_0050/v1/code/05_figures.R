# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 05_figures.R - Publication-Quality Figures
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Load Data and Results
# ============================================================================

message("Loading data and results...")
cps <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
results <- readRDS("data/main_results.rds")
robustness <- readRDS("data/robustness_results.rds")

# ============================================================================
# Figure 1: Policy Adoption Map
# ============================================================================

message("Creating Figure 1: Policy adoption map...")

# Get US states shapefile
states_sf <- tigris::states(cb = TRUE, class = "sf") %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%  # Exclude AK, HI, territories
  shift_geometry()  # Move AK/HI if wanted

# Prepare treatment data for mapping
treatment_map <- cps %>%
  distinct(statefip, treatment_year, cohort) %>%
  mutate(
    STATEFP = sprintf("%02d", statefip),
    adoption_year = ifelse(treatment_year == 0, "Not adopted", as.character(treatment_year))
  )

# Merge with shapefile
states_map <- states_sf %>%
  left_join(treatment_map, by = "STATEFP") %>%
  mutate(
    adoption_year = factor(
      adoption_year,
      levels = c("2021", "2023", "2024", "2025", "Not adopted")
    )
  )

# Create map
fig1 <- ggplot(states_map) +
  geom_sf(aes(fill = adoption_year), color = "white", size = 0.2) +
  scale_fill_manual(
    values = c(
      "2021" = "#1a9850",
      "2023" = "#91cf60",
      "2024" = "#d9ef8b",
      "2025" = "#fee08b",
      "Not adopted" = "#f7f7f7"
    ),
    na.value = "#f7f7f7",
    name = "Adoption Year"
  ) +
  labs(
    title = "State Salary Transparency Law Adoption",
    subtitle = "Laws requiring salary range disclosure in job postings",
    caption = "Note: Shows states with laws effective by end of 2025.\nStates shown in grey have not adopted transparency laws as of 2025."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9)
  ) +
  guides(fill = guide_legend(nrow = 1))

save_figure(fig1, "fig1_adoption_map.pdf", width = 10, height = 7)
save_figure(fig1, "fig1_adoption_map.png", width = 10, height = 7)

# ============================================================================
# Figure 2: Treatment Rollout Timeline
# ============================================================================

message("Creating Figure 2: Treatment rollout timeline...")

treatment_timeline <- cps %>%
  distinct(state_name, treatment_year, threshold) %>%
  filter(treatment_year > 0) %>%
  arrange(treatment_year) %>%
  mutate(
    state_name = factor(state_name, levels = state_name),
    threshold_label = case_when(
      threshold == 1 ~ "All employers",
      threshold <= 5 ~ paste0(threshold, "+ employees"),
      TRUE ~ paste0(threshold, "+ employees")
    )
  )

fig2 <- ggplot(treatment_timeline,
               aes(x = treatment_year, y = fct_rev(state_name))) +
  geom_segment(aes(x = 2016, xend = treatment_year,
                   y = fct_rev(state_name), yend = fct_rev(state_name)),
               color = "grey80", linewidth = 0.5) +
  geom_point(aes(color = factor(treatment_year)), size = 4) +
  geom_text(aes(label = threshold_label), hjust = -0.2, size = 3) +
  scale_color_manual(
    values = c("2021" = "#1a9850", "2023" = "#91cf60",
               "2024" = "#d9ef8b", "2025" = "#fee08b"),
    name = "Adoption Year"
  ) +
  scale_x_continuous(
    breaks = 2016:2025,
    limits = c(2016, 2026)
  ) +
  labs(
    title = "Staggered Adoption of Salary Transparency Laws",
    subtitle = "Effective dates and employer size thresholds",
    x = "Year",
    y = NULL,
    caption = "Note: Employer threshold refers to minimum number of employees for law to apply."
  ) +
  theme_apep() +
  theme(
    panel.grid.major.y = element_blank(),
    legend.position = "none"
  )

save_figure(fig2, "fig2_treatment_timeline.pdf", width = 9, height = 6)
save_figure(fig2, "fig2_treatment_timeline.png", width = 9, height = 6)

# ============================================================================
# Figure 3: Raw Outcome Trends by Cohort
# ============================================================================

message("Creating Figure 3: Raw outcome trends...")

cohort_trends <- state_year %>%
  group_by(cohort, year) %>%
  summarise(
    mean_earn = mean(mean_log_earn, na.rm = TRUE),
    se_earn = sd(mean_log_earn, na.rm = TRUE) / sqrt(n()),
    n_states = n(),
    .groups = "drop"
  ) %>%
  filter(cohort %in% c("2021", "2023", "2024", "2025", "Never treated"))

# Vertical lines for treatment years
treatment_lines <- tibble(
  cohort = c("2021", "2023", "2024", "2025"),
  treat_year = c(2021, 2023, 2024, 2025)
)

fig3 <- ggplot(cohort_trends, aes(x = year, y = mean_earn, color = cohort)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean_earn - 1.96 * se_earn,
                  ymax = mean_earn + 1.96 * se_earn,
                  fill = cohort),
              alpha = 0.2, color = NA) +
  # Add vertical treatment lines
  geom_vline(data = treatment_lines,
             aes(xintercept = treat_year, color = cohort),
             linetype = "dashed", alpha = 0.5) +
  scale_color_manual(
    values = c(
      "2021" = "#1a9850",
      "2023" = "#91cf60",
      "2024" = "#d9ef8b",
      "2025" = "#fee08b",
      "Never treated" = "#d73027"
    ),
    name = "Treatment Cohort"
  ) +
  scale_fill_manual(
    values = c(
      "2021" = "#1a9850",
      "2023" = "#91cf60",
      "2024" = "#d9ef8b",
      "2025" = "#fee08b",
      "Never treated" = "#d73027"
    ),
    guide = "none"
  ) +
  labs(
    title = "Average Log Weekly Earnings by Treatment Cohort",
    subtitle = "State-level means with 95% confidence intervals",
    x = "Year",
    y = "Log Weekly Earnings",
    caption = "Note: Dashed vertical lines indicate treatment year for each cohort.\nNever-treated states shown for comparison."
  ) +
  theme_apep() +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 1))

save_figure(fig3, "fig3_cohort_trends.pdf", width = 10, height = 6)
save_figure(fig3, "fig3_cohort_trends.png", width = 10, height = 6)

# ============================================================================
# Figure 4: Event Study - Main Result
# ============================================================================

message("Creating Figure 4: Event study...")

# Extract event study results from Callaway-Sant'Anna
es_att <- results$es_att

# Create event study data frame
es_df <- tibble(
  event_time = es_att$egt,
  estimate = es_att$att.egt,
  se = es_att$se.egt
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    significant = ci_lower > 0 | ci_upper < 0
  )

fig4 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
  # Reference line at zero
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  # Reference line at treatment
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30", linewidth = 0.5) +
  # Confidence intervals
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, color = apep_colors["treated"]) +
  # Point estimates
  geom_point(aes(fill = significant), shape = 21, size = 3, color = "black") +
  scale_fill_manual(values = c("TRUE" = apep_colors["treated"],
                               "FALSE" = "white"),
                    guide = "none") +
  scale_x_continuous(breaks = seq(-5, 4, by = 1)) +
  labs(
    title = "Effect of Salary Transparency Laws on Log Weekly Earnings",
    subtitle = "Callaway-Sant'Anna event study estimates",
    x = "Years Relative to Treatment",
    y = "ATT (Log Points)",
    caption = "Note: Estimates from Callaway-Sant'Anna (2021) with not-yet-treated control group.\nClustered standard errors at state level. 95% confidence intervals shown."
  ) +
  theme_apep() +
  annotate("text", x = -3, y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", size = 3.5, color = "grey40") +
  annotate("text", x = 2, y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment", size = 3.5, color = "grey40")

save_figure(fig4, "fig4_event_study.pdf", width = 10, height = 6)
save_figure(fig4, "fig4_event_study.png", width = 10, height = 6)

# ============================================================================
# Figure 5: Gender Wage Gap Event Study
# ============================================================================

message("Creating Figure 5: Gender wage gap event study...")

# Extract gender gap event study
gap_es <- results$gap_es

# Get coefficients from Sun-Abraham model
gap_coefs <- coef(gap_es)
gap_se <- se(gap_es)

# Parse event time from coefficient names
gap_df <- tibble(
  term = names(gap_coefs),
  estimate = gap_coefs,
  se = gap_se
) %>%
  filter(grepl("cohort_year", term)) %>%
  mutate(
    event_time = as.numeric(gsub(".*::([-0-9]+)", "\\1", term)),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

fig5 <- ggplot(gap_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30", linewidth = 0.5) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, color = apep_colors["female"]) +
  geom_point(size = 3, color = apep_colors["female"]) +
  scale_x_continuous(breaks = seq(-5, 4, by = 1)) +
  labs(
    title = "Effect of Salary Transparency Laws on Gender Wage Gap",
    subtitle = "Change in female-male log wage differential",
    x = "Years Relative to Treatment",
    y = "Change in Gender Gap (Log Points)",
    caption = "Note: Negative values indicate reduction in gender wage gap.\nSun-Abraham event study with state and year fixed effects."
  ) +
  theme_apep()

save_figure(fig5, "fig5_gender_gap_event_study.pdf", width = 10, height = 6)
save_figure(fig5, "fig5_gender_gap_event_study.png", width = 10, height = 6)

# ============================================================================
# Figure 6: Heterogeneity by Gender
# ============================================================================

message("Creating Figure 6: Heterogeneity by gender...")

# Extract heterogeneity results
het_df <- tibble(
  Group = c("All Workers", "Male", "Female", "College+", "No College"),
  ATT = c(
    results$overall_att$overall.att,
    results$het_male$overall.att,
    results$het_female$overall.att,
    results$het_college$overall.att,
    results$het_nocollege$overall.att
  ),
  SE = c(
    results$overall_att$overall.se,
    results$het_male$overall.se,
    results$het_female$overall.se,
    results$het_college$overall.se,
    results$het_nocollege$overall.se
  )
) %>%
  mutate(
    ci_lower = ATT - 1.96 * SE,
    ci_upper = ATT + 1.96 * SE,
    Group = factor(Group, levels = rev(c("All Workers", "Male", "Female",
                                          "College+", "No College")))
  )

fig6 <- ggplot(het_df, aes(x = ATT, y = Group)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = apep_colors["treated"]) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  labs(
    title = "Heterogeneous Treatment Effects",
    subtitle = "Callaway-Sant'Anna ATT by subgroup",
    x = "ATT (Log Points)",
    y = NULL,
    caption = "Note: 95% confidence intervals with state-clustered standard errors."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

save_figure(fig6, "fig6_heterogeneity.pdf", width = 8, height = 5)
save_figure(fig6, "fig6_heterogeneity.png", width = 8, height = 5)

# ============================================================================
# Figure 7: Robustness Across Specifications
# ============================================================================

message("Creating Figure 7: Robustness across specifications...")

robust_df <- robustness$robustness_summary %>%
  mutate(
    Specification = factor(
      Specification,
      levels = rev(c(
        "Main (not-yet-treated control)",
        "Never-treated control only",
        "Excluding Colorado",
        "Balanced panel",
        "TWFE (biased comparison)"
      ))
    )
  )

fig7 <- ggplot(robust_df, aes(x = ATT, y = Specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  # Highlight main estimate
  geom_rect(data = robust_df %>% filter(Specification == "Main (not-yet-treated control)"),
            aes(xmin = -Inf, xmax = Inf, ymin = as.numeric(Specification) - 0.4,
                ymax = as.numeric(Specification) + 0.4),
            fill = "lightblue", alpha = 0.3) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper),
                 height = 0.2, color = apep_colors["treated"]) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  labs(
    title = "Robustness Across Specifications",
    subtitle = "Overall ATT estimates",
    x = "ATT (Log Points)",
    y = NULL,
    caption = "Note: Main specification highlighted. 95% confidence intervals shown."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

save_figure(fig7, "fig7_robustness.pdf", width = 9, height = 5)
save_figure(fig7, "fig7_robustness.png", width = 9, height = 5)

# ============================================================================
# Figure 8: Wage Distribution Before/After
# ============================================================================

message("Creating Figure 8: Wage distribution shifts...")

# Compare wage distributions in treated states before/after
wage_dist <- cps %>%
  filter(ever_treated, treatment_year == 2021) %>%  # Colorado
  mutate(
    period = ifelse(year < treatment_year, "Pre-treatment (2016-2020)",
                    "Post-treatment (2021-2024)")
  )

fig8 <- ggplot(wage_dist, aes(x = log_earnweek, fill = period)) +
  geom_density(alpha = 0.5, color = NA) +
  scale_fill_manual(
    values = c("Pre-treatment (2016-2020)" = apep_colors["control"],
               "Post-treatment (2021-2024)" = apep_colors["treated"]),
    name = NULL
  ) +
  labs(
    title = "Wage Distribution in Colorado Before and After Transparency Law",
    subtitle = "Kernel density of log weekly earnings",
    x = "Log Weekly Earnings",
    y = "Density",
    caption = "Note: Colorado adopted salary transparency law effective January 1, 2021."
  ) +
  theme_apep() +
  theme(legend.position = c(0.8, 0.8))

save_figure(fig8, "fig8_wage_distribution.pdf", width = 9, height = 6)
save_figure(fig8, "fig8_wage_distribution.png", width = 9, height = 6)

# ============================================================================
# Figure 9: Gender Gap Over Time
# ============================================================================

message("Creating Figure 9: Gender gap over time...")

gender_gap_time <- cps %>%
  group_by(year, ever_treated) %>%
  summarise(
    mean_earn_male = weighted.mean(log_earnweek[female == 0], earnwt[female == 0], na.rm = TRUE),
    mean_earn_female = weighted.mean(log_earnweek[female == 1], earnwt[female == 1], na.rm = TRUE),
    gender_gap = mean_earn_male - mean_earn_female,
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    group = ifelse(ever_treated, "Treated States", "Control States")
  )

fig9 <- ggplot(gender_gap_time, aes(x = year, y = gender_gap, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_color_manual(
    values = c("Treated States" = apep_colors["treated"],
               "Control States" = apep_colors["control"]),
    name = NULL
  ) +
  labs(
    title = "Gender Wage Gap Over Time",
    subtitle = "Male-female log wage differential",
    x = "Year",
    y = "Gender Gap (Log Points)",
    caption = "Note: Higher values indicate larger male wage premium.\nTreated states = states adopting transparency laws by 2025."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

save_figure(fig9, "fig9_gender_gap_time.pdf", width = 9, height = 6)
save_figure(fig9, "fig9_gender_gap_time.png", width = 9, height = 6)

# ============================================================================
# Figure 10: Bacon Decomposition (if available)
# ============================================================================

message("Creating Figure 10: Supplementary figures...")

# Additional figures for appendix would go here

message("\n=== All Figures Complete ===")
message("Figures saved to: figures/")
