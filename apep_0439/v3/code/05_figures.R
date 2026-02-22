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
# FIGURE 0: Map of Switzerland showing culture groups
# ============================================================================
cat("=== Figure 0: Culture group map ===\n")

# Try to load municipality shapefile
if (file.exists(file.path(data_dir, "municipalities_sf.rds"))) {
  mun_sf <- readRDS(file.path(data_dir, "municipalities_sf.rds"))
  cat("  Loaded municipality shapefile with", nrow(mun_sf), "features\n")

  # Try to find the ID column for municipality
  sf_names <- names(mun_sf)
  cat("  Shapefile columns:", paste(sf_names, collapse = ", "), "\n")

  # Look for municipality ID column (BFS number)
  id_col <- sf_names[grepl("bfs|BFS|GMDNR|GMDE|mun_id|id|ID|nummer|NR", sf_names, ignore.case = TRUE)][1]
  name_col <- sf_names[grepl("name|NAME|GMDNAME|gem_name", sf_names, ignore.case = TRUE)][1]

  if (!is.na(id_col)) {
    cat("  Using ID column:", id_col, "\n")

    # Prepare gender index for joining
    mun_culture <- gender_index %>%
      select(mun_id, culture_group) %>%
      filter(culture_group %in% c("French-Protestant", "French-Catholic",
                                   "German-Protestant", "German-Catholic"))

    # Join culture groups to shapefile
    mun_sf_joined <- mun_sf %>%
      mutate(join_id = as.integer(.data[[id_col]])) %>%
      left_join(mun_culture, by = c("join_id" = "mun_id"))

    n_matched <- sum(!is.na(mun_sf_joined$culture_group))
    cat("  Matched", n_matched, "of", nrow(mun_sf), "polygons to culture groups\n")

    if (n_matched > 50) {
      # Create map
      fig0 <- ggplot(mun_sf_joined) +
        geom_sf(aes(fill = culture_group), color = "grey80", linewidth = 0.05) +
        scale_fill_manual(
          values = c(interaction_colors, "NA" = "grey95"),
          na.value = "grey95",
          name = "Culture Group",
          labels = c("French-Catholic", "French-Protestant",
                     "German-Catholic", "German-Protestant", "Not in sample")
        ) +
        labs(
          title = "Swiss Municipalities by Cultural Group",
          subtitle = "Language (French/German) x Historical Confession (Protestant/Catholic)",
          caption = paste0("Note: Grey = Italian-speaking or not in analysis sample.\n",
                           "N = ", n_matched, " municipalities classified into four culture groups.")
        ) +
        theme_void(base_size = 11) +
        theme(
          plot.title = element_text(face = "bold", size = 13),
          plot.subtitle = element_text(color = "grey40", size = 10),
          plot.caption = element_text(color = "grey50", size = 8, hjust = 0),
          legend.position = "bottom",
          legend.title = element_text(face = "bold", size = 9)
        ) +
        guides(fill = guide_legend(nrow = 1, override.aes = list(linewidth = 0)))

      ggsave(file.path(fig_dir, "fig0_map.pdf"), fig0,
             width = 10, height = 7)
      cat("  Saved fig0_map.pdf\n")
    } else {
      cat("  Not enough matches for a meaningful map - creating schematic instead\n")
    }
  } else {
    cat("  Could not identify municipality ID column in shapefile\n")
  }
} else {
  cat("  No municipality shapefile available\n")
}

# Fallback: create a canton-level schematic if no spatial map was created
if (!file.exists(file.path(fig_dir, "fig0_map.pdf"))) {
  cat("  Creating schematic canton-level culture group chart instead\n")

  # Canton-level summary
  canton_culture <- gender_index %>%
    filter(culture_group %in% c("French-Protestant", "French-Catholic",
                                 "German-Protestant", "German-Catholic")) %>%
    group_by(canton_abbr = NA) %>%
    count(culture_group) %>%
    ungroup()

  # Actually use the canton_abbr from the data
  canton_culture <- gender_panel %>%
    filter(culture_4 %in% c("French-Protestant", "French-Catholic",
                             "German-Protestant", "German-Catholic")) %>%
    distinct(mun_id, .keep_all = TRUE) %>%
    count(canton_abbr, culture_4) %>%
    rename(culture_group = culture_4)

  fig0 <- ggplot(canton_culture, aes(x = reorder(canton_abbr, -n), y = n,
                                      fill = culture_group)) +
    geom_col(position = "stack") +
    scale_fill_manual(values = interaction_colors, name = "Culture Group") +
    labs(
      title = "Distribution of Municipalities by Canton and Culture Group",
      subtitle = "Number of municipalities in each canton classified by language and historical confession",
      x = "Canton",
      y = "Number of Municipalities"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))

  ggsave(file.path(fig_dir, "fig0_map.pdf"), fig0,
         width = 10, height = 6)
  cat("  Saved fig0_map.pdf (schematic canton chart)\n")
}

# ============================================================================
# FIGURE 1: Bar chart of culture group means
# ============================================================================
cat("=== Figure 1: Culture group bar chart ===\n")

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
# FIGURE 3: Improved interaction plot with CI bands and additive prediction
# ============================================================================
cat("=== Figure 3: Interaction plot (improved) ===\n")

fig3_data <- fig2_data %>%
  group_by(mun_language, hist_religion) %>%
  summarize(
    mean_index = mean(gender_index),
    se = sd(gender_index) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

# Compute the additive prediction for French-Catholic
gp_val <- fig3_data$mean_index[fig3_data$mun_language == "German" & fig3_data$hist_religion == "Protestant"]
gc_val <- fig3_data$mean_index[fig3_data$mun_language == "German" & fig3_data$hist_religion == "Catholic"]
fp_val <- fig3_data$mean_index[fig3_data$mun_language == "French" & fig3_data$hist_religion == "Protestant"]
additive_fc <- gp_val + (fp_val - gp_val) + (gc_val - gp_val)
actual_fc <- fig3_data$mean_index[fig3_data$mun_language == "French" & fig3_data$hist_religion == "Catholic"]
interaction_deviation <- actual_fc - additive_fc

fig3 <- ggplot(fig3_data, aes(x = hist_religion, y = mean_index,
                               color = mun_language, group = mun_language)) +
  # Shaded CI bands
  geom_ribbon(aes(ymin = mean_index - 1.96 * se,
                  ymax = mean_index + 1.96 * se,
                  fill = mun_language),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 4) +
  # Add additive prediction point
  annotate("point", x = "Catholic", y = additive_fc,
           shape = 4, size = 4, stroke = 1.5, color = "grey40") +
  # Arrow from additive prediction to actual
  annotate("segment",
           x = 2.15, xend = 2.15,
           y = additive_fc, yend = actual_fc,
           arrow = arrow(length = unit(0.15, "cm"), ends = "both"),
           color = "grey30", linewidth = 0.6) +
  # Label the interaction deviation
  annotate("text",
           x = 2.25, y = (additive_fc + actual_fc) / 2,
           label = paste0("Interaction\n= ", sprintf("%+.1f", interaction_deviation * 100), " pp"),
           color = "grey30", size = 3, hjust = 0, fontface = "italic") +
  # Label the additive prediction
  annotate("text",
           x = 2.15, y = additive_fc - 0.005,
           label = "Additive\nprediction",
           color = "grey50", size = 2.5, hjust = 0.5, vjust = 1) +
  scale_color_manual(values = lang_colors) +
  scale_fill_manual(values = lang_colors, guide = "none") +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title = "The Intersectional Gap: Language x Religion",
    subtitle = "Mean yes-share on gender referenda by cultural group",
    x = "Historical Confessional Status",
    y = "Mean Yes-Share on Gender Referenda",
    color = "Language",
    caption = paste0(
      "Note: Shaded bands show 95% CIs. X marks additive prediction (sum of main effects).\n",
      "Arrow shows interaction deviation from additivity. Based on ",
      sum(fig3_data$n), " municipalities."
    )
  )

ggsave(file.path(fig_dir, "fig3_interaction.pdf"), fig3,
       width = 8, height = 5.5)
cat("  Saved fig3_interaction.pdf\n")

# ============================================================================
# FIGURE 4: Time-varying gaps with CI ribbons
# ============================================================================
cat("=== Figure 4: Convergence dynamics (improved) ===\n")

fig4_data <- time_gaps %>%
  filter(!is.na(lang_gap))

fig4a <- ggplot(fig4_data, aes(x = year, y = lang_gap)) +
  geom_ribbon(aes(ymin = lang_gap - 1.96 * lang_se,
                  ymax = lang_gap + 1.96 * lang_se),
              fill = lang_colors["French"], alpha = 0.2) +
  geom_line(color = lang_colors["French"], linewidth = 0.8) +
  geom_point(color = lang_colors["French"], size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  # Add trend line
  geom_smooth(method = "lm", se = FALSE, color = lang_colors["French"],
              linewidth = 0.5, linetype = "dashed") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "A. Language Gap Over Time",
       subtitle = "French - German difference in yes-share on gender referenda",
       x = "Year", y = "Language Gap (pp)")

fig4b <- ggplot(fig4_data %>% filter(!is.na(relig_gap)),
                aes(x = year, y = relig_gap)) +
  geom_ribbon(aes(ymin = relig_gap - 1.96 * relig_se,
                  ymax = relig_gap + 1.96 * relig_se),
              fill = relig_colors["Catholic"], alpha = 0.2) +
  geom_line(color = relig_colors["Catholic"], linewidth = 0.8) +
  geom_point(color = relig_colors["Catholic"], size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dotted") +
  geom_smooth(method = "lm", se = FALSE, color = relig_colors["Catholic"],
              linewidth = 0.5, linetype = "dashed") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "B. Religion Gap Over Time",
       subtitle = "Catholic - Protestant difference in yes-share on gender referenda",
       x = "Year", y = "Religion Gap (pp)")

fig4c_data <- fig4_data %>% filter(!is.na(interaction))
fig4c <- ggplot(fig4c_data, aes(x = year, y = interaction)) +
  {if ("interaction_se" %in% names(fig4c_data) && any(!is.na(fig4c_data$interaction_se)))
    geom_ribbon(aes(ymin = interaction - 1.96 * interaction_se,
                    ymax = interaction + 1.96 * interaction_se),
                fill = "grey30", alpha = 0.15)
  } +
  geom_line(color = "grey30", linewidth = 0.8) +
  geom_point(color = "grey30", size = 2.5) +
  {if ("interaction_se" %in% names(fig4c_data) && any(!is.na(fig4c_data$interaction_se)))
    geom_smooth(method = "lm", se = FALSE, color = "grey30",
                linewidth = 0.5, linetype = "dashed")
  } +
  geom_hline(yintercept = 0, linetype = "dotted") +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "C. Interaction Over Time",
       subtitle = "French x Catholic interaction term",
       x = "Year", y = "Interaction (pp)")

fig4 <- fig4a / fig4b / fig4c + plot_annotation(
  title = "Evolution of Cultural Gaps in Gender Attitudes (1981-2021)",
  subtitle = "Each point is one gender referendum. Shaded ribbons show 95% CIs. Dashed line shows linear trend."
)

ggsave(file.path(fig_dir, "fig4_convergence.pdf"), fig4,
       width = 8, height = 12)
cat("  Saved fig4_convergence.pdf\n")

# ============================================================================
# FIGURE 5: Permutation distribution
# ============================================================================
cat("=== Figure 5: Permutation inference ===\n")

# Panel A: Language effect permutation
perm_lang_data <- tibble(coef = robustness$permutation$perm_lang_coefs)
perm_p_lang_val <- robustness$permutation$perm_p_lang
perm_p_lang_label <- if (perm_p_lang_val == 0) {
  paste0("< ", round(1/length(robustness$permutation$perm_lang_coefs), 4))
} else {
  as.character(round(perm_p_lang_val, 3))
}

fig5a <- ggplot(perm_lang_data, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = robustness$permutation$obs_lang,
             color = "red", linewidth = 1.2) +
  annotate("text",
           x = robustness$permutation$obs_lang,
           y = Inf, vjust = 1.5,
           label = paste0("Observed = ",
                          sprintf("%.4f", robustness$permutation$obs_lang),
                          "\np ", perm_p_lang_label),
           color = "red", hjust = 1.1, size = 3.5) +
  labs(title = "A. Language Effect",
       x = "Permuted Language Coefficient", y = "Count")

# Panel B: Interaction permutation
perm_int_data <- tibble(coef = robustness$permutation$perm_coefs)
perm_p_int_val <- robustness$permutation$perm_p_interaction
perm_p_int_label <- if (perm_p_int_val == 0) {
  paste0("< ", round(1/length(robustness$permutation$perm_coefs), 4))
} else {
  as.character(round(perm_p_int_val, 3))
}

fig5b <- ggplot(perm_int_data, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = robustness$permutation$obs_interaction,
             color = "red", linewidth = 1.2) +
  annotate("text",
           x = robustness$permutation$obs_interaction,
           y = Inf, vjust = 1.5,
           label = paste0("Observed = ",
                          sprintf("%.4f", robustness$permutation$obs_interaction),
                          "\np = ", perm_p_int_label),
           color = "red", hjust = -0.1, size = 3.5) +
  labs(title = "B. Interaction",
       x = "Permuted Interaction Coefficient", y = "Count")

# Combine panels
fig5 <- fig5a + fig5b +
  plot_annotation(
    title = "Permutation Inference",
    subtitle = paste0(length(robustness$permutation$perm_coefs),
                      " random label permutations; red lines show observed coefficients")
  )

ggsave(file.path(fig_dir, "fig5_permutation.pdf"), fig5,
       width = 10, height = 5)
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
    x = "French - German Difference in Yes-Share",
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
  labs(title = "A. Language Gap", y = "French - German (pp)", x = NULL)

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
  labs(title = "B. French x Catholic Interaction", y = "Interaction (pp)", x = NULL)

fig7 <- fig7a | fig7b
fig7 <- fig7 + plot_annotation(
  title = "Falsification: Gender vs. Non-Gender Referenda",
  subtitle = "Language x religion interaction should be domain-specific"
)

ggsave(file.path(fig_dir, "fig7_falsification.pdf"), fig7,
       width = 9, height = 5)
cat("  Saved fig7_falsification.pdf\n")

cat("\n=== ALL FIGURES GENERATED ===\n")
cat("Figures in", fig_dir, ":\n")
cat(paste("  ", list.files(fig_dir, pattern = "\\.pdf$"), collapse = "\n"), "\n")
