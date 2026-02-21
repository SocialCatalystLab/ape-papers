## ============================================================
## 05_figures.R — All figures for the paper
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
results <- readRDS("../data/rd_results.rds")
rd_first <- readRDS("../data/rd_first_stage.rds")
density_test <- readRDS("../data/density_test.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")
placebo_results <- readRDS("../data/placebo_results.rds")
balance_results <- readRDS("../data/balance_results.rds")

fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

## ----------------------------------------------------------
## Figure 1: RDD Plot — First Stage (Female Councillor Share)
## ----------------------------------------------------------

cat("Creating Figure 1: First Stage RDD...\n")

# Create binned scatter
bw_plot <- 500
plot_data <- df %>%
  filter(abs(pop_centered) <= bw_plot) %>%
  mutate(bin = cut(pop_centered,
                   breaks = seq(-bw_plot, bw_plot, by = 20),
                   include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    pop_mid = mean(pop_centered),
    female_share = mean(female_share),
    n = n(),
    .groups = "drop"
  )

p1 <- ggplot() +
  geom_point(data = plot_data, aes(x = pop_mid, y = female_share),
             color = "grey50", size = 2, alpha = 0.7) +
  geom_smooth(data = df %>% filter(pop_centered >= -bw_plot & pop_centered < 0),
              aes(x = pop_centered, y = female_share),
              method = "lm", formula = y ~ x,
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = df %>% filter(pop_centered >= 0 & pop_centered <= bw_plot),
              aes(x = pop_centered, y = female_share),
              method = "lm", formula = y ~ x,
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.2, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.7) +
  annotate("text", x = 300, y = 0.33,
           label = "Proportional +\nGender Parity",
           size = 3.5, fontface = "italic", color = apep_colors[2]) +
  annotate("text", x = -300, y = 0.33,
           label = "Majority vote\nNo parity",
           size = 3.5, fontface = "italic", color = apep_colors[1]) +
  labs(
    title = "First Stage: Female Councillor Share at the 1,000 Threshold",
    subtitle = "Binned means (bins of 20 inhabitants), linear fit within each side",
    x = "Population Relative to 1,000 Threshold",
    y = "Female Share of Municipal Councillors",
    caption = "Source: Répertoire National des Élus (2025). Each point is a binned mean."
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig1_first_stage.pdf"), p1, width = 8, height = 5)

## ----------------------------------------------------------
## Figure 2: McCrary Density Test
## ----------------------------------------------------------

cat("Creating Figure 2: Density Test...\n")

# Histogram of population near threshold
hist_data <- df %>%
  filter(abs(pop_centered) <= 500) %>%
  mutate(side = ifelse(pop_centered < 0, "Below", "Above"))

p2 <- ggplot(hist_data, aes(x = pop_centered, fill = side)) +
  geom_histogram(binwidth = 10, color = "white", linewidth = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.7) +
  scale_fill_manual(values = c("Below" = apep_colors[1],
                                "Above" = apep_colors[2]),
                    name = "") +
  labs(
    title = "Density of Communes Around the 1,000-Inhabitant Threshold",
    subtitle = paste0("McCrary test: T = ",
                      round(density_test$test$t_jk, 2),
                      ", p = ", round(density_test$test$p_jk, 3),
                      " (no evidence of manipulation)"),
    x = "Population Relative to 1,000",
    y = "Number of Communes",
    caption = "Source: INSEE Communes data. Bins of 10 inhabitants."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_density.pdf"), p2, width = 8, height = 5)

## ----------------------------------------------------------
## Figure 3: RDD Plot — Main Outcome (Female Employment Rate)
## ----------------------------------------------------------

cat("Creating Figure 3: Main Outcome RDD...\n")

plot_data3 <- df %>%
  filter(abs(pop_centered) <= bw_plot) %>%
  mutate(bin = cut(pop_centered,
                   breaks = seq(-bw_plot, bw_plot, by = 25),
                   include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    pop_mid = mean(pop_centered),
    female_emp_rate = mean(female_emp_rate, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

p3 <- ggplot() +
  geom_point(data = plot_data3, aes(x = pop_mid, y = female_emp_rate),
             color = "grey50", size = 2, alpha = 0.7) +
  geom_smooth(data = df %>% filter(pop_centered >= -bw_plot & pop_centered < 0),
              aes(x = pop_centered, y = female_emp_rate),
              method = "lm", formula = y ~ x,
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = df %>% filter(pop_centered >= 0 & pop_centered <= bw_plot),
              aes(x = pop_centered, y = female_emp_rate),
              method = "lm", formula = y ~ x,
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.2, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.7) +
  labs(
    title = "Female Employment Rate at the 1,000-Inhabitant Threshold",
    subtitle = "RDD estimate: no statistically significant discontinuity",
    x = "Population Relative to 1,000 Threshold",
    y = "Female Employment Rate (ages 15-64)",
    caption = "Source: INSEE Census 2022. Points are binned means (bins of 25)."
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig3_female_emp.pdf"), p3, width = 8, height = 5)

## ----------------------------------------------------------
## Figure 4: Bandwidth Sensitivity
## ----------------------------------------------------------

cat("Creating Figure 4: Bandwidth Sensitivity...\n")

p4 <- ggplot(bw_results, aes(x = bandwidth, y = coef)) +
  geom_ribbon(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "Bandwidth Sensitivity: RDD Estimate for Female Employment Rate",
    subtitle = "Local linear regression with HC1 standard errors, 95% CI",
    x = "Bandwidth (inhabitants from threshold)",
    y = "RDD Estimate (pp)",
    caption = "Note: Shaded region shows 95% confidence interval."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_bw_sensitivity.pdf"), p4, width = 8, height = 5)

## ----------------------------------------------------------
## Figure 5: Multi-outcome RDD coefficients
## ----------------------------------------------------------

cat("Creating Figure 5: Multi-outcome coefficients...\n")

coef_data <- bind_rows(lapply(names(results), function(v) {
  r <- results[[v]]
  data.frame(
    outcome = r$name,
    coef = r$coef_conv,
    se = r$se_robust,
    ci_lower = r$ci_lower,
    ci_upper = r$ci_upper,
    pv = r$pv_robust
  )
}))

coef_data$outcome <- factor(coef_data$outcome,
                            levels = rev(coef_data$outcome))

p5 <- ggplot(coef_data, aes(x = coef, y = outcome)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = apep_colors[1]) +
  geom_point(size = 3, color = apep_colors[1]) +
  labs(
    title = "RDD Estimates Across Outcome Variables",
    subtitle = "Local linear regression with robust bias-corrected inference",
    x = "RDD Estimate (percentage points)",
    y = "",
    caption = "Note: Horizontal bars show 95% robust confidence intervals."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 10))

ggsave(file.path(fig_dir, "fig5_multi_outcome.pdf"), p5, width = 8, height = 5)

## ----------------------------------------------------------
## Figure 6: Placebo Cutoffs
## ----------------------------------------------------------

cat("Creating Figure 6: Placebo Cutoffs...\n")

p6 <- ggplot(placebo_results, aes(x = cutoff, y = coef)) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 30, color = ifelse(placebo_results$is_real,
                                           apep_colors[2], "grey60")) +
  geom_point(size = 3, color = ifelse(placebo_results$is_real,
                                       apep_colors[2], "grey50")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1000, linetype = "dotted", color = apep_colors[2],
             alpha = 0.5) +
  annotate("text", x = 1000, y = max(placebo_results$coef + 1.96 * placebo_results$se),
           label = "Actual\nthreshold", size = 3, color = apep_colors[2],
           vjust = -0.5) +
  labs(
    title = "Placebo Cutoff Tests: Female Employment Rate",
    subtitle = "RDD estimated at various population thresholds",
    x = "Population Cutoff",
    y = "RDD Estimate",
    caption = "Note: Orange = actual threshold (1,000). Grey = placebo cutoffs."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo.pdf"), p6, width = 8, height = 5)

## ----------------------------------------------------------
## Figure 7: Female LFPR RDD
## ----------------------------------------------------------

cat("Creating Figure 7: Female LFPR RDD...\n")

plot_data7 <- df %>%
  filter(abs(pop_centered) <= bw_plot) %>%
  mutate(bin = cut(pop_centered,
                   breaks = seq(-bw_plot, bw_plot, by = 25),
                   include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    pop_mid = mean(pop_centered),
    female_lfpr = mean(female_lfpr, na.rm = TRUE),
    .groups = "drop"
  )

p7 <- ggplot() +
  geom_point(data = plot_data7, aes(x = pop_mid, y = female_lfpr),
             color = "grey50", size = 2, alpha = 0.7) +
  geom_smooth(data = df %>% filter(pop_centered >= -bw_plot & pop_centered < 0),
              aes(x = pop_centered, y = female_lfpr),
              method = "lm", formula = y ~ x,
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = df %>% filter(pop_centered >= 0 & pop_centered <= bw_plot),
              aes(x = pop_centered, y = female_lfpr),
              method = "lm", formula = y ~ x,
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.2, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.7) +
  labs(
    title = "Female Labor Force Participation at the 1,000 Threshold",
    subtitle = "No economically meaningful discontinuity despite parity mandate",
    x = "Population Relative to 1,000 Threshold",
    y = "Female LFPR (ages 15-64)",
    caption = "Source: INSEE Census 2022. Points are binned means (bins of 25)."
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig7_female_lfpr.pdf"), p7, width = 8, height = 5)

cat("All figures saved to", fig_dir, "\n")
