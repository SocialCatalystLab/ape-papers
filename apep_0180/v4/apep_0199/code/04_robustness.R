# ============================================================================
# 04_robustness.R - Sensitivity and robustness analysis
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load data
load("../data/kenya_uct_data.RData")
mvpf_results <- readRDS("../data/mvpf_results.rds")

# Extract key values from main results
wtp_direct <- mvpf_results$wtp_direct
wtp_total <- wtp_direct + mvpf_results$wtp_spillover
pv_vat <- mvpf_results$vat_externality
pv_income_tax <- mvpf_results$income_tax_externality
net_cost <- mvpf_results$net_cost
mvpf_direct_no_mcpf <- mvpf_results$mvpf_direct

params <- mvpf_results$params

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY ANALYSIS\n")
cat(rep("=", 60), "\n\n")

cat("Baseline MVPF:", round(mvpf_direct_no_mcpf, 3), "\n")

# -----------------------------------------------------------------------------
# Sensitivity Analysis 1: MCPF Values
# -----------------------------------------------------------------------------

cat("\n=== SENSITIVITY: MARGINAL COST OF PUBLIC FUNDS ===\n\n")

mcpf_values <- c(1.0, 1.1, 1.2, 1.3, 1.5, 2.0)

mcpf_sensitivity <- tibble(mcpf = mcpf_values) %>%
  mutate(
    net_cost_adjusted = net_cost * mcpf,
    mvpf_direct = wtp_direct / net_cost_adjusted,
    mvpf_total = wtp_total / net_cost_adjusted
  )

cat("MVPF by MCPF assumption:\n")
print(mcpf_sensitivity %>% mutate(across(where(is.numeric), ~round(., 3))))

# -----------------------------------------------------------------------------
# Sensitivity Analysis 2: Informality Share
# -----------------------------------------------------------------------------

cat("\n=== SENSITIVITY: INFORMALITY SHARE ===\n\n")

formality_scenarios <- tibble(
  scenario = c("Baseline (80%)", "High (90%)", "Medium (60%)", "Full formal (0%)"),
  informal_share = c(0.80, 0.90, 0.60, 0.00)
)

calc_pv_factor <- function(years, decay_rate, discount_rate) {
  pv <- 0
  for (t in 1:years) {
    pv <- pv + (1 - decay_rate)^(t-1) / (1 + discount_rate)^t
  }
  return(pv)
}

pv_earnings <- calc_pv_factor(params$earnings_persist_years,
                               params$earnings_decay,
                               params$discount_rate)

# Get earnings effect
earnings_effect <- haushofer_shapiro_effects %>%
  filter(outcome == "Non-agricultural revenue") %>%
  pull(treatment_effect)

formality_sensitivity <- formality_scenarios %>%
  rowwise() %>%
  mutate(
    formal_share = 1 - informal_share,
    earnings_usd = (earnings_effect / params$ppp_factor) * 12,
    pv_income_tax = params$income_tax_formal * formal_share * earnings_usd * pv_earnings,
    total_fiscal_ext = pv_vat + pv_income_tax,
    net_cost_new = 1000 - total_fiscal_ext,
    mvpf = wtp_direct / net_cost_new
  ) %>%
  ungroup() %>%
  select(scenario, informal_share, pv_income_tax, net_cost_new, mvpf)

cat("MVPF by informality scenario:\n")
print(formality_sensitivity %>% mutate(across(where(is.numeric), ~round(., 3))))

# -----------------------------------------------------------------------------
# Sensitivity Analysis 3: VAT Coverage Rate
# -----------------------------------------------------------------------------

cat("\n=== SENSITIVITY: VAT COVERAGE RATE ===\n\n")

vat_coverage_rates <- c(0.25, 0.50, 0.75, 1.00)

pv_consumption <- calc_pv_factor(params$consumption_persist_years,
                                  params$consumption_decay,
                                  params$discount_rate)

consumption_effect <- haushofer_shapiro_effects %>%
  filter(outcome == "Total consumption") %>%
  pull(treatment_effect)

vat_sensitivity <- tibble(vat_coverage = vat_coverage_rates) %>%
  rowwise() %>%
  mutate(
    consumption_usd = (consumption_effect / params$ppp_factor) * 12,
    pv_vat_new = params$vat_rate * vat_coverage * consumption_usd * pv_consumption,
    net_cost_new = 1000 - pv_vat_new - pv_income_tax,
    mvpf = wtp_direct / net_cost_new
  ) %>%
  ungroup() %>%
  select(vat_coverage, pv_vat_new, net_cost_new, mvpf)

cat("MVPF by VAT coverage rate:\n")
print(vat_sensitivity %>% mutate(across(where(is.numeric), ~round(., 3))))

# -----------------------------------------------------------------------------
# Sensitivity Analysis 4: Discount Rate
# -----------------------------------------------------------------------------

cat("\n=== SENSITIVITY: DISCOUNT RATE ===\n\n")

discount_rates <- c(0.03, 0.05, 0.07, 0.10)

discount_sensitivity <- tibble(discount_rate = discount_rates) %>%
  rowwise() %>%
  mutate(
    pv_c = calc_pv_factor(params$consumption_persist_years,
                          params$consumption_decay,
                          discount_rate),
    pv_e = calc_pv_factor(params$earnings_persist_years,
                          params$earnings_decay,
                          discount_rate),

    consumption_usd = (consumption_effect / params$ppp_factor) * 12,
    earnings_usd = (earnings_effect / params$ppp_factor) * 12,

    pv_vat_new = params$vat_rate * params$vat_coverage * consumption_usd * pv_c,
    pv_income_new = params$income_tax_formal * (1 - params$informal_share) * earnings_usd * pv_e,

    net_cost_new = 1000 - pv_vat_new - pv_income_new,
    mvpf = wtp_direct / net_cost_new
  ) %>%
  ungroup() %>%
  select(discount_rate, pv_vat_new, pv_income_new, net_cost_new, mvpf)

cat("MVPF by discount rate:\n")
print(discount_sensitivity %>% mutate(across(where(is.numeric), ~round(., 3))))

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SENSITIVITY SUMMARY\n")
cat(rep("=", 60), "\n\n")

all_mvpfs <- c(
  mcpf_sensitivity$mvpf_direct,
  formality_sensitivity$mvpf,
  vat_sensitivity$mvpf,
  discount_sensitivity$mvpf
)

cat(sprintf("Baseline MVPF:     %.3f\n", mvpf_direct_no_mcpf))
cat(sprintf("Range across all:  [%.3f, %.3f]\n", min(all_mvpfs), max(all_mvpfs)))
cat(sprintf("With MCPF = 1.3:   %.3f\n", mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.3]))
cat(sprintf("Full formality:    %.3f\n", formality_sensitivity$mvpf[formality_sensitivity$informal_share == 0]))

# Save results
save(
  mcpf_sensitivity,
  formality_sensitivity,
  vat_sensitivity,
  discount_sensitivity,
  file = "../data/robustness_results.RData"
)

cat("\nRobustness results saved to: ../data/robustness_results.RData\n")
