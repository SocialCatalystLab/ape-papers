##############################################################################
# 05_figures.R - Generate all figures
# Revision of apep_0149: Medicaid Postpartum Coverage Extensions
# CHANGES: Extended to 2024, new Fig 6 (DDD ES), new Fig 7 (PHE vs post-PHE)
##############################################################################

source("00_packages.R")

cat("=== Generating Figures ===\n")

# Load data and results
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- tryCatch(readRDS(file.path(data_dir, "robustness_results.rds")),
                       error = function(e) NULL)
treatment_dates <- fread(file.path(data_dir, "treatment_dates.csv"))

# =========================================================
# Figure 1: Policy Adoption Timeline
# =========================================================

cat("  Figure 1: Adoption timeline\n")

adoption_by_year <- treatment_dates %>%
  count(adopt_year) %>%
  mutate(cumulative = cumsum(n))

p1 <- ggplot(adoption_by_year, aes(x = adopt_year, y = cumulative)) +
  geom_step(linewidth = 1.2, color = "#2c3e50") +
  geom_point(size = 3, color = "#2c3e50") +
  geom_text(aes(label = n), vjust = -1.5, size = 3.5, fontface = "bold") +
  geom_vline(xintercept = 2022.25, linetype = "dashed", color = "#e74c3c", linewidth = 0.8) +
  annotate("text", x = 2022.25, y = 5, label = "ARPA SPA\navailable",
           hjust = -0.1, color = "#e74c3c", size = 3) +
  geom_rect(aes(xmin = 2020, xmax = 2023.4, ymin = -Inf, ymax = Inf),
            alpha = 0.1, fill = "gray80", inherit.aes = FALSE) +
  annotate("text", x = 2021.7, y = 48, label = "PHE Continuous\nEnrollment",
           color = "gray50", size = 3, fontface = "italic") +
  scale_x_continuous(breaks = 2021:2025) +
  scale_y_continuous(limits = c(0, 52), breaks = seq(0, 50, 10)) +
  labs(
    title = "Staggered Adoption of Medicaid Postpartum Coverage Extensions",
    subtitle = "Cumulative number of states extending coverage from 60 days to 12 months",
    x = "Year of Adoption",
    y = "Cumulative Number of States",
    caption = "Notes: Numbers above points show new adopters in each year.\nGray shading indicates the PHE continuous enrollment period (March 2020 - May 2023)."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_adoption_timeline.pdf"), p1,
       width = 8, height = 5.5, dpi = 300)

# =========================================================
# Figure 2: Raw Trends in Medicaid Coverage (EXTENDED to 2024)
# =========================================================

cat("  Figure 2: Raw trends (extended to 2024)\n")

# Classify states by adoption timing
state_year_pp <- state_year_pp %>%
  mutate(
    adoption_group = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat <= 2022 ~ "Early Adopters (2021-2022)",
      first_treat >= 2023 ~ "Late Adopters (2023-2024)"
    )
  )

trends_data <- state_year_pp %>%
  group_by(year, adoption_group) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid_rate, total_weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured_rate, total_weight, na.rm = TRUE),
    .groups = "drop"
  )

# CHANGE: Updated caption and x-axis to reflect 2024 data
p2a <- ggplot(trends_data, aes(x = year, y = medicaid_rate, color = adoption_group,
                                linetype = adoption_group)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.5) +
  geom_rect(aes(xmin = 2020, xmax = 2022.5, ymin = -Inf, ymax = Inf),
            alpha = 0.05, fill = "gray80", inherit.aes = FALSE) +
  annotate("text", x = 2021.25, y = max(trends_data$medicaid_rate, na.rm = TRUE) + 0.01,
           label = "PHE", color = "gray50", size = 3, fontface = "italic") +
  geom_vline(xintercept = 2022.5, linetype = "dotted", color = "gray40", linewidth = 0.5) +
  annotate("text", x = 2023.2, y = min(trends_data$medicaid_rate, na.rm = TRUE) - 0.01,
           label = "PHE ends\nMay 2023", color = "gray40", size = 2.5, hjust = 0) +
  scale_color_manual(values = c("Early Adopters (2021-2022)" = "#3498db",
                                "Late Adopters (2023-2024)" = "#e67e22",
                                "Never Treated" = "#7f8c8d")) +
  scale_linetype_manual(values = c("Early Adopters (2021-2022)" = "solid",
                                   "Late Adopters (2023-2024)" = "dashed",
                                   "Never Treated" = "dotted")) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Medicaid Coverage Among Postpartum Women",
    subtitle = "By state adoption timing of 12-month postpartum extension",
    x = "Year",
    y = "Medicaid Coverage Rate",
    color = NULL, linetype = NULL,
    caption = "Source: ACS 1-year PUMS, 2017-2024 (excl. 2020). Women aged 18-44 who gave birth in past 12 months.\nGray shading: PHE continuous enrollment period. Dotted line: PHE end."
  ) +
  theme_apep()

p2b <- ggplot(trends_data, aes(x = year, y = uninsured_rate, color = adoption_group,
                                linetype = adoption_group)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.5) +
  geom_rect(aes(xmin = 2020, xmax = 2022.5, ymin = -Inf, ymax = Inf),
            alpha = 0.05, fill = "gray80", inherit.aes = FALSE) +
  geom_vline(xintercept = 2022.5, linetype = "dotted", color = "gray40", linewidth = 0.5) +
  scale_color_manual(values = c("Early Adopters (2021-2022)" = "#3498db",
                                "Late Adopters (2023-2024)" = "#e67e22",
                                "Never Treated" = "#7f8c8d")) +
  scale_linetype_manual(values = c("Early Adopters (2021-2022)" = "solid",
                                   "Late Adopters (2023-2024)" = "dashed",
                                   "Never Treated" = "dotted")) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Uninsurance Among Postpartum Women",
    subtitle = "By state adoption timing",
    x = "Year",
    y = "Uninsurance Rate",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

p2 <- p2a / p2b + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_raw_trends.pdf"), p2,
       width = 9, height = 10, dpi = 300)

# =========================================================
# Figure 3: CS-DiD Event Study (EXTENDED max_e = 3)
# =========================================================

cat("  Figure 3: Event study (extended to e=3)\n")

plot_event_study <- function(cs_dyn, title, ylab, color = "#2c3e50") {
  es_data <- data.frame(
    e = cs_dyn$egt,
    att = cs_dyn$att.egt,
    se = cs_dyn$se.egt
  ) %>%
    mutate(
      ci_low = att - 1.96 * se,
      ci_high = att + 1.96 * se,
      pre = as.integer(e < 0),
      # Mark post-PHE periods
      post_phe = as.integer(e >= 2)  # roughly 2023+ for 2021 cohort
    )

  ggplot(es_data, aes(x = e, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "#e74c3c") +
    geom_ribbon(aes(ymin = ci_low, ymax = ci_high), alpha = 0.2, fill = color) +
    geom_line(linewidth = 1, color = color) +
    geom_point(size = 3, color = color) +
    labs(
      title = title,
      x = "Years Relative to Adoption",
      y = ylab,
      caption = "Callaway & Sant'Anna (2021). 95% pointwise confidence intervals."
    ) +
    theme_apep()
}

p3a <- plot_event_study(results$cs_dyn$medicaid,
                         "Event Study: Medicaid Coverage (All Postpartum Women)",
                         "ATT (Medicaid Coverage Rate)",
                         "#3498db")

p3b <- plot_event_study(results$cs_dyn$uninsured,
                         "Event Study: Uninsurance (All Postpartum Women)",
                         "ATT (Uninsurance Rate)",
                         "#e74c3c")

p3c <- plot_event_study(results$cs_dyn$employer,
                         "Event Study: Employer Insurance (Placebo Outcome)",
                         "ATT (Employer Insurance Rate)",
                         "#7f8c8d")

p3 <- p3a / p3b / p3c

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), p3,
       width = 8, height = 12, dpi = 300)

# =========================================================
# Figure 4: Low-Income Subgroup Event Study
# =========================================================

cat("  Figure 4: Low-income event study\n")

p4a <- plot_event_study(results$cs_dyn$medicaid_low,
                         "Event Study: Medicaid Coverage (Low-Income Postpartum Women)",
                         "ATT (Medicaid Coverage Rate)",
                         "#2ecc71")

p4b <- plot_event_study(results$cs_dyn$uninsured_low,
                         "Event Study: Uninsurance (Low-Income Postpartum Women)",
                         "ATT (Uninsurance Rate)",
                         "#e74c3c")

p4 <- p4a / p4b

ggsave(file.path(fig_dir, "fig4_event_study_lowinc.pdf"), p4,
       width = 8, height = 8, dpi = 300)

# =========================================================
# Figure 5: Geographic Map of Adoption
# =========================================================

cat("  Figure 5: Geographic map\n")

if (requireNamespace("maps", quietly = TRUE)) {
  library(maps)

  us_states <- map_data("state")

  state_info <- data.frame(
    state_fips = c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56),
    state_name = tolower(c(
      "alabama", "alaska", "arizona", "arkansas", "california",
      "colorado", "connecticut", "delaware", "district of columbia",
      "florida", "georgia", "hawaii", "idaho", "illinois", "indiana",
      "iowa", "kansas", "kentucky", "louisiana", "maine", "maryland",
      "massachusetts", "michigan", "minnesota", "mississippi", "missouri",
      "montana", "nebraska", "nevada", "new hampshire", "new jersey",
      "new mexico", "new york", "north carolina", "north dakota", "ohio",
      "oklahoma", "oregon", "pennsylvania", "rhode island", "south carolina",
      "south dakota", "tennessee", "texas", "utah", "vermont", "virginia",
      "washington", "west virginia", "wisconsin", "wyoming"
    ))
  )

  map_data_merged <- state_info %>%
    left_join(treatment_dates %>% select(state_fips, adopt_year), by = "state_fips") %>%
    mutate(
      adopt_group = case_when(
        is.na(adopt_year) ~ "Not Adopted",
        adopt_year <= 2021 ~ "2021 (Waiver)",
        adopt_year == 2022 ~ "2022 (First Wave)",
        adopt_year == 2023 ~ "2023",
        adopt_year >= 2024 ~ "2024-2025"
      )
    ) %>%
    right_join(us_states, by = c("state_name" = "region"))

  p5 <- ggplot(map_data_merged, aes(x = long, y = lat, group = group, fill = adopt_group)) +
    geom_polygon(color = "white", linewidth = 0.3) +
    scale_fill_manual(
      values = c("2021 (Waiver)" = "#1a5276",
                 "2022 (First Wave)" = "#2980b9",
                 "2023" = "#5dade2",
                 "2024-2025" = "#aed6f1",
                 "Not Adopted" = "#e74c3c"),
      name = "Adoption Year"
    ) +
    coord_map("albers", lat0 = 39, lat1 = 45) +
    labs(
      title = "Geographic Distribution of Medicaid Postpartum Coverage Extensions",
      subtitle = "Year of adoption of 12-month postpartum Medicaid coverage"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      legend.position = "bottom"
    )

  ggsave(file.path(fig_dir, "fig5_adoption_map.pdf"), p5,
         width = 10, height = 6, dpi = 300)
}

# =========================================================
# NEW Figure 6: DDD Event Study
# =========================================================

cat("  Figure 6: DDD event study\n")

if (!is.null(results$ddd$cs_dyn_medicaid)) {
  p6 <- plot_event_study(results$ddd$cs_dyn_medicaid,
                          "Triple-Difference Event Study: Postpartum vs Non-Postpartum",
                          "DDD ATT (Differenced Medicaid Rate: PP - Non-PP)",
                          "#8e44ad")
  p6 <- p6 + labs(
    caption = paste0("Callaway & Sant'Anna (2021) on differenced outcome ",
                     "(postpartum - non-postpartum low-income women Medicaid rate).\n",
                     "95% pointwise confidence intervals.")
  )
} else {
  # Fallback: use DDD TWFE coefficients as a bar chart
  ddd_coefs <- data.frame(
    outcome = c("Medicaid", "Uninsured", "Employer"),
    estimate = c(coef(results$ddd$twfe_medicaid)[1],
                 coef(results$ddd$twfe_uninsured)[1],
                 coef(results$ddd$twfe_employer)[1]),
    se = c(se(results$ddd$twfe_medicaid)[1],
           se(results$ddd$twfe_uninsured)[1],
           se(results$ddd$twfe_employer)[1])
  ) %>%
    mutate(
      ci_low = estimate - 1.96 * se,
      ci_high = estimate + 1.96 * se
    )

  p6 <- ggplot(ddd_coefs, aes(x = outcome, y = estimate, fill = outcome)) +
    geom_col(width = 0.6, alpha = 0.8) +
    geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    scale_fill_manual(values = c("Medicaid" = "#3498db",
                                 "Uninsured" = "#e74c3c",
                                 "Employer" = "#7f8c8d")) +
    labs(
      title = "Triple-Difference Estimates (DDD)",
      subtitle = "Postpartum vs non-postpartum low-income women, treated vs control states",
      x = NULL, y = "DDD Estimate (pp)",
      caption = "TWFE DDD: treated x postpartum_ind with state^postpartum and year^postpartum FE.\n95% confidence intervals based on state-clustered standard errors."
    ) +
    theme_apep() +
    theme(legend.position = "none")
}

ggsave(file.path(fig_dir, "fig6_ddd.pdf"), p6,
       width = 8, height = 6, dpi = 300)

# =========================================================
# NEW Figure 7: PHE-Period vs Post-PHE ATTs
# =========================================================

cat("  Figure 7: PHE vs Post-PHE comparison\n")

# Extract calendar-time ATTs
cal_data <- NULL
if (!is.null(results$cs_cal$medicaid)) {
  cal_obj <- results$cs_cal$medicaid
  cal_data <- data.frame(
    year = cal_obj$egt,
    att = cal_obj$att.egt,
    se = cal_obj$se.egt
  ) %>%
    mutate(
      ci_low = att - 1.96 * se,
      ci_high = att + 1.96 * se,
      period = ifelse(year <= 2022, "PHE Period\n(2021-2022)", "Post-PHE\n(2023-2024)")
    )
}

if (!is.null(cal_data) && nrow(cal_data) > 0) {
  # Panel A: Calendar-time ATTs
  p7a <- ggplot(cal_data, aes(x = year, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_rect(aes(xmin = 2020.5, xmax = 2022.5, ymin = -Inf, ymax = Inf),
              alpha = 0.1, fill = "gray80", inherit.aes = FALSE) +
    geom_point(aes(color = period), size = 4) +
    geom_errorbar(aes(ymin = ci_low, ymax = ci_high, color = period), width = 0.2) +
    scale_color_manual(values = c("PHE Period\n(2021-2022)" = "#e67e22",
                                   "Post-PHE\n(2023-2024)" = "#2ecc71")) +
    labs(
      title = "Calendar-Time ATTs: PHE vs Post-PHE",
      subtitle = "CS-DiD Medicaid coverage effect by calendar year",
      x = "Calendar Year", y = "ATT (Medicaid Coverage Rate)",
      color = NULL,
      caption = "Callaway & Sant'Anna (2021) calendar-time aggregation.\n95% pointwise confidence intervals."
    ) +
    theme_apep()

  # Panel B: Bar chart comparing PHE vs post-PHE average ATT
  period_avg <- cal_data %>%
    group_by(period) %>%
    summarise(
      mean_att = mean(att),
      mean_se = sqrt(mean(se^2)),
      .groups = "drop"
    ) %>%
    mutate(
      ci_low = mean_att - 1.96 * mean_se,
      ci_high = mean_att + 1.96 * mean_se
    )

  p7b <- ggplot(period_avg, aes(x = period, y = mean_att, fill = period)) +
    geom_col(width = 0.6, alpha = 0.8) +
    geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    scale_fill_manual(values = c("PHE Period\n(2021-2022)" = "#e67e22",
                                  "Post-PHE\n(2023-2024)" = "#2ecc71")) +
    labs(
      title = "Average ATT by Period",
      subtitle = "PHE-period vs post-PHE Medicaid coverage effect",
      x = NULL, y = "Mean ATT (Medicaid Coverage Rate)"
    ) +
    theme_apep() +
    theme(legend.position = "none")

  p7 <- p7a / p7b

  ggsave(file.path(fig_dir, "fig7_phe_comparison.pdf"), p7,
         width = 9, height = 10, dpi = 300)
} else {
  cat("  No calendar-time data available for Fig 7\n")
}

cat("\n=== Figures complete ===\n")
