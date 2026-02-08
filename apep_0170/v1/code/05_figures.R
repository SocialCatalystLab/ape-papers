# ==============================================================================
# 05_figures.R - Generate Publication-Quality Figures
# Paper: Salary History Bans and Wage Compression
# ==============================================================================

library(tidyverse)
library(patchwork)
library(scales)
library(here)

# Set paths relative to paper directory
data_dir <- file.path(here::here(), "data")
figures_dir <- file.path(here::here(), "figures")

# APEP theme
theme_apep <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      legend.position = "bottom",
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_apep())

# Load data
state_year <- read_csv(file.path(data_dir, "state_year_wages.csv"),
                       show_col_types = FALSE)

event_study <- tryCatch(
  read_csv(file.path(data_dir, "event_study_estimates.csv"), show_col_types = FALSE),
  error = function(e) NULL
)

# ------------------------------------------------------------------------------
# Figure 1: Treatment Timing Map
# ------------------------------------------------------------------------------

treatment_dates <- read_csv(file.path(data_dir, "shb_treatment_dates.csv"),
                           show_col_types = FALSE)

# Create adoption year summary
adoption_by_year <- treatment_dates %>%
  count(effective_year, name = "n_states") %>%
  mutate(cumulative = cumsum(n_states))

fig1 <- ggplot(adoption_by_year, aes(x = effective_year)) +
  geom_col(aes(y = n_states), fill = "steelblue", alpha = 0.7) +
  geom_line(aes(y = cumulative), color = "darkred", linewidth = 1) +
  geom_point(aes(y = cumulative), color = "darkred", size = 2) +
  scale_x_continuous(breaks = 2017:2023) +
  scale_y_continuous(
    name = "States Adopting (bars)",
    sec.axis = sec_axis(~., name = "Cumulative Adoptions (line)")
  ) +
  labs(
    title = "Salary History Ban Adoption Across States",
    subtitle = "Number of states enacting bans by year",
    x = "Year"
  ) +
  theme_apep()

ggsave(file.path(figures_dir, "fig1_adoption_timeline.pdf"), fig1,
       width = 8, height = 5)

# ------------------------------------------------------------------------------
# Figure 2: Pre-Treatment Trends in Wage Inequality
# ------------------------------------------------------------------------------

# Compare treated vs control states over time
trends_data <- state_year %>%
  mutate(group = ifelse(first_treat > 0, "Later Treated", "Never Treated")) %>%
  group_by(year, group) %>%
  summarise(
    mean_p90p10 = mean(p90_p10, na.rm = TRUE),
    se = sd(p90_p10, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig2 <- ggplot(trends_data, aes(x = year, y = mean_p90p10, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean_p90p10 - 1.96*se, 
                  ymax = mean_p90p10 + 1.96*se,
                  fill = group), alpha = 0.2, color = NA) +
  geom_vline(xintercept = 2017.5, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2018, y = max(trends_data$mean_p90p10), 
           label = "First major\nadoptions", hjust = 0, size = 3) +
  scale_color_manual(values = c("Later Treated" = "steelblue", 
                                "Never Treated" = "coral")) +
  scale_fill_manual(values = c("Later Treated" = "steelblue", 
                               "Never Treated" = "coral")) +
  labs(
    title = "Wage Inequality Trends: Treated vs. Control States",
    subtitle = "90-10 log wage gap by year",
    x = "Year",
    y = "90-10 Log Wage Gap",
    color = NULL,
    fill = NULL
  ) +
  theme_apep()

ggsave(file.path(figures_dir, "fig2_parallel_trends.pdf"), fig2,
       width = 8, height = 5)

# ------------------------------------------------------------------------------
# Figure 3: Event Study Plot (Callaway-Sant'Anna)
# ------------------------------------------------------------------------------

if (!is.null(event_study)) {
  fig3 <- ggplot(event_study, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_low, ymax = ci_high), 
                fill = "steelblue", alpha = 0.2) +
    geom_line(color = "steelblue", linewidth = 1) +
    geom_point(color = "steelblue", size = 3) +
    scale_x_continuous(breaks = seq(-5, 5, 1)) +
    labs(
      title = "Effect of Salary History Bans on Wage Inequality",
      subtitle = "Callaway-Sant'Anna event study estimates",
      x = "Years Relative to Treatment",
      y = "ATT: Change in 90-10 Log Wage Gap"
    ) +
    theme_apep()
  
  ggsave(file.path(figures_dir, "fig3_event_study.pdf"), fig3,
         width = 8, height = 5)
  
} else {
  cat("Event study data not available. Skipping Figure 3.\n")
}

# ------------------------------------------------------------------------------
# Figure 4: Heterogeneity - Job Changers vs. All Workers
# ------------------------------------------------------------------------------

# Load job changer data
job_changers <- tryCatch(
  read_csv(file.path(data_dir, "job_changer_wages.csv"), show_col_types = FALSE),
  error = function(e) NULL
)

if (!is.null(job_changers)) {
  # Compare trends
  compare_data <- bind_rows(
    state_year %>% 
      mutate(sample = "All Workers") %>%
      group_by(year, sample, group = ifelse(first_treat > 0, "Treated", "Control")) %>%
      summarise(mean_p90p10 = mean(p90_p10, na.rm = TRUE), .groups = "drop"),
    job_changers %>% 
      mutate(sample = "Job Changers") %>%
      group_by(year, sample, group = ifelse(first_treat > 0, "Treated", "Control")) %>%
      summarise(mean_p90p10 = mean(p90_p10, na.rm = TRUE), .groups = "drop")
  )
  
  fig4 <- ggplot(compare_data, aes(x = year, y = mean_p90p10, 
                                   color = group, linetype = sample)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2) +
    geom_vline(xintercept = 2017.5, linetype = "dashed", color = "gray70") +
    scale_color_manual(values = c("Treated" = "steelblue", "Control" = "coral")) +
    facet_wrap(~sample) +
    labs(
      title = "Wage Inequality by Sample: All Workers vs. Job Changers",
      subtitle = "Comparing exposure to salary history bans",
      x = "Year",
      y = "90-10 Log Wage Gap",
      color = NULL,
      linetype = NULL
    ) +
    theme_apep() +
    theme(legend.position = "bottom")
  
  ggsave(file.path(figures_dir, "fig4_heterogeneity.pdf"), fig4,
         width = 10, height = 5)
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

cat("\n")
cat(strrep("=", 60), "\n")
cat("FIGURES GENERATED\n")
cat(strrep("=", 60), "\n")
cat("\nFigures saved to figures/:\n")
cat("  - fig1_adoption_timeline.pdf\n")
cat("  - fig2_parallel_trends.pdf\n")
cat("  - fig3_event_study.pdf (if data available)\n")
cat("  - fig4_heterogeneity.pdf (if data available)\n")
