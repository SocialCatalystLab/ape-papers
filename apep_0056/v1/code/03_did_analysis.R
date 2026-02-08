# ==============================================================================
# Paper 72: PDMP Mandatory Query Effects on Opioid Overdose Deaths
# 03_did_analysis.R - Staggered DiD Analysis with Modern Methods
# ==============================================================================

library(tidyverse)
library(fixest)  # For two-way fixed effects and event studies

# Set seed for reproducibility
set.seed(72)

cat("=== Staggered DiD Analysis: PDMP Mandates ===\n\n")

# ------------------------------------------------------------------------------
# Load Data
# ------------------------------------------------------------------------------

panel <- readRDS("../data_pdmp/panel_state_year.rds")

# Filter to valid US jurisdictions (exclude PR, YC which are in CDC data)
valid_us <- c(state.abb, "DC")
panel <- panel %>% filter(state_abbr %in% valid_us)

# TRUNCATE TO 2015-2020 to avoid post-2020 policy changes (Michigan 2021)
panel <- panel %>% filter(year <= 2020)

cat(sprintf("Panel data: %d state-years\n", nrow(panel)))
cat(sprintf("Jurisdictions: %d\n", n_distinct(panel$state_abbr)))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))

# Log transform outcome (deaths are count data, often log-normal)
panel <- panel %>%
  mutate(
    log_opioid_deaths = log(opioid_deaths_clean + 1),
    log_total_deaths = log(total_overdose_clean + 1)
  )

# Check for missing outcomes
cat(sprintf("\nMissing opioid deaths: %d\n", sum(is.na(panel$opioid_deaths_clean))))

# Remove jurisdictions with missing outcomes
panel_clean <- panel %>%
  filter(!is.na(log_opioid_deaths))

cat(sprintf("Clean panel: %d state-years\n", nrow(panel_clean)))

# ------------------------------------------------------------------------------
# Main Analysis: Two-Way Fixed Effects (TWFE)
# Benchmark specification
# ------------------------------------------------------------------------------

cat("\n=== Model 1: TWFE (Benchmark) ===\n")

# Basic TWFE
twfe_basic <- feols(
  log_opioid_deaths ~ treated | state_abbr + year,
  data = panel_clean,
  cluster = ~state_abbr
)

cat("TWFE Regression Results:\n")
print(summary(twfe_basic))

# Store coefficient
twfe_coef <- coef(twfe_basic)["treated"]
twfe_se <- sqrt(vcov(twfe_basic)["treated", "treated"])
cat(sprintf("\nTWFE ATT: %.3f (SE: %.3f)\n", twfe_coef, twfe_se))
cat(sprintf("Percent effect: %.1f%%\n", (exp(twfe_coef) - 1) * 100))

# ------------------------------------------------------------------------------
# Event Study: Pre-trends and Dynamic Effects
# ------------------------------------------------------------------------------

cat("\n=== Model 2: Event Study ===\n")

# Create event time indicators (relative to mandate adoption)
# Bin endpoints: -5 and earlier, 6 and later
panel_clean <- panel_clean %>%
  mutate(
    rel_year_binned = case_when(
      is.na(rel_year) ~ NA_integer_,
      rel_year <= -5 ~ -5L,
      rel_year >= 6 ~ 6L,
      TRUE ~ as.integer(rel_year)
    )
  )

# Event study regression
# Reference period: rel_year = -1 (year before treatment)
event_study <- feols(
  log_opioid_deaths ~ i(rel_year_binned, ref = -1) | state_abbr + year,
  data = panel_clean,
  cluster = ~state_abbr
)

cat("Event Study Results:\n")
print(summary(event_study))

# Extract event study coefficients for plotting
es_coefs <- tibble(
  rel_year = as.integer(gsub("rel_year_binned::", "", names(coef(event_study)))),
  estimate = coef(event_study),
  se = sqrt(diag(vcov(event_study)))
) %>%
  mutate(
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se
  ) %>%
  add_row(rel_year = -1, estimate = 0, se = 0, ci_low = 0, ci_high = 0) %>%
  arrange(rel_year)

cat("\nEvent Study Coefficients:\n")
print(es_coefs)

# Pre-trend test: joint significance of pre-treatment coefficients
pre_coefs <- names(coef(event_study))[grepl("::-[2-5]", names(coef(event_study)))]
if(length(pre_coefs) > 0) {
  pretrend_test <- wald(event_study, pre_coefs)
  cat(sprintf("\nPre-trend joint F-test: F=%.2f, p=%.4f\n",
              pretrend_test$stat, pretrend_test$p))
}

# ------------------------------------------------------------------------------
# Sun & Abraham (2021) Interaction-Weighted Estimator
# Robust to heterogeneous treatment effects
# ------------------------------------------------------------------------------

cat("\n=== Model 3: Sun & Abraham (IW) Estimator ===\n")

# For Sun-Abraham: EXCLUDE always-treated cohorts (2012-2015) who have no pre-period in our window
# These cohorts cannot contribute to the ATT because they have no observable pre-treatment baseline
panel_sa <- panel_clean %>%
  filter(is.na(cohort) | cohort >= 2016)  # Keep never-treated + 2016+ adopters

cat(sprintf("\nSun-Abraham sample: %d jurisdictions (excluding early adopters)\n",
            n_distinct(panel_sa$state_abbr)))

# Create cohort variable for never-treated (large value)
panel_sa <- panel_sa %>%
  mutate(
    cohort_sa = if_else(has_mandate, cohort, 10000L)
  )

# Sun-Abraham estimator using fixest's sunab() function
sunab_model <- feols(
  log_opioid_deaths ~ sunab(cohort_sa, year) | state_abbr + year,
  data = panel_sa,
  cluster = ~state_abbr
)

cat("Sun-Abraham Results:\n")
print(summary(sunab_model))

# Get aggregated ATT
sunab_att <- aggregate(sunab_model, "ATT")
cat("\nSun-Abraham Aggregated ATT:\n")
print(sunab_att)

# ------------------------------------------------------------------------------
# Robustness: Control for total overdose deaths (share of opioids)
# ------------------------------------------------------------------------------

cat("\n=== Robustness: Opioid Share of Total Overdose Deaths ===\n")

panel_clean <- panel_clean %>%
  mutate(
    opioid_share = opioid_deaths_clean / total_overdose_clean
  )

share_model <- feols(
  opioid_share ~ treated | state_abbr + year,
  data = panel_clean,
  cluster = ~state_abbr
)

cat("Opioid Share Regression:\n")
print(summary(share_model))

# ------------------------------------------------------------------------------
# Save Results
# ------------------------------------------------------------------------------

results <- list(
  twfe_basic = twfe_basic,
  event_study = event_study,
  es_coefs = es_coefs,
  sunab = sunab_model
)

saveRDS(results, "../data_pdmp/did_results.rds")

# ------------------------------------------------------------------------------
# Create Figures
# ------------------------------------------------------------------------------

source("00_theme.R")

# Figure 1: Event Study Plot using Sun-Abraham (heterogeneity-robust)
cat("\n=== Creating Figures ===\n")

dir.create("../figures", showWarnings = FALSE)

# Extract Sun-Abraham event study coefficients
# Get just the time coefficients (not ATT aggregated)
sunab_names <- names(coef(sunab_model))
sunab_coef_values <- coef(sunab_model)
sunab_se_values <- sqrt(diag(vcov(sunab_model)))

sunab_coefs <- tibble(
  rel_year = as.integer(gsub("year::", "", sunab_names)),
  estimate = as.numeric(sunab_coef_values),
  se = as.numeric(sunab_se_values[1:length(sunab_coef_values)])
) %>%
  mutate(
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se
  ) %>%
  add_row(rel_year = -1, estimate = 0, se = 0, ci_low = 0, ci_high = 0) %>%
  arrange(rel_year)

cat("Sun-Abraham Event Study Coefficients:\n")
print(sunab_coefs)

# Event study plot using Sun-Abraham
p_event <- ggplot(sunab_coefs, aes(x = rel_year, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray70") +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high), alpha = 0.2, fill = "#2563eb") +
  geom_point(color = "#2563eb", size = 3) +
  geom_line(color = "#2563eb", linewidth = 0.8) +
  annotate("text", x = -3, y = max(sunab_coefs$ci_high, na.rm = TRUE) * 0.8,
           label = "Pre-trend", hjust = 0.5, fontface = "italic", color = "gray40") +
  annotate("text", x = 2, y = max(sunab_coefs$ci_high, na.rm = TRUE) * 0.8,
           label = "Post-treatment", hjust = 0.5, fontface = "italic", color = "gray40") +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  labs(
    title = "Event Study: PDMP Mandatory Query Laws and Opioid Deaths",
    subtitle = "Sun-Abraham (2021) heterogeneity-robust coefficients relative to t = -1",
    x = "Years Relative to PDMP Mandate",
    y = "Effect on Log(Opioid Deaths)",
    caption = "Notes: 95% confidence intervals. Clustered standard errors at jurisdiction level.\nSun-Abraham estimator. Sample: 131 observations, 27 jurisdictions (excludes early adopters)."
  ) +
  theme_apep()

ggsave("../figures/fig1_event_study.png", p_event, width = 10, height = 7, dpi = 300, bg = "white")
ggsave("../figures/fig1_event_study.pdf", p_event, width = 10, height = 7)
cat("Saved: figures/fig1_event_study.png\n")

# Figure 2: Treatment Timing Map (using maps package only)
library(maps)

states_map <- map_data("state") %>%
  mutate(state_name_lower = region)

state_crosswalk <- tibble(
  state_name_lower = tolower(state.name),
  state_abbr = state.abb
)

map_data_plot <- states_map %>%
  left_join(state_crosswalk, by = "state_name_lower") %>%
  left_join(
    panel_clean %>%
      distinct(state_abbr, cohort, has_mandate) %>%
      mutate(cohort_factor = case_when(
        !has_mandate ~ "Never Treated",
        cohort <= 2013 ~ "2012-2013",
        cohort <= 2015 ~ "2014-2015",
        cohort <= 2017 ~ "2016-2017",
        TRUE ~ "2018-2020"
      )),
    by = "state_abbr"
  )

p_map <- ggplot(map_data_plot, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = cohort_factor), color = "white", linewidth = 0.3) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  scale_fill_manual(
    values = c(
      "2012-2013" = "#1e3a5f",
      "2014-2015" = "#2563eb",
      "2016-2017" = "#60a5fa",
      "2018-2020" = "#93c5fd",
      "Never Treated" = "#f3f4f6"
    ),
    na.value = "gray90",
    name = "Mandate\nAdoption"
  ) +
  labs(
    title = "PDMP Mandatory Query Law Adoption by State",
    subtitle = "Staggered implementation 2012-2020",
    caption = "Source: PDAPS, NCSL. Sample: 2015-2020 panel. 36 adopters, 7 never-treated.\nLA/PA missing from CDC data (shown in gray)."
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ggsave("../figures/fig2_adoption_map.png", p_map, width = 10, height = 6, dpi = 300, bg = "white")
ggsave("../figures/fig2_adoption_map.pdf", p_map, width = 10, height = 6)
cat("Saved: figures/fig2_adoption_map.png\n")

# Figure 3: Raw trends by cohort
# Use consistent cohort definitions: Early = 2012-2015 (always-treated)
trend_data <- panel_clean %>%
  filter(has_mandate) %>%
  mutate(
    cohort_group = case_when(
      cohort <= 2015 ~ "Early (2012-2015)",
      cohort <= 2017 ~ "Middle (2016-2017)",
      TRUE ~ "Late (2018-2020)"
    )
  ) %>%
  group_by(cohort_group, year) %>%
  summarise(
    mean_deaths = mean(opioid_deaths_clean, na.rm = TRUE),
    se_deaths = sd(opioid_deaths_clean, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Add never-treated
never_trend <- panel_clean %>%
  filter(!has_mandate) %>%
  group_by(year) %>%
  summarise(
    mean_deaths = mean(opioid_deaths_clean, na.rm = TRUE),
    se_deaths = sd(opioid_deaths_clean, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(cohort_group = "Never Treated")

trend_data <- bind_rows(trend_data, never_trend)

p_trends <- ggplot(trend_data, aes(x = year, y = mean_deaths, color = cohort_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean_deaths - 1.96*se_deaths,
                  ymax = mean_deaths + 1.96*se_deaths, fill = cohort_group),
              alpha = 0.1, color = NA) +
  scale_color_manual(
    values = c(
      "Early (2012-2015)" = "#1e3a5f",
      "Middle (2016-2017)" = "#2563eb",
      "Late (2018-2020)" = "#60a5fa",
      "Never Treated" = "#6b7280"
    ),
    name = "Cohort"
  ) +
  scale_fill_manual(
    values = c(
      "Early (2012-2015)" = "#1e3a5f",
      "Middle (2016-2017)" = "#2563eb",
      "Late (2018-2020)" = "#60a5fa",
      "Never Treated" = "#6b7280"
    ),
    guide = "none"
  ) +
  labs(
    title = "Opioid Overdose Deaths by PDMP Mandate Adoption Cohort",
    subtitle = "Mean deaths per state with 95% confidence bands",
    x = "Year",
    y = "Mean Opioid Deaths per State",
    caption = "Source: CDC VSRR 2015-2020. States grouped by mandate adoption year."
  ) +
  theme_apep()

ggsave("../figures/fig3_trends_by_cohort.png", p_trends, width = 10, height = 7, dpi = 300, bg = "white")
ggsave("../figures/fig3_trends_by_cohort.pdf", p_trends, width = 10, height = 7)
cat("Saved: figures/fig3_trends_by_cohort.png\n")

# Figure 4: Distribution of treatment effects
# Bacon decomposition (informative about TWFE weights)
# We'll create a simplified version showing heterogeneity

# Calculate state-specific effects using TWFE with state-year interactions
# This is a diagnostic, not a formal estimator
state_effects <- panel_clean %>%
  filter(has_mandate) %>%
  group_by(state_abbr) %>%
  mutate(
    pre_mean = mean(log_opioid_deaths[rel_year < 0], na.rm = TRUE),
    post_mean = mean(log_opioid_deaths[rel_year >= 0], na.rm = TRUE)
  ) %>%
  distinct(state_abbr, cohort, pre_mean, post_mean) %>%
  ungroup() %>%
  mutate(
    diff = post_mean - pre_mean
  )

p_hetero <- ggplot(state_effects, aes(x = reorder(state_abbr, diff), y = diff)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = twfe_coef, linetype = "solid", color = "#dc2626", linewidth = 1) +
  geom_col(aes(fill = as.factor(cohort)), width = 0.7) +
  scale_fill_viridis_d(option = "plasma", name = "Cohort\nYear") +
  coord_flip() +
  annotate("text", x = 5, y = twfe_coef + 0.05, label = "ATT", color = "#dc2626", fontface = "bold") +
  labs(
    title = "State-Level Pre-Post Changes in Log Opioid Deaths",
    subtitle = "Sorted by effect magnitude; red line = average treatment effect",
    x = "",
    y = "Change in Log(Opioid Deaths): Post - Pre",
    caption = "Notes: Simple pre-post difference by state. Not a causal estimator.\nHorizontal red line shows TWFE ATT estimate."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave("../figures/fig4_state_heterogeneity.png", p_hetero, width = 10, height = 12, dpi = 300, bg = "white")
ggsave("../figures/fig4_state_heterogeneity.pdf", p_hetero, width = 10, height = 12)
cat("Saved: figures/fig4_state_heterogeneity.png\n")

cat("\n=== Analysis Complete ===\n")

# Print summary for paper
cat("\n========================================\n")
cat("RESULTS SUMMARY FOR PAPER\n")
cat("========================================\n")
cat(sprintf("Sample: %d state-years (%d states, %d-%d)\n",
            nrow(panel_clean), n_distinct(panel_clean$state_abbr),
            min(panel_clean$year), max(panel_clean$year)))
cat(sprintf("Treatment: %d states with PDMP mandates\n", sum(panel_clean$has_mandate[!duplicated(panel_clean$state_abbr)])))
cat(sprintf("Control: %d never-treated states\n", sum(!panel_clean$has_mandate[!duplicated(panel_clean$state_abbr)])))
cat(sprintf("\nTWFE ATT: %.3f (SE: %.3f), p=%.4f\n",
            twfe_coef, twfe_se, 2*(1-pnorm(abs(twfe_coef/twfe_se)))))
cat(sprintf("Interpretation: PDMP mandates associated with %.1f%% change in opioid deaths\n",
            (exp(twfe_coef) - 1) * 100))
cat("========================================\n")
