## ============================================================
## 05_figures.R — Publication-quality figures
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

source("00_packages.R")

DATA_DIR <- "../data"
FIG_DIR <- "../figures"
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(DATA_DIR, "analysis_data.rds"))
cat(sprintf("Loaded analysis data: %d municipalities\n", nrow(df)))

# Color palette for language regions
lang_colors <- c("de" = "#C0392B", "fr" = "#2980B9", "it" = "#27AE60")
lang_labels <- c("de" = "German", "fr" = "French", "it" = "Italian")

# Professional theme refinements
theme_paper <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey92", linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 12, hjust = 0),
    plot.subtitle = element_text(size = 9, color = "grey40", hjust = 0),
    strip.text = element_text(face = "bold", size = 10),
    legend.position = "bottom",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 8)
  )

## ---------------------------------------------------------------
## Figure 1: Persistence Scatter Plot
## ---------------------------------------------------------------
cat("=== Figure 1: Persistence scatter ===\n")

# OLS fit for full sample (for annotation)
ols_biv <- lm(yes_paternity_2020 ~ yes_equal_rights_1981, data = df)
beta_biv <- round(coef(ols_biv)["yes_equal_rights_1981"], 3)
r2_biv <- round(summary(ols_biv)$r.squared, 3)

fig1 <- ggplot(df, aes(x = yes_equal_rights_1981, y = yes_paternity_2020,
                        color = primary_language)) +
  geom_point(alpha = 0.35, size = 1.2, shape = 16) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE,
              color = "black", linewidth = 0.8, linetype = "solid",
              fill = "grey80", alpha = 0.3) +
  scale_color_manual(values = lang_colors, labels = lang_labels,
                     name = "Language Region") +
  annotate("text", x = 25, y = 80,
           label = sprintf("hat(beta) == %.3f ~~~ R^2 == %.3f", beta_biv, r2_biv),
           parse = TRUE, size = 3.5, hjust = 0, color = "grey30") +
  labs(
    title = "Persistence of Gender Progressivism, 1981-2020",
    subtitle = "Municipal YES shares: 1981 Equal Rights Article vs. 2020 Paternity Leave",
    x = "YES Share: Equal Rights Article 1981 (%)",
    y = "YES Share: Paternity Leave 2020 (%)"
  ) +
  theme_paper +
  coord_cartesian(xlim = c(15, 95), ylim = c(20, 90))

ggsave(file.path(FIG_DIR, "fig1_persistence_scatter.pdf"),
       fig1, width = 7, height = 5, dpi = 300)
ggsave(file.path(FIG_DIR, "fig1_persistence_scatter.png"),
       fig1, width = 7, height = 5, dpi = 300)
cat("Saved fig1_persistence_scatter\n")

## ---------------------------------------------------------------
## Figure 2: Beta-Convergence by Language Region
## ---------------------------------------------------------------
cat("=== Figure 2: Beta-convergence ===\n")

# Compute regression line per panel for annotation
conv_stats <- df |>
  group_by(primary_language) |>
  summarise(
    beta = coef(lm(delta_gender ~ yes_equal_rights_1981))[2],
    r2 = summary(lm(delta_gender ~ yes_equal_rights_1981))$r.squared,
    n = n(),
    .groups = "drop"
  ) |>
  mutate(
    label = sprintf("beta == %.3f ~~ (n == %d)", beta, n),
    x_pos = 25,
    y_pos = 30
  )

fig2 <- ggplot(df, aes(x = yes_equal_rights_1981, y = delta_gender)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60", linewidth = 0.4) +
  geom_point(aes(color = primary_language), alpha = 0.3, size = 1, shape = 16) +
  geom_smooth(method = "lm", se = TRUE, color = "black",
              linewidth = 0.7, fill = "grey80", alpha = 0.3) +
  facet_wrap(~ primary_language, scales = "free_x",
             labeller = labeller(primary_language = lang_labels)) +
  geom_text(data = conv_stats, aes(x = x_pos, y = y_pos, label = label),
            parse = TRUE, size = 3, hjust = 0, color = "grey30") +
  scale_color_manual(values = lang_colors, guide = "none") +
  labs(
    title = expression(beta * "-Convergence in Gender Attitudes"),
    subtitle = expression("Negative slope: initially progressive municipalities converge toward the mean (" *
                            Delta[gender] * " = 2020 - 1981)"),
    x = "YES Share: Equal Rights Article 1981 (%)",
    y = expression(Delta[gender] * " = Paternity 2020 - Equal Rights 1981 (pp)")
  ) +
  theme_paper

ggsave(file.path(FIG_DIR, "fig2_beta_convergence.pdf"),
       fig2, width = 7, height = 5, dpi = 300)
ggsave(file.path(FIG_DIR, "fig2_beta_convergence.png"),
       fig2, width = 7, height = 5, dpi = 300)
cat("Saved fig2_beta_convergence\n")

## ---------------------------------------------------------------
## Figure 3: Sigma-Convergence
## ---------------------------------------------------------------
cat("=== Figure 3: Sigma-convergence ===\n")

# Build sigma data across years
sigma_vars <- tribble(
  ~year, ~variable,                ~label,
  1981,  "yes_equal_rights_1981",  "Equal Rights",
  1984,  "yes_maternity_1984",     "Maternity (1984)",
  1999,  "yes_maternity_1999",     "Maternity (1999)",
  2004,  "yes_maternity_2004",     "Maternity (2004)",
  2020,  "yes_paternity_2020",     "Paternity",
  2021,  "yes_marriage_2021",      "Marriage Equality"
)

df_de <- df |> filter(primary_language == "de")
df_fr <- df |> filter(primary_language == "fr")

sigma_long <- sigma_vars |>
  rowwise() |>
  summarise(
    year = year,
    label = label,
    All = sd(df[[variable]], na.rm = TRUE),
    German = sd(df_de[[variable]], na.rm = TRUE),
    French = sd(df_fr[[variable]], na.rm = TRUE),
    .groups = "drop"
  ) |>
  pivot_longer(cols = c(All, German, French),
               names_to = "group", values_to = "sd")

fig3 <- ggplot(sigma_long, aes(x = year, y = sd, color = group, group = group)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.5) +
  geom_text(aes(label = round(sd, 1)), vjust = -0.8, size = 2.8, show.legend = FALSE) +
  scale_color_manual(
    values = c("All" = "black", "German" = "#C0392B", "French" = "#2980B9"),
    name = ""
  ) +
  scale_x_continuous(breaks = c(1981, 1984, 1999, 2004, 2020, 2021)) +
  labs(
    title = expression(sigma * "-Convergence: Cross-Municipality Dispersion Over Time"),
    subtitle = "Declining standard deviation of YES shares across gender referenda",
    x = "Referendum Year",
    y = "Standard Deviation of Municipal YES Share (pp)"
  ) +
  theme_paper +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG_DIR, "fig3_sigma_convergence.pdf"),
       fig3, width = 7, height = 5, dpi = 300)
ggsave(file.path(FIG_DIR, "fig3_sigma_convergence.png"),
       fig3, width = 7, height = 5, dpi = 300)
cat("Saved fig3_sigma_convergence\n")

## ---------------------------------------------------------------
## Figure 4: Distribution Shifts (1981 vs 2020)
## ---------------------------------------------------------------
cat("=== Figure 4: Distribution shifts ===\n")

dist_data <- df |>
  select(mun_id, yes_equal_rights_1981, yes_paternity_2020) |>
  pivot_longer(cols = c(yes_equal_rights_1981, yes_paternity_2020),
               names_to = "referendum", values_to = "yes_share") |>
  mutate(
    referendum = case_when(
      referendum == "yes_equal_rights_1981" ~ "Equal Rights 1981",
      referendum == "yes_paternity_2020" ~ "Paternity Leave 2020"
    ),
    referendum = factor(referendum,
                        levels = c("Equal Rights 1981", "Paternity Leave 2020"))
  )

# Summary stats for annotation
dist_stats <- dist_data |>
  group_by(referendum) |>
  summarise(
    mean_val = mean(yes_share, na.rm = TRUE),
    sd_val = sd(yes_share, na.rm = TRUE),
    .groups = "drop"
  )

fig4 <- ggplot(dist_data, aes(x = yes_share, fill = referendum, color = referendum)) +
  geom_density(alpha = 0.35, linewidth = 0.7) +
  geom_vline(data = dist_stats, aes(xintercept = mean_val, color = referendum),
             linetype = "dashed", linewidth = 0.6, show.legend = FALSE) +
  scale_fill_manual(values = c("Equal Rights 1981" = "#E74C3C",
                                "Paternity Leave 2020" = "#3498DB"),
                    name = "") +
  scale_color_manual(values = c("Equal Rights 1981" = "#C0392B",
                                 "Paternity Leave 2020" = "#2980B9"),
                     name = "") +
  annotate("text", x = 25, y = 0.035,
           label = sprintf("1981: mu == %.1f ~~ sigma == %.1f",
                           dist_stats$mean_val[1], dist_stats$sd_val[1]),
           parse = TRUE, size = 3, hjust = 0, color = "#C0392B") +
  annotate("text", x = 25, y = 0.032,
           label = sprintf("2020: mu == %.1f ~~ sigma == %.1f",
                           dist_stats$mean_val[2], dist_stats$sd_val[2]),
           parse = TRUE, size = 3, hjust = 0, color = "#2980B9") +
  labs(
    title = "Distribution of Municipal Gender Progressivism: 1981 vs. 2020",
    subtitle = "Shift rightward (higher YES) and compression (lower SD) indicate convergence",
    x = "YES Share (%)",
    y = "Density"
  ) +
  theme_paper +
  coord_cartesian(xlim = c(10, 95))

ggsave(file.path(FIG_DIR, "fig4_distribution_shift.pdf"),
       fig4, width = 7, height = 5, dpi = 300)
ggsave(file.path(FIG_DIR, "fig4_distribution_shift.png"),
       fig4, width = 7, height = 5, dpi = 300)
cat("Saved fig4_distribution_shift\n")

## ---------------------------------------------------------------
## Figure 5: Falsification R-squared Comparison
## ---------------------------------------------------------------
cat("=== Figure 5: Falsification R-squared ===\n")

# Collect R2 from canton FE models
falsi_r2 <- tribble(
  ~outcome,               ~type,         ~r2,
  "Maternity 2004",       "Gender",      NA_real_,
  "Paternity 2020",       "Gender",      NA_real_,
  "Marriage 2021",        "Gender",      NA_real_,
  "Immigration 2014",     "Non-gender",  NA_real_,
  "Fighter Jets 2020",    "Non-gender",  NA_real_,
  "Corp. Resp. 2020",     "Non-gender",  NA_real_,
  "Burqa Ban 2021",       "Non-gender",  NA_real_
)

# Run all models to get R2
falsi_r2$r2[1] <- r2(feols(yes_maternity_2004 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")
falsi_r2$r2[2] <- r2(feols(yes_paternity_2020 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")
falsi_r2$r2[3] <- r2(feols(yes_marriage_2021 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")
falsi_r2$r2[4] <- r2(feols(yes_immigration_2014 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")
falsi_r2$r2[5] <- r2(feols(yes_jets_2020 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")
falsi_r2$r2[6] <- r2(feols(yes_corporate_2020 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")
falsi_r2$r2[7] <- r2(feols(yes_burqa_2021 ~ yes_equal_rights_1981 | canton,
                            data = df, cluster = ~canton), "r2")

# Order by R2 for display
falsi_r2 <- falsi_r2 |>
  mutate(outcome = fct_reorder(outcome, r2))

fig5 <- ggplot(falsi_r2, aes(x = outcome, y = r2, fill = type)) +
  geom_col(width = 0.65, alpha = 0.85) +
  geom_text(aes(label = sprintf("%.3f", r2)), hjust = -0.15, size = 3) +
  coord_flip() +
  scale_fill_manual(
    values = c("Gender" = "#2980B9", "Non-gender" = "#95A5A6"),
    name = "Vote Type"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Falsification: Predictive Power of 1981 Gender Baseline",
    subtitle = expression("Within-canton " * R^2 * " of 1981 Equal Rights YES share predicting each outcome"),
    x = "",
    y = expression(R^2 * " (canton FE model)")
  ) +
  theme_paper +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(FIG_DIR, "fig5_falsification_r2.pdf"),
       fig5, width = 7, height = 5, dpi = 300)
ggsave(file.path(FIG_DIR, "fig5_falsification_r2.png"),
       fig5, width = 7, height = 5, dpi = 300)
cat("Saved fig5_falsification_r2\n")

## ---------------------------------------------------------------
## Figure 6: Cantonal Suffrage Timing x Progressivism
## ---------------------------------------------------------------
cat("=== Figure 6: Suffrage timing ===\n")

# Create suffrage timing groups
df <- df |>
  mutate(
    suffrage_group = case_when(
      suffrage_year < 1970 ~ "Early adopters\n(before 1970)",
      suffrage_year %in% 1970:1971 ~ "Federal mandate\n(1970-71)",
      suffrage_year > 1971 ~ "Late holdouts\n(after 1971)"
    ),
    suffrage_group = factor(suffrage_group,
                            levels = c("Early adopters\n(before 1970)",
                                       "Federal mandate\n(1970-71)",
                                       "Late holdouts\n(after 1971)"))
  )

# Summary statistics for annotation
suff_stats <- df |>
  group_by(suffrage_group) |>
  summarise(
    n = n(),
    mean_val = mean(yes_paternity_2020, na.rm = TRUE),
    median_val = median(yes_paternity_2020, na.rm = TRUE),
    .groups = "drop"
  )

fig6 <- ggplot(df |> filter(!is.na(suffrage_group)),
               aes(x = suffrage_group, y = yes_paternity_2020,
                   fill = suffrage_group)) +
  geom_boxplot(alpha = 0.7, outlier.size = 0.8, outlier.alpha = 0.3,
               width = 0.6, linewidth = 0.4) +
  geom_text(data = suff_stats,
            aes(x = suffrage_group, y = 90,
                label = sprintf("n = %d\nmean = %.1f", n, mean_val)),
            size = 2.8, color = "grey30") +
  scale_fill_manual(
    values = c("Early adopters\n(before 1970)" = "#27AE60",
               "Federal mandate\n(1970-71)" = "#F39C12",
               "Late holdouts\n(after 1971)" = "#E74C3C"),
    guide = "none"
  ) +
  labs(
    title = "Gender Progressivism by Cantonal Women's Suffrage Timing",
    subtitle = "Distribution of 2020 paternity leave YES share by when canton adopted suffrage",
    x = "",
    y = "YES Share: Paternity Leave 2020 (%)"
  ) +
  theme_paper +
  theme(panel.grid.major.x = element_blank())

ggsave(file.path(FIG_DIR, "fig6_suffrage_timing.pdf"),
       fig6, width = 7, height = 5, dpi = 300)
ggsave(file.path(FIG_DIR, "fig6_suffrage_timing.png"),
       fig6, width = 7, height = 5, dpi = 300)
cat("Saved fig6_suffrage_timing\n")

## ---------------------------------------------------------------
## Summary
## ---------------------------------------------------------------
cat("\n=== All figures saved to", FIG_DIR, "===\n")
cat("Files:\n")
list.files(FIG_DIR, pattern = "\\.(pdf|png)$") |> cat(sep = "\n")
cat("\n=== Figures complete ===\n")
