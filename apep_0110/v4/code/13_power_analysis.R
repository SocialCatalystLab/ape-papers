# =============================================================================
# 13_power_analysis.R
# Statistical Power Analysis and Minimum Detectable Effects (MDE)
# =============================================================================

source("00_packages.R")

# Load data
crashes <- readRDS("../data/crashes_analysis.rds")
crashes$rv <- -crashes$running_var  # Positive = legal

cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("STATISTICAL POWER ANALYSIS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# PART 1: MDE Formula and Baseline
# =============================================================================

cat("MDE CALCULATION\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

# MDE formula for 80% power, two-sided alpha = 0.05:
# MDE = (z_alpha/2 + z_beta) * SE
# For 80% power: z_0.025 + z_0.20 = 1.96 + 0.84 = 2.80
# So MDE = 2.80 * SE

power_multiplier <- 2.80  # For 80% power, two-sided alpha = 0.05

cat("Formula: MDE = 2.80 * SE (for 80% power, two-sided alpha = 0.05)\n\n")

# =============================================================================
# PART 2: Main RDD Specification
# =============================================================================

cat("Main RDD Specification:\n")

# Run main RDD to get SE
rdd_main <- rdrobust(
  y = crashes$alcohol_involved,
  x = crashes$rv,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

main_se <- rdd_main$se[1]
main_mde <- power_multiplier * main_se
main_bw <- rdd_main$bws[1, 1]
main_n_eff <- rdd_main$N_h[1] + rdd_main$N_h[2]

cat(sprintf("  Bandwidth: %.1f km\n", main_bw))
cat(sprintf("  Effective N: %d\n", main_n_eff))
cat(sprintf("  SE: %.4f\n", main_se))
cat(sprintf("  MDE (80%% power): %.4f (%.1f pp)\n", main_mde, 100 * main_mde))

# =============================================================================
# PART 3: MDE by Bandwidth
# =============================================================================

cat("\n\nMDE BY BANDWIDTH\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

# Get optimal bandwidth and create variations
h_opt <- main_bw
bandwidth_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)

bw_results <- data.frame()

for (mult in bandwidth_multipliers) {
  h <- h_opt * mult

  rdd_bw <- tryCatch({
    rdrobust(
      y = crashes$alcohol_involved,
      x = crashes$rv,
      c = 0,
      kernel = "triangular",
      p = 1,
      h = h
    )
  }, error = function(e) NULL)

  if (!is.null(rdd_bw)) {
    se <- rdd_bw$se[1]
    mde <- power_multiplier * se
    n_eff <- rdd_bw$N_h[1] + rdd_bw$N_h[2]

    bw_results <- rbind(bw_results, data.frame(
      bandwidth_multiplier = mult,
      bandwidth_km = h,
      n_effective = n_eff,
      se = se,
      mde = mde,
      mde_pp = 100 * mde
    ))

    cat(sprintf("  %.2fh (%.1f km): N_eff = %d, SE = %.4f, MDE = %.1f pp\n",
                mult, h, n_eff, se, 100 * mde))
  }
}

# =============================================================================
# PART 4: MDE for Key Specifications
# =============================================================================

cat("\n\nMDE FOR KEY SPECIFICATIONS\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

spec_results <- data.frame()

# 1. Main specification (already computed)
spec_results <- rbind(spec_results, data.frame(
  specification = "Main RDD (all crashes)",
  n_total = nrow(crashes),
  n_effective = main_n_eff,
  se = main_se,
  mde = main_mde,
  mde_pp = 100 * main_mde
))

# 2. In-state drivers only
crashes_instate <- crashes %>% filter(is_instate_driver == 1)
if (nrow(crashes_instate) > 500) {
  rdd_instate <- tryCatch({
    rdrobust(
      y = crashes_instate$alcohol_involved,
      x = crashes_instate$rv,
      c = 0, kernel = "triangular", p = 1
    )
  }, error = function(e) NULL)

  if (!is.null(rdd_instate)) {
    spec_results <- rbind(spec_results, data.frame(
      specification = "In-state drivers only",
      n_total = nrow(crashes_instate),
      n_effective = rdd_instate$N_h[1] + rdd_instate$N_h[2],
      se = rdd_instate$se[1],
      mde = power_multiplier * rdd_instate$se[1],
      mde_pp = 100 * power_multiplier * rdd_instate$se[1]
    ))
    cat(sprintf("  In-state drivers: N_eff = %d, SE = %.4f, MDE = %.1f pp\n",
                rdd_instate$N_h[1] + rdd_instate$N_h[2],
                rdd_instate$se[1],
                100 * power_multiplier * rdd_instate$se[1]))
  }
}

# 3. Single-vehicle, in-state drivers
if ("ve_total" %in% names(crashes) || "numveh" %in% names(crashes)) {
  # Try different column names for number of vehicles
  if ("ve_total" %in% names(crashes)) {
    crashes_sv_instate <- crashes %>%
      filter(is_instate_driver == 1, ve_total == 1)
  } else if ("numveh" %in% names(crashes)) {
    crashes_sv_instate <- crashes %>%
      filter(is_instate_driver == 1, numveh == 1)
  } else {
    crashes_sv_instate <- data.frame()
  }

  if (nrow(crashes_sv_instate) > 200) {
    rdd_sv_instate <- tryCatch({
      rdrobust(
        y = crashes_sv_instate$alcohol_involved,
        x = crashes_sv_instate$rv,
        c = 0, kernel = "triangular", p = 1
      )
    }, error = function(e) NULL)

    if (!is.null(rdd_sv_instate)) {
      spec_results <- rbind(spec_results, data.frame(
        specification = "Single-vehicle, in-state",
        n_total = nrow(crashes_sv_instate),
        n_effective = rdd_sv_instate$N_h[1] + rdd_sv_instate$N_h[2],
        se = rdd_sv_instate$se[1],
        mde = power_multiplier * rdd_sv_instate$se[1],
        mde_pp = 100 * power_multiplier * rdd_sv_instate$se[1]
      ))
      cat(sprintf("  Single-vehicle, in-state: N_eff = %d, SE = %.4f, MDE = %.1f pp\n",
                  rdd_sv_instate$N_h[1] + rdd_sv_instate$N_h[2],
                  rdd_sv_instate$se[1],
                  100 * power_multiplier * rdd_sv_instate$se[1]))
    }
  }
}

# 4. Nighttime crashes only
crashes_night <- crashes %>% filter(is_nighttime == 1)
if (nrow(crashes_night) > 500) {
  rdd_night <- tryCatch({
    rdrobust(
      y = crashes_night$alcohol_involved,
      x = crashes_night$rv,
      c = 0, kernel = "triangular", p = 1
    )
  }, error = function(e) NULL)

  if (!is.null(rdd_night)) {
    spec_results <- rbind(spec_results, data.frame(
      specification = "Nighttime crashes (9pm-5am)",
      n_total = nrow(crashes_night),
      n_effective = rdd_night$N_h[1] + rdd_night$N_h[2],
      se = rdd_night$se[1],
      mde = power_multiplier * rdd_night$se[1],
      mde_pp = 100 * power_multiplier * rdd_night$se[1]
    ))
    cat(sprintf("  Nighttime crashes: N_eff = %d, SE = %.4f, MDE = %.1f pp\n",
                rdd_night$N_h[1] + rdd_night$N_h[2],
                rdd_night$se[1],
                100 * power_multiplier * rdd_night$se[1]))
  }
}

# 5. 2km Donut
crashes_donut2 <- crashes %>% filter(abs(rv) > 2)
if (nrow(crashes_donut2) > 500) {
  rdd_donut2 <- tryCatch({
    rdrobust(
      y = crashes_donut2$alcohol_involved,
      x = crashes_donut2$rv,
      c = 0, kernel = "triangular", p = 1
    )
  }, error = function(e) NULL)

  if (!is.null(rdd_donut2)) {
    spec_results <- rbind(spec_results, data.frame(
      specification = "2km Donut RDD",
      n_total = nrow(crashes_donut2),
      n_effective = rdd_donut2$N_h[1] + rdd_donut2$N_h[2],
      se = rdd_donut2$se[1],
      mde = power_multiplier * rdd_donut2$se[1],
      mde_pp = 100 * power_multiplier * rdd_donut2$se[1]
    ))
    cat(sprintf("  2km Donut: N_eff = %d, SE = %.4f, MDE = %.1f pp\n",
                rdd_donut2$N_h[1] + rdd_donut2$N_h[2],
                rdd_donut2$se[1],
                100 * power_multiplier * rdd_donut2$se[1]))
  }
}

# =============================================================================
# PART 5: Comparison to Literature
# =============================================================================

cat("\n\nCOMPARISON TO PRIOR LITERATURE\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

# Effect sizes from prior studies (estimated from papers)
literature <- data.frame(
  study = c(
    "Anderson et al. (2013) - MML fatalities",
    "Hansen et al. (2020) - RML fatalities",
    "Santaella-Tenorio (2017) - Meta-analysis",
    "Dills et al. (2021) - DiD synthesis"
  ),
  effect_estimate = c(
    0.08,  # ~8% reduction in traffic fatalities
    0.05,  # ~5% reduction (some specifications)
    0.10,  # ~10% range in meta-analysis
    0.00   # Null/small effects
  ),
  effect_type = c(
    "Fatality reduction",
    "Fatality reduction",
    "Fatality reduction",
    "Null effect"
  )
)

cat("Prior effect size estimates:\n")
for (i in 1:nrow(literature)) {
  cat(sprintf("  %s: %.0f%%\n", literature$study[i], 100 * literature$effect_estimate[i]))
}

cat("\n\nPower to detect prior effect sizes:\n")
cat(sprintf("  Our main spec MDE: %.1f pp\n", 100 * main_mde))
cat(sprintf("  Anderson et al. (2013) effect: %.1f pp\n", 100 * 0.08))
cat(sprintf("  → We can %s detect this effect\n",
            ifelse(main_mde < 0.08, "likely", "NOT")))
cat(sprintf("  Hansen et al. (2020) effect: %.1f pp\n", 100 * 0.05))
cat(sprintf("  → We can %s detect this effect\n",
            ifelse(main_mde < 0.05, "likely", "NOT")))

# =============================================================================
# PART 6: Power Curve Visualization
# =============================================================================

cat("\n\nCreating power curve visualization...\n")

# Calculate power for different effect sizes given our SE
effect_sizes <- seq(0, 0.30, by = 0.01)
power_curve <- data.frame(
  effect_size = effect_sizes,
  effect_pp = 100 * effect_sizes,
  power = sapply(effect_sizes, function(delta) {
    # Power = P(reject H0 | H1 true)
    # = P(|Z| > 1.96 | delta) = 1 - pnorm(1.96 - delta/SE) + pnorm(-1.96 - delta/SE)
    z <- delta / main_se
    1 - pnorm(1.96 - z) + pnorm(-1.96 - z)
  })
)

# Create plot
p_power <- ggplot(power_curve, aes(x = effect_pp, y = power)) +
  geom_line(size = 1.2, color = "steelblue") +
  geom_hline(yintercept = 0.80, linetype = "dashed", color = "red") +
  geom_vline(xintercept = 100 * main_mde, linetype = "dotted", color = "darkgreen") +
  # Add literature effect sizes
  geom_vline(xintercept = 8, linetype = "dashed", color = "gray50", alpha = 0.7) +
  geom_vline(xintercept = 5, linetype = "dashed", color = "gray50", alpha = 0.7) +
  annotate("text", x = 8, y = 0.95, label = "Anderson (2013)", angle = 90, vjust = -0.5, size = 3) +
  annotate("text", x = 5, y = 0.95, label = "Hansen (2020)", angle = 90, vjust = -0.5, size = 3) +
  annotate("text", x = 100 * main_mde, y = 0.85, label = "MDE", vjust = -0.5, hjust = -0.1, size = 3, color = "darkgreen") +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(
    x = "True Effect Size (percentage points)",
    y = "Statistical Power",
    title = "Power Curve for Main RDD Specification",
    subtitle = sprintf("SE = %.3f, MDE (80%% power) = %.1f pp", main_se, 100 * main_mde),
    caption = "Red dashed line: 80% power. Green dotted line: MDE. Gray lines: prior literature effect sizes."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold")
  )

ggsave("../figures/fig10_power_curve.pdf", p_power, width = 8, height = 5)
cat("Saved: fig10_power_curve.pdf\n")

# =============================================================================
# PART 7: Save Results
# =============================================================================

saveRDS(spec_results, "../data/mde_by_specification.rds")
saveRDS(bw_results, "../data/mde_by_bandwidth.rds")
saveRDS(power_curve, "../data/power_curve.rds")

# =============================================================================
# Summary Table for Paper
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("TABLE FOR PAPER: MINIMUM DETECTABLE EFFECTS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

print(spec_results %>%
        mutate(
          mde_pp = sprintf("%.1f", mde_pp),
          se = sprintf("%.4f", se)
        ) %>%
        select(specification, n_effective, se, mde_pp) %>%
        rename(
          Specification = specification,
          `Effective N` = n_effective,
          `SE` = se,
          `MDE (pp)` = mde_pp
        ))

cat("\n\nKey Finding:\n")
cat(sprintf("Our main specification can detect effects of %.1f pp or larger with 80%% power.\n", 100 * main_mde))
cat(sprintf("Effect sizes from prior DiD studies (~5-10 pp) are %s our MDE.\n",
            ifelse(main_mde > 0.10, "BELOW", ifelse(main_mde > 0.05, "AT THE MARGIN OF", "ABOVE"))))
cat("This explains why null results should be interpreted cautiously.\n")

cat("\n\nPOWER ANALYSIS COMPLETE\n")
