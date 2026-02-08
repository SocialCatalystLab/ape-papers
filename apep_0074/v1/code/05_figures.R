# ============================================================
# 05_figures.R - Generate Publication-Quality Figures
# ============================================================

source("00_packages.R")

cat("=== Generating Figures ===\n")

# Load data and results
df <- readRDS("../data/analysis_data.rds")
results <- readRDS("../data/main_results.rds")

# Ensure figures directory exists
dir.create("../figures", showWarnings = FALSE)

# ============================================================
# Figure 1: Event Study Plot
# ============================================================

cat("Creating Figure 1: Event Study...\n")

# Extract dynamic effects
dyn <- results$agg_dynamic

# Create data frame for plotting
es_df <- data.frame(
  event_time = dyn$egt,
  estimate = dyn$att.egt,
  se = dyn$se.egt
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(!is.na(estimate))  # Remove any missing estimates

# Event study plot
fig1 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = apep_colors["ci"], alpha = 0.3) +
  geom_line(color = apep_colors["treated"], linewidth = 0.8) +
  geom_point(color = apep_colors["treated"], size = 2) +
  labs(
    title = "Effect of ERPO Laws on Suicide Rate",
    subtitle = "Callaway-Sant'Anna Event Study Estimates",
    x = "Years Relative to ERPO Adoption",
    y = "ATT (Suicide Deaths per 100,000)",
    caption = "Notes: Shaded region shows 95% confidence interval. Vertical dashed line marks treatment."
  ) +
  scale_x_continuous(breaks = seq(-10, 10, by = 2)) +
  coord_cartesian(xlim = c(-10, 11)) +  # Max event time is +11 (Indiana 2006 to 2017)
  theme_apep()

ggsave("../figures/fig1_event_study.pdf", fig1, width = 8, height = 5)
ggsave("../figures/fig1_event_study.png", fig1, width = 8, height = 5, dpi = 300)

# ============================================================
# Figure 2: Raw Trends by Treatment Status
# ============================================================

cat("Creating Figure 2: Raw Trends...\n")

# Calculate mean by year and treatment group
trends_df <- df %>%
  mutate(
    treatment_group = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat <= 2006 ~ "Early Adopters (CT/IN)",
      TRUE ~ "Later Adopters (CA/WA)"
    )
  ) %>%
  group_by(year, treatment_group) %>%
  summarise(
    mean_rate = mean(suicide_rate, na.rm = TRUE),
    se = sd(suicide_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig2 <- ggplot(trends_df, aes(x = year, y = mean_rate,
                               color = treatment_group,
                               linetype = treatment_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c(
    "Never Treated" = "#377EB8",
    "Early Adopters (CT/IN)" = "#E41A1C",
    "Later Adopters (CA/WA)" = "#4DAF4A"
  )) +
  scale_linetype_manual(values = c(
    "Never Treated" = "solid",
    "Early Adopters (CT/IN)" = "dashed",
    "Later Adopters (CA/WA)" = "dotted"
  )) +
  labs(
    title = "Suicide Rate Trends by ERPO Adoption Status",
    subtitle = "State-Level Mean Suicide Rates, 1999-2017",
    x = "Year",
    y = "Suicide Rate (per 100,000)",
    color = "Group",
    linetype = "Group",
    caption = "Notes: Early adopters = CT (2000) and IN (2006). Later adopters = CA (2016) and WA (2017)."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("../figures/fig2_raw_trends.pdf", fig2, width = 8, height = 5)
ggsave("../figures/fig2_raw_trends.png", fig2, width = 8, height = 5, dpi = 300)

# ============================================================
# Figure 3: Group-Specific Effects
# ============================================================

cat("Creating Figure 3: Group Effects...\n")

# Extract group effects - only show IN (2006) and CA (2016) which have sufficient variation
# CT (2000) has only 1 pre-treatment year; WA (2017) has only 1 post-treatment year
grp <- results$agg_group

cat("Group years (egt):", grp$egt, "\n")
cat("Group ATTs:", grp$att.egt, "\n")
cat("Group SEs:", grp$se.egt, "\n")

# Note: SEs are NA for group-specific effects with few units
# Use overall SE as a rough approximation for CIs (conservative)
overall_se <- grp$overall.se  # Use overall SE as proxy

grp_df <- data.frame(
  group = grp$egt,
  estimate = grp$att.egt,
  stringsAsFactors = FALSE
) %>%
  filter(!is.na(group)) %>%
  filter(group %in% c(2006, 2016)) %>%
  filter(!is.na(estimate)) %>%
  mutate(
    # Use overall SE as a conservative approximation for CIs
    se = overall_se,
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    label = case_when(
      group == 2006 ~ "Indiana (2006)",
      group == 2016 ~ "California (2016)"
    )
  ) %>%
  filter(!is.na(label))

cat("Filtered group data frame:\n")
print(grp_df)

fig3 <- ggplot(grp_df, aes(x = label, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 4, color = "#E41A1C") +
  labs(
    title = "Cohort-Specific Treatment Effects (Descriptive)",
    subtitle = "ATT for Indiana and California (1999-2017 sample)",
    x = "",
    y = "ATT (Suicide Deaths per 100,000)",
    caption = "Notes: Point estimates only; CIs unavailable with few treated units. CT and WA excluded."
  ) +
  coord_cartesian(ylim = c(-0.5, 1.5)) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave("../figures/fig3_group_effects.pdf", fig3, width = 6, height = 5)
ggsave("../figures/fig3_group_effects.png", fig3, width = 6, height = 5, dpi = 300)

# ============================================================
# Figure 4: ERPO Adoption Map
# ============================================================

cat("Creating Figure 4: Adoption Map...\n")

# State map data
library(maps)
us_states <- map_data("state")

# Create state data - using the cohort variable which properly classifies states
state_erpo <- df %>%
  filter(year == 2017) %>%
  select(state_name, cohort, first_treat) %>%
  distinct() %>%
  mutate(
    region = tolower(state_name),
    adoption_status = case_when(
      first_treat == 2000 | first_treat == 2006 ~ "Before 2007 (CT, IN)",
      first_treat == 2016 | first_treat == 2017 ~ "2016-2017 (CA, WA)",
      TRUE ~ "No ERPO by 2017"
    )
  )

map_df <- us_states %>%
  left_join(state_erpo, by = "region")

fig4 <- ggplot(map_df, aes(x = long, y = lat, group = group, fill = adoption_status)) +
  geom_polygon(color = "white", linewidth = 0.2) +
  scale_fill_manual(
    values = c(
      "No ERPO by 2017" = "gray85",
      "Before 2007 (CT, IN)" = "#E41A1C",
      "2016-2017 (CA, WA)" = "#4DAF4A"
    ),
    na.value = "gray95"
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(
    title = "ERPO Law Adoption Across U.S. States",
    subtitle = "As of 2017",
    fill = "Adoption Status",
    caption = "Notes: Gray = no ERPO by 2017. Many states adopted 2018-2019 (not shown)."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(color = "gray40", hjust = 0.5),
    legend.position = "bottom"
  )

ggsave("../figures/fig4_adoption_map.pdf", fig4, width = 10, height = 6)
ggsave("../figures/fig4_adoption_map.png", fig4, width = 10, height = 6, dpi = 300)

# ============================================================
# Figure 5: Pre-Trends Test (Zoomed)
# ============================================================

cat("Creating Figure 5: Pre-Trends...\n")

# Focus on pre-treatment periods only
pretrend_df <- es_df %>%
  filter(event_time < 0) %>%
  filter(event_time >= -6)  # Last 6 pre-treatment years

fig5 <- ggplot(pretrend_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = apep_colors["ci"], alpha = 0.3) +
  geom_line(color = apep_colors["treated"], linewidth = 0.8) +
  geom_point(color = apep_colors["treated"], size = 3) +
  labs(
    title = "Pre-Trends Test",
    subtitle = "Pre-Treatment Dynamic Effects (Should be Zero Under Parallel Trends)",
    x = "Years Before ERPO Adoption",
    y = "Estimated Effect",
    caption = "Notes: Under parallel trends, pre-treatment effects should not differ from zero."
  ) +
  scale_x_continuous(breaks = seq(-6, -1, by = 1)) +
  theme_apep()

ggsave("../figures/fig5_pretrends.pdf", fig5, width = 7, height = 5)
ggsave("../figures/fig5_pretrends.png", fig5, width = 7, height = 5, dpi = 300)

cat("\n=== All Figures Saved ===\n")
cat("Files in figures/:\n")
list.files("../figures")
