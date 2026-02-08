# ============================================================================
# 03_main_analysis.R - Calculate MVPF from Published Estimates
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================
#
# This script implements MVPF calculation following Hendren & Sprung-Keyser (2020):
# 1. Uses treatment effects from published experimental studies
# 2. Propagates uncertainty via Monte Carlo simulation
# 3. Computes MVPF with proper confidence intervals
#
# Data sources:
#   - Haushofer & Shapiro (2016 QJE): Direct treatment effects
#   - Haushofer & Shapiro (2018): Long-term effect persistence
#   - Egger et al. (2022 Econometrica): General equilibrium spillovers
# ============================================================================

source("00_packages.R")

cat("\n", rep("=", 60), "\n")
cat("MVPF CALCULATION FROM PUBLISHED ESTIMATES\n")
cat(rep("=", 60), "\n\n")

# -----------------------------------------------------------------------------
# Load calibration data from 01_fetch_data.R
# -----------------------------------------------------------------------------

data_dir <- "../data"

if (!file.exists(file.path(data_dir, "kenya_uct_data.RData"))) {
  stop("Calibration data not found. Run 01_fetch_data.R first.")
}

load(file.path(data_dir, "kenya_uct_data.RData"))

cat("Loaded calibration data:\n")
cat(sprintf("  - %d treatment effect estimates\n", nrow(haushofer_shapiro_effects)))
cat(sprintf("  - %d GE effect estimates\n", nrow(egger_ge_effects)))
cat(sprintf("  - Fiscal multiplier: %.2f\n", fiscal_multiplier$estimate[3]))

# -----------------------------------------------------------------------------
# Kenya Fiscal Parameters
# -----------------------------------------------------------------------------

params <- list(
  # Tax rates
  vat_rate = 0.16,              # Standard VAT rate
  vat_coverage = 0.50,          # Share of consumption subject to VAT
  income_tax_formal = 0.185,    # Effective rate for formal workers
  informal_share = 0.80,        # Share of rural workforce informal

  # Transfer program
  transfer_amount = 1000,       # USD
  admin_cost_rate = 0.15,       # GiveDirectly overhead

  # MCPF
  mcpf_baseline = 1.0,          # Baseline: no distortion
  mcpf_high = 1.3,              # Sensitivity: developing country estimate

  # Discount rate and persistence
  discount_rate = 0.05,
  consumption_persist_years = 3,
  consumption_decay = 0.50,     # 50% annual decay
  earnings_persist_years = 5,
  earnings_decay = 0.25,        # 25% annual decay

  # PPP conversion
  ppp_factor = 2.515
)

# -----------------------------------------------------------------------------
# Present Value Calculations
# -----------------------------------------------------------------------------

calc_pv_factor <- function(years, decay_rate, discount_rate) {
  pv <- 0
  for (t in 1:years) {
    pv <- pv + (1 - decay_rate)^(t-1) / (1 + discount_rate)^t
  }
  return(pv)
}

pv_consumption <- calc_pv_factor(
  params$consumption_persist_years,
  params$consumption_decay,
  params$discount_rate
)

pv_earnings <- calc_pv_factor(
  params$earnings_persist_years,
  params$earnings_decay,
  params$discount_rate
)

cat(sprintf("\nPresent value factors:\n"))
cat(sprintf("  Consumption (%.0f yr, %.0f%% decay): %.3f\n",
            params$consumption_persist_years, params$consumption_decay * 100, pv_consumption))
cat(sprintf("  Earnings (%.0f yr, %.0f%% decay): %.3f\n",
            params$earnings_persist_years, params$earnings_decay * 100, pv_earnings))

# -----------------------------------------------------------------------------
# Core MVPF Calculation Function
# -----------------------------------------------------------------------------

calculate_mvpf <- function(consumption_effect, earnings_effect,
                           consumption_se = NULL, earnings_se = NULL,
                           include_spillovers = FALSE,
                           spillover_consumption = 0,
                           spillover_earnings = 0,
                           params) {

  # Willingness to pay = transfer net of admin costs
  transfer <- params$transfer_amount
  wtp_direct <- transfer * (1 - params$admin_cost_rate)

  # Convert PPP effects to USD
  consumption_usd <- consumption_effect / params$ppp_factor
  earnings_usd <- earnings_effect / params$ppp_factor

  # Annualize monthly consumption effect
  annual_consumption <- consumption_usd * 12
  annual_earnings <- earnings_usd * 12

  # Present value of behavioral responses
  pv_consumption <- annual_consumption * calc_pv_factor(
    params$consumption_persist_years,
    params$consumption_decay,
    params$discount_rate
  )

  pv_earnings <- annual_earnings * calc_pv_factor(
    params$earnings_persist_years,
    params$earnings_decay,
    params$discount_rate
  )

  # Fiscal externalities
  vat_externality <- params$vat_rate * params$vat_coverage * pv_consumption

  # Income tax externality (only formal workers pay)
  formal_share <- 1 - params$informal_share
  income_tax_externality <- params$income_tax_formal * formal_share * pv_earnings

  total_fiscal_externality <- vat_externality + income_tax_externality

  # Net cost to government
  net_cost <- transfer - total_fiscal_externality

  # Add spillovers if requested
  wtp_total <- wtp_direct
  if (include_spillovers) {
    # Spillover WTP (consumption gains to non-recipients)
    spillover_usd <- spillover_consumption / params$ppp_factor
    # Adjust for number of non-recipients relative to recipients
    # In Egger et al., ratio = (1 - 2/3) / (2/3) = 0.5 in high-saturation villages
    spillover_ratio <- if (!is.null(params$spillover_ratio)) params$spillover_ratio else 0.5
    spillover_wtp <- spillover_usd * 12 * spillover_ratio *
      calc_pv_factor(params$consumption_persist_years,
                     params$consumption_decay,
                     params$discount_rate)
    wtp_total <- wtp_direct + spillover_wtp
  }

  # MVPF
  mvpf <- wtp_total / net_cost

  # Return detailed components
  list(
    mvpf = mvpf,
    wtp_direct = wtp_direct,
    wtp_spillover = if(include_spillovers) wtp_total - wtp_direct else 0,
    wtp_total = wtp_total,
    gross_cost = transfer,
    vat_externality = vat_externality,
    income_tax_externality = income_tax_externality,
    total_fiscal_externality = total_fiscal_externality,
    net_cost = net_cost
  )
}

# -----------------------------------------------------------------------------
# Main MVPF Estimates
# -----------------------------------------------------------------------------

# Get treatment effects
consumption_effect <- haushofer_shapiro_effects %>%
  filter(outcome == "Total consumption") %>%
  pull(treatment_effect)

consumption_se <- haushofer_shapiro_effects %>%
  filter(outcome == "Total consumption") %>%
  pull(se)

earnings_effect <- haushofer_shapiro_effects %>%
  filter(outcome == "Non-agricultural revenue") %>%
  pull(treatment_effect)

earnings_se <- haushofer_shapiro_effects %>%
  filter(outcome == "Non-agricultural revenue") %>%
  pull(se)

# Spillover effects from Egger et al.
spillover_consumption <- egger_ge_effects %>%
  filter(outcome == "Consumption") %>%
  pull(nonrecipient_effect)

spillover_consumption_se <- egger_ge_effects %>%
  filter(outcome == "Consumption") %>%
  pull(nonrecipient_se)

cat("\n=== Treatment Effects (Published Estimates) ===\n")
cat(sprintf("Consumption effect: $%.0f PPP/month (SE: $%.0f)\n",
            consumption_effect, consumption_se))
cat(sprintf("Earnings effect: $%.0f PPP/month (SE: $%.0f)\n",
            earnings_effect, earnings_se))
cat(sprintf("Spillover consumption: $%.0f PPP/year (SE: $%.0f)\n",
            spillover_consumption, spillover_consumption_se))

# Calculate point estimates
mvpf_direct <- calculate_mvpf(
  consumption_effect = consumption_effect,
  earnings_effect = earnings_effect,
  include_spillovers = FALSE,
  params = params
)

mvpf_with_spillovers <- calculate_mvpf(
  consumption_effect = consumption_effect,
  earnings_effect = earnings_effect,
  include_spillovers = TRUE,
  spillover_consumption = spillover_consumption / 12,  # Convert to monthly
  params = params
)

cat("\n=== MVPF Results (Point Estimates) ===\n")
cat(sprintf("Direct recipients only: %.3f\n", mvpf_direct$mvpf))
cat(sprintf("Including GE spillovers: %.3f\n", mvpf_with_spillovers$mvpf))

# -----------------------------------------------------------------------------
# Monte Carlo Simulation for Confidence Intervals
# -----------------------------------------------------------------------------

set.seed(20231215)
n_sims <- 10000

# Draw from distributions of treatment effects
consumption_draws <- rnorm(n_sims, consumption_effect, consumption_se)
earnings_draws <- rnorm(n_sims, earnings_effect, earnings_se)
spillover_draws <- rnorm(n_sims, spillover_consumption, spillover_consumption_se)

# Draw fiscal parameters from beta distributions (as described in paper §4.6)
# VAT coverage: Beta(5,5) scaled to [0.25, 0.75], centered ~0.50
vat_coverage_draws <- 0.25 + 0.50 * rbeta(n_sims, 5, 5)
# Informality share: Beta(8,2) scaled to [0.60, 0.95], centered ~0.80
informality_draws <- 0.60 + 0.35 * rbeta(n_sims, 8, 2)
# Admin cost rate: Beta(3,3) scaled to [0.10, 0.20], centered ~0.15
admin_cost_draws <- 0.10 + 0.10 * rbeta(n_sims, 3, 3)

cat(sprintf("\nFiscal parameter draws (mean [2.5%%, 97.5%%]):\n"))
cat(sprintf("  VAT coverage:    %.3f [%.3f, %.3f]\n",
            mean(vat_coverage_draws), quantile(vat_coverage_draws, 0.025), quantile(vat_coverage_draws, 0.975)))
cat(sprintf("  Informality:     %.3f [%.3f, %.3f]\n",
            mean(informality_draws), quantile(informality_draws, 0.025), quantile(informality_draws, 0.975)))
cat(sprintf("  Admin cost rate: %.3f [%.3f, %.3f]\n",
            mean(admin_cost_draws), quantile(admin_cost_draws, 0.025), quantile(admin_cost_draws, 0.975)))

# Calculate MVPF for each draw
mvpf_direct_draws <- numeric(n_sims)
mvpf_spillover_draws <- numeric(n_sims)

# Store component draws for variance decomposition
wtp_direct_draws <- numeric(n_sims)
vat_ext_draws <- numeric(n_sims)
income_ext_draws <- numeric(n_sims)
net_cost_draws <- numeric(n_sims)
wtp_spillover_draws <- numeric(n_sims)

for (i in 1:n_sims) {
  # Override fiscal parameters for this draw
  params_i <- params
  params_i$vat_coverage <- vat_coverage_draws[i]
  params_i$informal_share <- informality_draws[i]
  params_i$admin_cost_rate <- admin_cost_draws[i]

  result_direct <- calculate_mvpf(
    consumption_effect = consumption_draws[i],
    earnings_effect = earnings_draws[i],
    include_spillovers = FALSE,
    params = params_i
  )
  mvpf_direct_draws[i] <- result_direct$mvpf
  wtp_direct_draws[i] <- result_direct$wtp_direct
  vat_ext_draws[i] <- result_direct$vat_externality
  income_ext_draws[i] <- result_direct$income_tax_externality
  net_cost_draws[i] <- result_direct$net_cost

  result_spillover <- calculate_mvpf(
    consumption_effect = consumption_draws[i],
    earnings_effect = earnings_draws[i],
    include_spillovers = TRUE,
    spillover_consumption = spillover_draws[i] / 12,
    params = params_i
  )
  mvpf_spillover_draws[i] <- result_spillover$mvpf
  wtp_spillover_draws[i] <- result_spillover$wtp_total - result_spillover$wtp_direct
}

# Confidence intervals
ci_direct <- quantile(mvpf_direct_draws, c(0.025, 0.975))
ci_spillover <- quantile(mvpf_spillover_draws, c(0.025, 0.975))

cat("\n=== MVPF with 95% Confidence Intervals ===\n")
cat(sprintf("Direct only:    %.3f [%.3f, %.3f]\n",
            mvpf_direct$mvpf, ci_direct[1], ci_direct[2]))
cat(sprintf("With spillovers: %.3f [%.3f, %.3f]\n",
            mvpf_with_spillovers$mvpf, ci_spillover[1], ci_spillover[2]))

# -----------------------------------------------------------------------------
# MVPF Decomposition
# -----------------------------------------------------------------------------

cat("\n=== MVPF Decomposition ===\n")
cat(sprintf("Transfer amount:           $%.0f\n", params$transfer_amount))
cat(sprintf("Administrative costs:      $%.0f (%.0f%%)\n",
            params$transfer_amount * params$admin_cost_rate,
            params$admin_cost_rate * 100))
cat(sprintf("WTP (direct):              $%.0f\n", mvpf_direct$wtp_direct))
cat(sprintf("\nFiscal Externalities:\n"))
cat(sprintf("  VAT externality:         $%.2f\n", mvpf_direct$vat_externality))
cat(sprintf("  Income tax externality:  $%.2f\n", mvpf_direct$income_tax_externality))
cat(sprintf("  Total fiscal externality: $%.2f (%.1f%% of transfer)\n",
            mvpf_direct$total_fiscal_externality,
            mvpf_direct$total_fiscal_externality / params$transfer_amount * 100))
cat(sprintf("\nNet cost to government:    $%.2f\n", mvpf_direct$net_cost))
cat(sprintf("MVPF = WTP / Net Cost = $%.0f / $%.2f = %.3f\n",
            mvpf_direct$wtp_direct, mvpf_direct$net_cost, mvpf_direct$mvpf))

# -----------------------------------------------------------------------------
# Save Results
# -----------------------------------------------------------------------------

# Variance decomposition: compute share of MVPF variance from each source
# Hold all but one parameter fixed at a time and compute resulting MVPF variance
cat("\n=== Variance Decomposition ===\n")

# Function to compute MVPF variance contribution from a single source
compute_partial_variance <- function(vary_idx, consumption_draws, earnings_draws,
                                      spillover_draws, vat_coverage_draws,
                                      informality_draws, admin_cost_draws, params) {
  n <- length(consumption_draws)
  partial_mvpf <- numeric(n)
  for (i in 1:n) {
    p <- params
    if (1 %in% vary_idx) p$admin_cost_rate <- admin_cost_draws[i]
    c_eff <- if (2 %in% vary_idx) consumption_draws[i] else consumption_effect
    e_eff <- if (3 %in% vary_idx) earnings_draws[i] else earnings_effect
    if (4 %in% vary_idx) p$vat_coverage <- vat_coverage_draws[i]
    if (5 %in% vary_idx) p$informal_share <- informality_draws[i]
    result <- calculate_mvpf(c_eff, e_eff, include_spillovers = FALSE, params = p)
    partial_mvpf[i] <- result$mvpf
  }
  var(partial_mvpf)
}

total_var <- var(mvpf_direct_draws)
var_treatment <- compute_partial_variance(c(2, 3), consumption_draws, earnings_draws,
                                           spillover_draws, vat_coverage_draws,
                                           informality_draws, admin_cost_draws, params)
var_vat_cov <- compute_partial_variance(4, consumption_draws, earnings_draws,
                                         spillover_draws, vat_coverage_draws,
                                         informality_draws, admin_cost_draws, params)
var_informal <- compute_partial_variance(5, consumption_draws, earnings_draws,
                                          spillover_draws, vat_coverage_draws,
                                          informality_draws, admin_cost_draws, params)
var_admin <- compute_partial_variance(1, consumption_draws, earnings_draws,
                                       spillover_draws, vat_coverage_draws,
                                       informality_draws, admin_cost_draws, params)

# Shares (may not sum to 1 due to interactions)
sum_partial <- var_treatment + var_vat_cov + var_informal + var_admin

variance_decomp <- tibble(
  source = c("Treatment effects", "VAT coverage", "Informality share", "Admin cost rate", "Interactions"),
  variance = c(var_treatment, var_vat_cov, var_informal, var_admin, total_var - sum_partial),
  share_pct = c(var_treatment, var_vat_cov, var_informal, var_admin, total_var - sum_partial) / total_var * 100
)

cat("Total MVPF variance:", round(total_var, 8), "\n")
print(variance_decomp %>% mutate(across(where(is.numeric), ~round(., 4))))

# Component-level SEs and CIs
component_uncertainty <- tibble(
  component = c("WTP (direct)", "FE (VAT)", "FE (income tax)", "Net cost", "WTP (spillover)"),
  point_estimate = c(mvpf_direct$wtp_direct, mvpf_direct$vat_externality,
                     mvpf_direct$income_tax_externality, mvpf_direct$net_cost,
                     mvpf_with_spillovers$wtp_total - mvpf_with_spillovers$wtp_direct),
  se = c(sd(wtp_direct_draws), sd(vat_ext_draws), sd(income_ext_draws),
         sd(net_cost_draws), sd(wtp_spillover_draws)),
  ci_lower = c(quantile(wtp_direct_draws, 0.025), quantile(vat_ext_draws, 0.025),
               quantile(income_ext_draws, 0.025), quantile(net_cost_draws, 0.025),
               quantile(wtp_spillover_draws, 0.025)),
  ci_upper = c(quantile(wtp_direct_draws, 0.975), quantile(vat_ext_draws, 0.975),
               quantile(income_ext_draws, 0.975), quantile(net_cost_draws, 0.975),
               quantile(wtp_spillover_draws, 0.975))
)

cat("\nComponent-level uncertainty:\n")
print(component_uncertainty %>% mutate(across(where(is.numeric), ~round(., 2))))

mvpf_results <- list(
  # Point estimates
  mvpf_direct = mvpf_direct$mvpf,
  mvpf_with_spillovers = mvpf_with_spillovers$mvpf,

  # Confidence intervals
  ci_direct_lower = ci_direct[1],
  ci_direct_upper = ci_direct[2],
  ci_spillover_lower = ci_spillover[1],
  ci_spillover_upper = ci_spillover[2],

  # Components
  wtp_direct = mvpf_direct$wtp_direct,
  wtp_spillover = mvpf_with_spillovers$wtp_spillover,
  gross_cost = mvpf_direct$gross_cost,
  vat_externality = mvpf_direct$vat_externality,
  income_tax_externality = mvpf_direct$income_tax_externality,
  net_cost = mvpf_direct$net_cost,

  # Simulation draws (for robustness)
  mvpf_direct_draws = mvpf_direct_draws,
  mvpf_spillover_draws = mvpf_spillover_draws,

  # Component draws for downstream use
  wtp_direct_draws = wtp_direct_draws,
  vat_ext_draws = vat_ext_draws,
  income_ext_draws = income_ext_draws,
  net_cost_draws = net_cost_draws,
  wtp_spillover_draws = wtp_spillover_draws,

  # Variance decomposition
  variance_decomp = variance_decomp,
  component_uncertainty = component_uncertainty,

  # Fiscal parameter draws (for verification)
  fiscal_param_draws = list(
    vat_coverage = vat_coverage_draws,
    informality = informality_draws,
    admin_cost = admin_cost_draws
  ),

  # Parameters used
  params = params,

  # Metadata
  timestamp = Sys.time(),
  methodology = "Calibration from published estimates (Haushofer & Shapiro 2016, Egger et al. 2022)"
)

saveRDS(mvpf_results, file.path(data_dir, "mvpf_results.rds"))

cat("\n\nResults saved to:", file.path(data_dir, "mvpf_results.rds"), "\n")
cat("\n", rep("=", 60), "\n")
cat("ANALYSIS COMPLETE\n")
cat(rep("=", 60), "\n")
