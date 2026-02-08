# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 05_figures.R - Generate publication-quality figures
# ==============================================================================

source("00_packages.R")
library(patchwork)

# Load data
analysis_sample <- read_csv(file.path(dir_data, "analysis_sample.csv"),
                            show_col_types = FALSE)
es_data <- read_csv(file.path(dir_tables, "event_study_data.csv"),
                    show_col_types = FALSE)

message("Generating figures...")

# ==============================================================================
# Figure 1: Trends in Business Applications by Treatment Status
# ==============================================================================

trends_data <- analysis_sample %>%
  mutate(
    group = if_else(treated_ever, "Will be Treated (2023+)", "Never Treated")
  ) %>%
  group_by(group, date) %>%
  summarise(
    mean_apps = mean(business_apps, na.rm = TRUE),
    se_apps = sd(business_apps, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig1 <- ggplot(trends_data, aes(x = date, y = mean_apps, color = group)) +
  geom_vline(xintercept = as.Date("2023-01-01"), linetype = "dashed",
             color = "gray50", alpha = 0.7) +
  geom_ribbon(aes(ymin = mean_apps - 1.96 * se_apps,
                  ymax = mean_apps + 1.96 * se_apps,
                  fill = group), alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("Will be Treated (2023+)" = "#e41a1c",
                                "Never Treated" = "#377eb8")) +
  scale_fill_manual(values = c("Will be Treated (2023+)" = "#e41a1c",
                               "Never Treated" = "#377eb8")) +
  annotate("text", x = as.Date("2023-03-01"), y = max(trends_data$mean_apps) * 0.95,
           label = "First privacy\nlaws effective", hjust = 0, size = 3,
           color = "gray30") +
  labs(
    title = "Business Applications by Treatment Status",
    subtitle = "High-propensity business applications, monthly, 2018-2025",
    x = NULL,
    y = "Mean Business Applications",
    color = NULL,
    fill = NULL
  ) +
  theme(
    legend.position = c(0.15, 0.9),
    legend.background = element_rect(fill = "white", color = NA)
  )

ggsave(file.path(dir_figures, "fig1_trends.pdf"), fig1, width = 10, height = 6)
ggsave(file.path(dir_figures, "fig1_trends.png"), fig1, width = 10, height = 6, dpi = 300)

message("Saved: fig1_trends.pdf")

# ==============================================================================
# Figure 2: Event Study
# ==============================================================================

fig2 <- ggplot(es_data, aes(x = rel_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray70") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "firebrick", alpha = 0.6) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.15, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.8) +
  geom_point(color = "steelblue", size = 2.5) +
  annotate("text", x = 1, y = max(es_data$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment", hjust = 0, size = 3.5, color = "gray30") +
  annotate("text", x = -2, y = max(es_data$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", hjust = 1, size = 3.5, color = "gray30") +
  scale_x_continuous(breaks = seq(-24, 24, by = 6)) +
  labs(
    title = "Event Study: Effect of Privacy Laws on Business Applications",
    subtitle = "Callaway-Sant'Anna estimator with 95% confidence intervals",
    x = "Months Relative to Law Effective Date",
    y = "Average Treatment Effect"
  )

ggsave(file.path(dir_figures, "fig2_event_study.pdf"), fig2, width = 10, height = 6)
ggsave(file.path(dir_figures, "fig2_event_study.png"), fig2, width = 10, height = 6, dpi = 300)

message("Saved: fig2_event_study.pdf")

# ==============================================================================
# Figure 3: Map of Privacy Law Adoption
# ==============================================================================

library(maps)
library(sf)

# Get US states map data
us_map <- map_data("state")

# State name to abbreviation mapping
state_mapping <- tibble(
  region = tolower(state.name),
  state_abbr = state.abb
)

# Privacy law effective dates (statutory, not treatment-coded)
# These match Table 1 in the paper
statutory_dates <- tribble(
  ~state_abbr, ~effective_year,
  "VA", 2023,
  "CO", 2023,
  "CT", 2023,
  "UT", 2023,  # Dec 31, 2023 - statutory year is 2023
  "TX", 2024,
  "OR", 2024,
  "MT", 2024,
  "IA", 2025,
  "DE", 2025,
  "NH", 2025,
  "NJ", 2025,
  "NE", 2025,
  "CA", 2020  # California for reference
)

# All other states have no privacy law
all_states <- tibble(state_abbr = c(state.abb, "DC"))
privacy_status <- all_states %>%
  left_join(statutory_dates, by = "state_abbr") %>%
  mutate(
    status = case_when(
      state_abbr == "CA" ~ "2020 (CA)",
      effective_year == 2023 ~ "2023",
      effective_year == 2024 ~ "2024",
      effective_year == 2025 ~ "2025+",
      TRUE ~ "No Privacy Law"
    )
  )

# Merge with map data
map_data_merged <- us_map %>%
  left_join(state_mapping, by = "region") %>%
  left_join(privacy_status, by = "state_abbr") %>%
  # Replace NA status with "No Privacy Law" to avoid NA in legend
  mutate(status = if_else(is.na(status), "No Privacy Law", status))

fig3 <- ggplot(map_data_merged, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = status), color = "white", linewidth = 0.3) +
  scale_fill_manual(
    values = c(
      "No Privacy Law" = "#d9d9d9",
      "2020 (CA)" = "#08519c",
      "2023" = "#3182bd",
      "2024" = "#6baed6",
      "2025+" = "#bdd7e7"
    ),
    name = "Privacy Law\nEffective Date",
    na.translate = FALSE
  ) +
  coord_fixed(1.3) +
  labs(
    title = "State Comprehensive Privacy Law Adoption",
    subtitle = "As of January 2025"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    legend.position = "right"
  )

ggsave(file.path(dir_figures, "fig3_map.pdf"), fig3, width = 12, height = 8)
ggsave(file.path(dir_figures, "fig3_map.png"), fig3, width = 12, height = 8, dpi = 300)

message("Saved: fig3_map.pdf")

# ==============================================================================
# Figure 4: Pre-treatment Covariate Balance
# ==============================================================================

# Calculate pre-treatment means by treatment status
balance_data <- analysis_sample %>%
  filter(date < "2023-01-01") %>%
  group_by(state_abbr) %>%
  summarise(
    treated_ever = first(treated_ever),
    mean_apps = mean(business_apps, na.rm = TRUE),
    mean_unemp = mean(unemployment_rate, na.rm = TRUE),
    .groups = "drop"
  )

fig4a <- ggplot(balance_data, aes(x = factor(treated_ever), y = mean_apps)) +
  geom_boxplot(aes(fill = factor(treated_ever)), alpha = 0.7) +
  scale_fill_manual(values = c("FALSE" = "#377eb8", "TRUE" = "#e41a1c"),
                    labels = c("Never Treated", "Treated")) +
  labs(
    title = "Pre-Treatment Business Applications",
    x = NULL,
    y = "Mean Monthly Applications (2018-2022)",
    fill = NULL
  ) +
  theme(legend.position = "none")

fig4b <- ggplot(balance_data, aes(x = factor(treated_ever), y = mean_unemp)) +
  geom_boxplot(aes(fill = factor(treated_ever)), alpha = 0.7) +
  scale_fill_manual(values = c("FALSE" = "#377eb8", "TRUE" = "#e41a1c"),
                    labels = c("Never Treated", "Treated")) +
  labs(
    title = "Pre-Treatment Unemployment Rate",
    x = NULL,
    y = "Mean Unemployment Rate (2018-2022)",
    fill = NULL
  ) +
  scale_x_discrete(labels = c("Never Treated", "Treated")) +
  theme(legend.position = "none")

fig4 <- fig4a + fig4b +
  plot_annotation(
    title = "Pre-Treatment Covariate Balance",
    theme = theme(plot.title = element_text(size = 14, face = "bold"))
  )

ggsave(file.path(dir_figures, "fig4_balance.pdf"), fig4, width = 10, height = 5)
ggsave(file.path(dir_figures, "fig4_balance.png"), fig4, width = 10, height = 5, dpi = 300)

message("Saved: fig4_balance.pdf")

# ==============================================================================
# Summary
# ==============================================================================

message("\n", strrep("=", 60))
message("FIGURES COMPLETE")
message(strrep("=", 60))

message("\nGenerated figures:")
message("  - fig1_trends.pdf: Time trends by treatment status")
message("  - fig2_event_study.pdf: Event study plot")
message("  - fig3_map.pdf: Map of privacy law adoption")
message("  - fig4_balance.pdf: Pre-treatment balance")
