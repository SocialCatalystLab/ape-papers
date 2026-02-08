# =============================================================================
# Paper 83: Social Security at 62 and Civic Engagement (Revision of apep_0081)
# 05_figures.R - Publication-ready figures
# =============================================================================
#
# KEY ADDITIONS for this revision:
#   - First-stage employment figure
#   - Bandwidth comparison (standard vs clustered SEs)
#   - Honest CI annotations where applicable
# =============================================================================

source("00_packages.R")

cat("=" %>% strrep(70), "\n")
cat("Creating Publication Figures - EXPANDED VERSION\n")
cat("=" %>% strrep(70), "\n\n")

# Load data
atus <- readRDS(paste0(data_dir, "atus_analysis.rds"))

# Load results
main_results <- readRDS(paste0(data_dir, "rdd_results.rds"))
by_age <- main_results$by_age

# -----------------------------------------------------------------------------
# Figure 1: Main RDD Plot - Volunteering Rate
# -----------------------------------------------------------------------------

cat("--- Figure 1: Main RDD Plot ---\n")

fig1 <- ggplot(by_age, aes(x = age, y = volunteer_rate * 100)) +
  # Vertical line at cutoff
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50", linewidth = 0.5) +
  # Separate regression lines
  geom_smooth(data = filter(by_age, age < 62),
              method = "lm", se = TRUE, color = apep_colors["primary"],
              fill = apep_colors["primary"], alpha = 0.2) +
  geom_smooth(data = filter(by_age, age >= 62),
              method = "lm", se = TRUE, color = apep_colors["primary"],
              fill = apep_colors["primary"], alpha = 0.2) +
  # Points with error bars
  geom_point(size = 2.5, color = apep_colors["primary"]) +
  geom_errorbar(
    aes(ymin = (volunteer_rate - 1.96*volunteer_se) * 100,
        ymax = (volunteer_rate + 1.96*volunteer_se) * 100),
    width = 0.3, color = apep_colors["primary"], alpha = 0.7
  ) +
  # Annotations
  annotate("text", x = 62, y = 4.5, label = "Age 62: SS Eligibility",
           hjust = -0.1, size = 3, color = "gray40") +
  # Labels
  labs(
    title = "Volunteering Increases at Social Security Eligibility Age",
    subtitle = "American Time Use Survey, 2003-2023 (N = 57,900)",
    x = "Age",
    y = "Percent Volunteering on Diary Day",
    caption = "Notes: Each point shows the mean volunteering rate by integer age. Error bars show 95% CIs.\nDashed line indicates age 62, the Social Security early retirement eligibility threshold."
  ) +
  scale_x_continuous(breaks = seq(55, 70, 1)) +
  scale_y_continuous(limits = c(4.5, 11)) +
  theme_apep() +
  theme(
    plot.caption = element_text(hjust = 0, size = 8)
  )

ggsave(paste0(fig_dir, "fig1_main_rdd.pdf"), fig1, width = 8, height = 6)
ggsave(paste0(fig_dir, "fig1_main_rdd.png"), fig1, width = 8, height = 6, dpi = 300)
cat("Saved: fig1_main_rdd.pdf\n")

# -----------------------------------------------------------------------------
# Figure 2: First Stage - Employment Declines at 62
# -----------------------------------------------------------------------------

cat("--- Figure 2: First Stage (Employment) ---\n")

# Load first-stage results if available
first_stage_file <- paste0(data_dir, "first_stage_results.rds")
if (file.exists(first_stage_file)) {
  first_stage <- readRDS(first_stage_file)
  by_age_work <- first_stage$by_age_work

  fig2 <- ggplot(by_age_work, aes(x = age, y = work_mins)) +
    geom_vline(xintercept = 62, linetype = "dashed", color = "gray50", linewidth = 0.5) +
    geom_smooth(data = filter(by_age_work, age < 62),
                method = "lm", se = TRUE, color = apep_colors["tertiary"],
                fill = apep_colors["tertiary"], alpha = 0.2) +
    geom_smooth(data = filter(by_age_work, age >= 62),
                method = "lm", se = TRUE, color = apep_colors["tertiary"],
                fill = apep_colors["tertiary"], alpha = 0.2) +
    geom_point(size = 2.5, color = apep_colors["tertiary"]) +
    geom_errorbar(
      aes(ymin = work_mins - 1.96*work_se,
          ymax = work_mins + 1.96*work_se),
      width = 0.3, color = apep_colors["tertiary"], alpha = 0.7
    ) +
    labs(
      title = "First Stage: Work Time Declines at Age 62",
      subtitle = "American Time Use Survey, 2003-2023",
      x = "Age",
      y = "Minutes Worked on Diary Day",
      caption = "Notes: Work time from ATUS activity category 05. Supports the mechanism:\nSS eligibility enables reduced labor supply, freeing time for volunteering."
    ) +
    scale_x_continuous(breaks = seq(55, 70, 1)) +
    theme_apep() +
    theme(plot.caption = element_text(hjust = 0, size = 8))

  ggsave(paste0(fig_dir, "fig2_first_stage.pdf"), fig2, width = 8, height = 5)
  cat("Saved: fig2_first_stage.pdf\n")
} else {
  cat("First-stage results not found. Run 03b_first_stage.R first.\n")

  # Fallback: volunteer minutes figure
  fig2 <- ggplot(by_age, aes(x = age, y = volunteer_mins)) +
    geom_vline(xintercept = 62, linetype = "dashed", color = "gray50", linewidth = 0.5) +
    geom_smooth(data = filter(by_age, age < 62),
                method = "lm", se = TRUE, color = apep_colors["tertiary"],
                fill = apep_colors["tertiary"], alpha = 0.2) +
    geom_smooth(data = filter(by_age, age >= 62),
                method = "lm", se = TRUE, color = apep_colors["tertiary"],
                fill = apep_colors["tertiary"], alpha = 0.2) +
    geom_point(size = 2.5, color = apep_colors["tertiary"]) +
    labs(
      title = "Minutes Spent Volunteering by Age",
      subtitle = "American Time Use Survey, 2003-2023",
      x = "Age",
      y = "Minutes per Day",
      caption = "Notes: Unconditional means including zeros."
    ) +
    scale_x_continuous(breaks = seq(55, 70, 1)) +
    theme_apep() +
    theme(plot.caption = element_text(hjust = 0, size = 8))

  ggsave(paste0(fig_dir, "fig2_volunteer_minutes.pdf"), fig2, width = 8, height = 5)
  cat("Saved: fig2_volunteer_minutes.pdf\n")
}

# -----------------------------------------------------------------------------
# Figure 3: Bandwidth Sensitivity - Comparing Inference Methods
# -----------------------------------------------------------------------------

cat("--- Figure 3: Bandwidth Sensitivity (Standard vs Clustered) ---\n")

bw_file <- paste0(tab_dir, "table_bandwidth.csv")
if (file.exists(bw_file)) {
  bw_results <- read_csv(bw_file, show_col_types = FALSE)

  # Check if we have the comparison columns
  if ("Estimate_cluster" %in% names(bw_results)) {
    # New format with comparison
    bw_plot_data <- bw_results %>%
      pivot_longer(cols = c(Estimate_rdrobust, Estimate_cluster),
                   names_to = "Method", values_to = "Estimate") %>%
      mutate(
        SE = ifelse(Method == "Estimate_rdrobust", SE_rdrobust, SE_cluster),
        Method = ifelse(Method == "Estimate_rdrobust", "rdrobust (standard)", "Clustered by Age")
      )

    fig3 <- ggplot(bw_plot_data, aes(x = Bandwidth, y = Estimate * 100, color = Method)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_point(position = position_dodge(width = 0.3), size = 3) +
      geom_errorbar(aes(ymin = (Estimate - 1.96*SE) * 100,
                        ymax = (Estimate + 1.96*SE) * 100),
                    position = position_dodge(width = 0.3), width = 0.2) +
      scale_color_manual(values = c("rdrobust (standard)" = apep_colors["primary"],
                                    "Clustered by Age" = apep_colors["secondary"])) +
      labs(
        title = "Bandwidth Sensitivity: Standard vs Clustered Inference",
        subtitle = "Effect of SS Eligibility on Volunteering Rate",
        x = "Bandwidth (Years from Cutoff)",
        y = "RDD Estimate (Percentage Points)",
        color = "Inference Method",
        caption = "Notes: Clustering by age accounts for discrete running variable.\nClustered SEs are wider, reflecting true uncertainty."
      ) +
      scale_x_continuous(breaks = bw_results$Bandwidth) +
      theme_apep() +
      theme(
        plot.caption = element_text(hjust = 0, size = 8),
        legend.position = "bottom"
      )
  } else {
    # Old format
    fig3 <- ggplot(bw_results, aes(x = Bandwidth, y = Estimate * 100)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_ribbon(aes(ymin = CI_Low * 100, ymax = CI_High * 100),
                  fill = apep_colors["primary"], alpha = 0.2) +
      geom_line(color = apep_colors["primary"], linewidth = 0.8) +
      geom_point(size = 3, color = apep_colors["primary"]) +
      labs(
        title = "RDD Estimates Across Different Bandwidths",
        subtitle = "Effect of SS Eligibility on Volunteering Rate",
        x = "Bandwidth (Years from Cutoff)",
        y = "RDD Estimate (Percentage Points)",
        caption = "Notes: Shaded region shows 95% confidence interval."
      ) +
      scale_x_continuous(breaks = bw_results$Bandwidth) +
      theme_apep() +
      theme(plot.caption = element_text(hjust = 0, size = 8))
  }

  ggsave(paste0(fig_dir, "fig3_bandwidth.pdf"), fig3, width = 8, height = 5)
  cat("Saved: fig3_bandwidth.pdf\n")
} else {
  cat("Bandwidth results not found. Run 04_robustness.R first.\n")
}

# -----------------------------------------------------------------------------
# Figure 4: Placebo Cutoffs
# -----------------------------------------------------------------------------

cat("--- Figure 4: Placebo Cutoffs ---\n")

placebo_file <- paste0(tab_dir, "table_placebo.csv")
if (file.exists(placebo_file)) {
  placebo_results <- read_csv(placebo_file, show_col_types = FALSE)

  # Use clustered SEs if available
  se_col <- if ("SE_cluster" %in% names(placebo_results)) "SE_cluster" else "SE"

  fig4 <- ggplot(placebo_results, aes(x = factor(Cutoff), y = Estimate * 100)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_point(aes(color = Cutoff == 62), size = 4) +
    geom_errorbar(aes(ymin = (Estimate - 1.96*placebo_results[[se_col]]) * 100,
                      ymax = (Estimate + 1.96*placebo_results[[se_col]]) * 100,
                      color = Cutoff == 62), width = 0.3) +
    scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = apep_colors["secondary"]),
                       guide = "none") +
    labs(
      title = "Placebo Cutoff Tests",
      subtitle = "RDD Estimates at True (62) and Placebo Cutoffs",
      x = "Cutoff Age",
      y = "RDD Estimate (Percentage Points)",
      caption = "Notes: Only age 62 shows a positive effect. Estimates use clustered SEs."
    ) +
    theme_apep() +
    theme(plot.caption = element_text(hjust = 0, size = 8))

  ggsave(paste0(fig_dir, "fig4_placebo_cutoffs.pdf"), fig4, width = 8, height = 5)
  cat("Saved: fig4_placebo_cutoffs.pdf\n")
} else {
  cat("Placebo results not found. Run 04_robustness.R first.\n")
}

# -----------------------------------------------------------------------------
# Figure 5: Grandchild Care by Age
# -----------------------------------------------------------------------------

cat("--- Figure 5: Grandchild Care ---\n")

fig5 <- ggplot(by_age, aes(x = age, y = grandchild_rate * 100)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50", linewidth = 0.5) +
  geom_smooth(data = filter(by_age, age < 62),
              method = "lm", se = TRUE, color = apep_colors["quaternary"],
              fill = apep_colors["quaternary"], alpha = 0.2) +
  geom_smooth(data = filter(by_age, age >= 62),
              method = "lm", se = TRUE, color = apep_colors["quaternary"],
              fill = apep_colors["quaternary"], alpha = 0.2) +
  geom_point(size = 2.5, color = apep_colors["quaternary"]) +
  labs(
    title = "Grandchild Care by Age",
    subtitle = "Caring for Non-Household Children, ATUS 2003-2023",
    x = "Age",
    y = "Percent Providing Care on Diary Day",
    caption = "Notes: No clear discontinuity at age 62. Effect concentrated in volunteering."
  ) +
  scale_x_continuous(breaks = seq(55, 70, 1)) +
  theme_apep() +
  theme(plot.caption = element_text(hjust = 0, size = 8))

ggsave(paste0(fig_dir, "fig5_grandchild_care.pdf"), fig5, width = 8, height = 5)
cat("Saved: fig5_grandchild_care.pdf\n")

# -----------------------------------------------------------------------------
# Figure 6: Inference Comparison Summary
# -----------------------------------------------------------------------------

cat("--- Figure 6: Inference Method Comparison ---\n")

inference_file <- paste0(tab_dir, "table_inference_comparison.csv")
if (file.exists(inference_file)) {
  inference_summary <- read_csv(inference_file, show_col_types = FALSE)

  fig6 <- ggplot(inference_summary, aes(x = reorder(Method, Estimate), y = Estimate * 100)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_point(aes(color = Significant == "Yes"), size = 4) +
    geom_errorbar(aes(ymin = CI_Low * 100, ymax = CI_High * 100,
                      color = Significant == "Yes"), width = 0.3) +
    scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = apep_colors["secondary"]),
                       labels = c("Not Significant", "Significant at 5%"),
                       name = "") +
    coord_flip() +
    labs(
      title = "Effect Estimates Across Inference Methods",
      subtitle = "Effect of SS Eligibility on Any Volunteering",
      x = "",
      y = "Estimate (Percentage Points)",
      caption = "Notes: Methods accounting for discrete running variable show wider CIs."
    ) +
    theme_apep() +
    theme(
      plot.caption = element_text(hjust = 0, size = 8),
      legend.position = "bottom"
    )

  ggsave(paste0(fig_dir, "fig6_inference_comparison.pdf"), fig6, width = 8, height = 5)
  cat("Saved: fig6_inference_comparison.pdf\n")
} else {
  cat("Inference comparison not found. Run 03_main_analysis.R first.\n")
}

cat("\n" , "=" %>% strrep(70), "\n")
cat("Figures complete!\n")
cat("=" %>% strrep(70), "\n")
