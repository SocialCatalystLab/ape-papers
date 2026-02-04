# ============================================================================
# 04_robustness.R - Sensitivity and robustness analysis
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load data
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")
load("../data/main_results.RData")

# -----------------------------------------------------------------------------
# Sensitivity Analysis 1: Persistence Assumptions
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY 1: EFFECT PERSISTENCE\n")
cat(rep("=", 60), "\n\n")

# Function to calculate MVPF under different persistence assumptions
calc_mvpf_persistence <- function(persistence_years, decay_rate) {

  # Recalculate fiscal externalities
  consumption_gain_usd <- egger_ge_effects$recipient_effect[1] / kenya_fiscal$ppp_factor
  vat_coverage <- 0.50
  vat_annual <- consumption_gain_usd * kenya_fiscal$vat_rate * vat_coverage

  # PV of VAT
  pv_vat_new <- 0
  for (t in 1:persistence_years) {
    pv_vat_new <- pv_vat_new + vat_annual * (1 - decay_rate)^(t-1) / (1 + kenya_fiscal$discount_rate)^t
  }

  # Income tax (use same persistence for simplicity)
  wage_gain_usd <- egger_ge_effects$recipient_effect[egger_ge_effects$outcome == "Wage earnings"] / kenya_fiscal$ppp_factor
  formal_share <- 1 - kenya_fiscal$informal_share
  income_tax_annual <- wage_gain_usd * kenya_fiscal$income_tax_formal * formal_share

  pv_income_tax_new <- 0
  for (t in 1:persistence_years) {
    pv_income_tax_new <- pv_income_tax_new + income_tax_annual * (1 - decay_rate * 0.5)^(t-1) / (1 + kenya_fiscal$discount_rate)^t
  }

  # Net cost
  net_cost_new <- 1000 - pv_vat_new - pv_income_tax_new

  # MVPF
  mvpf <- wtp_direct / net_cost_new

  return(list(
    persistence_years = persistence_years,
    decay_rate = decay_rate,
    pv_vat = pv_vat_new,
    pv_income_tax = pv_income_tax_new,
    net_cost = net_cost_new,
    mvpf = mvpf
  ))
}

# Grid of persistence scenarios
persistence_scenarios <- expand.grid(
  persistence_years = c(1, 3, 5, 10),
  decay_rate = c(0.0, 0.25, 0.50, 0.77)  # 0.77 from H&S consumption decay
)

persistence_results <- persistence_scenarios %>%
  rowwise() %>%
  mutate(
    result = list(calc_mvpf_persistence(persistence_years, decay_rate)),
    mvpf = result$mvpf,
    net_cost = result$net_cost
  ) %>%
  ungroup() %>%
  select(persistence_years, decay_rate, mvpf, net_cost)

cat("MVPF by persistence assumption:\n")
persistence_results %>%
  mutate(mvpf = round(mvpf, 2)) %>%
  pivot_wider(names_from = decay_rate, values_from = mvpf, names_prefix = "decay_") %>%
  print()

# -----------------------------------------------------------------------------
# Sensitivity Analysis 2: Tax Incidence
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY 2: TAX INCIDENCE ASSUMPTIONS\n")
cat(rep("=", 60), "\n\n")

# Different formality assumptions
formality_scenarios <- tibble(
  scenario = c("Baseline (80% informal)", "Conservative (90% informal)",
               "Optimistic (60% informal)", "Full formality"),
  informal_share = c(0.80, 0.90, 0.60, 0.00)
)

tax_sensitivity <- formality_scenarios %>%
  rowwise() %>%
  mutate(
    # Recalculate income tax
    wage_gain = egger_ge_effects$recipient_effect[egger_ge_effects$outcome == "Wage earnings"] / kenya_fiscal$ppp_factor,
    annual_income_tax = wage_gain * kenya_fiscal$income_tax_formal * (1 - informal_share),
    pv_income_tax = annual_income_tax * 5 / (1 + kenya_fiscal$discount_rate)^2.5,  # Rough PV

    # Net cost and MVPF
    net_cost = 1000 - pv_vat - pv_income_tax,
    mvpf = wtp_direct / net_cost
  ) %>%
  select(scenario, informal_share, annual_income_tax, pv_income_tax, net_cost, mvpf)

cat("MVPF by tax incidence scenario:\n")
print(tax_sensitivity)

# -----------------------------------------------------------------------------
# Sensitivity Analysis 3: Discount Rate
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY 3: DISCOUNT RATE\n")
cat(rep("=", 60), "\n\n")

discount_rates <- c(0.03, 0.05, 0.07, 0.10)

discount_sensitivity <- tibble(discount_rate = discount_rates) %>%
  rowwise() %>%
  mutate(
    # Recalculate PV of fiscal externalities
    pv_factor = 1 / discount_rate * (1 - 1/(1 + discount_rate)^3),  # 3-year annuity factor

    # VAT
    consumption_gain = egger_ge_effects$recipient_effect[1] / kenya_fiscal$ppp_factor,
    vat_annual = consumption_gain * kenya_fiscal$vat_rate * 0.50,
    pv_vat_new = vat_annual * pv_factor,

    # Income tax
    wage_gain = egger_ge_effects$recipient_effect[egger_ge_effects$outcome == "Wage earnings"] / kenya_fiscal$ppp_factor,
    income_tax_annual = wage_gain * kenya_fiscal$income_tax_formal * 0.20,
    pv_income_tax_new = income_tax_annual * pv_factor * (5/3),  # Longer persistence

    # MVPF
    net_cost = 1000 - pv_vat_new - pv_income_tax_new,
    mvpf = wtp_direct / net_cost
  ) %>%
  select(discount_rate, pv_vat_new, pv_income_tax_new, net_cost, mvpf)

cat("MVPF by discount rate:\n")
print(discount_sensitivity)

# -----------------------------------------------------------------------------
# Sensitivity Analysis 4: MCPF Values
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY 4: MARGINAL COST OF PUBLIC FUNDS\n")
cat(rep("=", 60), "\n\n")

mcpf_values <- c(1.0, 1.1, 1.2, 1.3, 1.5, 2.0)

mcpf_sensitivity <- tibble(mcpf = mcpf_values) %>%
  mutate(
    net_cost_adjusted = net_cost * mcpf,
    mvpf_direct = wtp_direct / net_cost_adjusted,
    mvpf_total = wtp_total / net_cost_adjusted
  )

cat("MVPF by MCPF assumption:\n")
print(mcpf_sensitivity)

# -----------------------------------------------------------------------------
# Sensitivity Analysis 5: VAT Coverage Rate
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY 5: VAT COVERAGE RATE\n")
cat(rep("=", 60), "\n\n")

# Many goods in rural Kenya are exempt or untaxed
vat_coverage_rates <- c(0.25, 0.50, 0.75, 1.00)

vat_sensitivity <- tibble(vat_coverage = vat_coverage_rates) %>%
  rowwise() %>%
  mutate(
    consumption_gain = egger_ge_effects$recipient_effect[1] / kenya_fiscal$ppp_factor,
    vat_annual = consumption_gain * kenya_fiscal$vat_rate * vat_coverage,
    pv_vat_new = vat_annual * 3 / (1 + kenya_fiscal$discount_rate)^1.5,  # Rough 3-year PV
    net_cost = 1000 - pv_vat_new - pv_income_tax,
    mvpf = wtp_direct / net_cost
  ) %>%
  select(vat_coverage, vat_annual, pv_vat_new, net_cost, mvpf)

cat("MVPF by VAT coverage rate:\n")
print(vat_sensitivity)

# -----------------------------------------------------------------------------
# Combined sensitivity summary
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("COMBINED SENSITIVITY SUMMARY\n")
cat(rep("=", 60), "\n\n")

sensitivity_summary <- tibble(
  parameter = c(
    "Baseline",
    "Persistence: 1 year",
    "Persistence: 10 years",
    "High informality (90%)",
    "Low informality (60%)",
    "Discount: 3%",
    "Discount: 10%",
    "MCPF: 1.0",
    "MCPF: 1.5",
    "VAT coverage: 25%",
    "VAT coverage: 100%"
  ),
  mvpf = c(
    mvpf_direct_no_mcpf,
    persistence_results$mvpf[persistence_results$persistence_years == 1 & persistence_results$decay_rate == 0.50],
    persistence_results$mvpf[persistence_results$persistence_years == 10 & persistence_results$decay_rate == 0.50],
    tax_sensitivity$mvpf[tax_sensitivity$informal_share == 0.90],
    tax_sensitivity$mvpf[tax_sensitivity$informal_share == 0.60],
    discount_sensitivity$mvpf[discount_sensitivity$discount_rate == 0.03],
    discount_sensitivity$mvpf[discount_sensitivity$discount_rate == 0.10],
    mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.0],
    mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.5],
    vat_sensitivity$mvpf[vat_sensitivity$vat_coverage == 0.25],
    vat_sensitivity$mvpf[vat_sensitivity$vat_coverage == 1.00]
  )
) %>%
  mutate(
    mvpf = round(mvpf, 2),
    change_from_baseline = round((mvpf - mvpf_direct_no_mcpf) / mvpf_direct_no_mcpf * 100, 1)
  )

cat("Sensitivity of MVPF to parameter assumptions:\n")
print(sensitivity_summary, n = Inf)

cat("\nMVPF Range:", min(sensitivity_summary$mvpf), "-", max(sensitivity_summary$mvpf), "\n")
cat("Central estimate:", round(mvpf_direct_no_mcpf, 2), "\n")

# Save robustness results
save(
  persistence_results,
  tax_sensitivity,
  discount_sensitivity,
  mcpf_sensitivity,
  vat_sensitivity,
  sensitivity_summary,
  file = "../data/robustness_results.RData"
)

cat("\nRobustness results saved to: ../data/robustness_results.RData\n")
