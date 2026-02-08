# ============================================================================
# 02_clean_data.R - Clean and prepare data for MVPF calculation
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load raw data
load("../data/kenya_uct_data.RData")

# -----------------------------------------------------------------------------
# Construct MVPF-relevant variables
# -----------------------------------------------------------------------------

# Convert effects to annualized values for MVPF calculation
# Haushofer & Shapiro report monthly consumption; annualize

mvpf_inputs <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Total assets", "Non-agricultural revenue")) %>%
  mutate(
    # Annualize monthly flows
    annual_effect = case_when(
      outcome == "Total consumption" ~ treatment_effect * 12,
      outcome == "Non-agricultural revenue" ~ treatment_effect * 12,
      TRUE ~ treatment_effect  # Assets are stock
    ),
    annual_se = case_when(
      outcome == "Total consumption" ~ se * 12,
      outcome == "Non-agricultural revenue" ~ se * 12,
      TRUE ~ se
    )
  )

# -----------------------------------------------------------------------------
# Construct WTP components
# -----------------------------------------------------------------------------

# For cash transfers, WTP = transfer amount for infra-marginal recipients
# This is the standard MVPF assumption (Hendren & Sprung-Keyser 2020)

wtp_direct <- kenya_fiscal$transfer_amount_usd * (1 - kenya_fiscal$admin_cost_rate)
cat("Direct WTP (transfer net of admin):", wtp_direct, "USD\n")

# Calculate spillover WTP from Egger et al.
# Non-recipients in treatment villages gained consumption

spillover_consumption_gain <- egger_ge_effects %>%
  filter(outcome == "Consumption") %>%
  pull(nonrecipient_effect)

spillover_consumption_se <- egger_ge_effects %>%
  filter(outcome == "Consumption") %>%
  pull(nonrecipient_se)

# Number of non-recipient households in treatment villages
# From Egger et al.: ~50% of households in high-saturation villages were non-recipients
# 328 high-sat villages × ~150 HH/village × 0.33 non-recipient rate
n_spillover_hh <- study_design$egger_high_sat_villages * 150 * 0.33

# But we express spillover WTP per recipient for comparability
# Spillover recipients per treated HH in high-saturation areas
spillover_ratio <- (1 - study_design$high_saturation_rate) / study_design$high_saturation_rate

# Convert spillover gains from PPP to USD and scale by ratio
# Note: PPP values are already welfare-adjusted, so we convert for USD comparability
spillover_consumption_gain_usd <- spillover_consumption_gain / kenya_fiscal$ppp_factor
spillover_consumption_se_usd <- spillover_consumption_se / kenya_fiscal$ppp_factor

wtp_spillover_per_recipient <- spillover_consumption_gain_usd * spillover_ratio
wtp_spillover_se <- spillover_consumption_se_usd * spillover_ratio

cat("Spillover WTP per recipient:", wtp_spillover_per_recipient, "USD (SE:", wtp_spillover_se, ")\n")

# Total WTP (direct + spillover)
wtp_total <- wtp_direct + wtp_spillover_per_recipient
cat("Total WTP:", wtp_total, "USD\n")

# -----------------------------------------------------------------------------
# Construct fiscal externality components
# -----------------------------------------------------------------------------

# 1. VAT on consumption increase
# Recipients increase consumption by $35 PPP/month (Haushofer & Shapiro 2016)
# Using H&S recipient effects for fiscal externalities to avoid double-counting
# with GE spillovers (which enter the numerator as non-recipient WTP)

consumption_gain_monthly_ppp <- haushofer_shapiro_effects %>%
  filter(outcome == "Total consumption") %>%
  pull(treatment_effect)

# Annualize and convert to USD (divide by PPP factor)
consumption_gain_ppp <- consumption_gain_monthly_ppp * 12
consumption_gain_usd <- consumption_gain_ppp / kenya_fiscal$ppp_factor

# VAT revenue (assumes all consumption is taxable at standard rate)
# In practice, many goods are exempt - use 50% coverage as baseline
vat_coverage <- 0.50
vat_annual <- consumption_gain_usd * kenya_fiscal$vat_rate * vat_coverage

# Present value of VAT over persistence period
# Use long-term persistence ratio from Haushofer & Shapiro (2018)
persistence_years <- 3  # Baseline assumption
decay_rate <- 1 - longterm_effects$persistence_ratio[longterm_effects$outcome == "Consumption"]

# Simple geometric decay PV calculation
pv_vat <- 0
for (t in 1:persistence_years) {
  pv_vat <- pv_vat + vat_annual * (1 - decay_rate)^(t-1) / (1 + kenya_fiscal$discount_rate)^t
}

cat("Annual VAT revenue:", vat_annual, "USD\n")
cat("PV of VAT (", persistence_years, " years):", pv_vat, "USD\n")

# 2. Income tax on earnings increase
# Non-agricultural revenue increased by $17 PPP/month (Haushofer & Shapiro 2016)
# Using H&S recipient effects for fiscal externalities (consistent with VAT above)
# But ~80% of rural Kenya is informal, so effective tax rate is low

wage_gain_monthly_ppp <- haushofer_shapiro_effects %>%
  filter(outcome == "Non-agricultural revenue") %>%
  pull(treatment_effect)

# Annualize and convert to USD
wage_gain_ppp <- wage_gain_monthly_ppp * 12
wage_gain_usd <- wage_gain_ppp / kenya_fiscal$ppp_factor

# Effective income tax (weighted by formality)
formal_share <- 1 - kenya_fiscal$informal_share
effective_income_tax <- wage_gain_usd * kenya_fiscal$income_tax_formal * formal_share

# PV of income tax (assume earnings persist longer than consumption)
earnings_persistence <- 5  # years
pv_income_tax <- 0
for (t in 1:earnings_persistence) {
  pv_income_tax <- pv_income_tax + effective_income_tax / (1 + kenya_fiscal$discount_rate)^t
}

cat("Annual income tax revenue:", effective_income_tax, "USD\n")
cat("PV of income tax (", earnings_persistence, " years):", pv_income_tax, "USD\n")

# 3. Reduced future transfer dependency (speculative)
# Asset accumulation may reduce need for future transfers
# This is difficult to estimate without long-run data on welfare receipt
# We conservatively set this to zero in baseline

transfer_savings <- 0

# -----------------------------------------------------------------------------
# Calculate net government cost
# -----------------------------------------------------------------------------

gross_cost <- kenya_fiscal$transfer_amount_usd
fiscal_externalities <- pv_vat + pv_income_tax + transfer_savings
net_cost <- gross_cost - fiscal_externalities

cat("\n=== Net Cost Calculation ===\n")
cat("Gross transfer:", gross_cost, "USD\n")
cat("Less: VAT recapture:", pv_vat, "USD\n")
cat("Less: Income tax:", pv_income_tax, "USD\n")
cat("Less: Transfer savings:", transfer_savings, "USD\n")
cat("= Net cost:", net_cost, "USD\n")

# Adjust for MCPF if government-financed
net_cost_mcpf <- net_cost * kenya_fiscal$mcpf_baseline
cat("Net cost (MCPF-adjusted):", net_cost_mcpf, "USD\n")

# -----------------------------------------------------------------------------
# Create clean analysis dataset
# -----------------------------------------------------------------------------

mvpf_components <- tibble(
  component = c(
    "WTP_direct",
    "WTP_spillover",
    "WTP_total",
    "Gross_cost",
    "Fiscal_VAT",
    "Fiscal_income_tax",
    "Fiscal_transfer_savings",
    "Net_cost",
    "Net_cost_MCPF"
  ),
  value = c(
    wtp_direct,
    wtp_spillover_per_recipient,
    wtp_total,
    gross_cost,
    pv_vat,
    pv_income_tax,
    transfer_savings,
    net_cost,
    net_cost_mcpf
  ),
  description = c(
    "Transfer amount net of admin costs",
    "Non-recipient consumption gains (per recipient)",
    "Direct + spillover WTP",
    "Transfer amount ($1000)",
    "PV of VAT on consumption gains",
    "PV of income tax on earnings gains",
    "Reduced future transfer needs",
    "Gross cost - fiscal externalities",
    "Net cost × MCPF (1.3)"
  )
)

# Save cleaned data
save(
  mvpf_inputs,
  mvpf_components,
  wtp_direct,
  wtp_spillover_per_recipient,
  wtp_total,
  gross_cost,
  fiscal_externalities,
  net_cost,
  net_cost_mcpf,
  pv_vat,
  pv_income_tax,
  file = "../data/mvpf_clean.RData"
)

cat("\n=== MVPF Components ===\n")
print(mvpf_components, n = Inf)
cat("\nCleaned data saved to: ../data/mvpf_clean.RData\n")
