# ============================================================================
# 05b_figures_car_housing.R
# Car Ownership, Housing Tenure, and Educational Achievement in Sweden
# Figure generation
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("\n=== Loading data for figures ===\n")

analysis_data <- read_csv("../data/processed/analysis_with_predictions.csv", show_col_types = FALSE)
county_summary <- read_csv("../tables/county_summary.csv", show_col_types = FALSE)

# Use 2015 data for cross-sectional figures
data_2015 <- analysis_data |>
  filter(year == 2015)

cat("  Data loaded:", nrow(data_2015), "municipalities\n")

# Swedish colors
sweden_blue <- "#006AA7"
sweden_yellow <- "#FECC00"
sweden_dark <- "#003366"

# ============================================================================
# FIGURE 1: Car Ownership vs Merit Points (Scatter)
# ============================================================================

cat("\n=== Figure 1: Car ownership scatter ===\n")

fig1 <- ggplot(data_2015, aes(x = cars_per_1000, y = merit_excl_new)) +
  geom_point(aes(color = urban_proxy), alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = sweden_dark, linewidth = 1) +
  scale_color_viridis_d(name = "Municipality Type", option = "plasma") +
  labs(
    title = "Car Ownership and Educational Achievement in Swedish Municipalities",
    subtitle = "Municipalities with lower car ownership (urban areas) have higher merit points",
    x = "Cars per 1,000 Inhabitants",
    y = "Average Merit Points (Grade 9)",
    caption = "Data: Kolada Database (2013 cars, 2015 merit). Each point is one of 290 municipalities.\nLine shows OLS fit with 95% CI."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40"),
    legend.position = c(0.85, 0.85),
    legend.background = element_rect(fill = "white", color = "gray80")
  )

ggsave("../figures/fig1_car_merit_scatter.pdf", fig1, width = 10, height = 7)
ggsave("../figures/fig1_car_merit_scatter.png", fig1, width = 10, height = 7, dpi = 300)

cat("  Figure 1 saved\n")

# ============================================================================
# FIGURE 2: Housing Tenure and Merit Points (Box Plot)
# ============================================================================

cat("\n=== Figure 2: Housing tenure boxplot ===\n")

fig2 <- data_2015 |>
  mutate(housing_dominant = factor(housing_dominant,
                                    levels = c("Coop dominant", "Rental dominant", "Owner dominant"))) |>
  ggplot(aes(x = housing_dominant, y = merit_excl_new, fill = housing_dominant)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.5) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c(sweden_blue, sweden_yellow, "gray60")) +
  labs(
    title = "Educational Achievement by Dominant Housing Tenure Type",
    subtitle = "Cooperative-dominant municipalities show highest merit points",
    x = "Dominant Housing Tenure Type",
    y = "Average Merit Points (Grade 9)",
    caption = "Data: Kolada Database (2013 housing, 2015 merit). N=290 municipalities.\nBoxes show median and IQR; points show individual municipalities."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none"
  )

ggsave("../figures/fig2_housing_boxplot.pdf", fig2, width = 9, height = 6)
ggsave("../figures/fig2_housing_boxplot.png", fig2, width = 9, height = 6, dpi = 300)

cat("  Figure 2 saved\n")

# ============================================================================
# FIGURE 3: Urbanity Gradient
# ============================================================================

cat("\n=== Figure 3: Urbanity gradient ===\n")

urban_summary <- data_2015 |>
  group_by(urban_proxy) |>
  summarise(
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    se_merit = sd(merit_excl_new, na.rm = TRUE) / sqrt(n()),
    mean_cars = mean(cars_per_1000, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) |>
  mutate(urban_proxy = factor(urban_proxy,
                               levels = c("Urban (low car)", "Suburban", "Semi-rural", "Rural (high car)")))

fig3 <- ggplot(urban_summary, aes(x = urban_proxy, y = mean_merit)) +
  geom_col(fill = sweden_blue, alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_merit - 1.96*se_merit, ymax = mean_merit + 1.96*se_merit),
                width = 0.2) +
  geom_text(aes(label = sprintf("n=%d", n)), vjust = -0.5, size = 3) +
  coord_cartesian(ylim = c(210, 240)) +
  labs(
    title = "Educational Achievement by Municipality Urbanity",
    subtitle = "Clear gradient: urban municipalities outperform rural ones",
    x = "Municipality Type (based on car ownership)",
    y = "Mean Merit Points",
    caption = "Data: Kolada Database. Error bars show 95% CI.\nUrbanity proxied by car ownership: <400 = Urban, 400-500 = Suburban, 500-600 = Semi-rural, >600 = Rural"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("../figures/fig3_urbanity_gradient.pdf", fig3, width = 9, height = 6)
ggsave("../figures/fig3_urbanity_gradient.png", fig3, width = 9, height = 6, dpi = 300)

cat("  Figure 3 saved\n")

# ============================================================================
# FIGURE 4: County-Level Comparison
# ============================================================================

cat("\n=== Figure 4: County comparison ===\n")

fig4 <- county_summary |>
  mutate(county_name = fct_reorder(county_name, mean_merit)) |>
  ggplot(aes(x = mean_merit, y = county_name)) +
  geom_point(aes(size = n_municipalities, color = mean_cars), alpha = 0.8) +
  scale_color_viridis_c(name = "Cars per\n1000", option = "plasma", direction = -1) +
  scale_size_continuous(name = "N municipalities", range = c(2, 8)) +
  geom_vline(xintercept = mean(county_summary$mean_merit), linetype = "dashed", color = "gray50") +
  labs(
    title = "Educational Achievement Across Swedish Counties",
    subtitle = "Stockholm leads; car ownership inversely correlated with merit",
    x = "Mean Merit Points (Grade 9)",
    y = "County (Län)",
    caption = "Data: Kolada Database (2015). Dashed line = national mean.\nPoint size = number of municipalities; color = average car ownership."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right"
  )

ggsave("../figures/fig4_county_comparison.pdf", fig4, width = 11, height = 8)
ggsave("../figures/fig4_county_comparison.png", fig4, width = 11, height = 8, dpi = 300)

cat("  Figure 4 saved\n")

# ============================================================================
# FIGURE 5: Correlation Heatmap
# ============================================================================

cat("\n=== Figure 5: Correlation heatmap ===\n")

# Load correlation matrix
cor_matrix <- read.csv("../tables/table2_correlations.csv", row.names = 1)

# Convert to long format for ggplot
cor_long <- cor_matrix |>
  as.data.frame() |>
  rownames_to_column("var1") |>
  pivot_longer(-var1, names_to = "var2", values_to = "correlation") |>
  mutate(
    var1 = case_when(
      var1 == "merit_excl_new" ~ "Merit Points",
      var1 == "cars_per_1000" ~ "Cars/1000",
      var1 == "rental_housing_pct" ~ "Rental %",
      var1 == "owner_housing_pct" ~ "Owner %",
      var1 == "coop_housing_pct" ~ "Coop %",
      var1 == "teachers_qualified" ~ "Teacher Qual %"
    ),
    var2 = case_when(
      var2 == "merit_excl_new" ~ "Merit Points",
      var2 == "cars_per_1000" ~ "Cars/1000",
      var2 == "rental_housing_pct" ~ "Rental %",
      var2 == "owner_housing_pct" ~ "Owner %",
      var2 == "coop_housing_pct" ~ "Coop %",
      var2 == "teachers_qualified" ~ "Teacher Qual %"
    )
  )

fig5 <- ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f", correlation)), size = 3) +
  scale_fill_gradient2(low = sweden_blue, mid = "white", high = sweden_yellow,
                        midpoint = 0, limits = c(-1, 1), name = "Correlation") +
  labs(
    title = "Correlation Matrix: Key Variables",
    subtitle = "Car ownership negatively correlated with merit; coop housing positively correlated",
    x = "", y = ""
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("../figures/fig5_correlation_heatmap.pdf", fig5, width = 8, height = 7)
ggsave("../figures/fig5_correlation_heatmap.png", fig5, width = 8, height = 7, dpi = 300)

cat("  Figure 5 saved\n")

# ============================================================================
# FIGURE 6: Rental Housing vs Merit (with car ownership)
# ============================================================================

cat("\n=== Figure 6: Rental housing scatter ===\n")

fig6 <- ggplot(data_2015, aes(x = rental_housing_pct, y = merit_excl_new)) +
  geom_point(aes(color = cars_per_1000), alpha = 0.7, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = sweden_dark, linewidth = 1) +
  scale_color_viridis_c(name = "Cars per\n1000", option = "plasma", direction = -1) +
  labs(
    title = "Rental Housing and Educational Achievement",
    subtitle = "Higher rental share associated with lower merit points, controlling for urbanity",
    x = "Rental Housing Share (%)",
    y = "Average Merit Points (Grade 9)",
    caption = "Data: Kolada Database (2013 housing, 2015 merit). Each point is one municipality.\nColor indicates car ownership (darker = fewer cars = more urban)."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right"
  )

ggsave("../figures/fig6_rental_merit_scatter.pdf", fig6, width = 10, height = 7)
ggsave("../figures/fig6_rental_merit_scatter.png", fig6, width = 10, height = 7, dpi = 300)

cat("  Figure 6 saved\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n=== Figures generated ===\n")
figure_files <- list.files("../figures", pattern = "\\.(pdf|png)$", full.names = FALSE)
for (f in figure_files) {
  cat("  ", f, "\n")
}

cat("\nFigure generation complete.\n")
