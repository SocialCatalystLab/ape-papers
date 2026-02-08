# Create publication figures for paper_84
library(ggplot2)
library(dplyr)

setwd("/Users/dyanag/auto-policy-evals/output/paper_84")

# Create figures directory if needed
dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)

# Read event study coefficients
coefs <- read.csv("data/event_study_coefs.csv")

# Create event study plot
p <- ggplot(coefs, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "steelblue") +
  geom_point(size = 3, color = "steelblue") +
  geom_line(color = "steelblue") +
  scale_x_continuous(breaks = seq(-4, 5, 1)) +
  labs(
    title = "Event Study: Effect of Sports Betting Legalization on Gambling Employment",
    subtitle = "Point estimates with 95% confidence intervals (Callaway-Sant'Anna)",
    x = "Years Relative to Legalization",
    y = "ATT (Employment)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("figures/event_study.pdf", p, width = 10, height = 6)
ggsave("figures/event_study.png", p, width = 10, height = 6, dpi = 300)
cat("Event study figure saved\n")

# Read analysis panel for additional figures
panel <- read.csv("data/analysis_panel.csv")

# Create treatment timing figure - bar chart of cohort sizes
cohort_sizes <- panel %>%
  filter(G > 0) %>%
  distinct(state_fips, G) %>%
  count(G, name = "n_states")

p2 <- ggplot(cohort_sizes, aes(x = factor(G), y = n_states)) +
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.7) +
  geom_text(aes(label = n_states), vjust = -0.5) +
  labs(
    title = "Treatment Cohorts: Number of States by Legalization Year",
    x = "Year of First Legal Sports Bet",
    y = "Number of States"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave("figures/cohort_sizes.pdf", p2, width = 8, height = 5)
ggsave("figures/cohort_sizes.png", p2, width = 8, height = 5, dpi = 300)
cat("Cohort sizes figure saved\n")

# Create employment trends by treatment status
trends <- panel %>%
  filter(employment > 0) %>%
  mutate(treated_group = ifelse(G == 0, "Never Treated", "Eventually Treated")) %>%
  group_by(year, treated_group) %>%
  summarize(
    mean_emp = mean(employment, na.rm = TRUE),
    se_emp = sd(employment, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

cat("Trends data:\n")
print(trends)

p3 <- ggplot(trends, aes(x = year, y = mean_emp, color = treated_group, fill = treated_group)) +
  geom_vline(xintercept = 2018.5, linetype = "dotted", color = "gray50") +
  geom_ribbon(aes(ymin = mean_emp - 1.96 * se_emp, ymax = mean_emp + 1.96 * se_emp),
              alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = 2014:2023) +
  scale_color_brewer(palette = "Set1") +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Mean Gambling Employment by Treatment Status",
    subtitle = "Vertical line indicates Murphy v. NCAA (May 2018)",
    x = "Year",
    y = "Mean Employment (NAICS 7132)",
    color = "Group",
    fill = "Group"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

ggsave("figures/employment_trends.pdf", p3, width = 10, height = 6)
ggsave("figures/employment_trends.png", p3, width = 10, height = 6, dpi = 300)
cat("Employment trends figure saved\n")

# Save robustness results as table
robustness <- read.csv("data/robustness_results.csv")
write.csv(robustness, "tables/robustness_results.csv", row.names = FALSE)
cat("Tables saved\n")

cat("\nAll figures and tables created successfully!\n")
