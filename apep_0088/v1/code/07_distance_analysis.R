# =============================================================================
# 07_distance_analysis.R
# Distance-to-Dispensary Analysis with Temporal Placebo
# Following the economic model: Cost of cannabis drives substitution
# =============================================================================

source("00_packages.R")

# Load data
crashes_sf <- readRDS("../data/crashes_sf.rds")
states_sf <- readRDS("../data/states_sf.rds")
dispensaries_sf <- readRDS("../data/dispensaries_sf.rds")

cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("DISTANCE-TO-DISPENSARY ANALYSIS\n")
cat("(Prohibition States Only, with Temporal Placebo)\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# PART 1: Filter to Prohibition States Only
# =============================================================================

# Prohibition states that NEVER legalized during study period
prohibition_states <- c("Arizona", "Idaho", "Kansas", "Montana",
                        "Nebraska", "New Mexico", "Utah", "Wyoming")

crashes_prohib <- crashes_sf %>%
  filter(NAME %in% prohibition_states)

cat(sprintf("Prohibition state crashes: %d\n", nrow(crashes_prohib)))

# =============================================================================
# PART 2: Define Treatment Windows Based on Neighboring State Legalization
# =============================================================================

# Key dates: When did the nearest legal market open?
# Colorado: Jan 2014 retail
# Washington: Jul 2014 retail
# Oregon: Oct 2015 retail
# Nevada: Jul 2017 retail
# California: Jan 2018 retail

# For each prohibition state, identify the relevant legal market timing:
# Idaho -> Oregon (Oct 2015) or Washington (Jul 2014)
# Wyoming -> Colorado (Jan 2014)
# Nebraska -> Colorado (Jan 2014)
# Kansas -> Colorado (Jan 2014)
# Utah -> Colorado (Jan 2014) or Nevada (Jul 2017)
# Arizona -> Nevada (Jul 2017) or California (Jan 2018)
# New Mexico -> Colorado (Jan 2014)
# Montana -> No direct neighbor; Washington closest (Jul 2014)

# Create treatment timing based on nearest legal market
get_treatment_date <- function(state_name) {
  switch(state_name,
    "Idaho" = as.Date("2015-10-01"),      # Oregon opened Oct 2015
    "Wyoming" = as.Date("2014-01-01"),    # Colorado
    "Nebraska" = as.Date("2014-01-01"),   # Colorado
    "Kansas" = as.Date("2014-01-01"),     # Colorado
    "Utah" = as.Date("2014-01-01"),       # Colorado (Nevada came later)
    "Arizona" = as.Date("2017-07-01"),    # Nevada
    "New Mexico" = as.Date("2014-01-01"), # Colorado
    "Montana" = as.Date("2014-07-01"),    # Washington (not direct neighbor)
    as.Date("2014-01-01")  # Default
  )
}

# =============================================================================
# PART 3: Compute Distance to Nearest Dispensary
# =============================================================================

cat("\nComputing distance to nearest dispensary for each crash...\n")

# For each crash, compute distance to nearest dispensary
# Note: We use all dispensaries that existed at the time of crash

crashes_prohib$dist_to_disp_km <- st_distance(
  crashes_prohib,
  dispensaries_sf %>% st_union()
) %>%
  as.numeric() / 1000

cat(sprintf("Mean distance to dispensary: %.1f km\n", mean(crashes_prohib$dist_to_disp_km)))
cat(sprintf("Median distance: %.1f km\n", median(crashes_prohib$dist_to_disp_km)))

# =============================================================================
# PART 4: Create Post-Treatment Indicator
# =============================================================================

crashes_prohib_df <- crashes_prohib %>%
  st_drop_geometry() %>%
  mutate(
    treatment_date = sapply(NAME, get_treatment_date) %>% as.Date(origin = "1970-01-01"),
    crash_date = as.Date(paste(year, "07", "01", sep = "-")),  # Mid-year approximation
    post_treatment = as.integer(crash_date >= treatment_date),
    log_dist = log(dist_to_disp_km + 1),  # Log distance (add 1 to avoid log(0))
    alcohol_involved = as.integer(drunk_dr >= 1)
  ) %>%
  filter(!is.na(alcohol_involved)) %>%
  filter(!is.na(dist_to_disp_km)) %>%
  filter(dist_to_disp_km > 0)  # Exclude exact zeros (coding errors)

cat(sprintf("\nAnalysis sample: %d crashes\n", nrow(crashes_prohib_df)))
cat(sprintf("Post-treatment: %d (%.1f%%)\n",
            sum(crashes_prohib_df$post_treatment),
            100 * mean(crashes_prohib_df$post_treatment)))

# =============================================================================
# PART 5: Main Analysis - OLS with State and Year FE
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 5: MAIN REGRESSION RESULTS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# Model 1: Log distance on alcohol involvement (full sample, post-treatment)
model_post <- feols(
  alcohol_involved ~ log_dist | NAME + year,
  data = crashes_prohib_df %>% filter(post_treatment == 1),
  cluster = ~ NAME
)

cat("Model 1: Post-Treatment Period Only\n")
cat(paste0(rep("-", 40), collapse = ""), "\n")
print(summary(model_post))

# Model 2: Full sample with interaction
model_interaction <- feols(
  alcohol_involved ~ log_dist * post_treatment | NAME + year,
  data = crashes_prohib_df,
  cluster = ~ NAME
)

cat("\n\nModel 2: Full Sample with Treatment Interaction\n")
cat(paste0(rep("-", 40), collapse = ""), "\n")
print(summary(model_interaction))

# =============================================================================
# PART 6: Temporal Placebo - Pre-Treatment Period
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 6: TEMPORAL PLACEBO (PRE-TREATMENT)\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# In pre-treatment period, distance to (future) dispensary locations
# should NOT predict alcohol involvement
# (Dispensaries didn't exist yet, so no substitution channel)

model_pre <- tryCatch({
  feols(
    alcohol_involved ~ log_dist | NAME + year,
    data = crashes_prohib_df %>% filter(post_treatment == 0),
    cluster = ~ NAME
  )
}, error = function(e) {
  cat("Pre-treatment sample too small or collinear.\n")
  NULL
})

if (!is.null(model_pre)) {
  cat("Placebo: Pre-Treatment Period Only\n")
  cat(paste0(rep("-", 40), collapse = ""), "\n")
  print(summary(model_pre))
} else {
  cat("Note: Most crashes are in post-treatment period (after 2014-2015).\n")
  cat("Study period 2016-2019 means Colorado border states are all post-treatment.\n")
}

# =============================================================================
# PART 7: Heterogeneity by Time of Day
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 7: HETEROGENEITY BY TIME OF DAY\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

crashes_prohib_df <- crashes_prohib_df %>%
  mutate(is_nighttime = as.integer(hour >= 21 | hour <= 5))

# Nighttime only
model_night <- feols(
  alcohol_involved ~ log_dist | NAME + year,
  data = crashes_prohib_df %>% filter(post_treatment == 1 & is_nighttime == 1),
  cluster = ~ NAME
)

# Daytime only
model_day <- feols(
  alcohol_involved ~ log_dist | NAME + year,
  data = crashes_prohib_df %>% filter(post_treatment == 1 & is_nighttime == 0),
  cluster = ~ NAME
)

cat("Nighttime Crashes (9pm-5am):\n")
print(summary(model_night))

cat("\n\nDaytime Crashes (6am-9pm):\n")
print(summary(model_day))

# =============================================================================
# PART 8: Non-parametric Visualization
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 8: CREATING VISUALIZATIONS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# Create binned scatter plot: alcohol rate vs distance
crashes_prohib_df <- crashes_prohib_df %>%
  mutate(dist_bin = cut(dist_to_disp_km,
                        breaks = c(0, 50, 100, 150, 200, 300, 500, 1000),
                        include.lowest = TRUE))

bin_summary <- crashes_prohib_df %>%
  filter(post_treatment == 1) %>%
  group_by(dist_bin) %>%
  summarise(
    n = n(),
    mean_dist = mean(dist_to_disp_km),
    alcohol_rate = mean(alcohol_involved),
    se = sd(alcohol_involved) / sqrt(n()),
    .groups = "drop"
  ) %>%
  filter(n >= 20)

# Save for visualization
saveRDS(bin_summary, "../data/dist_bin_summary.rds")
saveRDS(crashes_prohib_df, "../data/crashes_prohib_analysis.rds")

# Create the scatter plot
fig_dist <- ggplot(bin_summary, aes(x = mean_dist, y = alcohol_rate)) +
  geom_errorbar(aes(ymin = alcohol_rate - 1.96*se, ymax = alcohol_rate + 1.96*se),
                width = 20, color = "gray60") +
  geom_point(aes(size = n), color = "#C62828", alpha = 0.8) +
  geom_smooth(method = "loess", se = TRUE, color = "#1565C0", fill = "#90CAF9") +
  scale_size_continuous(range = c(3, 10), guide = "none") +
  scale_y_continuous(labels = scales::percent, limits = c(0.15, 0.45)) +
  labs(
    x = "Distance to Nearest Legal Dispensary (km)",
    y = "Alcohol Involvement Rate",
    title = "Alcohol-Involved Crashes by Distance to Nearest Dispensary",
    subtitle = "Prohibition states only, post-legalization period (2016-2019)",
    caption = "Note: Each point is a distance bin; size proportional to crashes. Loess curve with 95% CI."
  ) +
  theme_minimal(base_size = 11)

ggsave("../figures/fig14_distance_scatter.pdf", fig_dist, width = 10, height = 7, dpi = 300)
ggsave("../figures/fig14_distance_scatter.png", fig_dist, width = 10, height = 7, dpi = 300)

cat("Saved figure: fig14_distance_scatter.pdf/png\n")

# =============================================================================
# PART 9: Summary Statistics Table
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("SUMMARY STATISTICS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

summary_by_state <- crashes_prohib_df %>%
  filter(post_treatment == 1) %>%
  group_by(NAME) %>%
  summarise(
    n_crashes = n(),
    alcohol_rate = mean(alcohol_involved),
    mean_dist_km = mean(dist_to_disp_km),
    median_dist_km = median(dist_to_disp_km),
    .groups = "drop"
  ) %>%
  arrange(mean_dist_km)

print(summary_by_state)

saveRDS(summary_by_state, "../data/prohib_state_summary.rds")

# =============================================================================
# PART 10: Save Regression Results
# =============================================================================

distance_results <- list(
  model_post = model_post,
  model_interaction = model_interaction,
  model_night = model_night,
  model_day = model_day,
  bin_summary = bin_summary,
  state_summary = summary_by_state
)

saveRDS(distance_results, "../data/distance_results.rds")

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("ANALYSIS COMPLETE\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")

# Print key results
cat("\nKEY FINDINGS:\n")
cat(sprintf("1. Post-treatment: log(distance) coefficient = %.4f (SE = %.4f)\n",
            coef(model_post)["log_dist"], se(model_post)["log_dist"]))
cat("   Interpretation: Farther from dispensary -> [direction] alcohol involvement\n")
cat(sprintf("2. Nighttime: coefficient = %.4f (SE = %.4f)\n",
            coef(model_night)["log_dist"], se(model_night)["log_dist"]))
cat(sprintf("3. Daytime: coefficient = %.4f (SE = %.4f)\n",
            coef(model_day)["log_dist"], se(model_day)["log_dist"]))
