## =============================================================================
## 05_figures.R — Publication-quality figures
## The Innovation Cost of Privacy
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")
fig_dir  <- file.path(base_dir, "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# ==== Load results ====
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness   <- readRDS(file.path(data_dir, "robustness_results.rds"))
panel_info   <- read_csv(file.path(data_dir, "panel_information.csv"), show_col_types = FALSE)
panel_bfs    <- read_csv(file.path(data_dir, "panel_bfs.csv"), show_col_types = FALSE)

# Treatment assignment reference
privacy_laws <- tribble(
  ~state_abbr, ~law_name, ~effective_year,
  "CA", "CCPA", 2020,
  "VA", "VCDPA", 2023,
  "CO", "CPA", 2023,
  "CT", "CTDPA", 2023,
  "UT", "UCPA", 2024,
  "TX", "TDPSA", 2024,
  "OR", "OCPA", 2024,
  "MT", "MTCDPA", 2024,
  "DE", "DPDPA", 2025,
  "IA", "ICDPA", 2025,
  "NE", "NDPA", 2025,
  "NH", "NHPA", 2025,
  "NJ", "NJDPA", 2025,
  "TN", "TIPA", 2025,
  "MN", "MCDPA", 2025,
  "MD", "MODPA", 2025
)
# Note: IN, KY, RI (2026) excluded — data panel ends 2025Q4


# ==== Figure 1: Treatment Adoption Map ====
cat("Creating Figure 1: Treatment map...\n")

us_states <- map_data("state")

# State name -> abbreviation lookup
state_lookup <- tibble(
  region = tolower(state.name),
  state_abbr = state.abb
) %>% add_row(region = "district of columbia", state_abbr = "DC")

map_data_df <- us_states %>%
  left_join(state_lookup, by = "region") %>%
  left_join(privacy_laws %>% select(state_abbr, effective_year), by = "state_abbr") %>%
  mutate(
    treatment_status = case_when(
      effective_year <= 2020 ~ "Early (2020)",
      effective_year <= 2023 ~ "Wave 2 (2023)",
      effective_year <= 2024 ~ "Wave 3 (2024)",
      effective_year <= 2025 ~ "Wave 4 (2025)",
      TRUE ~ "No Privacy Law"
    ),
    treatment_status = factor(treatment_status,
                               levels = c("Early (2020)", "Wave 2 (2023)", "Wave 3 (2024)",
                                         "Wave 4 (2025)", "No Privacy Law"))
  )

p1 <- ggplot(map_data_df, aes(x = long, y = lat, group = group, fill = treatment_status)) +
  geom_polygon(color = "white", linewidth = 0.2) +
  scale_fill_manual(
    name = "Privacy Law Effective",
    values = c(
      "Early (2020)" = "#0072B2",
      "Wave 2 (2023)" = "#56B4E9",
      "Wave 3 (2024)" = "#009E73",
      "Wave 4 (2025)" = "#E69F00",
      "No Privacy Law" = "grey85"
    )
  ) +
  coord_map("polyconic") +
  labs(
    title = "Staggered Adoption of State Comprehensive Data Privacy Laws",
    subtitle = "19 states enacted laws by 2026; 13 with post-treatment data; Florida excluded ($1B threshold)",
    caption = "Source: IAPP State Privacy Legislation Tracker, author compilation."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.size = unit(0.4, "cm"),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0.5),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(fig_dir, "fig1_treatment_map.pdf"), p1, width = 10, height = 6.5)
cat("  Saved fig1_treatment_map.pdf\n")


# ==== Figure 2: Pre-Trends (Treated vs Control) ====
cat("Creating Figure 2: Pre-trends...\n")

trends_data <- panel_info %>%
  mutate(group = ifelse(first_treat > 0, "Treated States", "Control States")) %>%
  group_by(group, year, qtr) %>%
  summarise(
    mean_emp = mean(avg_emp, na.rm = TRUE),
    mean_estabs = mean(qtrly_estabs, na.rm = TRUE),
    mean_wage = mean(avg_wkly_wage, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(date = year + (qtr - 1) / 4)

p2a <- ggplot(trends_data, aes(x = date, y = mean_emp, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey50", linewidth = 0.4) +
  annotate("text", x = 2020.1, y = max(trends_data$mean_emp, na.rm = TRUE) * 0.95,
           label = "CCPA\n(2020)", size = 2.8, hjust = 0, color = "grey40") +
  scale_color_manual(values = c("Treated States" = apep_colors[1],
                                 "Control States" = apep_colors[2]),
                      name = "") +
  labs(title = "A. Average Employment in Information Sector",
       x = "", y = "Average Quarterly Employment") +
  theme_apep()

p2b <- ggplot(trends_data, aes(x = date, y = mean_estabs, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey50", linewidth = 0.4) +
  scale_color_manual(values = c("Treated States" = apep_colors[1],
                                 "Control States" = apep_colors[2]),
                      name = "") +
  labs(title = "B. Information Sector Establishments",
       x = "", y = "Quarterly Establishments") +
  theme_apep()

p2c <- ggplot(trends_data, aes(x = date, y = mean_wage, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey50", linewidth = 0.4) +
  scale_color_manual(values = c("Treated States" = apep_colors[1],
                                 "Control States" = apep_colors[2]),
                      name = "") +
  labs(title = "C. Average Weekly Wages",
       x = "Year", y = "Average Weekly Wage ($)") +
  theme_apep()

p2 <- (p2a / p2b / p2c) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_pretrends.pdf"), p2, width = 8, height = 12)
cat("  Saved fig2_pretrends.pdf\n")


# ==== Figure 3: Event Study — Software Publishers Employment (Primary) ====
cat("Creating Figure 3: Event study (Software Publishers)...\n")

es_soft <- main_results$es_soft

es_df <- data.frame(
  time = es_soft$egt,
  att = es_soft$att.egt,
  se = es_soft$se.egt
) %>%
  mutate(
    ci_lo = att - 1.96 * se,
    ci_hi = att + 1.96 * se
  )

p3 <- ggplot(es_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: Effect of Privacy Laws on Software Publishers Employment",
    subtitle = "Callaway-Sant'Anna estimator, NAICS 5112, 95% confidence intervals",
    x = "Quarters Relative to Privacy Law Effective Date",
    y = "ATT (Log Employment)",
    caption = "Note: Reference period is t = -1. Shaded region shows pointwise 95% CI.\nDoubly robust estimation with never-treated controls."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 8, 2))

ggsave(file.path(fig_dir, "fig3_event_study_emp.pdf"), p3, width = 8, height = 5.5)
cat("  Saved fig3_event_study_emp.pdf\n")


# ==== Figure 4: Event Study Panel (All Outcomes) ====
cat("Creating Figure 4: Event study panel (all outcomes)...\n")

make_es_df <- function(es, label) {
  data.frame(
    time = es$egt,
    att = es$att.egt,
    se = es$se.egt,
    outcome = label
  )
}

es_all <- bind_rows(
  make_es_df(main_results$es_soft, "Log Employment\n(Software 5112)"),
  make_es_df(main_results$es_estabs, "Log Establishments\n(Info 51)"),
  make_es_df(main_results$es_bfs, "Log Business Apps\n(BFS, CA only)")
) %>%
  mutate(
    ci_lo = att - 1.96 * se,
    ci_hi = att + 1.96 * se,
    outcome = factor(outcome, levels = c("Log Employment\n(Software 5112)", "Log Establishments\n(Info 51)",
                                          "Log Business Apps\n(BFS, CA only)"))
  )

p4 <- ggplot(es_all, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 1.8) +
  geom_line(color = apep_colors[1], linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  facet_wrap(~outcome, scales = "free_y", ncol = 3) +
  labs(
    title = "Event Studies: Privacy Law Effects Across Outcomes",
    subtitle = "Callaway-Sant'Anna DiD, doubly robust, 95% CI",
    x = "Quarters Relative to Treatment",
    y = "ATT",
    caption = "Note: Vertical dotted line marks treatment onset. Never-treated states serve as controls."
  ) +
  theme_apep() +
  theme(strip.text = element_text(size = 11, face = "bold")) +
  scale_x_continuous(breaks = seq(-8, 8, 4))

ggsave(file.path(fig_dir, "fig4_event_study_panel.pdf"), p4, width = 9, height = 7)
cat("  Saved fig4_event_study_panel.pdf\n")


# ==== Figure 5: Placebo Tests Comparison ====
cat("Creating Figure 5: Placebo comparison...\n")

placebo_results <- list()

# Main result
placebo_results[["Information (51)"]] <- list(
  att = main_results$att_emp$overall.att,
  se = main_results$att_emp$overall.se
)

# Placebos
if (!is.null(robustness$placebo_manuf)) {
  placebo_results[["Manufacturing"]] <- list(
    att = robustness$placebo_manuf$att$overall.att,
    se = robustness$placebo_manuf$att$overall.se
  )
}
if (!is.null(robustness$placebo_health)) {
  placebo_results[["Healthcare"]] <- list(
    att = robustness$placebo_health$att$overall.att,
    se = robustness$placebo_health$att$overall.se
  )
}
if (!is.null(robustness$placebo_constr)) {
  placebo_results[["Construction"]] <- list(
    att = robustness$placebo_constr$att$overall.att,
    se = robustness$placebo_constr$att$overall.se
  )
}

# Software (narrow tech)
if (!is.null(robustness$cs_soft)) {
  placebo_results[["Software (5112)"]] <- list(
    att = robustness$cs_soft$att$overall.att,
    se = robustness$cs_soft$att$overall.se
  )
}

placebo_df <- bind_rows(lapply(names(placebo_results), function(nm) {
  data.frame(
    industry = nm,
    att = placebo_results[[nm]]$att,
    se = placebo_results[[nm]]$se,
    type = ifelse(nm %in% c("Information (51)", "Software (5112)"), "Tech Sector", "Placebo")
  )
})) %>%
  mutate(
    ci_lo = att - 1.96 * se,
    ci_hi = att + 1.96 * se,
    industry = factor(industry, levels = rev(unique(industry)))
  )

p5 <- ggplot(placebo_df, aes(x = att, y = industry, color = type)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, linewidth = 0.6) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("Tech Sector" = apep_colors[1],
                                 "Placebo" = apep_colors[2]),
                      name = "") +
  labs(
    title = "Placebo Tests: Privacy Laws Should Only Affect Tech Sectors",
    subtitle = "CS-DiD ATT estimates with 95% CI across industries",
    x = "ATT (Log Employment)",
    y = "",
    caption = "Note: Placebo industries (Manufacturing, Healthcare, Construction) should show null effects."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig5_placebo_tests.pdf"), p5, width = 8, height = 5)
cat("  Saved fig5_placebo_tests.pdf\n")


# ==== Figure 6: Randomization Inference Distribution ====
cat("Creating Figure 6: Randomization inference...\n")

if (length(robustness$ri_distribution) > 10) {
  ri_df <- data.frame(att = robustness$ri_distribution)

  p6 <- ggplot(ri_df, aes(x = att)) +
    geom_histogram(bins = 40, fill = "grey70", color = "white", alpha = 0.8) +
    geom_vline(xintercept = robustness$ri_observed, color = apep_colors[1],
               linewidth = 1.2, linetype = "solid") +
    geom_vline(xintercept = -robustness$ri_observed, color = apep_colors[1],
               linewidth = 0.8, linetype = "dashed") +
    annotate("text", x = robustness$ri_observed, y = Inf,
             label = sprintf("Observed\nATT = %.4f", robustness$ri_observed),
             vjust = 1.5, hjust = -0.1, size = 3.5, color = apep_colors[1], fontface = "bold") +
    annotate("text", x = max(ri_df$att) * 0.6, y = Inf,
             label = sprintf("RI p-value = %.3f\n(n = %d permutations)",
                             robustness$ri_pvalue, length(robustness$ri_distribution)),
             vjust = 2, hjust = 0.5, size = 3.2, color = "grey30") +
    labs(
      title = "Randomization Inference: Permutation Distribution of ATT",
      subtitle = "500 random reassignments of treatment status",
      x = "Permuted ATT (Log Employment)",
      y = "Frequency",
      caption = "Note: Solid line = observed ATT. Dashed line = mirror image. Grey bars = permutation distribution."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_randomization_inference.pdf"), p6, width = 8, height = 5)
  cat("  Saved fig6_randomization_inference.pdf\n")
} else {
  cat("  Skipping RI figure (insufficient valid permutations)\n")
}


# ==== Figure 7: Heterogeneity by Tech Intensity ====
cat("Creating Figure 7: Heterogeneity...\n")

het_data <- list()
if (!is.null(robustness$het_high)) {
  es_high <- aggte(robustness$het_high$cs, type = "dynamic", min_e = -8, max_e = 8)
  het_data[["High-Tech States"]] <- make_es_df(es_high, "High-Tech States")
}
if (!is.null(robustness$het_low)) {
  es_low <- aggte(robustness$het_low$cs, type = "dynamic", min_e = -8, max_e = 8)
  het_data[["Low-Tech States"]] <- make_es_df(es_low, "Low-Tech States")
}

if (length(het_data) == 2) {
  het_df <- bind_rows(het_data) %>%
    mutate(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)

  p7 <- ggplot(het_df, aes(x = time, y = att, color = outcome, fill = outcome)) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, color = NA) +
    geom_point(size = 2) +
    geom_line(linewidth = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c("High-Tech States" = apep_colors[1],
                                   "Low-Tech States" = apep_colors[2]),
                        name = "") +
    scale_fill_manual(values = c("High-Tech States" = apep_colors[1],
                                  "Low-Tech States" = apep_colors[2]),
                       name = "") +
    labs(
      title = "Heterogeneity: Privacy Law Effects by Baseline Tech Intensity",
      subtitle = "States split at median share of Information sector employment (2019)",
      x = "Quarters Relative to Treatment",
      y = "ATT (Log Employment)",
      caption = "Note: CS-DiD with doubly robust estimation. 95% CI shown."
    ) +
    theme_apep() +
    scale_x_continuous(breaks = seq(-8, 8, 2))

  ggsave(file.path(fig_dir, "fig7_heterogeneity.pdf"), p7, width = 8, height = 5.5)
  cat("  Saved fig7_heterogeneity.pdf\n")
} else {
  cat("  Skipping heterogeneity figure (missing results)\n")
}


# ==== Figure 8: Treatment Timing Plot ====
cat("Creating Figure 8: Treatment timing...\n")

timing_df <- privacy_laws %>%
  arrange(effective_year) %>%
  mutate(state_abbr = factor(state_abbr, levels = rev(state_abbr)))

p8 <- ggplot(timing_df, aes(x = effective_year, y = state_abbr)) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_segment(aes(xend = 2025.75, yend = state_abbr), linewidth = 0.3,
               color = apep_colors[1], alpha = 0.3) +
  geom_vline(xintercept = 2019.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2019.5, y = 0.5, label = "Pre-treatment cutoff",
           hjust = 1.05, size = 2.8, color = "grey40") +
  labs(
    title = "Treatment Timing: State Privacy Law Effective Dates",
    subtitle = "Each point marks the quarter a state's privacy law took effect",
    x = "Year",
    y = ""
  ) +
  theme_apep() +
  scale_x_continuous(breaks = 2015:2025, limits = c(2015, 2025.75))

ggsave(file.path(fig_dir, "fig8_treatment_timing.pdf"), p8, width = 8, height = 6)
cat("  Saved fig8_treatment_timing.pdf\n")


cat("\n=== All figures complete ===\n")
