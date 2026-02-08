# ==============================================================================
# Paper 86: Minimum Wage and Teen Time Allocation
# 05_figures.R - Generate publication-quality figures
# ==============================================================================

source("00_packages.R")

cat("\n=== Generating Figures ===\n")

# Load data and results
data_dir <- "../data"
fig_dir <- "../figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
# Same restriction as main analysis: 2010-2023 (federal MW constant)
df <- df[YEAR >= 2010 & YEAR < 2024]

# Load event study results
es_fe <- readRDS(file.path(data_dir, "event_study_fe.rds"))

# ==============================================================================
# Figure 1: Minimum Wage Variation Over Time
# ==============================================================================

cat("\nFigure 1: MW variation over time...\n")

# Load MW panel
mw_panel <- fread(file.path(data_dir, "state_mw_panel.csv"))

# Calculate share of states with MW above federal by year
mw_by_year <- mw_panel[, .(
  pct_above = mean(mw_above_federal, na.rm = TRUE) * 100,
  mean_mw = mean(effective_mw, na.rm = TRUE),
  max_mw = max(effective_mw, na.rm = TRUE),
  federal = unique(federal_mw)
), by = .(year)]

# Panel A: Share of states with MW above federal
p1a <- ggplot(mw_by_year, aes(x = year, y = pct_above)) +
  geom_line(linewidth = 1, color = apep_colors["blue"]) +
  geom_point(size = 2, color = apep_colors["blue"]) +
  scale_x_continuous(breaks = seq(2003, 2023, 4)) +
  scale_y_continuous(limits = c(0, 100)) +
  labs(
    title = "A. Share of States with MW Above Federal",
    x = "Year",
    y = "Percent of States"
  ) +
  theme_apep()

# Panel B: Mean effective MW vs federal
mw_long <- mw_by_year |>
  select(year, mean_mw, federal) |>
  pivot_longer(cols = c(mean_mw, federal), names_to = "type", values_to = "mw")

p1b <- ggplot(mw_long, aes(x = year, y = mw, color = type, linetype = type)) +
  geom_line(linewidth = 1) +
  scale_x_continuous(breaks = seq(2003, 2023, 4)) +
  scale_color_manual(
    values = c("mean_mw" = apep_colors["blue"], "federal" = apep_colors["red"]),
    labels = c("Mean State MW", "Federal MW")
  ) +
  scale_linetype_manual(
    values = c("mean_mw" = "solid", "federal" = "dashed"),
    labels = c("Mean State MW", "Federal MW")
  ) +
  labs(
    title = "B. Mean Effective MW vs Federal",
    x = "Year",
    y = "Minimum Wage ($/hour)",
    color = NULL,
    linetype = NULL
  ) +
  theme_apep() +
  theme(legend.position = c(0.25, 0.85))

# Combine
fig1 <- p1a + p1b +
  plot_annotation(
    title = "State Minimum Wage Variation, 2003-2023",
    theme = theme(plot.title = element_text(face = "bold", size = 14))
  )

ggsave(file.path(fig_dir, "fig1_mw_variation.pdf"), fig1, width = 10, height = 4.5)
ggsave(file.path(fig_dir, "fig1_mw_variation.png"), fig1, width = 10, height = 4.5, dpi = 300)

cat("  Saved: fig1_mw_variation.pdf\n")

# ==============================================================================
# Figure 2: Event Study Plot
# ==============================================================================

cat("\nFigure 2: Event study...\n")

# Extract event study coefficients
es_coef <- broom::tidy(es_fe, conf.int = TRUE)
es_coef <- as.data.table(es_coef)

# Parse event time from term
es_coef[, event_time := as.numeric(gsub("event_time_bin::", "", term))]

# Add reference period (t=-1)
ref_row <- data.table(
  term = "event_time_bin::-1",
  estimate = 0,
  std.error = 0,
  statistic = NA,
  p.value = NA,
  conf.low = 0,
  conf.high = 0,
  event_time = -1
)
es_coef <- rbind(es_coef, ref_row)
es_coef <- es_coef[order(event_time)]

# Create event study plot
fig2 <- ggplot(es_coef, aes(x = event_time, y = estimate)) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  # Confidence intervals
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, fill = apep_colors["blue"]) +
  # Point estimates
  geom_line(linewidth = 0.8, color = apep_colors["blue"]) +
  geom_point(size = 2.5, color = apep_colors["blue"]) +
  # Reference point
  geom_point(data = es_coef[event_time == -1], size = 3, shape = 18, color = apep_colors["red"]) +
  # Scales
  scale_x_continuous(breaks = -5:5, limits = c(-5.5, 5.5)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  # Labels
  labs(
    title = "Effect of State MW Increases on Teen Employment",
    subtitle = "Event study estimates relative to year before first MW increase above federal",
    x = "Years Relative to First MW Increase",
    y = "Effect on Employment Rate",
    caption = "Notes: Coefficients from two-way fixed effects regression with state and year FE.\n95% confidence intervals with standard errors clustered at state level."
  ) +
  # Theme
  theme_apep() +
  theme(
    plot.caption = element_text(hjust = 0, size = 9)
  )

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), fig2, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig2_event_study.png"), fig2, width = 8, height = 5.5, dpi = 300)

cat("  Saved: fig2_event_study.pdf\n")

# ==============================================================================
# Figure 3: Heterogeneity by Age
# ==============================================================================

cat("\nFigure 3: Heterogeneity by age...\n")

# Run age-specific regressions
age_results <- list()
for (a in 16:19) {
  mod <- feols(
    employed ~ mw_above_federal | STATEFIP + YEAR,
    data = df[AGE == a],
    weights = ~weight,
    cluster = ~STATEFIP
  )
  age_results[[as.character(a)]] <- data.table(
    age = a,
    estimate = coef(mod)["mw_above_federalTRUE"],
    se = se(mod)["mw_above_federalTRUE"]
  )
}
age_df <- rbindlist(age_results)
age_df[, ci_low := estimate - 1.96 * se]
age_df[, ci_high := estimate + 1.96 * se]

fig3 <- ggplot(age_df, aes(x = factor(age), y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2, color = apep_colors["blue"]) +
  geom_point(size = 3, color = apep_colors["blue"]) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Effect of MW on Employment by Age",
    x = "Age",
    y = "Effect on Employment Rate",
    caption = "Notes: Separate TWFE regressions for each age group.\n95% CIs with standard errors clustered at state level."
  ) +
  theme_apep() +
  theme(plot.caption = element_text(hjust = 0, size = 9))

ggsave(file.path(fig_dir, "fig3_heterogeneity_age.pdf"), fig3, width = 6, height = 5)
ggsave(file.path(fig_dir, "fig3_heterogeneity_age.png"), fig3, width = 6, height = 5, dpi = 300)

cat("  Saved: fig3_heterogeneity_age.pdf\n")

# ==============================================================================
# Figure 4: Treatment Cohort Map
# ==============================================================================

cat("\nFigure 4: Treatment cohort map...\n")

# Get first treatment year by state
# First add first_treat_year if missing
if (!"first_treat_year" %in% names(df)) {
  df[first_treat_ym > 0, first_treat_year := floor(first_treat_ym / 12)]
  df[first_treat_ym == 0, first_treat_year := 0]
}
state_treat <- unique(df[, .(STATEFIP, first_treat_year)])
state_treat[first_treat_year == 0, first_treat_year := NA]

# Create treatment period categories
state_treat[, treat_period := case_when(
  is.na(first_treat_year) ~ "Never treated",
  first_treat_year <= 2005 ~ "2003-2005",
  first_treat_year <= 2010 ~ "2006-2010",
  first_treat_year <= 2015 ~ "2011-2015",
  TRUE ~ "2016-2023"
)]
state_treat[, treat_period := factor(treat_period,
                                      levels = c("2003-2005", "2006-2010", "2011-2015",
                                                 "2016-2023", "Never treated"))]

# Get US state map data
us_states <- map_data("state")

# Create state name lookup
state_lookup <- data.table(
  STATEFIP = c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20,
               21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
               36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51,
               53, 54, 55, 56),
  region = tolower(c("alabama", "alaska", "arizona", "arkansas", "california",
                     "colorado", "connecticut", "delaware", "district of columbia",
                     "florida", "georgia", "hawaii", "idaho", "illinois", "indiana",
                     "iowa", "kansas", "kentucky", "louisiana", "maine", "maryland",
                     "massachusetts", "michigan", "minnesota", "mississippi", "missouri",
                     "montana", "nebraska", "nevada", "new hampshire", "new jersey",
                     "new mexico", "new york", "north carolina", "north dakota", "ohio",
                     "oklahoma", "oregon", "pennsylvania", "rhode island", "south carolina",
                     "south dakota", "tennessee", "texas", "utah", "vermont", "virginia",
                     "washington", "west virginia", "wisconsin", "wyoming"))
)

state_treat <- merge(state_treat, state_lookup, by = "STATEFIP", all.x = TRUE)
us_states <- merge(us_states, state_treat, by = "region", all.x = TRUE)

fig4 <- ggplot(us_states, aes(x = long, y = lat, group = group, fill = treat_period)) +
  geom_polygon(color = "white", linewidth = 0.2) +
  coord_fixed(1.3) +
  scale_fill_viridis_d(
    option = "plasma",
    na.value = "gray80",
    name = "First MW Increase\nAbove Federal"
  ) +
  labs(
    title = "Timing of State Minimum Wage Increases",
    caption = "Notes: Shows year of first state MW increase above federal level."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.caption = element_text(hjust = 0, size = 9),
    legend.position = "bottom"
  )

ggsave(file.path(fig_dir, "fig4_treatment_map.pdf"), fig4, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig4_treatment_map.png"), fig4, width = 9, height = 6, dpi = 300)

cat("  Saved: fig4_treatment_map.pdf\n")

# ==============================================================================
# Figure 5: Teen Employment Trends by Treatment Status
# ==============================================================================

cat("\nFigure 5: Parallel trends...\n")

# Calculate employment rates by treatment status and year
trends <- df[, .(
  employed = weighted.mean(employed, weight, na.rm = TRUE),
  n = .N
), by = .(YEAR, ever_treated = first_treat_year > 0)]

fig5 <- ggplot(trends, aes(x = YEAR, y = employed, color = ever_treated, linetype = ever_treated)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = seq(2003, 2023, 4)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_color_manual(
    values = c("FALSE" = apep_colors["gray"], "TRUE" = apep_colors["blue"]),
    labels = c("Never Treated", "Eventually Treated")
  ) +
  scale_linetype_manual(
    values = c("FALSE" = "dashed", "TRUE" = "solid"),
    labels = c("Never Treated", "Eventually Treated")
  ) +
  labs(
    title = "Teen Employment Rates by Treatment Status",
    subtitle = "Eventually treated vs. never treated states",
    x = "Year",
    y = "Employment Rate",
    color = NULL,
    linetype = NULL,
    caption = "Notes: Employment rates weighted by ATUS sample weights."
  ) +
  theme_apep() +
  theme(
    legend.position = c(0.8, 0.9),
    plot.caption = element_text(hjust = 0, size = 9)
  )

ggsave(file.path(fig_dir, "fig5_parallel_trends.pdf"), fig5, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig5_parallel_trends.png"), fig5, width = 8, height = 5, dpi = 300)

cat("  Saved: fig5_parallel_trends.pdf\n")

# ==============================================================================
# Combine all figures for PDF output
# ==============================================================================

cat("\nCombining all figures...\n")

# Create multi-page PDF with all figures
pdf(file.path(fig_dir, "all_figures.pdf"), width = 10, height = 7)

print(fig1)
print(fig2)
print(fig3)
print(fig4)
print(fig5)

dev.off()

cat("\n=== Figures Complete ===\n")
cat("Files saved in:", normalizePath(fig_dir), "\n")
