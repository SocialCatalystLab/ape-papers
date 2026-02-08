# ============================================================================
# 02_clean_data.R - Construct MVPF components from treatment effects
# MVPF of Unconditional Cash Transfers in Kenya (v4)
# ============================================================================

source("00_packages.R")
load("../data/kenya_uct_data.RData")

# ── Helper: PV of decaying stream ──────────────────────────────────────────

pv_decaying_stream <- function(annual_value, years, retention_rate, discount_rate) {
  # PV = sum_{t=1}^{T} value * gamma^{t-1} / (1 + r)^t
  # where gamma = annual retention rate (fraction remaining each year)
  # Convention: t=1 is first year (full initial effect); t=T is final year
  pv <- 0
  for (t in 1:years) {
    pv <- pv + annual_value * retention_rate^(t - 1) / (1 + discount_rate)^t
  }
  pv
}

# ── WTP: Direct recipients ─────────────────────────────────────────────────
# → Table 4, Panel A, Row 1

wtp_direct <- kenya_fiscal$transfer_amount_usd * (1 - kenya_fiscal$admin_cost_rate)
cat("Direct WTP (transfer net of 15% admin):", wtp_direct, "USD\n")

# ── WTP: Spillover to non-recipients ──────────────────────────────────────
# → Table 4, Panel A, Row 2
#
# In high-saturation villages (Egger et al.), 2/3 of households are treated.
# The remaining 1/3 are non-recipients who experience spillover gains.
# Per treated household, the spillover ratio = (1 - 2/3) / (2/3) = 0.5,
# meaning each recipient "generates" spillover benefits for 0.5 non-recipients.

spillover_consumption_ppp <- egger_ge_effects$nonrecipient_effect[
  egger_ge_effects$outcome == "Consumption"
]
spillover_consumption_se_ppp <- egger_ge_effects$nonrecipient_se[
  egger_ge_effects$outcome == "Consumption"
]

spillover_ratio <- (1 - study_design$high_saturation_rate) /
                    study_design$high_saturation_rate  # = 0.5

spillover_consumption_usd <- spillover_consumption_ppp / kenya_fiscal$ppp_factor
spillover_consumption_se_usd <- spillover_consumption_se_ppp / kenya_fiscal$ppp_factor

wtp_spillover_per_recipient <- spillover_consumption_usd * spillover_ratio
wtp_spillover_se <- spillover_consumption_se_usd * spillover_ratio

cat("Spillover WTP per recipient:", round(wtp_spillover_per_recipient, 1),
    "USD (SE:", round(wtp_spillover_se, 1), ")\n")

wtp_total <- wtp_direct + wtp_spillover_per_recipient

# ── Fiscal Externality 1: VAT on recipient consumption ────────────────────
# → Table 5, Panel B, Row 1

consumption_gain_ppp <- egger_ge_effects$recipient_effect[
  egger_ge_effects$outcome == "Consumption"
]
consumption_gain_usd <- consumption_gain_ppp / kenya_fiscal$ppp_factor

vat_annual <- consumption_gain_usd * kenya_fiscal$vat_rate * kenya_fiscal$vat_coverage

# Consumption retention: Haushofer & Shapiro (2018) find effect at 23% of initial after 3 years
# With t=1 = initial, t=3 = 3-year follow-up: gamma^2 = 0.23 => gamma = sqrt(0.23) ≈ 0.48
consumption_persistence_3yr <- longterm_effects$persistence_ratio[
  longterm_effects$outcome == "Consumption"
]
consumption_retention <- sqrt(consumption_persistence_3yr)  # = 0.48
cat("Consumption: 3yr persistence =", consumption_persistence_3yr,
    "→ annual retention gamma =", round(consumption_retention, 3), "\n")

pv_vat <- pv_decaying_stream(vat_annual, 3, consumption_retention, kenya_fiscal$discount_rate)

cat("VAT: annual =", round(vat_annual, 2), "→ PV (3yr) =", round(pv_vat, 2), "USD\n")

# ── Fiscal Externality 2: Income tax on recipient earnings ────────────────
# → Table 5, Panel B, Row 2

wage_gain_ppp <- egger_ge_effects$recipient_effect[
  egger_ge_effects$outcome == "Wage earnings"
]
wage_gain_usd <- wage_gain_ppp / kenya_fiscal$ppp_factor

formal_share <- 1 - kenya_fiscal$informal_share
income_tax_annual <- wage_gain_usd * kenya_fiscal$income_tax_formal * formal_share

# Earnings persist longer than consumption (tied to durable asset accumulation)
# Asset effects at 60% of initial after 3 years → gamma^2 = 0.60 → gamma = 0.775
# Use gamma_E = 0.75 (conservative) over 5 years
earnings_retention <- 0.75
pv_income_tax <- pv_decaying_stream(income_tax_annual, 5, earnings_retention,
                                     kenya_fiscal$discount_rate)

cat("Income tax: annual =", round(income_tax_annual, 2),
    "→ PV (5yr) =", round(pv_income_tax, 2), "USD\n")

# ── NEW: Fiscal Externality 3: VAT on non-recipient consumption ──────────
# → Table 5, Panel B, Row 3 (new in v4)
#
# Non-recipients in treatment villages increase consumption by $245 PPP/yr.
# This additional spending also generates VAT revenue. Prior versions
# excluded this channel; we include it as a robustness extension.

nonrecipient_consumption_usd <- spillover_consumption_ppp / kenya_fiscal$ppp_factor
nonrecipient_vat_annual <- nonrecipient_consumption_usd * kenya_fiscal$vat_rate *
                           kenya_fiscal$vat_coverage

# Scale per recipient using spillover ratio
nonrecipient_vat_per_recipient <- nonrecipient_vat_annual * spillover_ratio

# Same persistence as recipient consumption
pv_nonrecipient_vat <- pv_decaying_stream(nonrecipient_vat_per_recipient, 3,
                                           consumption_retention, kenya_fiscal$discount_rate)

cat("Non-recipient VAT per recipient: annual =", round(nonrecipient_vat_per_recipient, 2),
    "→ PV =", round(pv_nonrecipient_vat, 2), "USD\n")

# ── Net Government Cost ───────────────────────────────────────────────────
# → Table 5, Panel C

gross_cost <- kenya_fiscal$transfer_amount_usd

# Baseline: recipient FE only
fiscal_externalities_baseline <- pv_vat + pv_income_tax
net_cost <- gross_cost - fiscal_externalities_baseline

# Extended: including non-recipient FE
fiscal_externalities_extended <- fiscal_externalities_baseline + pv_nonrecipient_vat
net_cost_extended <- gross_cost - fiscal_externalities_extended

# MCPF-adjusted
net_cost_mcpf <- net_cost * kenya_fiscal$mcpf_baseline
net_cost_extended_mcpf <- net_cost_extended * kenya_fiscal$mcpf_baseline

cat("\n=== Net Cost ===\n")
cat("Gross transfer:", gross_cost, "\n")
cat("Recipient FE: VAT =", round(pv_vat, 2), "+ Income =", round(pv_income_tax, 2),
    "=", round(fiscal_externalities_baseline, 2), "\n")
cat("Net cost (baseline):", round(net_cost, 2), "\n")
cat("Non-recipient FE:", round(pv_nonrecipient_vat, 2), "\n")
cat("Net cost (extended):", round(net_cost_extended, 2), "\n")

# ── Store components ──────────────────────────────────────────────────────

mvpf_components <- tibble(
  component = c("WTP_direct", "WTP_spillover", "WTP_total",
                "Gross_cost", "Fiscal_VAT", "Fiscal_income_tax",
                "Fiscal_nonrecipient_VAT",
                "Net_cost", "Net_cost_extended", "Net_cost_MCPF"),
  value = c(wtp_direct, wtp_spillover_per_recipient, wtp_total,
            gross_cost, pv_vat, pv_income_tax,
            pv_nonrecipient_vat,
            net_cost, net_cost_extended, net_cost_mcpf),
  description = c("Transfer net of admin", "Non-recipient consumption gains (per recipient)",
                   "Direct + spillover WTP", "Transfer amount ($1000)",
                   "PV of VAT on recipient consumption", "PV of income tax on earnings",
                   "PV of VAT on non-recipient consumption",
                   "Gross - recipient FE", "Gross - all FE", "Net cost × MCPF")
)

mvpf_inputs <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Total assets", "Non-agricultural revenue")) %>%
  mutate(
    annual_effect = case_when(
      outcome %in% c("Total consumption", "Non-agricultural revenue") ~ treatment_effect * 12,
      TRUE ~ treatment_effect
    ),
    annual_se = case_when(
      outcome %in% c("Total consumption", "Non-agricultural revenue") ~ se * 12,
      TRUE ~ se
    )
  )

save(
  mvpf_inputs, mvpf_components,
  wtp_direct, wtp_spillover_per_recipient, wtp_spillover_se, wtp_total,
  gross_cost, fiscal_externalities_baseline, fiscal_externalities_extended,
  net_cost, net_cost_extended, net_cost_mcpf, net_cost_extended_mcpf,
  pv_vat, pv_income_tax, pv_nonrecipient_vat,
  vat_annual, income_tax_annual, nonrecipient_vat_per_recipient,
  consumption_gain_usd, wage_gain_usd, spillover_consumption_usd,
  consumption_retention, earnings_retention, spillover_ratio,
  file = "../data/mvpf_clean.RData"
)

cat("\nComponents saved to ../data/mvpf_clean.RData\n")
print(mvpf_components, n = Inf)
