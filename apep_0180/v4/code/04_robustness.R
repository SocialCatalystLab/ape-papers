# ============================================================================
# 04_robustness.R - Sensitivity and robustness analysis (v4)
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")
load("../data/main_results.RData")

# ── Helper ─────────────────────────────────────────────────────────────────

pv_stream <- function(annual, years, retention, r) {
  # retention = gamma = fraction remaining each year
  sum(annual * retention^(0:(years - 1)) / (1 + r)^(1:years))
}

# ── 1. Persistence: linear, exponential, and hyperbolic decay ─────────────

cat("\n=== SENSITIVITY 1: PERSISTENCE & DECAY MODELS ===\n\n")

calc_mvpf_persistence <- function(years, retention, decay_type = "geometric") {
  # retention = gamma = annual retention rate (fraction remaining each year)
  cons_usd <- consumption_gain_usd
  wage_usd <- wage_gain_usd
  r <- kenya_fiscal$discount_rate

  # Different decay functions (all parameterized by retention rate)
  decay_fn <- switch(decay_type,
    "geometric" = function(t) retention^(t - 1),
    "exponential" = function(t) exp(-(1 - retention) * (t - 1)),
    "hyperbolic" = function(t) 1 / (1 + (1 - retention) * (t - 1))
  )

  pv_vat <- sum(sapply(1:years, function(t)
    cons_usd * 0.16 * 0.50 * decay_fn(t) / (1 + r)^t))

  pv_inc <- sum(sapply(1:years, function(t)
    wage_usd * 0.185 * 0.20 * decay_fn(min(t, 5)) / (1 + r)^t))

  net <- 1000 - pv_vat - pv_inc
  wtp_direct / net
}

# Retention rates: 0.23 (fast, conservative), 0.48 (baseline from empirical), 0.75 (slow)
persistence_grid <- expand.grid(
  years = c(1, 3, 5, 10),
  retention = c(0.23, 0.48, 0.75),
  decay_type = c("geometric", "exponential", "hyperbolic"),
  stringsAsFactors = FALSE
)

persistence_results <- persistence_grid %>%
  rowwise() %>%
  mutate(mvpf = calc_mvpf_persistence(years, retention, decay_type)) %>%
  ungroup()

cat("Persistence × Decay Model (baseline retention = 0.48):\n")
persistence_results %>%
  filter(retention == 0.48) %>%
  pivot_wider(names_from = decay_type, values_from = mvpf) %>%
  mutate(across(where(is.numeric) & !matches("years|retention"), ~round(., 3))) %>%
  print()

# ── 2. Tax Incidence ─────────────────────────────────────────────────────

cat("\n=== SENSITIVITY 2: INFORMALITY ===\n\n")

formality_scenarios <- tibble(
  scenario = c("Baseline (80%)", "Conservative (90%)", "Optimistic (60%)", "Full formality"),
  informal_share = c(0.80, 0.90, 0.60, 0.00)
) %>%
  rowwise() %>%
  mutate(
    formal = 1 - informal_share,
    annual_income_tax = wage_gain_usd * 0.185 * formal,
    pv_income_tax_new = pv_stream(annual_income_tax, 5, 0.25, 0.05),
    net_cost_new = 1000 - pv_vat - pv_income_tax_new,
    mvpf = wtp_direct / net_cost_new
  ) %>%
  ungroup()

print(formality_scenarios %>% dplyr::select(scenario, informal_share, annual_income_tax, mvpf))

# ── 3. Discount Rate ────────────────────────────────────────────────────

cat("\n=== SENSITIVITY 3: DISCOUNT RATE ===\n\n")

discount_sensitivity <- tibble(discount_rate = c(0.03, 0.05, 0.07, 0.10)) %>%
  rowwise() %>%
  mutate(
    pv_vat_new = pv_stream(vat_annual, 3, consumption_retention, discount_rate),
    pv_inc_new = pv_stream(income_tax_annual, 5, earnings_retention, discount_rate),
    net_cost_new = 1000 - pv_vat_new - pv_inc_new,
    mvpf = wtp_direct / net_cost_new
  ) %>%
  ungroup()

print(discount_sensitivity %>% dplyr::select(discount_rate, pv_vat_new, pv_inc_new, mvpf))

# ── 4. MCPF ─────────────────────────────────────────────────────────────

cat("\n=== SENSITIVITY 4: MCPF ===\n\n")

mcpf_sensitivity <- tibble(mcpf = c(1.0, 1.1, 1.2, 1.3, 1.5, 2.0)) %>%
  mutate(
    mvpf_direct = wtp_direct / (net_cost * mcpf),
    mvpf_total = wtp_total / (net_cost * mcpf)
  )

print(mcpf_sensitivity)

# ── 5. VAT Coverage ─────────────────────────────────────────────────────

cat("\n=== SENSITIVITY 5: VAT COVERAGE ===\n\n")

vat_sensitivity <- tibble(vat_coverage = c(0.25, 0.38, 0.50, 0.75, 1.00)) %>%
  rowwise() %>%
  mutate(
    vat_annual_new = consumption_gain_usd * 0.16 * vat_coverage,
    pv_vat_new = pv_stream(vat_annual_new, 3, consumption_retention, 0.05),
    net_cost_new = 1000 - pv_vat_new - pv_income_tax,
    mvpf = wtp_direct / net_cost_new,
    source_note = case_when(
      vat_coverage == 0.38 ~ "Bachas et al. (2022) implied",
      vat_coverage == 0.50 ~ "Baseline",
      TRUE ~ ""
    )
  ) %>%
  ungroup()

print(vat_sensitivity %>% dplyr::select(vat_coverage, pv_vat_new, mvpf, source_note))

# ── 6. Pecuniary vs. Real Spillovers ────────────────────────────────────

cat("\n=== SENSITIVITY 6: PECUNIARY SPILLOVER SHARE ===\n\n")

# If some spillovers are pecuniary (transfers between agents, not real gains),
# they should not count toward social welfare
pecuniary_sensitivity <- tibble(
  pecuniary_share = c(0, 0.25, 0.50, 0.75, 1.00)
) %>%
  mutate(
    real_spillover = wtp_spillover_per_recipient * (1 - pecuniary_share),
    mvpf = (wtp_direct + real_spillover) / net_cost
  )

print(pecuniary_sensitivity)

# ── 7. Bounding Exercise ────────────────────────────────────────────────

cat("\n=== BOUNDING EXERCISE ===\n\n")

# Lower bound: pessimistic on everything
# retention = 0.23 (fast decay), 1 year, high discount, low coverage
lb_net <- 1000 - pv_stream(consumption_gain_usd * 0.16 * 0.25, 1, 0.23, 0.10) -
          pv_stream(wage_gain_usd * 0.185 * 0.10, 1, 0.50, 0.10)
mvpf_lower <- (wtp_direct * 0.85) / (lb_net * 1.5)  # WTP<1 + high MCPF

# Upper bound: optimistic — high retention, long persistence, low discount
ub_net <- 1000 - pv_stream(consumption_gain_usd * 0.16 * 0.75, 10, 0.75, 0.03) -
          pv_stream(wage_gain_usd * 0.185 * 0.40, 10, 0.85, 0.03)
mvpf_upper <- wtp_total / ub_net

cat("Lower bound:", round(mvpf_lower, 2), "(1yr, 90% informal, MCPF=1.5, WTP=0.85)\n")
cat("Upper bound:", round(mvpf_upper, 2), "(10yr, 60% informal, with spillovers)\n")
cat("Central:", round(as.numeric(mvpf_direct_no_mcpf), 2), "\n")

# ── Combined Summary ────────────────────────────────────────────────────

sensitivity_summary <- tibble(
  parameter = c(
    "Baseline",
    "Persistence: 1 year", "Persistence: 10 years",
    "Decay: exponential", "Decay: hyperbolic",
    "High informality (90%)", "Low informality (60%)",
    "Discount: 3%", "Discount: 10%",
    "MCPF: 1.0", "MCPF: 1.5",
    "VAT coverage: 25%", "VAT coverage: 75%",
    "Pecuniary spillovers: 50%",
    "WTP ratio: 0.90",
    "Lower bound", "Upper bound"
  ),
  mvpf = round(c(
    as.numeric(mvpf_direct_no_mcpf),
    persistence_results$mvpf[persistence_results$years == 1 & persistence_results$retention == 0.48 & persistence_results$decay_type == "geometric"],
    persistence_results$mvpf[persistence_results$years == 10 & persistence_results$retention == 0.48 & persistence_results$decay_type == "geometric"],
    persistence_results$mvpf[persistence_results$years == 3 & persistence_results$retention == 0.48 & persistence_results$decay_type == "exponential"],
    persistence_results$mvpf[persistence_results$years == 3 & persistence_results$retention == 0.48 & persistence_results$decay_type == "hyperbolic"],
    formality_scenarios$mvpf[formality_scenarios$informal_share == 0.90],
    formality_scenarios$mvpf[formality_scenarios$informal_share == 0.60],
    discount_sensitivity$mvpf[discount_sensitivity$discount_rate == 0.03],
    discount_sensitivity$mvpf[discount_sensitivity$discount_rate == 0.10],
    mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.0],
    mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.5],
    vat_sensitivity$mvpf[vat_sensitivity$vat_coverage == 0.25],
    vat_sensitivity$mvpf[vat_sensitivity$vat_coverage == 0.75],
    pecuniary_sensitivity$mvpf[pecuniary_sensitivity$pecuniary_share == 0.50],
    wtp_direct * 0.90 / net_cost,
    mvpf_lower, mvpf_upper
  ), 3)
) %>%
  mutate(change_pct = round((mvpf - mvpf[1]) / mvpf[1] * 100, 1))

cat("\n=== COMBINED SENSITIVITY ===\n")
print(sensitivity_summary, n = Inf)

# ── Save ────────────────────────────────────────────────────────────────

save(
  persistence_results, formality_scenarios, discount_sensitivity,
  mcpf_sensitivity, vat_sensitivity, pecuniary_sensitivity,
  sensitivity_summary, mvpf_lower, mvpf_upper,
  file = "../data/robustness_results.RData"
)

cat("\nSaved to ../data/robustness_results.RData\n")
