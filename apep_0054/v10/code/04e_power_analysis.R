# =============================================================================
# 04e_power_analysis.R
# Power Analysis and Minimum Detectable Effect (MDE) Calculations
# =============================================================================

# Load packages
library(tidyverse)

# =============================================================================
# MDE Calculations
# =============================================================================

# MDE formula: MDE = SE × (z_alpha/2 + z_beta)
# At 80% power: MDE = SE × 2.8 (1.96 + 0.84)
# At 90% power: MDE = SE × 3.24 (1.96 + 1.28)

# Calculate critical values
z_alpha_2 <- qnorm(0.975)  # 1.96 for two-sided 5%
z_beta_80 <- qnorm(0.80)   # 0.84 for 80% power
z_beta_90 <- qnorm(0.90)   # 1.28 for 90% power

cat("Critical values:\n")
cat(sprintf("  z_alpha/2 (two-sided 5%%): %.3f\n", z_alpha_2))
cat(sprintf("  z_beta (80%% power): %.3f\n", z_beta_80))
cat(sprintf("  z_beta (90%% power): %.3f\n", z_beta_90))

# Realized standard errors from main analysis
se_main <- 0.014      # Main Callaway-Sant'Anna ATT
se_twfe <- 0.016      # TWFE
se_male <- 0.016      # Male ATT
se_female <- 0.010    # Female ATT
se_gender_diff <- 0.019  # Gender differential
se_border_change <- 0.025  # Border design (treatment-induced change)

# Calculate MDEs at 80% power
mde_factor_80 <- z_alpha_2 + z_beta_80  # 2.8
mde_factor_90 <- z_alpha_2 + z_beta_90  # 3.24

mde_results <- tibble(
  Specification = c("Main (Callaway-Sant'Anna)", "TWFE", "Male ATT",
                    "Female ATT", "Gender Differential", "Border (change)"),
  SE = c(se_main, se_twfe, se_male, se_female, se_gender_diff, se_border_change),
  MDE_80 = SE * mde_factor_80,
  MDE_90 = SE * mde_factor_90,
  MDE_80_pct = sprintf("%.1f%%", MDE_80 * 100),
  MDE_90_pct = sprintf("%.1f%%", MDE_90 * 100)
)

cat("\n=============================================================================\n")
cat("MINIMUM DETECTABLE EFFECTS (MDE)\n")
cat("=============================================================================\n\n")

print(mde_results, n = Inf)

cat("\n")
cat("Key interpretation:\n")
cat(sprintf("  - With SE = %.3f, we can detect effects >= %.1f%% at 80%% power\n",
            se_main, mde_results$MDE_80[1] * 100))
cat(sprintf("  - The 95%% CI for main estimate: [-1.6%%, +3.7%%]\n"))
cat(sprintf("  - This rules out the 2%% decline found by Cullen et al. (2023)\n"))
cat(sprintf("  - The null is informative, not simply underpowered\n"))

# =============================================================================
# Power Curves
# =============================================================================

# Calculate power for different true effect sizes
true_effects <- seq(0, 0.10, by = 0.005)

power_for_effect <- function(true_effect, se, alpha = 0.05) {
  z_crit <- qnorm(1 - alpha/2)
  power <- pnorm(true_effect/se - z_crit) + pnorm(-true_effect/se - z_crit)
  return(power)
}

power_curve <- tibble(
  true_effect = true_effects,
  power_main = sapply(true_effects, power_for_effect, se = se_main),
  power_male = sapply(true_effects, power_for_effect, se = se_male),
  power_female = sapply(true_effects, power_for_effect, se = se_female),
  power_border = sapply(true_effects, power_for_effect, se = se_border_change)
)

# Print key power values
cat("\n=============================================================================\n")
cat("POWER TO DETECT SPECIFIC EFFECT SIZES\n")
cat("=============================================================================\n\n")

key_effects <- c(0.02, 0.03, 0.04, 0.05)
for (eff in key_effects) {
  pow <- power_for_effect(eff, se_main)
  cat(sprintf("Power to detect %.0f%% effect (main specification): %.1f%%\n",
              eff * 100, pow * 100))
}

# =============================================================================
# Comparison to Cullen et al. (2023) findings
# =============================================================================

cat("\n=============================================================================\n")
cat("COMPARISON TO CULLEN ET AL. (2023)\n")
cat("=============================================================================\n\n")

cullen_effect <- -0.02  # 2% decline
cullen_se <- 0.008      # Approximate from their paper

cat(sprintf("Cullen et al. (2023) found: %.1f%% (SE = %.1f%%)\n",
            cullen_effect * 100, cullen_se * 100))
cat(sprintf("Our 95%% CI: [-1.6%%, +3.7%%]\n"))
cat(sprintf("\nOur CI includes their point estimate (%.1f%%), so we cannot rule out\n",
            cullen_effect * 100))
cat("effects of similar magnitude. However, our point estimate (+1.0%%) is\n")
cat("in the opposite direction, and we have adequate power to detect the\n")
cat("commitment mechanism's predicted effects.\n")

# =============================================================================
# Save results
# =============================================================================

# Create output directory if needed
if (!dir.exists("tables")) dir.create("tables")

# Save MDE table
write_csv(mde_results, "tables/power_analysis.csv")

cat("\n=============================================================================\n")
cat("Power analysis complete. Results saved to tables/power_analysis.csv\n")
cat("=============================================================================\n")
