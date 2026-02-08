# ==============================================================================
# 05_figures.R
# Create figures for the paper
# ==============================================================================

source("00_packages.R")

# Load results
results <- readRDS("../data/processed/synth_results.rds")
weights_df <- readRDS("../data/processed/synth_weights.rds")
estimates <- readRDS("../data/processed/estimates.rds")
analysis_data <- readRDS("../data/processed/analysis_data.rds")
params <- readRDS("../data/processed/analysis_params.rds")

# Create figures directory
dir.create("../figures", recursive = TRUE, showWarnings = FALSE)

# Treatment date for vertical lines
treatment_date <- params$treatment_date

# ------------------------------------------------------------------------------
# Figure 1: Netherlands vs Synthetic Control
# ------------------------------------------------------------------------------
cat("Creating Figure 1: Main synthetic control plot...\n")

fig1_data <- results %>%
  select(date, netherlands, synthetic) %>%
  pivot_longer(cols = c(netherlands, synthetic),
               names_to = "series",
               values_to = "hpi") %>%
  mutate(series = case_when(
    series == "netherlands" ~ "Netherlands (Actual)",
    series == "synthetic" ~ "Synthetic Netherlands"
  ))

fig1 <- ggplot(fig1_data, aes(x = date, y = hpi, color = series, linetype = series)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = treatment_date, linetype = "dashed", color = "gray40") +
  annotate("text", x = treatment_date, y = max(fig1_data$hpi, na.rm = TRUE) * 0.95,
           label = "Nitrogen Ruling\n(May 2019)", hjust = -0.1, size = 3) +
  scale_x_date(limits = c(ymd("2010-01-01"), ymd("2024-01-01")),
               date_breaks = "2 years", date_labels = "%Y") +
  scale_color_manual(values = c("Netherlands (Actual)" = "#d73027",
                                "Synthetic Netherlands" = "#4575b4")) +
  scale_linetype_manual(values = c("Netherlands (Actual)" = "solid",
                                   "Synthetic Netherlands" = "dashed")) +
  labs(
    title = "Real House Price Index: Netherlands vs. Synthetic Control",
    subtitle = "Quarterly data, 2010Q1-2023Q4",
    x = NULL,
    y = "Real House Price Index",
    color = NULL,
    linetype = NULL
  ) +
  theme_pub() +
  theme(
    legend.position = c(0.2, 0.85),
    legend.background = element_rect(fill = "white", color = NA)
  )

ggsave("../figures/fig1_synth_control.pdf", fig1, width = 8, height = 5)
ggsave("../figures/fig1_synth_control.png", fig1, width = 8, height = 5, dpi = 300)

# ------------------------------------------------------------------------------
# Figure 2: Treatment Effect (Gap)
# ------------------------------------------------------------------------------
cat("Creating Figure 2: Treatment effect gap...\n")

fig2 <- ggplot(results, aes(x = date, y = gap)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_area(data = filter(results, post), fill = "#fee090", alpha = 0.7) +
  geom_line(linewidth = 0.8, color = "#d73027") +
  geom_vline(xintercept = treatment_date, linetype = "dashed", color = "gray40") +
  annotate("text", x = treatment_date, y = max(results$gap, na.rm = TRUE) * 0.9,
           label = "Treatment", hjust = -0.1, size = 3) +
  annotate("text", x = ymd("2022-01-01"), y = 10,
           label = sprintf("ATT = %.1f points", estimates$post_effect$att),
           size = 4, fontface = "bold") +
  scale_x_date(limits = c(ymd("2010-01-01"), ymd("2024-01-01")),
               date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Treatment Effect: Netherlands vs. Synthetic Control",
    subtitle = "Difference in real house price index (Netherlands minus Synthetic)",
    x = NULL,
    y = "Gap (Index Points)"
  ) +
  theme_pub()

ggsave("../figures/fig2_treatment_gap.pdf", fig2, width = 8, height = 5)
ggsave("../figures/fig2_treatment_gap.png", fig2, width = 8, height = 5, dpi = 300)

# ------------------------------------------------------------------------------
# Figure 3: Synthetic Control Weights
# ------------------------------------------------------------------------------
cat("Creating Figure 3: Donor country weights...\n")

fig3 <- ggplot(weights_df, aes(x = reorder(country, weight), y = weight)) +
  geom_col(fill = "#4575b4") +
  geom_text(aes(label = sprintf("%.1f%%", weight * 100)),
            hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 0.55), labels = percent) +
  labs(
    title = "Synthetic Control Weights",
    subtitle = "Contribution of each donor country to Synthetic Netherlands",
    x = NULL,
    y = "Weight"
  ) +
  theme_pub()

ggsave("../figures/fig3_weights.pdf", fig3, width = 6, height = 4)
ggsave("../figures/fig3_weights.png", fig3, width = 6, height = 4, dpi = 300)

# ------------------------------------------------------------------------------
# Figure 4: All Countries Comparison
# ------------------------------------------------------------------------------
cat("Creating Figure 4: All countries comparison...\n")

# Add treatment indicator
analysis_data <- analysis_data %>%
  mutate(
    country_type = if_else(country == "Netherlands", "Netherlands", "Donor Countries")
  )

fig4 <- ggplot(analysis_data, aes(x = date, y = hpi_norm, group = country)) +
  geom_line(data = filter(analysis_data, country != "Netherlands"),
            color = "gray70", alpha = 0.5) +
  geom_line(data = filter(analysis_data, country == "Netherlands"),
            color = "#d73027", linewidth = 1.2) +
  geom_vline(xintercept = treatment_date, linetype = "dashed", color = "gray40") +
  annotate("text", x = ymd("2012-01-01"), y = 140,
           label = "Netherlands", color = "#d73027", size = 3.5, fontface = "bold") +
  annotate("text", x = ymd("2012-01-01"), y = 130,
           label = "Donor Countries", color = "gray50", size = 3.5) +
  scale_x_date(limits = c(ymd("2010-01-01"), ymd("2024-01-01")),
               date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Real House Price Index: Netherlands and Donor Countries",
    subtitle = "Quarterly data, 2010Q1-2023Q4",
    x = NULL,
    y = "Real House Price Index"
  ) +
  theme_pub()

ggsave("../figures/fig4_all_countries.pdf", fig4, width = 8, height = 5)
ggsave("../figures/fig4_all_countries.png", fig4, width = 8, height = 5, dpi = 300)

# ------------------------------------------------------------------------------
# Figure 5: Pre-treatment Fit (Zoomed)
# ------------------------------------------------------------------------------
cat("Creating Figure 5: Pre-treatment fit...\n")

pre_data <- results %>%
  filter(!post) %>%
  select(date, netherlands, synthetic) %>%
  pivot_longer(cols = c(netherlands, synthetic),
               names_to = "series",
               values_to = "hpi")

fig5 <- ggplot(pre_data, aes(x = date, y = hpi, color = series)) +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("netherlands" = "#d73027",
                                "synthetic" = "#4575b4"),
                     labels = c("Netherlands", "Synthetic")) +
  labs(
    title = "Pre-Treatment Fit: Netherlands vs. Synthetic Control",
    subtitle = sprintf("RMSE = %.2f, R² = %.3f",
                       estimates$pre_fit$rmse, estimates$pre_fit$r_squared),
    x = NULL,
    y = "Real House Price Index",
    color = NULL
  ) +
  theme_pub() +
  theme(legend.position = c(0.15, 0.85))

ggsave("../figures/fig5_pretreatment_fit.pdf", fig5, width = 8, height = 5)
ggsave("../figures/fig5_pretreatment_fit.png", fig5, width = 8, height = 5, dpi = 300)

# ------------------------------------------------------------------------------
# Figure 6: Yearly Effects Bar Chart
# ------------------------------------------------------------------------------
cat("Creating Figure 6: Yearly effects...\n")

yearly <- estimates$yearly_effects %>%
  mutate(
    significant = abs(mean_gap) > 2,  # Rough threshold
    fill_color = if_else(mean_gap > 0, "#d73027", "#4575b4")
  )

fig6 <- ggplot(yearly, aes(x = factor(year), y = mean_gap, fill = mean_gap > 0)) +
  geom_col(show.legend = FALSE) +
  geom_hline(yintercept = 0, color = "black") +
  scale_fill_manual(values = c("TRUE" = "#d73027", "FALSE" = "#4575b4")) +
  labs(
    title = "Average Treatment Effect by Year",
    subtitle = "Difference between Netherlands and Synthetic Control",
    x = "Year",
    y = "Effect (Index Points)"
  ) +
  theme_pub()

ggsave("../figures/fig6_yearly_effects.pdf", fig6, width = 7, height = 4)
ggsave("../figures/fig6_yearly_effects.png", fig6, width = 7, height = 4, dpi = 300)

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
cat("\n=== Figures Created ===\n")
list.files("../figures", pattern = "\\.(pdf|png)$") %>%
  sort() %>%
  cat(sep = "\n")

cat("\nFigures complete.\n")
