################################################################################
# 05_figures.R — All Figure Generation
# Paper: Digital Exodus or Digital Magnet?
################################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "00_packages.R"), "00_packages.R"))

cat("=== Generating Figures ===\n")

###############################################################################
# Load data and results
###############################################################################

qcew_panel <- read_csv(file.path(DATA_DIR, "qcew_panel.csv"),
                       show_col_types = FALSE) %>%
  mutate(state_f = factor(state_abbr), time_f = factor(yearqtr))

bfs_panel <- read_csv(file.path(DATA_DIR, "bfs_panel.csv"),
                      show_col_types = FALSE)

privacy_laws <- read_csv(file.path(DATA_DIR, "privacy_law_dates.csv"),
                         show_col_types = FALSE)

cs_dynamic  <- tryCatch(readRDS(file.path(DATA_DIR, "cs_dynamic.rds")),
                        error = function(e) list())
es_results  <- tryCatch(readRDS(file.path(DATA_DIR, "es_results.rds")),
                        error = function(e) list())
ri_results  <- tryCatch(readRDS(file.path(DATA_DIR, "ri_results.rds")),
                        error = function(e) NULL)
bacon_out   <- tryCatch(readRDS(file.path(DATA_DIR, "bacon_decomp.rds")),
                        error = function(e) NULL)

###############################################################################
# Figure 1: Treatment Adoption Timeline
###############################################################################

cat("  Figure 1: Treatment timeline\n")

treat_timeline <- privacy_laws %>%
  mutate(
    state_label = paste0(state_abbr, " (", format(effective_date, "%b %Y"), ")"),
    state_label = fct_reorder(state_label, effective_date)
  )

fig1 <- ggplot(treat_timeline,
               aes(x = effective_date, y = state_label)) +
  geom_segment(aes(xend = effective_date, yend = state_label),
               x = as.Date("2018-01-01"), color = "grey80", linewidth = 0.3) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_vline(xintercept = as.Date("2020-01-01"), linetype = "dashed",
             color = "grey50", linewidth = 0.4) +
  annotate("text", x = as.Date("2020-01-01"), y = 1, label = "CCPA\neffective",
           hjust = 1.1, size = 3, color = "grey50") +
  labs(
    title = "Staggered Adoption of State Data Privacy Laws",
    subtitle = "Effective dates of comprehensive consumer data privacy statutes",
    x = "Effective Date",
    y = NULL
  ) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_apep() +
  theme(axis.text.y = element_text(size = 8))

ggsave(file.path(FIG_DIR, "fig1_treatment_timeline.pdf"),
       fig1, width = 8, height = 7, dpi = 300)

###############################################################################
# Figure 2: Raw Trends — Treated vs Control
###############################################################################

cat("  Figure 2: Raw trends\n")

# Compute average log employment by treatment status × quarter
trend_data <- qcew_panel %>%
  filter(industry == "Information") %>%
  mutate(group = ifelse(treated_state == 1, "Treated", "Control")) %>%
  group_by(group, yearqtr) %>%
  summarize(
    mean_log_emp = mean(log_emp, na.rm = TRUE),
    se_log_emp = sd(log_emp, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Earliest treatment date for vertical line
first_treat <- min(privacy_laws$treat_yearqtr, na.rm = TRUE)

fig2 <- ggplot(trend_data, aes(x = yearqtr, y = mean_log_emp,
                                color = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_log_emp - 1.96 * se_log_emp,
                  ymax = mean_log_emp + 1.96 * se_log_emp),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = first_treat, linetype = "dashed",
             color = "grey50", linewidth = 0.4) +
  annotate("text", x = first_treat, y = max(trend_data$mean_log_emp),
           label = "First treatment\n(CA CCPA)", hjust = -0.1, size = 3,
           color = "grey50") +
  scale_color_manual(values = c("Control" = apep_colors[2],
                                 "Treated" = apep_colors[1])) +
  scale_fill_manual(values = c("Control" = apep_colors[2],
                                "Treated" = apep_colors[1])) +
  labs(
    title = "Information Sector Employment: Treated vs. Control States",
    subtitle = "Mean log employment with 95% confidence bands",
    x = "Year-Quarter",
    y = "Mean Log Employment",
    color = NULL, fill = NULL
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig2_raw_trends.pdf"),
       fig2, width = 9, height = 5.5, dpi = 300)

###############################################################################
# Figure 3: CS-DiD Event Study
###############################################################################

cat("  Figure 3: CS-DiD event study\n")

if (length(cs_dynamic) > 0) {
  es_plots <- list()

  for (ind in names(cs_dynamic)) {
    dyn <- cs_dynamic[[ind]]

    es_df <- tibble(
      rel_time = dyn$egt,
      att = dyn$att.egt,
      se = dyn$se.egt,
      ci_lo = att - 1.96 * se,
      ci_hi = att + 1.96 * se
    )

    p <- ggplot(es_df, aes(x = rel_time, y = att)) +
      geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
      geom_vline(xintercept = -0.5, linetype = "dashed",
                 color = "grey50", linewidth = 0.3) +
      geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                  fill = apep_colors[1], alpha = 0.15) +
      geom_line(color = apep_colors[1], linewidth = 0.7) +
      geom_point(color = apep_colors[1], size = 2) +
      labs(
        title = ind,
        x = "Quarters Relative to Treatment",
        y = "ATT (log employment)"
      ) +
      theme_apep()

    es_plots[[ind]] <- p
  }

  # Combine panels
  if (length(es_plots) >= 2) {
    fig3 <- wrap_plots(es_plots, ncol = 2) +
      plot_annotation(
        title = "Dynamic Treatment Effects: Callaway-Sant'Anna Estimator",
        subtitle = "Group-time ATTs aggregated by event time, 95% CI",
        theme = theme_apep()
      )
  } else if (length(es_plots) == 1) {
    fig3 <- es_plots[[1]] +
      labs(title = "Dynamic Treatment Effects: Callaway-Sant'Anna Estimator",
           subtitle = "Group-time ATTs aggregated by event time, 95% CI")
  }

  ggsave(file.path(FIG_DIR, "fig3_cs_event_study.pdf"),
         fig3, width = 10, height = 6, dpi = 300)
}

###############################################################################
# Figure 4: TWFE Event Study (fixest)
###############################################################################

cat("  Figure 4: TWFE event study\n")

if (length(es_results) > 0) {
  es_coef_plots <- list()

  for (ind in names(es_results)) {
    fit <- es_results[[ind]]
    ct <- as.data.frame(coeftable(fit))
    ct$term <- rownames(ct)

    # Parse relative time from coefficient names
    ct <- ct %>%
      filter(grepl("rel_time_binned", term)) %>%
      mutate(
        rel_time = as.numeric(str_extract(term, "-?\\d+")),
        ci_lo = Estimate - 1.96 * `Std. Error`,
        ci_hi = Estimate + 1.96 * `Std. Error`
      )

    # Add reference period (t = -1)
    ct <- bind_rows(ct, tibble(Estimate = 0, `Std. Error` = 0,
                                rel_time = -1, ci_lo = 0, ci_hi = 0,
                                term = "ref"))

    p <- ggplot(ct, aes(x = rel_time, y = Estimate)) +
      geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
      geom_vline(xintercept = -0.5, linetype = "dashed",
                 color = "grey50", linewidth = 0.3) +
      geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                  fill = apep_colors[3], alpha = 0.15) +
      geom_point(color = apep_colors[3], size = 2) +
      geom_line(color = apep_colors[3], linewidth = 0.6) +
      labs(title = ind, x = "Quarters Relative to Treatment",
           y = "Coefficient") +
      theme_apep()

    es_coef_plots[[ind]] <- p
  }

  if (length(es_coef_plots) >= 2) {
    fig4 <- wrap_plots(es_coef_plots, ncol = 2) +
      plot_annotation(
        title = "TWFE Event Study Coefficients",
        subtitle = "Reference period: t = -1 (quarter before treatment)",
        theme = theme_apep()
      )
  } else if (length(es_coef_plots) == 1) {
    fig4 <- es_coef_plots[[1]]
  }

  ggsave(file.path(FIG_DIR, "fig4_twfe_event_study.pdf"),
         fig4, width = 10, height = 6, dpi = 300)
}

###############################################################################
# Figure 5: Randomization Inference Distribution
###############################################################################

cat("  Figure 5: Randomization inference\n")

if (!is.null(ri_results)) {
  ri_df <- tibble(beta = ri_results$perm_betas)

  fig5 <- ggplot(ri_df, aes(x = beta)) +
    geom_histogram(bins = 50, fill = "grey80", color = "grey60") +
    geom_vline(xintercept = ri_results$actual_beta,
               color = apep_colors[2], linewidth = 1, linetype = "solid") +
    geom_vline(xintercept = -ri_results$actual_beta,
               color = apep_colors[2], linewidth = 0.5, linetype = "dashed") +
    annotate("text",
             x = ri_results$actual_beta, y = Inf,
             label = sprintf("Actual\n%.4f", ri_results$actual_beta),
             hjust = -0.1, vjust = 1.5, size = 3.5, color = apep_colors[2]) +
    annotate("text",
             x = max(ri_df$beta) * 0.7, y = Inf,
             label = sprintf("RI p = %.3f\n(n = %d perms)",
                             ri_results$ri_pvalue, length(ri_results$perm_betas)),
             vjust = 2, size = 3.5, fontface = "italic") +
    labs(
      title = "Fisher Randomization Inference: Information Sector",
      subtitle = "Distribution of placebo treatment effects under random assignment",
      x = expression(hat(beta)[placebo]),
      y = "Count"
    ) +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig5_randomization_inference.pdf"),
         fig5, width = 8, height = 5, dpi = 300)
}

###############################################################################
# Figure 6: Goodman-Bacon Decomposition
###############################################################################

cat("  Figure 6: Bacon decomposition\n")

if (!is.null(bacon_out)) {
  fig6 <- ggplot(bacon_out, aes(x = weight, y = estimate, color = type)) +
    geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_point(size = 3, alpha = 0.7) +
    scale_color_manual(values = apep_colors[1:4]) +
    labs(
      title = "Goodman-Bacon Decomposition: Information Sector",
      subtitle = "2x2 DiD sub-estimates weighted by sample size",
      x = "Weight",
      y = expression(hat(beta)["2x2"]),
      color = "Comparison Type"
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  ggsave(file.path(FIG_DIR, "fig6_bacon_decomp.pdf"),
         fig6, width = 8, height = 5.5, dpi = 300)
}

###############################################################################
# Figure 7: BFS Business Applications Trends
###############################################################################

cat("  Figure 7: BFS trends\n")

bfs_trend <- bfs_panel %>%
  filter(naics_sector %in% c("NAICS51", "NAICS54", "TOTAL"),
         yearqtr >= 2015, yearqtr <= 2024.75) %>%
  mutate(
    group = ifelse(!is.na(treat_yearqtr), "Treated", "Control"),
    sector_label = case_when(
      naics_sector == "NAICS51" ~ "Information (51)",
      naics_sector == "NAICS54" ~ "Professional/Technical (54)",
      naics_sector == "TOTAL" ~ "All Sectors",
      TRUE ~ naics_sector
    )
  ) %>%
  group_by(group, yearqtr, sector_label) %>%
  summarize(
    mean_apps = mean(avg_monthly_apps, na.rm = TRUE),
    .groups = "drop"
  )

fig7 <- ggplot(bfs_trend, aes(x = yearqtr, y = mean_apps,
                               color = group)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1) +
  facet_wrap(~sector_label, scales = "free_y", ncol = 1) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("Control" = apep_colors[2],
                                 "Treated" = apep_colors[1])) +
  labs(
    title = "Business Applications: Treated vs. Control States",
    subtitle = "Mean monthly applications by sector",
    x = "Year-Quarter",
    y = "Mean Monthly Applications",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig7_bfs_trends.pdf"),
       fig7, width = 9, height = 8, dpi = 300)

###############################################################################
# Figure 8: Industry Heterogeneity — Coefficient Plot
###############################################################################

cat("  Figure 8: Industry heterogeneity\n")

twfe_results <- tryCatch(readRDS(file.path(DATA_DIR, "twfe_results.rds")),
                         error = function(e) list())

if (length(twfe_results) > 0) {
  coef_df <- tibble(
    industry = names(twfe_results),
    estimate = sapply(twfe_results, function(x) coef(x)["treat"]),
    se = sapply(twfe_results, function(x) se(x)["treat"]),
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se
  ) %>%
    mutate(
      industry = fct_reorder(industry, estimate),
      is_tech = ifelse(industry %in% c("Information", "Software Publishers",
                                         "Computer Systems Design"),
                       "Tech", "Non-Tech")
    )

  fig8 <- ggplot(coef_df, aes(x = estimate, y = industry, color = is_tech)) +
    geom_vline(xintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                   height = 0.2, linewidth = 0.6) +
    geom_point(size = 3) +
    scale_color_manual(values = c("Tech" = apep_colors[1],
                                   "Non-Tech" = apep_colors[2])) +
    labs(
      title = "Privacy Law Effects Across Industries",
      subtitle = "TWFE estimates with 95% CI, state-clustered SEs",
      x = expression("Treatment Effect on Log Employment (" * hat(beta) * ")"),
      y = NULL,
      color = NULL
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  ggsave(file.path(FIG_DIR, "fig8_industry_heterogeneity.pdf"),
         fig8, width = 8, height = 5, dpi = 300)
}

###############################################################################
# Figure 9: Treatment Intensity Map
###############################################################################

cat("  Figure 9: Map (skipping if no maps package)\n")

tryCatch({
  if (requireNamespace("maps", quietly = TRUE)) {
    library(maps)

    state_map <- map_data("state") %>%
      mutate(state_abbr = state.abb[match(str_to_title(region), state.name)])

    map_data_df <- state_map %>%
      left_join(
        privacy_laws %>%
          mutate(treat_year = year(effective_date)) %>%
          select(state_abbr, treat_year),
        by = "state_abbr"
      ) %>%
      mutate(
        status = case_when(
          is.na(treat_year) ~ "No Privacy Law",
          treat_year <= 2020 ~ "Early Adopter (2020)",
          treat_year <= 2023 ~ "Wave 2 (2021-2023)",
          treat_year <= 2024 ~ "Wave 3 (2024)",
          TRUE ~ "Wave 4 (2025+)"
        ),
        status = factor(status, levels = c("Early Adopter (2020)", "Wave 2 (2021-2023)",
                                            "Wave 3 (2024)", "Wave 4 (2025+)",
                                            "No Privacy Law"))
      )

    fig9 <- ggplot(map_data_df, aes(x = long, y = lat, group = group, fill = status)) +
      geom_polygon(color = "white", linewidth = 0.2) +
      scale_fill_manual(values = c(
        "Early Adopter (2020)" = apep_colors[1],
        "Wave 2 (2021-2023)" = apep_colors[6],
        "Wave 3 (2024)" = apep_colors[3],
        "Wave 4 (2025+)" = apep_colors[4],
        "No Privacy Law" = "grey85"
      )) +
      coord_map("albers", lat0 = 39, lat1 = 45) +
      labs(
        title = "State Data Privacy Law Adoption",
        fill = "Treatment Cohort"
      ) +
      theme_void() +
      theme(
        legend.position = "bottom",
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
      )

    ggsave(file.path(FIG_DIR, "fig9_adoption_map.pdf"),
           fig9, width = 10, height = 6.5, dpi = 300)
  }
}, error = function(e) {
  cat("  Map generation failed:", e$message, "\n")
})

###############################################################################
# Done
###############################################################################

cat("\nFigures saved to:", FIG_DIR, "\n")
cat("Files:", paste(list.files(FIG_DIR, pattern = "\\.pdf$"), collapse = ", "), "\n")
cat("\n=== Figure generation complete ===\n")
