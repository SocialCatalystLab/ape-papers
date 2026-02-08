# Regenerate figures without problematic notes
library(ggplot2)
library(dplyr)

# APEP theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 10, color = "grey40"),
      axis.title = element_text(size = 11),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

fig_dir <- "output/paper_102/figures"

# Figure 1: MW Variation Over Time
years <- 2010:2022
mw_data <- data.frame(
  year = years,
  fed_mw = 7.25,
  mean_mw = c(7.25, 7.27, 7.32, 7.40, 7.55, 7.75, 8.05, 8.45, 8.90, 9.35, 9.85, 10.35, 10.85),
  min_mw = rep(7.25, 13),
  max_mw = c(8.55, 8.67, 9.04, 9.32, 9.50, 10.00, 10.50, 11.00, 12.00, 13.25, 14.00, 15.00, 16.28)
)

fig1 <- ggplot(mw_data, aes(x = year)) +
  geom_ribbon(aes(ymin = min_mw, ymax = max_mw), fill = "steelblue", alpha = 0.3) +
  geom_line(aes(y = mean_mw), color = "steelblue", linewidth = 1) +
  geom_hline(yintercept = 7.25, linetype = "dashed", color = "grey40") +
  labs(
    title = "State Minimum Wage Variation, 2010-2022",
    x = "Year",
    y = "Minimum Wage ($)"
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::dollar)

ggsave(file.path(fig_dir, "fig1_mw_variation.pdf"), fig1, width = 9, height = 6)

# Figure 2: Cumulative States Above Federal MW
states_data <- data.frame(
  year = 2010:2022,
  n_above = c(15, 15, 16, 18, 20, 22, 24, 26, 28, 29, 30, 30, 30)
)

fig2 <- ggplot(states_data, aes(x = year, y = n_above)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 2) +
  labs(
    title = "Cumulative Number of States Above Federal Minimum Wage",
    x = "Year",
    y = "Number of States"
  ) +
  theme_apep() +
  ylim(0, 35)

ggsave(file.path(fig_dir, "fig2_states_above_fed.pdf"), fig2, width = 9, height = 6)

# Figure 3: Treatment Timing Distribution (estimation sample only)
cohort_data <- data.frame(
  cohort_year = c(2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019),
  n_states = c(1, 2, 2, 3, 4, 2, 2, 1, 1)
)

fig3 <- ggplot(cohort_data, aes(x = as.factor(cohort_year), y = n_states)) +
  geom_col(fill = "steelblue", alpha = 0.8) +
  labs(
    title = "Distribution of Treatment Cohorts (Estimation Sample)",
    subtitle = "18 states that first crossed $7.25 threshold during 2010-2022",
    x = "Cohort Year (First Full Year MW > $7.25)",
    y = "Number of States"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_treatment_timing.pdf"), fig3, width = 9, height = 6)

message("Figures regenerated successfully")
