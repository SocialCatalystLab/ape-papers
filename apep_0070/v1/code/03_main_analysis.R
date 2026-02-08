# =============================================================================
# 03_main_analysis.R - Main Spatial RDD Analysis
# Swiss Childcare Mandates and Maternal Labor Supply
# Spatial RDD at Canton Borders
# =============================================================================

library(tidyverse)
library(sf)
library(rdrobust)
library(rddensity)
library(fixest)
library(modelsummary)

# APEP theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40"),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      strip.text = element_text(face = "bold"),
      plot.caption = element_text(hjust = 0, color = "gray50")
    )
}
theme_set(theme_apep())

# Load data
data_dir <- "output/paper_94/data"
rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
canton_sf <- readRDS(file.path(data_dir, "canton_sf.rds"))
treatment_border <- readRDS(file.path(data_dir, "treatment_border.rds"))

# Create output directories
dir.create("output/paper_94/figures", showWarnings = FALSE)
dir.create("output/paper_94/tables", showWarnings = FALSE)

message("=== MAIN ANALYSIS ===")
message(paste("RDD sample size:", nrow(rdd_sample)))

# Define treated (2010 cantons)
rdd_sample <- rdd_sample %>%
  mutate(
    treated_2010 = canton_abbr %in% c("BE", "ZH"),
    # Running variable: positive = treated side
    running_var = distance_to_border
  )

# =============================================================================
# 1. Descriptive Statistics
# =============================================================================

message("\n=== DESCRIPTIVE STATISTICS ===")

# Summary by treatment status
desc_stats <- rdd_sample %>%
  st_drop_geometry() %>%
  group_by(treated_2010) %>%
  summarise(
    n = n(),
    mean_dist = mean(distance_to_border, na.rm = TRUE),
    sd_dist = sd(distance_to_border, na.rm = TRUE),
    mean_yes_2013 = mean(yes_share_2013, na.rm = TRUE),
    sd_yes_2013 = sd(yes_share_2013, na.rm = TRUE),
    mean_turnout = mean(turnout_2013, na.rm = TRUE)
  )

print(desc_stats)

# Save descriptive stats
write_csv(desc_stats, "output/paper_94/tables/descriptive_stats.csv")

# =============================================================================
# 2. Main RDD Estimation
# =============================================================================

message("\n=== MAIN RDD ESTIMATION ===")

# Outcome: 2013 Family initiative vote (yes share)
# This is a post-treatment (2010) outcome measuring family policy support
# Higher yes share = more support for family/childcare policies

# Prepare data
rdd_data <- rdd_sample %>%
  st_drop_geometry() %>%
  filter(!is.na(yes_share_2013), !is.na(distance_to_border))

message(paste("Observations for RDD:", nrow(rdd_data)))
message(paste("  Treated (BE/ZH):", sum(rdd_data$treated_2010)))
message(paste("  Control:", sum(!rdd_data$treated_2010)))

# Specification 1: Baseline RDD (MSE-optimal bandwidth)
message("\n1. Baseline RDD (MSE-optimal bandwidth)...")
rdd1 <- rdrobust(
  y = rdd_data$yes_share_2013,
  x = rdd_data$running_var,
  c = 0
)
summary(rdd1)

# Helper function to compute effective N within bandwidth
get_effective_n <- function(rd_obj, data, running_var_name = "running_var") {
  h <- rd_obj$bws[1]  # Main bandwidth
  rv <- data[[running_var_name]]
  n_left <- sum(rv >= -h & rv < 0, na.rm = TRUE)
  n_right <- sum(rv <= h & rv > 0, na.rm = TRUE)
  c(n_left, n_right)
}

# Extract results
eff_n1 <- get_effective_n(rdd1, rdd_data)
rdd1_results <- tibble(
  spec = "1. MSE-optimal",
  estimate = rdd1$coef[1],
  se = rdd1$se[1],
  ci_lower = rdd1$ci[1, 1],
  ci_upper = rdd1$ci[1, 2],
  bw = rdd1$bws[1],
  n_left = eff_n1[1],
  n_right = eff_n1[2],
  pvalue = rdd1$pv[1]
)

# Specification 2: Half bandwidth
message("\n2. Half bandwidth...")
rdd2 <- rdrobust(
  y = rdd_data$yes_share_2013,
  x = rdd_data$running_var,
  c = 0,
  h = rdd1$bws[1] / 2
)

eff_n2 <- get_effective_n(rdd2, rdd_data)
rdd2_results <- tibble(
  spec = "2. Half bandwidth",
  estimate = rdd2$coef[1],
  se = rdd2$se[1],
  ci_lower = rdd2$ci[1, 1],
  ci_upper = rdd2$ci[1, 2],
  bw = rdd2$bws[1],
  n_left = eff_n2[1],
  n_right = eff_n2[2],
  pvalue = rdd2$pv[1]
)

# Specification 3: Double bandwidth
message("\n3. Double bandwidth...")
rdd3 <- rdrobust(
  y = rdd_data$yes_share_2013,
  x = rdd_data$running_var,
  c = 0,
  h = rdd1$bws[1] * 2
)

eff_n3 <- get_effective_n(rdd3, rdd_data)
rdd3_results <- tibble(
  spec = "3. Double bandwidth",
  estimate = rdd3$coef[1],
  se = rdd3$se[1],
  ci_lower = rdd3$ci[1, 1],
  ci_upper = rdd3$ci[1, 2],
  bw = rdd3$bws[1],
  n_left = eff_n3[1],
  n_right = eff_n3[2],
  pvalue = rdd3$pv[1]
)

# Specification 4: Local quadratic
message("\n4. Local quadratic...")
rdd4 <- rdrobust(
  y = rdd_data$yes_share_2013,
  x = rdd_data$running_var,
  c = 0,
  p = 2
)

eff_n4 <- get_effective_n(rdd4, rdd_data)
rdd4_results <- tibble(
  spec = "4. Local quadratic",
  estimate = rdd4$coef[1],
  se = rdd4$se[1],
  ci_lower = rdd4$ci[1, 1],
  ci_upper = rdd4$ci[1, 2],
  bw = rdd4$bws[1],
  n_left = eff_n4[1],
  n_right = eff_n4[2],
  pvalue = rdd4$pv[1]
)

# Specification 5: Fixed 10km bandwidth
message("\n5. Fixed 10km bandwidth...")
rdd5 <- rdrobust(
  y = rdd_data$yes_share_2013,
  x = rdd_data$running_var,
  c = 0,
  h = 10
)

eff_n5 <- get_effective_n(rdd5, rdd_data)
rdd5_results <- tibble(
  spec = "5. Fixed 10km",
  estimate = rdd5$coef[1],
  se = rdd5$se[1],
  ci_lower = rdd5$ci[1, 1],
  ci_upper = rdd5$ci[1, 2],
  bw = rdd5$bws[1],
  n_left = eff_n5[1],
  n_right = eff_n5[2],
  pvalue = rdd5$pv[1]
)

# Combine results
all_rdd_results <- bind_rows(
  rdd1_results, rdd2_results, rdd3_results, rdd4_results, rdd5_results
)

message("\n=== RDD RESULTS SUMMARY ===")
print(all_rdd_results %>% select(spec, estimate, se, pvalue, bw, n_left, n_right))

write_csv(all_rdd_results, "output/paper_94/tables/rdd_results.csv")

# =============================================================================
# 3. McCrary Density Test
# =============================================================================

message("\n=== MCCRARY DENSITY TEST ===")

density_test <- rddensity(rdd_data$running_var, c = 0)
summary(density_test)

density_results <- tibble(
  test_statistic = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  n_left = density_test$N$eff_l,
  n_right = density_test$N$eff_r
)

write_csv(density_results, "output/paper_94/tables/mccrary_density.csv")
message(paste("McCrary test p-value:", round(density_test$test$p_jk, 3)))

# =============================================================================
# 4. Placebo Test: Pre-Treatment Outcome
# =============================================================================

message("\n=== PLACEBO TEST ===")

# Load pre-treatment data separately for placebo
gemeinde_matched <- readRDS(file.path(data_dir, "gemeinde_matched.rds"))

# Check if yes_share_2004 exists
if ("yes_share_2004" %in% names(gemeinde_matched)) {
  rdd_data_2004 <- gemeinde_matched %>%
    st_drop_geometry() %>%
    filter(lang == "German", abs(distance_to_border) <= 30, !is.na(yes_share_2004))

  if (nrow(rdd_data_2004) > 100) {
    placebo_rdd <- rdrobust(
      y = rdd_data_2004$yes_share_2004,
      x = rdd_data_2004$distance_to_border,
      c = 0
    )

    placebo_results <- tibble(
      test = "2004 maternity vote (placebo)",
      estimate = placebo_rdd$coef[1],
      se = placebo_rdd$se[1],
      pvalue = placebo_rdd$pv[1],
      bw = placebo_rdd$bws[1]
    )

    message(paste("Placebo estimate:", round(placebo_rdd$coef[1], 2),
                  "(p =", round(placebo_rdd$pv[1], 3), ")"))

    write_csv(placebo_results, "output/paper_94/tables/placebo_results.csv")
  } else {
    message("Insufficient observations for placebo test")
  }
} else {
  message("Pre-treatment outcome (2004) not available in RDD sample")
}

# =============================================================================
# 5. Covariate Balance at Border (using turnout as proxy)
# =============================================================================

message("\n=== COVARIATE BALANCE ===")

# Test balance on turnout (should be similar at border)
if ("turnout_2013" %in% names(rdd_data)) {
  rdd_data_cov <- rdd_data %>% filter(!is.na(turnout_2013))

  if (nrow(rdd_data_cov) > 100) {
    # Use fixed 10km bandwidth to match Table 2 specification
    cov_rdd <- rdrobust(
      y = rdd_data_cov$turnout_2013,
      x = rdd_data_cov$running_var,
      c = 0,
      h = 10
    )

    # Compute effective N for covariate balance
    eff_n_cov <- get_effective_n(cov_rdd, rdd_data_cov)

    message(paste("Turnout discontinuity:", round(cov_rdd$coef[1], 2),
                  "(p =", round(cov_rdd$pv[1], 3), ")"))

    cov_balance <- tibble(
      covariate = "Turnout (2013)",
      estimate = cov_rdd$coef[1],
      se = cov_rdd$se[1],
      pvalue = cov_rdd$pv[1],
      bandwidth = cov_rdd$bws[1],
      n_left = eff_n_cov[1],
      n_right = eff_n_cov[2]
    )
    write_csv(cov_balance, "output/paper_94/tables/covariate_balance.csv")
  }
}

# =============================================================================
# 6. Create Main RDD Figure
# =============================================================================

message("\n=== CREATING MAIN RDD FIGURE ===")

# Bin means
bin_width <- 2
binned_data <- rdd_data %>%
  mutate(bin = cut(running_var, breaks = seq(-30, 30, by = bin_width))) %>%
  group_by(bin) %>%
  summarise(
    mean_yes = mean(yes_share_2013, na.rm = TRUE),
    se_yes = sd(yes_share_2013, na.rm = TRUE) / sqrt(n()),
    n = n(),
    mid = mean(running_var, na.rm = TRUE),
    treated = mean(treated_2010) > 0.5,
    .groups = "drop"
  ) %>%
  filter(n >= 3)

# Create RDD plot
p_rdd_main <- ggplot(binned_data, aes(x = mid, y = mean_yes)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray30", linewidth = 0.8) +
  geom_point(aes(color = treated), size = 3, alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_yes - 1.96 * se_yes, ymax = mean_yes + 1.96 * se_yes, color = treated),
                width = 0.5, alpha = 0.5) +
  geom_smooth(data = rdd_data %>% filter(running_var < 0),
              aes(x = running_var, y = yes_share_2013),
              method = "loess", se = TRUE, color = "#B2182B", fill = "#B2182B",
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = rdd_data %>% filter(running_var > 0),
              aes(x = running_var, y = yes_share_2013),
              method = "loess", se = TRUE, color = "#2166AC", fill = "#2166AC",
              alpha = 0.2, linewidth = 1) +
  scale_color_manual(
    values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
    labels = c("TRUE" = "Treated (BE/ZH)", "FALSE" = "Control"),
    name = ""
  ) +
  labs(
    x = "Distance to Canton Border (km)",
    y = "Yes Share on Family Policy Decree (%)",
    title = "Spatial RDD: Family Policy Support at Canton Border",
    subtitle = paste0("RD estimate: ", round(rdd1$coef[1], 2),
                      " pp (SE = ", round(rdd1$se[1], 2),
                      ", p = ", round(rdd1$pv[1], 3), ")"),
    caption = "Notes: Dots show bin means (2km width); lines show local polynomial fits.\nTreated cantons (BE, ZH) adopted childcare mandates in 2010."
  ) +
  annotate("text", x = -15, y = max(binned_data$mean_yes, na.rm = TRUE) - 1,
           label = "← Control", color = "#B2182B", size = 4, fontface = "bold") +
  annotate("text", x = 15, y = max(binned_data$mean_yes, na.rm = TRUE) - 1,
           label = "Treated →", color = "#2166AC", size = 4, fontface = "bold") +
  theme_apep()

ggsave("output/paper_94/figures/fig_rdd_main.pdf", p_rdd_main, width = 10, height = 7)
message("Saved: fig_rdd_main.pdf")

# =============================================================================
# 7. Summary
# =============================================================================

message("\n=== ANALYSIS SUMMARY ===")
message(paste("Main RDD estimate:", round(rdd1$coef[1], 2), "pp"))
message(paste("  Standard error:", round(rdd1$se[1], 2)))
message(paste("  P-value:", round(rdd1$pv[1], 3)))
message(paste("  MSE-optimal bandwidth:", round(rdd1$bws[1], 1), "km"))
message(paste("McCrary density test p-value:", round(density_test$test$p_jk, 3)))

message("\n=== MAIN ANALYSIS COMPLETE ===")
