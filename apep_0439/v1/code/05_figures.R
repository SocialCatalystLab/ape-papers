###############################################################################
# 05_figures.R - Maps, RDD plots, convergence dynamics, interaction visualization
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

gender_panel <- readRDS(file.path(data_dir, "gender_panel_final.rds"))
gender_index <- readRDS(file.path(data_dir, "gender_index.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
time_gaps <- readRDS(file.path(data_dir, "time_gaps.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ============================================================================
# FIGURE 1: Map of Switzerland showing language × religion classification
# ============================================================================
cat("=== Figure 1: Culture group map ===\n")

# Compute municipality-level means for the color scale
mun_summary <- gender_index %>%
  mutate(
    culture_label = case_when(
      culture_group == "French-Protestant" ~ "French-Protestant",
      culture_group == "French-Catholic" ~ "French-Catholic",
      culture_group == "German-Protestant" ~ "German-Protestant",
      culture_group == "German-Catholic" ~ "German-Catholic",
      TRUE ~ "Mixed/Other"
    )
  )

# Bar chart showing mean gender index by culture group
fig1_data <- mun_summary %>%
  filter(culture_label != "Mixed/Other") %>%
  group_by(culture_label) %>%
  summarize(
    n = n(),
    mean_index = mean(gender_index),
    se = sd(gender_index) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(culture_label = factor(culture_label,
                                levels = c("German-Catholic", "German-Protestant",
                                           "French-Catholic", "French-Protestant")))

fig1 <- ggplot(fig1_data, aes(x = culture_label, y = mean_index,
                               fill = culture_label)) +
  geom_col(width = 0.7) +
  geom_errorbar(aes(ymin = mean_index - 1.96 * se,
                    ymax = mean_index + 1.96 * se),
                width = 0.2) +
  scale_fill_manual(values = interaction_colors, guide = "none") +
  labs(
    title = "Gender Progressivism by Cultural Group",
    subtitle = "Mean yes-share across 6 pre-registered gender referenda (1981-2021)",
    x = NULL,
    y = "Mean Yes-Share on Gender Referenda",
    caption = "Note: Error bars show 95% confidence intervals.\nN municipalities shown in parentheses below each bar."
  ) +
  geom_text(aes(label = paste0("(n=", n, ")")),
            vjust = -0.3, size = 3, color = "grey40") +
  scale_y_continuous(labels = percent_format(), limits = c(0, NA)) +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave(file.path(fig_dir, "fig1_culture_groups.pdf"), fig1,
       width = 7, height = 5)
cat("  Saved fig1_culture_groups.pdf\n")

# ============================================================================
# FIGURE 2: Distribution of gender index by language and religion
# ============================================================================
cat("=== Figure 2: Distributions by cultural cleavage ===\n")

fig2_data <- mun_summary %>%
  filter(culture_label != "Mixed/Other")

fig2a <- ggplot(fig2_data, aes(x = gender_index, fill = mun_language)) +
  geom_density(alpha = 0.6, color = NA) +
  scale_fill_manual(values = lang_colors) +
  labs(title = "A. Language Border",
       x = "Gender Progressivism Index",
       y = "Density",
       fill = "Language") +
  scale_x_continuous(labels = percent_format()) +
  geom_vline(xintercept = median(fig2_data$gender_index[fig2_data$mun_language == "French"]),
             linetype = "dashed", color = lang_colors["French"]) +
  geom_vline(xintercept = median(fig2_data$gender_index[fig2_data$mun_language == "German"]),
             linetype = "dashed", color = lang_colors["German"])

fig2b <- ggplot(fig2_data, aes(x = gender_index, fill = hist_religion)) +
  geom_density(alpha = 0.6, color = NA) +
  scale_fill_manual(values = relig_colors) +
  labs(title = "B. Religion Border",
       x = "Gender Progressivism Index",
       y = "Density",
       fill = "Religion") +
  scale_x_continuous(labels = percent_format()) +
  geom_vline(xintercept = median(fig2_data$gender_index[fig2_data$hist_religion == "Protestant"]),
             linetype = "dashed", color = relig_colors["Protestant"]) +
  geom_vline(xintercept = median(fig2_data$gender_index[fig2_data$hist_religion == "Catholic"]),
             linetype = "dashed", color = relig_colors["Catholic"])

fig2 <- fig2a / fig2b + plot_annotation(
  title = "Distribution of Gender Progressivism Across Cultural Borders",
  subtitle = "Dashed lines show group medians"
)

ggsave(file.path(fig_dir, "fig2_distributions.pdf"), fig2,
       width = 8, height = 8)
cat("  Saved fig2_distributions.pdf\n")

# ============================================================================
# FIGURE 3: Interaction plot (2x2 factorial means)
# ============================================================================
cat("=== Figure 3: Interaction plot ===\n")

fig3_data <- fig2_data %>%
  group_by(mun_language, hist_religion) %>%
  summarize(
    mean_index = mean(gender_index),
    se = sd(gender_index) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

fig3 <- ggplot(fig3_data, aes(x = hist_religion, y = mean_index,
                               color = mun_language, group = mun_language)) +
  geom_point(size = 4, position = position_dodge(0.1)) +
  geom_line(linewidth = 1, position = position_dodge(0.1)) +
  geom_errorbar(aes(ymin = mean_index - 1.96 * se,
                    ymax = mean_index + 1.96 * se),
                width = 0.15, position = position_dodge(0.1)) +
  scale_color_manual(values = lang_colors) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title = "The Intersectional Gap: Language × Religion",
    subtitle = "Mean yes-share on gender referenda by cultural group",
    x = "Historical Confessional Status",
    y = "Mean Yes-Share on Gender Referenda",
    color = "Language",
    caption = paste0(
      "Note: Non-parallel lines indicate interaction (non-additivity).\n",
      "95% CI shown. Based on ", sum(fig3_data$n), " municipalities."
    )
  )

ggsave(file.path(fig_dir, "fig3_interaction.pdf"), fig3,
       width = 7, height = 5)
cat("  Saved fig3_interaction.pdf\n")

# ============================================================================
# FIGURE 4: Time-varying gaps (convergence dynamics)
# ============================================================================
cat("=== Figure 4: Convergence dynamics ===\n")

fig4_data <- time_gaps %>%
  filter(!is.na(lang_gap))

fig4a <- ggplot(fig4_data, aes(x = year, y = lang_gap)) +
  geom_point(color = lang_colors["French"], size = 2) +
  geom_errorbar(aes(ymin = lang_gap - 1.96 * lang_se,
                    ymax = lang_gap + 1.96 * lang_se),
                color = lang_colors["French"], width = 0.5) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "A. Language Gap Over Time",
       subtitle = "French - German difference in yes-share on gender referenda",
       x = "Year", y = "Language Gap (pp)")

fig4b <- ggplot(fig4_data %>% filter(!is.na(relig_gap)),
                aes(x = year, y = relig_gap)) +
  geom_point(color = relig_colors["Catholic"], size = 2) +
  geom_errorbar(aes(ymin = relig_gap - 1.96 * relig_se,
                    ymax = relig_gap + 1.96 * relig_se),
                color = relig_colors["Catholic"], width = 0.5) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "B. Religion Gap Over Time",
       subtitle = "Catholic - Protestant difference in yes-share on gender referenda",
       x = "Year", y = "Religion Gap (pp)")

fig4c_data <- fig4_data %>% filter(!is.na(interaction))
fig4c <- ggplot(fig4c_data, aes(x = year, y = interaction)) +
  geom_point(color = "grey30", size = 2) +
  {if ("interaction_se" %in% names(fig4c_data) && any(!is.na(fig4c_data$interaction_se)))
    geom_errorbar(aes(ymin = interaction - 1.96 * interaction_se,
                      ymax = interaction + 1.96 * interaction_se),
                  color = "grey30", width = 0.5)
  } +
  geom_hline(yintercept = 0, linetype = "dotted") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "C. Interaction Over Time",
       subtitle = "French × Catholic interaction term",
       x = "Year", y = "Interaction (pp)")

fig4 <- fig4a / fig4b / fig4c + plot_annotation(
  title = "Evolution of Cultural Gaps in Gender Attitudes (1981–2021)",
  subtitle = "Each point is one gender referendum"
)

ggsave(file.path(fig_dir, "fig4_convergence.pdf"), fig4,
       width = 8, height = 12)
cat("  Saved fig4_convergence.pdf\n")

# ============================================================================
# FIGURE 5: Permutation distribution
# ============================================================================
cat("=== Figure 5: Permutation inference ===\n")

perm_data <- tibble(coef = robustness$permutation$perm_coefs)

fig5 <- ggplot(perm_data, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = robustness$permutation$obs_interaction,
             color = "red", linewidth = 1.2) +
  annotate("text",
           x = robustness$permutation$obs_interaction,
           y = Inf, vjust = -0.5,
           label = paste0("Observed = ",
                          round(robustness$permutation$obs_interaction, 4),
                          "\np = ",
                          round(robustness$permutation$perm_p_interaction, 3)),
           color = "red", hjust = -0.1, size = 3.5) +
  labs(
    title = "Permutation Inference for Language × Religion Interaction",
    subtitle = paste0("Distribution of interaction coefficient under ",
                      length(robustness$permutation$perm_coefs),
                      " random label permutations"),
    x = "Permuted Interaction Coefficient",
    y = "Count",
    caption = "Red line shows observed interaction coefficient."
  )

ggsave(file.path(fig_dir, "fig5_permutation.pdf"), fig5,
       width = 7, height = 5)
cat("  Saved fig5_permutation.pdf\n")

# ============================================================================
# FIGURE 6: Individual referendum estimates (forest plot)
# ============================================================================
cat("=== Figure 6: Individual referendum forest plot ===\n")

ref_results <- robustness$individual_ref %>%
  filter(!is.na(french)) %>%
  mutate(
    ref_label = format(vote_date, "%Y-%m-%d"),
    ref_label = factor(ref_label, levels = rev(ref_label))
  )

fig6 <- ggplot(ref_results, aes(x = french, y = ref_label)) +
  geom_vline(xintercept = 0, linetype = "dotted") +
  geom_point(color = lang_colors["French"], size = 2.5) +
  geom_errorbarh(aes(xmin = french - 1.96 * french_se,
                     xmax = french + 1.96 * french_se),
                 height = 0.3, color = lang_colors["French"]) +
  scale_x_continuous(labels = percent_format()) +
  labs(
    title = "Language Gap by Individual Gender Referendum",
    subtitle = "Coefficient on French-speaking indicator with 95% CI",
    x = "French − German Difference in Yes-Share",
    y = NULL,
    caption = "Note: Each row is one gender-relevant federal referendum."
  )

ggsave(file.path(fig_dir, "fig6_forest.pdf"), fig6,
       width = 7, height = 5)
cat("  Saved fig6_forest.pdf\n")

# ============================================================================
# FIGURE 7: Falsification comparison
# ============================================================================
cat("=== Figure 7: Falsification ===\n")

# Compare interaction estimates: gender vs non-gender referenda
falsi_comparison <- bind_rows(
  tibble(
    type = "Gender Referenda",
    french = coef(results$m3_full)["is_frenchTRUE"],
    french_se = se(results$m3_full)["is_frenchTRUE"],
    interaction = coef(results$m3_full)["is_frenchTRUE:is_catholicTRUE"],
    interaction_se = se(results$m3_full)["is_frenchTRUE:is_catholicTRUE"]
  ),
  tibble(
    type = "Non-Gender Referenda",
    french = coef(robustness$falsi_extended)["is_frenchTRUE"],
    french_se = se(robustness$falsi_extended)["is_frenchTRUE"],
    interaction = coef(robustness$falsi_extended)["is_frenchTRUE:is_catholicTRUE"],
    interaction_se = se(robustness$falsi_extended)["is_frenchTRUE:is_catholicTRUE"]
  )
)

fig7a <- ggplot(falsi_comparison, aes(x = type, y = french, fill = type)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = french - 1.96 * french_se,
                    ymax = french + 1.96 * french_se),
                width = 0.2) +
  scale_fill_manual(values = c("Gender Referenda" = lang_colors["French"],
                                "Non-Gender Referenda" = "grey60"),
                    guide = "none") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "A. Language Gap", y = "French − German (pp)", x = NULL)

fig7b <- ggplot(falsi_comparison, aes(x = type, y = interaction, fill = type)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = interaction - 1.96 * interaction_se,
                    ymax = interaction + 1.96 * interaction_se),
                width = 0.2) +
  scale_fill_manual(values = c("Gender Referenda" = "grey30",
                                "Non-Gender Referenda" = "grey60"),
                    guide = "none") +
  scale_y_continuous(labels = percent_format()) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  labs(title = "B. French × Catholic Interaction", y = "Interaction (pp)", x = NULL)

fig7 <- fig7a | fig7b
fig7 <- fig7 + plot_annotation(
  title = "Falsification: Gender vs. Non-Gender Referenda",
  subtitle = "Language × religion interaction should be domain-specific"
)

ggsave(file.path(fig_dir, "fig7_falsification.pdf"), fig7,
       width = 9, height = 5)
cat("  Saved fig7_falsification.pdf\n")

cat("\n=== ALL FIGURES GENERATED ===\n")
cat("Figures in", fig_dir, ":\n")
cat(paste("  ", list.files(fig_dir, pattern = "\\.pdf$"), collapse = "\n"), "\n")
