## =============================================================================
## 05_figures.R — Generate all publication-ready figures
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "yrbs_panel.rds"))
laws <- readRDS(file.path(data_dir, "cyberbullying_laws.rds"))
sa_es_results <- readRDS(file.path(data_dir, "sa_es_results.rds"))
twfe_results <- readRDS(file.path(data_dir, "twfe_results.rds"))
ri_results <- readRDS(file.path(data_dir, "ri_results.rds"))

## Resolve namespace conflict
fpvalue <- fixest::pvalue

## APEP Standard Theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    axis.line = element_line(color = "grey30", linewidth = 0.4),
    axis.ticks = element_line(color = "grey30", linewidth = 0.3),
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10, color = "grey30"),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    plot.title = element_text(size = 13, face = "bold", hjust = 0),
    plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
    plot.margin = margin(10, 15, 10, 10)
  )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

## =============================================================================
## Figure 1: Treatment Rollout Map
## =============================================================================

cat("Figure 1: Treatment rollout...\n")

states_sf <- tryCatch({
  tigris::states(cb = TRUE, year = 2020) %>%
    filter(!STUSPS %in% c("HI", "AK", "PR", "VI", "GU", "AS", "MP")) %>%
    sf::st_transform(2163)
}, error = function(e) {
  cat(sprintf("  tigris failed: %s. Skipping map.\n", e$message))
  NULL
})

if (!is.null(states_sf)) {
  map_data <- states_sf %>%
    left_join(laws, by = c("STUSPS" = "state_abbr")) %>%
    mutate(
      adoption_period = case_when(
        is.na(law_year) ~ "Never adopted",
        law_year <= 2008 ~ "2006-2008",
        law_year <= 2011 ~ "2009-2011",
        TRUE ~ "2012-2015"
      ),
      adoption_period = factor(adoption_period,
                               levels = c("2006-2008", "2009-2011",
                                          "2012-2015", "Never adopted"))
    )

  p1 <- ggplot(map_data) +
    geom_sf(aes(fill = adoption_period), color = "white", linewidth = 0.3) +
    scale_fill_manual(
      values = c("2006-2008" = apep_colors[1],
                 "2009-2011" = apep_colors[6],
                 "2012-2015" = apep_colors[3],
                 "Never adopted" = "grey80"),
      name = "Adoption Period"
    ) +
    labs(
      title = "Staggered Adoption of State Anti-Cyberbullying Laws",
      subtitle = "48 states adopted between 2006 and 2015; AK and WI never adopted specific provisions",
      caption = "Source: NCSL, Cyberbullying Research Center (Hinduja & Patchin, 2016)"
    ) +
    theme_apep() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      panel.grid = element_blank(),
      axis.line = element_blank()
    )

  ggsave(file.path(fig_dir, "fig1_treatment_map.pdf"), p1,
         width = 8, height = 5, device = cairo_pdf)
  cat("  Saved fig1_treatment_map.pdf\n")
} else {
  cat("  Skipped map.\n")
}

## =============================================================================
## Figure 2: Treatment Rollout Histogram
## =============================================================================

cat("Figure 2: Treatment rollout histogram...\n")

rollout_df <- laws %>%
  filter(!is.na(law_year)) %>%
  count(law_year)

p2 <- ggplot(rollout_df, aes(x = law_year, y = n)) +
  geom_col(fill = apep_colors[1], alpha = 0.8, width = 0.7) +
  geom_text(aes(label = n), vjust = -0.5, size = 3.5, fontface = "bold") +
  scale_x_continuous(breaks = 2006:2015) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Distribution of Anti-Cyberbullying Law Adoption",
    x = "Year of Adoption",
    y = "Number of States",
    caption = "Note: 48 states adopted; AK and WI never included specific cyberbullying provisions."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_adoption_histogram.pdf"), p2,
       width = 7, height = 4.5, device = cairo_pdf)
cat("  Saved fig2_adoption_histogram.pdf\n")

## =============================================================================
## Figure 3: Outcome Trends by Cohort Group
## =============================================================================

cat("Figure 3: Outcome trends by cohort...\n")

panel <- panel %>%
  mutate(
    cohort_group = case_when(
      is.na(law_year) ~ "Never treated",
      law_year <= 2008 ~ "Early (2006-2008)",
      law_year <= 2011 ~ "Middle (2009-2011)",
      TRUE ~ "Late (2012-2015)"
    ),
    cohort_group = factor(cohort_group,
                          levels = c("Early (2006-2008)", "Middle (2009-2011)",
                                     "Late (2012-2015)", "Never treated"))
  )

cohort_means <- panel %>%
  filter(!is.na(suicide_ideation)) %>%
  group_by(year, cohort_group) %>%
  summarise(
    mean_val = mean(suicide_ideation, na.rm = TRUE),
    se_val = sd(suicide_ideation, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

p3a <- ggplot(cohort_means, aes(x = year, y = mean_val, color = cohort_group)) +
  geom_point(size = 2.5) +
  geom_line(linewidth = 0.7) +
  geom_ribbon(aes(ymin = mean_val - 1.96*se_val, ymax = mean_val + 1.96*se_val,
                  fill = cohort_group), alpha = 0.05, color = NA) +
  scale_color_manual(values = c(apep_colors[1:3], "grey50"), name = "Cohort") +
  scale_fill_manual(values = c(apep_colors[1:3], "grey50"), guide = "none") +
  labs(
    title = "Suicide Ideation by Treatment Cohort",
    x = "YRBS Survey Year",
    y = "% Considered Suicide"
  ) +
  theme_apep()

cohort_dep <- panel %>%
  filter(!is.na(depression)) %>%
  group_by(year, cohort_group) %>%
  summarise(mean_val = mean(depression, na.rm = TRUE),
            se_val = sd(depression, na.rm = TRUE) / sqrt(n()),
            .groups = "drop")

p3b <- ggplot(cohort_dep, aes(x = year, y = mean_val, color = cohort_group)) +
  geom_point(size = 2.5) +
  geom_line(linewidth = 0.7) +
  geom_ribbon(aes(ymin = mean_val - 1.96*se_val, ymax = mean_val + 1.96*se_val,
                  fill = cohort_group), alpha = 0.05, color = NA) +
  scale_color_manual(values = c(apep_colors[1:3], "grey50"), name = "Cohort") +
  scale_fill_manual(values = c(apep_colors[1:3], "grey50"), guide = "none") +
  labs(
    title = "Depression (Sad or Hopeless) by Treatment Cohort",
    x = "YRBS Survey Year",
    y = "% Feeling Sad or Hopeless"
  ) +
  theme_apep()

p3 <- p3a / p3b + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig3_cohort_trends.pdf"), p3,
       width = 8, height = 9, device = cairo_pdf)
cat("  Saved fig3_cohort_trends.pdf\n")

## =============================================================================
## Figure 4: Event Study Plots (Sun-Abraham)
## =============================================================================

cat("Figure 4: Event studies (Sun-Abraham)...\n")

make_sa_es_plot <- function(sa_es, title, ylab, xlims = NULL) {
  if (is.null(sa_es)) return(ggplot() + labs(title = paste("No data:", title)))

  es_df <- data.frame(
    period = as.numeric(gsub("year::", "", names(coef(sa_es)))),
    att = as.numeric(coef(sa_es)),
    se = as.numeric(se(sa_es))
  ) %>%
    filter(!is.na(period)) %>%
    arrange(period)

  p <- ggplot(es_df, aes(x = period, y = att)) +
    geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
                alpha = 0.15, fill = apep_colors[1]) +
    geom_point(color = apep_colors[1], size = 2.5) +
    geom_line(color = apep_colors[1], linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_x_continuous(breaks = scales::pretty_breaks(), limits = xlims) +
    labs(title = title, x = "Relative Time (Years to Treatment)", y = ylab) +
    theme_apep()
  p
}

# Compute common x-axis range for panels A-C (primary mental health outcomes)
get_periods <- function(sa_es) {
  if (is.null(sa_es)) return(numeric(0))
  as.numeric(gsub("year::", "", names(coef(sa_es))))
}
all_periods_abc <- c(get_periods(sa_es_results[["suicide_ideation"]]),
                     get_periods(sa_es_results[["suicide_attempt"]]),
                     get_periods(sa_es_results[["depression"]]))
all_periods_abc <- all_periods_abc[!is.na(all_periods_abc)]
common_xlims <- if (length(all_periods_abc) > 0) range(all_periods_abc) else NULL

p4a <- make_sa_es_plot(sa_es_results[["suicide_ideation"]],
                       "A. Suicide Ideation", "ATT (percentage points)", xlims = common_xlims)
p4b <- make_sa_es_plot(sa_es_results[["suicide_attempt"]],
                       "B. Suicide Attempt", "ATT (percentage points)", xlims = common_xlims)
p4c <- make_sa_es_plot(sa_es_results[["depression"]],
                       "C. Depression (Sad/Hopeless)", "ATT (percentage points)", xlims = common_xlims)
p4d <- make_sa_es_plot(sa_es_results[["bullying_school"]],
                       "D. Traditional Bullying (Spillover)", "ATT (percentage points)")

p4 <- (p4a | p4b) / (p4c | p4d)

ggsave(file.path(fig_dir, "fig4_event_studies.pdf"), p4,
       width = 10, height = 8, device = cairo_pdf)
cat("  Saved fig4_event_studies.pdf\n")

## =============================================================================
## Figure 5: Randomization Inference Distribution
## =============================================================================

cat("Figure 5: Randomization inference...\n")

ri_plots <- list()
for (outcome in names(ri_results)) {
  ri <- ri_results[[outcome]]
  label <- gsub("_", " ", tools::toTitleCase(outcome))

  ri_df <- data.frame(coef = ri$perm_dist)

  p <- ggplot(ri_df, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white", alpha = 0.8) +
    geom_vline(xintercept = ri$actual, color = apep_colors[2],
               linewidth = 1, linetype = "solid") +
    annotate("text", x = ri$actual, y = Inf, vjust = 2,
             label = sprintf("Actual = %.3f\nRI p = %.3f", ri$actual, ri$p_value),
             color = apep_colors[2], fontface = "bold", size = 3.5) +
    labs(title = label, x = "Coefficient Under Null", y = "Frequency") +
    theme_apep()

  ri_plots[[outcome]] <- p
}

p5 <- wrap_plots(ri_plots, ncol = 3)
ggsave(file.path(fig_dir, "fig5_randomization_inference.pdf"), p5,
       width = 12, height = 4.5, device = cairo_pdf)
cat("  Saved fig5_randomization_inference.pdf\n")

## =============================================================================
## Figure 6: TWFE Coefficient Gradient Across Outcomes
## =============================================================================

cat("Figure 6: Severity gradient...\n")

outcome_names <- c("Depression" = "depression",
                   "Suicide\nIdeation" = "suicide_ideation",
                   "Suicide\nPlan" = "suicide_plan",
                   "Suicide\nAttempt" = "suicide_attempt",
                   "Bullying\n(School)" = "bullying_school",
                   "Cyber-\nbullying" = "cyberbullying")

gradient_df <- data.frame(
  outcome = names(outcome_names),
  order = seq_along(outcome_names),
  att = NA_real_,
  se = NA_real_,
  stringsAsFactors = FALSE
)

for (i in seq_along(outcome_names)) {
  key <- outcome_names[i]
  fit <- twfe_results[[key]]
  if (!is.null(fit)) {
    gradient_df$att[i] <- coef(fit)[[1]]
    gradient_df$se[i] <- se(fit)[[1]]
  }
}

gradient_df <- gradient_df %>% filter(!is.na(att))

p6 <- ggplot(gradient_df, aes(x = reorder(outcome, order), y = att)) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
                width = 0.15, color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "TWFE Point Estimates Across Mental Health Outcome Severity",
    x = "Outcome (Increasing Severity)",
    y = "Coefficient (percentage points)",
    caption = "TWFE estimates with state and year fixed effects. 95% CI from state-clustered SEs."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_severity_gradient.pdf"), p6,
       width = 7, height = 5, device = cairo_pdf)
cat("  Saved fig6_severity_gradient.pdf\n")

cat("\n=== All figures generated ===\n")
