# ============================================================================
# 03_main_analysis.R - MVPF calculation with correlated bootstrap
# MVPF of Unconditional Cash Transfers in Kenya (v4)
# ============================================================================
#
# KEY IMPROVEMENT OVER v2/v3:
# Previous versions drew consumption and earnings treatment effects
# independently, ignoring potential correlation. This version:
# (1) Uses MASS::mvrnorm to draw correlated (consumption, earnings) pairs
# (2) Sweeps over ρ ∈ {-0.25, 0, 0.25, 0.50, 0.75} for sensitivity
# (3) Increases bootstrap replications from 1,000 to 5,000
# (4) Adds delta-method analytical SEs as a cross-check
# (5) Models government implementation scenarios (Inua Jamii)
# ============================================================================

source("00_packages.R")
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")

# ── Helper: PV of decaying stream ──────────────────────────────────────────

pv_stream <- function(annual, years, retention, r) {
  # retention = gamma = fraction of effect remaining each year
  sum(annual * retention^(0:(years - 1)) / (1 + r)^(1:years))
}

# ── Core MVPF function (single draw) ──────────────────────────────────────

calc_mvpf <- function(consumption_draw_usd, earnings_draw_usd,
                      spillover_draw_usd = NULL,
                      vat_coverage, informal_share,
                      admin_rate = 0.15, transfer = 1000,
                      mcpf = 1.0,
                      cons_persist_yrs = 3, cons_retention = 0.48,
                      earn_persist_yrs = 5, earn_retention = 0.75,
                      discount = 0.05,
                      include_nonrecipient_fe = FALSE,
                      spillover_ratio = 0.5) {

  # WTP
  wtp <- transfer * (1 - admin_rate)
  if (!is.null(spillover_draw_usd)) {
    wtp <- wtp + spillover_draw_usd * spillover_ratio
  }

  # Fiscal externalities (retention = gamma = annual fraction remaining)
  fe_vat <- pv_stream(consumption_draw_usd * 0.16 * vat_coverage,
                       cons_persist_yrs, cons_retention, discount)

  formal <- 1 - informal_share
  fe_income <- pv_stream(earnings_draw_usd * 0.185 * formal,
                          earn_persist_yrs, earn_retention, discount)

  fe_nr_vat <- 0
  if (include_nonrecipient_fe && !is.null(spillover_draw_usd)) {
    fe_nr_vat <- pv_stream(spillover_draw_usd * 0.16 * vat_coverage,
                            cons_persist_yrs, cons_retention, discount)
  }

  net_cost <- (transfer - fe_vat - fe_income - fe_nr_vat) * mcpf
  if (net_cost <= 0) return(NA_real_)

  wtp / net_cost
}

# ── Correlated Bootstrap ──────────────────────────────────────────────────

set.seed(42)
n_boot <- 5000

# Treatment effect means and SEs (in USD, converted from PPP)
cons_mean_usd <- consumption_gain_usd        # from 02_clean_data.R
cons_se_usd   <- egger_ge_effects$recipient_se[1] / kenya_fiscal$ppp_factor

earn_mean_usd <- wage_gain_usd
earn_se_usd   <- egger_ge_effects$recipient_se[
  egger_ge_effects$outcome == "Wage earnings"
] / kenya_fiscal$ppp_factor

spillover_mean_usd <- spillover_consumption_usd
spillover_se_usd   <- egger_ge_effects$nonrecipient_se[1] / kenya_fiscal$ppp_factor

# Fiscal parameter draws
# Using empirically calibrated beta distributions
vat_coverage_draws  <- rbeta(n_boot, 5, 5) * 0.50 + 0.25   # [0.25, 0.75], mean ≈ 0.50
informal_draws      <- rbeta(n_boot, 8, 2) * 0.35 + 0.60   # [0.60, 0.95], mean ≈ 0.88

# ── Baseline: ρ = 0 (independence, comparable to v2) ─────────────────────

mu <- c(cons_mean_usd, earn_mean_usd)
sigma_indep <- diag(c(cons_se_usd^2, earn_se_usd^2))

draws_indep <- MASS::mvrnorm(n_boot, mu, sigma_indep)
cons_draws  <- draws_indep[, 1]
earn_draws  <- draws_indep[, 2]
spill_draws <- rnorm(n_boot, spillover_mean_usd, spillover_se_usd)

# Four main specifications → Table 4
mvpf_direct_boot <- mapply(calc_mvpf,
  consumption_draw_usd = cons_draws, earnings_draw_usd = earn_draws,
  vat_coverage = vat_coverage_draws, informal_share = informal_draws,
  MoreArgs = list(mcpf = 1.0, spillover_draw_usd = NULL))

mvpf_direct_mcpf_boot <- mapply(calc_mvpf,
  consumption_draw_usd = cons_draws, earnings_draw_usd = earn_draws,
  vat_coverage = vat_coverage_draws, informal_share = informal_draws,
  MoreArgs = list(mcpf = 1.3, spillover_draw_usd = NULL))

mvpf_spillover_boot <- mapply(calc_mvpf,
  consumption_draw_usd = cons_draws, earnings_draw_usd = earn_draws,
  spillover_draw_usd = spill_draws,
  vat_coverage = vat_coverage_draws, informal_share = informal_draws,
  MoreArgs = list(mcpf = 1.0))

mvpf_spillover_mcpf_boot <- mapply(calc_mvpf,
  consumption_draw_usd = cons_draws, earnings_draw_usd = earn_draws,
  spillover_draw_usd = spill_draws,
  vat_coverage = vat_coverage_draws, informal_share = informal_draws,
  MoreArgs = list(mcpf = 1.3))

# Extended: including non-recipient FE
mvpf_extended_boot <- mapply(calc_mvpf,
  consumption_draw_usd = cons_draws, earnings_draw_usd = earn_draws,
  spillover_draw_usd = spill_draws,
  vat_coverage = vat_coverage_draws, informal_share = informal_draws,
  MoreArgs = list(mcpf = 1.0, include_nonrecipient_fe = TRUE))

# Point estimates and CIs
get_stats <- function(x) {
  x <- x[!is.na(x)]
  ci <- quantile(x, probs = c(0.025, 0.975))
  c(mean = mean(x), median = median(x), sd = sd(x),
    ci_lo = unname(ci[1]), ci_hi = unname(ci[2]))
}

stats_direct    <- get_stats(mvpf_direct_boot)
stats_direct_m  <- get_stats(mvpf_direct_mcpf_boot)
stats_spill     <- get_stats(mvpf_spillover_boot)
stats_spill_m   <- get_stats(mvpf_spillover_mcpf_boot)
stats_extended  <- get_stats(mvpf_extended_boot)

# Store point estimates for use in other scripts
mvpf_direct_no_mcpf <- stats_direct["mean"]
mvpf_direct_mcpf    <- stats_direct_m["mean"]
mvpf_total_no_mcpf  <- stats_spill["mean"]
mvpf_total_mcpf     <- stats_spill_m["mean"]
mvpf_extended       <- stats_extended["mean"]

ci_direct      <- stats_direct[c("ci_lo", "ci_hi")]
ci_mcpf        <- stats_direct_m[c("ci_lo", "ci_hi")]
ci_total       <- stats_spill[c("ci_lo", "ci_hi")]
ci_total_mcpf  <- stats_spill_m[c("ci_lo", "ci_hi")]
ci_extended    <- stats_extended[c("ci_lo", "ci_hi")]

cat("\n", rep("=", 60), "\n")
cat("MAIN MVPF RESULTS (ρ = 0, N_boot = 5000)\n")
cat(rep("=", 60), "\n\n")
cat("Direct, no MCPF:", round(mvpf_direct_no_mcpf, 3),
    "[", round(ci_direct[1], 2), ",", round(ci_direct[2], 2), "]\n")
cat("Direct, MCPF=1.3:", round(mvpf_direct_mcpf, 3),
    "[", round(ci_mcpf[1], 2), ",", round(ci_mcpf[2], 2), "]\n")
cat("With spillovers:", round(mvpf_total_no_mcpf, 3),
    "[", round(ci_total[1], 2), ",", round(ci_total[2], 2), "]\n")
cat("With spillovers + MCPF:", round(mvpf_total_mcpf, 3),
    "[", round(ci_total_mcpf[1], 2), ",", round(ci_total_mcpf[2], 2), "]\n")
cat("Extended (+ NR FE):", round(mvpf_extended, 3),
    "[", round(ci_extended[1], 2), ",", round(ci_extended[2], 2), "]\n")

# ── Covariance Sensitivity: sweep over ρ ──────────────────────────────────
# → Table 8 (new)

rho_values <- c(-0.25, 0, 0.25, 0.50, 0.75)

covariance_results <- tibble()
for (rho in rho_values) {
  Sigma <- matrix(
    c(cons_se_usd^2, rho * cons_se_usd * earn_se_usd,
      rho * cons_se_usd * earn_se_usd, earn_se_usd^2),
    nrow = 2
  )

  draws <- MASS::mvrnorm(n_boot, mu, Sigma)

  mvpf_rho <- mapply(calc_mvpf,
    consumption_draw_usd = draws[, 1], earnings_draw_usd = draws[, 2],
    spillover_draw_usd = spill_draws,
    vat_coverage = vat_coverage_draws, informal_share = informal_draws,
    MoreArgs = list(mcpf = 1.0))

  s <- get_stats(mvpf_rho)
  covariance_results <- bind_rows(covariance_results, tibble(
    rho = rho,
    mvpf_mean = s["mean"],
    mvpf_sd = s["sd"],
    ci_lo = s["ci_lo"],
    ci_hi = s["ci_hi"]
  ))
}

cat("\n=== Covariance Sensitivity (with spillovers) ===\n")
print(covariance_results, n = Inf)

# ── Delta-Method Cross-Check ──────────────────────────────────────────────
# Analytical SE for the baseline direct MVPF
# MVPF = W / (T - FE_vat - FE_inc)
# ∂MVPF/∂FE_vat = W / (T - FE_vat - FE_inc)^2
# ∂MVPF/∂FE_inc = W / (T - FE_vat - FE_inc)^2

se_vat <- cons_se_usd * 0.16 * 0.50 * 1.2   # rough PV factor
se_inc <- earn_se_usd * 0.185 * 0.20 * 4.4   # rough PV factor

deriv_common <- wtp_direct / net_cost^2
delta_se <- sqrt((deriv_common * se_vat)^2 + (deriv_common * se_inc)^2)

cat("\nDelta-method SE:", round(delta_se, 4), "\n")
cat("Bootstrap SE:", round(stats_direct["sd"], 4), "\n")

# ── Government Scenarios (Inua Jamii) ─────────────────────────────────────
# → Table 7

gov_scenarios <- tibble::tribble(
  ~scenario, ~admin_cost, ~leakage, ~label,
  "NGO (GiveDirectly)",     0.15, 0.00, "GiveDirectly baseline",
  "Best-case government",   0.20, 0.05, "M-Pesa delivery, community targeting",
  "Typical government",     0.30, 0.10, "Standard Inua Jamii delivery",
  "High-cost government",   0.40, 0.20, "In-person delivery, weak targeting"
)

gov_results <- gov_scenarios %>%
  rowwise() %>%
  mutate(
    effective_wtp = 1000 * (1 - admin_cost) * (1 - leakage + leakage * 0.5),
    mvpf = effective_wtp / net_cost,
    mvpf_with_spillover = (effective_wtp + wtp_spillover_per_recipient) / net_cost
  ) %>%
  ungroup()

cat("\n=== Government Implementation Scenarios ===\n")
print(gov_results %>% dplyr::select(scenario, admin_cost, leakage, effective_wtp,
                                     mvpf, mvpf_with_spillover))

# ── WTP Sensitivity (WTP < 1) ────────────────────────────────────────────
# Robustness: what if recipients value $1 at less than $1?

wtp_ratios <- c(0.80, 0.85, 0.90, 0.95, 1.00)
wtp_sensitivity <- tibble(
  wtp_ratio = wtp_ratios,
  wtp = 1000 * (1 - 0.15) * wtp_ratios,
  mvpf = 1000 * (1 - 0.15) * wtp_ratios / net_cost
)

cat("\n=== WTP < 1 Sensitivity ===\n")
print(wtp_sensitivity)

# ── US Benchmarks ─────────────────────────────────────────────────────────

us_benchmarks <- tibble::tribble(
  ~policy, ~mvpf, ~category, ~target,
  "EITC expansion (adults)",     0.92, "Tax credits",       "Adults",
  "TANF (cash welfare)",         0.65, "Cash transfers",    "Adults",
  "Food stamps (SNAP)",          0.76, "In-kind transfers", "Adults",
  "Medicaid (adults)",           1.20, "Health insurance",  "Adults",
  "Head Start",                  1.50, "Early childhood",   "Children",
  "Medicaid (children)",         Inf,  "Health insurance",  "Children",
  "Moving to Opportunity",       Inf,  "Housing",           "Families"
)

kenya_row <- tibble(
  policy = "Kenya UCT (GiveDirectly)",
  mvpf = as.numeric(mvpf_direct_no_mcpf),
  category = "Cash transfers",
  target = "Adults"
)

comparison_df <- bind_rows(us_benchmarks, kenya_row) %>%
  mutate(mvpf_display = ifelse(is.infinite(mvpf), "Inf", round(mvpf, 2)))

# ── Assemble main results ────────────────────────────────────────────────

main_results <- tibble(
  specification = c(
    "Direct WTP, no MCPF",
    "Direct WTP, MCPF=1.3",
    "With spillovers, no MCPF",
    "With spillovers, MCPF=1.3",
    "Extended (incl. NR FE), no MCPF"
  ),
  mvpf = c(mvpf_direct_no_mcpf, mvpf_direct_mcpf, mvpf_total_no_mcpf,
           mvpf_total_mcpf, mvpf_extended),
  ci_lower = c(ci_direct[1], ci_mcpf[1], ci_total[1], ci_total_mcpf[1], ci_extended[1]),
  ci_upper = c(ci_direct[2], ci_mcpf[2], ci_total[2], ci_total_mcpf[2], ci_extended[2]),
  wtp = c(wtp_direct, wtp_direct, wtp_total, wtp_total,
          wtp_total),
  net_cost_val = c(net_cost, net_cost_mcpf, net_cost, net_cost_mcpf, net_cost_extended)
)

save(
  main_results,
  mvpf_direct_no_mcpf, mvpf_total_no_mcpf, mvpf_direct_mcpf, mvpf_total_mcpf,
  mvpf_extended,
  ci_direct, ci_total, ci_mcpf, ci_total_mcpf, ci_extended,
  comparison_df,
  covariance_results,
  gov_results,
  wtp_sensitivity,
  delta_se,
  mvpf_direct_boot, mvpf_spillover_boot,
  file = "../data/main_results.RData"
)

cat("\n", rep("=", 60), "\n")
cat("KEY RESULT: Kenya UCT MVPF =", round(mvpf_direct_no_mcpf, 2),
    "[", round(ci_direct[1], 2), ",", round(ci_direct[2], 2), "]\n")
cat("With spillovers:", round(mvpf_total_no_mcpf, 2),
    "[", round(ci_total[1], 2), ",", round(ci_total[2], 2), "]\n")
cat("Results saved to ../data/main_results.RData\n")
