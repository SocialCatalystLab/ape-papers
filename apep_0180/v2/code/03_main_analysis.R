# ============================================================================
# 03_main_analysis.R - Calculate MVPF and conduct main analysis
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load cleaned data
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")

# -----------------------------------------------------------------------------
# Main MVPF Calculation
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("MAIN MVPF CALCULATION\n")
cat(rep("=", 60), "\n\n")

# Specification 1: Direct recipients only, no MCPF adjustment
# This is the most conservative/comparable specification
mvpf_direct_no_mcpf <- wtp_direct / net_cost
cat("MVPF (direct WTP, no MCPF):", round(mvpf_direct_no_mcpf, 2), "\n")

# Specification 2: Direct recipients, MCPF-adjusted
mvpf_direct_mcpf <- wtp_direct / net_cost_mcpf
cat("MVPF (direct WTP, MCPF=1.3):", round(mvpf_direct_mcpf, 2), "\n")

# Specification 3: Including spillovers, no MCPF
mvpf_total_no_mcpf <- wtp_total / net_cost
cat("MVPF (total WTP, no MCPF):", round(mvpf_total_no_mcpf, 2), "\n")

# Specification 4: Including spillovers, MCPF-adjusted
mvpf_total_mcpf <- wtp_total / net_cost_mcpf
cat("MVPF (total WTP, MCPF=1.3):", round(mvpf_total_mcpf, 2), "\n")

# -----------------------------------------------------------------------------
# Bootstrap confidence intervals
# -----------------------------------------------------------------------------

# Function to calculate MVPF with parameter uncertainty
calc_mvpf_bootstrap <- function(
    wtp_direct_draw,
    spillover_draw,
    vat_draw,
    income_tax_draw,
    gross_cost = 1000,
    mcpf = 1.0,
    include_spillover = FALSE
) {

  wtp <- wtp_direct_draw
  if (include_spillover) {
    wtp <- wtp + spillover_draw
  }

  fiscal_ext <- vat_draw + income_tax_draw
  net_cost <- (gross_cost - fiscal_ext) * mcpf

  return(wtp / net_cost)
}

# Bootstrap parameters (using normal approximation from SEs)
set.seed(42)
n_boot <- 1000

# Draw from sampling distributions
# WTP direct: fixed (cash transfer)
wtp_direct_draws <- rep(wtp_direct, n_boot)

# Spillover WTP: uncertain
spillover_draws <- rnorm(n_boot,
                         mean = wtp_spillover_per_recipient,
                         sd = egger_ge_effects$nonrecipient_se[1] * 0.5)  # Per recipient

# VAT: depends on consumption effect
consumption_se <- egger_ge_effects$recipient_se[1] / kenya_fiscal$ppp_factor
vat_draws <- rnorm(n_boot,
                   mean = pv_vat,
                   sd = consumption_se * kenya_fiscal$vat_rate * 0.5 * 3)  # 3-year PV

# Income tax: depends on earnings effect
earnings_se <- egger_ge_effects$recipient_se[egger_ge_effects$outcome == "Wage earnings"] / kenya_fiscal$ppp_factor
income_tax_draws <- rnorm(n_boot,
                          mean = pv_income_tax,
                          sd = earnings_se * kenya_fiscal$income_tax_formal * (1 - kenya_fiscal$informal_share) * 5)

# Calculate bootstrap MVPFs
mvpf_boot_direct <- mapply(calc_mvpf_bootstrap,
                           wtp_direct_draws, spillover_draws, vat_draws, income_tax_draws,
                           MoreArgs = list(gross_cost = 1000, mcpf = 1.0, include_spillover = FALSE))

mvpf_boot_total <- mapply(calc_mvpf_bootstrap,
                          wtp_direct_draws, spillover_draws, vat_draws, income_tax_draws,
                          MoreArgs = list(gross_cost = 1000, mcpf = 1.0, include_spillover = TRUE))

mvpf_boot_mcpf <- mapply(calc_mvpf_bootstrap,
                         wtp_direct_draws, spillover_draws, vat_draws, income_tax_draws,
                         MoreArgs = list(gross_cost = 1000, mcpf = 1.3, include_spillover = FALSE))

mvpf_boot_total_mcpf <- mapply(calc_mvpf_bootstrap,
                               wtp_direct_draws, spillover_draws, vat_draws, income_tax_draws,
                               MoreArgs = list(gross_cost = 1000, mcpf = 1.3, include_spillover = TRUE))

# Calculate confidence intervals
ci_direct <- quantile(mvpf_boot_direct, probs = c(0.025, 0.975))
ci_total <- quantile(mvpf_boot_total, probs = c(0.025, 0.975))
ci_mcpf <- quantile(mvpf_boot_mcpf, probs = c(0.025, 0.975))
ci_total_mcpf <- quantile(mvpf_boot_total_mcpf, probs = c(0.025, 0.975))

cat("\n95% Confidence Intervals:\n")
cat("MVPF (direct):", round(ci_direct[1], 2), "-", round(ci_direct[2], 2), "\n")
cat("MVPF (with spillovers):", round(ci_total[1], 2), "-", round(ci_total[2], 2), "\n")
cat("MVPF (MCPF-adjusted):", round(ci_mcpf[1], 2), "-", round(ci_mcpf[2], 2), "\n")
cat("MVPF (spillovers + MCPF):", round(ci_total_mcpf[1], 2), "-", round(ci_total_mcpf[2], 2), "\n")

# -----------------------------------------------------------------------------
# Comparison to US MVPF benchmarks
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("COMPARISON TO US MVPF BENCHMARKS\n")
cat(rep("=", 60), "\n\n")

# US cash transfer MVPFs from Hendren & Sprung-Keyser (2020)
us_benchmarks <- tibble::tribble(
  ~policy, ~mvpf, ~category, ~target,
  "EITC expansion (adults)", 0.92, "Tax credits", "Adults",
  "TANF (cash welfare)", 0.65, "Cash transfers", "Adults",
  "Food stamps (SNAP)", 0.76, "In-kind transfers", "Adults",
  "Medicaid (adults)", 1.20, "Health insurance", "Adults",
  "Head Start", 1.50, "Early childhood", "Children",
  "Medicaid (children)", Inf, "Health insurance", "Children",
  "Moving to Opportunity", Inf, "Housing", "Families"
)

# Add Kenya UCT to comparison
kenya_row <- tibble(
  policy = "Kenya UCT (GiveDirectly)",
  mvpf = mvpf_direct_no_mcpf,
  category = "Cash transfers",
  target = "Adults"
)

comparison_df <- bind_rows(us_benchmarks, kenya_row) %>%
  mutate(mvpf_display = ifelse(is.infinite(mvpf), "Inf", round(mvpf, 2)))

cat("Policy Comparison:\n")
comparison_df %>%
  filter(category == "Cash transfers" | policy == "EITC expansion (adults)") %>%
  select(policy, mvpf_display) %>%
  print()

# -----------------------------------------------------------------------------
# Store main results
# -----------------------------------------------------------------------------

main_results <- tibble(
  specification = c(
    "Direct WTP, no MCPF",
    "Direct WTP, MCPF=1.3",
    "Total WTP (with spillovers), no MCPF",
    "Total WTP (with spillovers), MCPF=1.3"
  ),
  mvpf = c(
    mvpf_direct_no_mcpf,
    mvpf_direct_mcpf,
    mvpf_total_no_mcpf,
    mvpf_total_mcpf
  ),
  ci_lower = c(ci_direct[1], ci_mcpf[1], ci_total[1], ci_total_mcpf[1]),
  ci_upper = c(ci_direct[2], ci_mcpf[2], ci_total[2], ci_total_mcpf[2]),
  wtp = c(wtp_direct, wtp_direct, wtp_total, wtp_total),
  net_cost = c(net_cost, net_cost_mcpf, net_cost, net_cost_mcpf)
)

# Save results
save(
  main_results,
  mvpf_direct_no_mcpf,
  mvpf_total_no_mcpf,
  mvpf_direct_mcpf,
  mvpf_total_mcpf,
  ci_direct,
  ci_total,
  ci_mcpf,
  ci_total_mcpf,
  comparison_df,
  file = "../data/main_results.RData"
)

cat("\n", rep("=", 60), "\n")
cat("MAIN RESULTS\n")
cat(rep("=", 60), "\n\n")

print(main_results, n = Inf)

cat("\n\nKey finding: Kenya UCT MVPF =", round(mvpf_direct_no_mcpf, 2),
    "(95% CI:", round(ci_direct[1], 2), "-", round(ci_direct[2], 2), ")\n")
cat("This is comparable to US cash transfers (EITC: 0.92, TANF: 0.65, SNAP: 0.76)\n")
cat("Including spillovers raises MVPF to", round(mvpf_total_no_mcpf, 2), "\n")
