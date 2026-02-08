# ============================================================================
# 06_tables.R - Generate all tables for the paper
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load data
load("../data/kenya_uct_data.RData")
mvpf_results <- readRDS("../data/mvpf_results.rds")
het_results <- readRDS("../data/heterogeneity_results.rds")
if (file.exists("../data/robustness_results.RData")) {
  load("../data/robustness_results.RData")
}

# Table output directory
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Table 1: Treatment Effects from Original Studies
# -----------------------------------------------------------------------------

table1 <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Food consumption", "Non-food consumption",
                        "Total assets", "Livestock", "Non-agricultural revenue",
                        "Psychological wellbeing index")) %>%
  mutate(
    stars = case_when(
      pvalue < 0.001 ~ "***",
      pvalue < 0.01 ~ "**",
      pvalue < 0.05 ~ "*",
      TRUE ~ ""
    ),
    effect_str = paste0(round(treatment_effect, 1), stars, "\n(", round(se, 1), ")"),
    control_str = round(control_mean, 1)
  ) %>%
  select(Outcome = outcome, `Control Mean` = control_str,
         `Treatment Effect (SE)` = effect_str, N = n_obs)

write_csv(table1 %>% mutate(`Treatment Effect (SE)` = str_replace_all(`Treatment Effect (SE)`, "\n", " ")),
          file.path(tab_dir, "table1_treatment_effects.csv"))

cat("Table 1: Treatment Effects from Haushofer & Shapiro (2016)\n")
print(table1)

# LaTeX version
table1_latex <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Food consumption", "Non-food consumption",
                        "Total assets", "Livestock", "Non-agricultural revenue",
                        "Psychological wellbeing index")) %>%
  mutate(
    stars = case_when(
      pvalue < 0.001 ~ "***",
      pvalue < 0.01 ~ "**",
      pvalue < 0.05 ~ "*",
      TRUE ~ ""
    )
  )

sink(file.path(tab_dir, "table1_treatment_effects.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Treatment Effects on Household Outcomes}\n")
cat("\\label{tab:treatment_effects}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat("Outcome & Control Mean & Treatment Effect & SE & N \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(table1_latex)) {
  cat(paste(
    table1_latex$outcome[i], "&",
    round(table1_latex$control_mean[i], 1), "&",
    paste0(round(table1_latex$treatment_effect[i], 1), table1_latex$stars[i]), "&",
    paste0("(", round(table1_latex$se[i], 1), ")"), "&",
    table1_latex$n_obs[i], "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\footnotesize Notes: ITT estimates from Haushofer \\& Shapiro (2016). *p<0.05; **p<0.01; ***p<0.001}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

# -----------------------------------------------------------------------------
# Table 2: MVPF Calculation Components
# -----------------------------------------------------------------------------

# Extract values from mvpf_results
wtp_direct <- mvpf_results$wtp_direct
wtp_spillover_per_recipient <- mvpf_results$wtp_spillover
wtp_total <- wtp_direct + wtp_spillover_per_recipient
pv_vat <- mvpf_results$vat_externality
pv_income_tax <- mvpf_results$income_tax_externality
net_cost <- mvpf_results$net_cost
net_cost_mcpf <- net_cost * 1.3
mvpf_direct_no_mcpf <- mvpf_results$mvpf_direct
mvpf_total_no_mcpf <- mvpf_results$mvpf_with_spillovers
mvpf_direct_mcpf <- wtp_direct / net_cost_mcpf

table2 <- tibble(
  Component = c(
    "Panel A: Willingness to Pay",
    "  Direct transfer (net of admin)",
    "  Spillover WTP (per recipient)",
    "  Total WTP",
    "",
    "Panel B: Net Government Cost",
    "  Gross transfer",
    "  Less: VAT revenue (PV)",
    "  Less: Income tax (PV)",
    "  Net cost (no MCPF)",
    "  Net cost (MCPF = 1.3)",
    "",
    "Panel C: MVPF",
    "  Direct WTP / Net cost",
    "  Total WTP / Net cost",
    "  Direct WTP / Net cost (MCPF)"
  ),
  Value = c(
    "",
    sprintf("$%.0f", wtp_direct),
    sprintf("$%.0f", wtp_spillover_per_recipient),
    sprintf("$%.0f", wtp_total),
    "",
    "",
    "$1,000",
    sprintf("-$%.0f", pv_vat),
    sprintf("-$%.0f", pv_income_tax),
    sprintf("$%.0f", net_cost),
    sprintf("$%.0f", net_cost_mcpf),
    "",
    "",
    sprintf("%.2f", mvpf_direct_no_mcpf),
    sprintf("%.2f", mvpf_total_no_mcpf),
    sprintf("%.2f", mvpf_direct_mcpf)
  ),
  Notes = c(
    "",
    "Transfer × (1 - 0.15 admin rate)",
    "Non-recipient consumption gain × ratio",
    "Sum of direct + spillover",
    "",
    "",
    "GiveDirectly transfer amount",
    "16% VAT × consumption gain × 50% coverage × 3 years",
    "18.5% × earnings gain × 20% formal × 5 years",
    "Gross - fiscal externalities",
    "Net cost × MCPF",
    "",
    "",
    "Baseline specification",
    "Including GE spillovers",
    "Government financing adjustment"
  )
)

write_csv(table2, file.path(tab_dir, "table2_mvpf_components.csv"))

cat("\n\nTable 2: MVPF Calculation Components\n")
print(table2, n = Inf)

# -----------------------------------------------------------------------------
# Table 3: MVPF Comparison with US Transfer Programs
# -----------------------------------------------------------------------------

# Create comparison data frame with US programs from Hendren & Sprung-Keyser (2020)
comparison_df <- tibble(
  policy = c("Kenya UCT (GiveDirectly)", "EITC", "SNAP", "TANF", "Medicaid (Children)"),
  category = c("Cash transfers", "Tax credits", "In-kind transfers", "Cash transfers", "In-kind transfers"),
  target = c("Poor rural households", "Low-income workers", "Low-income households", "Poor families", "Children"),
  mvpf = c(mvpf_results$mvpf_direct, 0.92, 0.76, 0.65, 1.8)
)

table3 <- comparison_df %>%
  filter(category %in% c("Cash transfers", "Tax credits", "In-kind transfers") |
         policy == "Kenya UCT (GiveDirectly)") %>%
  arrange(desc(mvpf)) %>%
  mutate(
    MVPF = ifelse(is.infinite(mvpf), "∞", sprintf("%.2f", mvpf)),
    Country = ifelse(grepl("Kenya", policy), "Kenya", "United States")
  ) %>%
  select(Policy = policy, Category = category, Target = target, Country, MVPF)

write_csv(table3, file.path(tab_dir, "table3_mvpf_comparison.csv"))

cat("\n\nTable 3: MVPF Comparison with US Transfer Programs\n")
print(table3)

# LaTeX version
sink(file.path(tab_dir, "table3_mvpf_comparison.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MVPF Comparison: Kenya UCT vs. US Transfer Programs}\n")
cat("\\label{tab:mvpf_comparison}\n")
cat("\\begin{tabular}{lllcc}\n")
cat("\\hline\\hline\n")
cat("Policy & Category & Target & Country & MVPF \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(table3)) {
  cat(paste(
    table3$Policy[i], "&",
    table3$Category[i], "&",
    table3$Target[i], "&",
    table3$Country[i], "&",
    table3$MVPF[i], "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\footnotesize Notes: US MVPFs from Hendren \\& Sprung-Keyser (2020). $\\infty$ indicates policy pays for itself.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

# -----------------------------------------------------------------------------
# Table 4: Sensitivity Analysis Summary
# -----------------------------------------------------------------------------

# Build sensitivity summary from computed robustness_results.RData
baseline_mvpf <- mvpf_results$mvpf_direct

# Extract values from computed robustness objects
vat_25  <- vat_sensitivity$mvpf[vat_sensitivity$vat_coverage == 0.25]
vat_100 <- vat_sensitivity$mvpf[vat_sensitivity$vat_coverage == 1.00]
form_10 <- formality_sensitivity$mvpf[formality_sensitivity$informal_share == 0.90]
form_30 <- formality_sensitivity$mvpf[formality_sensitivity$informal_share == 0.60]
disc_3  <- discount_sensitivity$mvpf[discount_sensitivity$discount_rate == 0.03]
disc_10 <- discount_sensitivity$mvpf[discount_sensitivity$discount_rate == 0.10]

# MCPF sensitivity
mcpf_1  <- mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.0]
mcpf_13 <- mcpf_sensitivity$mvpf_direct[mcpf_sensitivity$mcpf == 1.3]

sensitivity_summary <- tibble(
  parameter = c("Baseline", "VAT coverage 25%", "VAT coverage 100%",
                "Formality rate 10%", "Formality rate 30%",
                "Discount rate 3%", "Discount rate 10%",
                "MCPF = 1.0", "MCPF = 1.3"),
  mvpf = c(baseline_mvpf, vat_25, vat_100, form_10, form_30,
           disc_3, disc_10, mcpf_1, mcpf_13),
  change_from_baseline = round((c(baseline_mvpf, vat_25, vat_100, form_10, form_30,
                                  disc_3, disc_10, mcpf_1, mcpf_13) / baseline_mvpf - 1) * 100, 1)
)

table4 <- sensitivity_summary %>%
  mutate(
    MVPF = sprintf("%.2f", mvpf),
    `Change (%)` = sprintf("%+.1f%%", change_from_baseline)
  ) %>%
  select(Assumption = parameter, MVPF, `Change (%)`)

write_csv(table4, file.path(tab_dir, "table4_sensitivity.csv"))

cat("\n\nTable 4: Sensitivity Analysis\n")
print(table4, n = Inf)

# LaTeX version
sink(file.path(tab_dir, "table4_sensitivity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Sensitivity of MVPF to Key Assumptions}\n")
cat("\\label{tab:sensitivity}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat("Assumption & MVPF & Change from Baseline \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(table4)) {
  cat(paste(table4$Assumption[i], "&", table4$MVPF[i], "&", table4$`Change (%)`[i], "\\\\\n"))
}
cat("\\hline\n")
cat("\\multicolumn{3}{l}{\\footnotesize Notes: Baseline assumes 3-year persistence, 50\\% decay, 80\\% informality,}\\\\\n")
cat("\\multicolumn{3}{l}{\\footnotesize 5\\% discount rate, and 50\\% VAT coverage.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

# -----------------------------------------------------------------------------
# Table 5: General Equilibrium Effects
# -----------------------------------------------------------------------------

table5 <- egger_ge_effects %>%
  mutate(
    Recipient = sprintf("%.0f (%.0f)", recipient_effect, recipient_se),
    `Non-Recipient` = sprintf("%.0f (%.0f)", nonrecipient_effect, nonrecipient_se),
    `Spillover Ratio` = sprintf("%.0f%%", nonrecipient_effect / recipient_effect * 100)
  ) %>%
  select(Outcome = outcome, Recipient, `Non-Recipient`, `Spillover Ratio`)

write_csv(table5, file.path(tab_dir, "table5_ge_effects.csv"))

cat("\n\nTable 5: General Equilibrium Effects\n")
print(table5)

# -----------------------------------------------------------------------------
# Table 6: Kenya Fiscal Parameters
# -----------------------------------------------------------------------------

table6 <- tibble(
  Parameter = c(
    "VAT rate (standard)",
    "Effective income tax (formal sector)",
    "Informal sector share (rural)",
    "MCPF (baseline)",
    "Discount rate",
    "PPP conversion factor",
    "Transfer amount",
    "Admin cost rate"
  ),
  Value = c(
    "16%",
    "18.5%",
    "80%",
    "1.3",
    "5%",
    "2.515",
    "$1,000 USD",
    "15%"
  ),
  Source = c(
    "Kenya Revenue Authority",
    "IEA Kenya",
    "Tandfonline (2021)",
    "Dahlby (2008)",
    "Standard assumption",
    "World Bank ICP",
    "GiveDirectly",
    "GiveDirectly financials"
  )
)

write_csv(table6, file.path(tab_dir, "table6_kenya_parameters.csv"))

cat("\n\nTable 6: Kenya Fiscal Parameters\n")
print(table6)

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

cat("\n\n=== Tables Generated ===\n")
cat("1. table1_treatment_effects.csv/tex - Original treatment effects\n")
cat("2. table2_mvpf_components.csv - MVPF calculation breakdown\n")
cat("3. table3_mvpf_comparison.csv/tex - Comparison with US programs\n")
cat("4. table4_sensitivity.csv/tex - Sensitivity analysis\n")
cat("5. table5_ge_effects.csv - General equilibrium effects\n")
cat("6. table6_kenya_parameters.csv - Fiscal parameters used\n")
cat("\nAll tables saved to:", tab_dir, "\n")
