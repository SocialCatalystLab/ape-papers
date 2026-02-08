# ============================================================================
# 05_figures.R - Generate all figures for the paper
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load data
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

# Figure output directory
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Figure 1: MVPF Components Breakdown
# -----------------------------------------------------------------------------

fig1_data <- mvpf_components %>%
  filter(component %in% c("WTP_direct", "Gross_cost", "Fiscal_VAT", "Fiscal_income_tax", "Net_cost")) %>%
  mutate(
    component_label = case_when(
      component == "WTP_direct" ~ "WTP (Direct)",
      component == "Gross_cost" ~ "Gross Cost",
      component == "Fiscal_VAT" ~ "VAT Recapture",
      component == "Fiscal_income_tax" ~ "Income Tax",
      component == "Net_cost" ~ "Net Cost"
    ),
    bar_type = case_when(
      component %in% c("Fiscal_VAT", "Fiscal_income_tax") ~ "Fiscal Externality",
      component == "WTP_direct" ~ "Willingness to Pay",
      TRUE ~ "Cost"
    )
  )

fig1 <- ggplot(fig1_data, aes(x = reorder(component_label, -value), y = value, fill = bar_type)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = paste0("$", round(value, 0))),
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("Willingness to Pay" = "#009E73",
                               "Cost" = "#D55E00",
                               "Fiscal Externality" = "#0072B2"),
                    name = "") +
  labs(
    title = "MVPF Components: Kenya UCT Program",
    subtitle = "Willingness to pay and net government cost per recipient",
    x = "",
    y = "USD per recipient",
    caption = "Source: Authors' calculations based on Haushofer & Shapiro (2016) and Egger et al. (2022)"
  ) +
  theme_mvpf +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig1_mvpf_components.pdf"), fig1, width = 8, height = 6)
ggsave(file.path(fig_dir, "fig1_mvpf_components.png"), fig1, width = 8, height = 6, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 2: MVPF Comparison with US Policies
# -----------------------------------------------------------------------------

# Prepare comparison data (exclude infinite MVPFs for plotting)
fig2_data <- comparison_df %>%
  filter(!is.infinite(mvpf)) %>%
  mutate(
    country = ifelse(grepl("Kenya", policy), "Kenya", "United States"),
    policy_short = case_when(
      policy == "Kenya UCT (GiveDirectly)" ~ "Kenya UCT",
      policy == "EITC expansion (adults)" ~ "EITC",
      policy == "TANF (cash welfare)" ~ "TANF",
      policy == "Food stamps (SNAP)" ~ "SNAP",
      policy == "Medicaid (adults)" ~ "Medicaid\n(adults)",
      policy == "Head Start" ~ "Head Start",
      TRUE ~ policy
    )
  ) %>%
  filter(policy_short %in% c("Kenya UCT", "EITC", "TANF", "SNAP", "Medicaid\n(adults)", "Head Start"))

fig2 <- ggplot(fig2_data, aes(x = reorder(policy_short, mvpf), y = mvpf, fill = country)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
  geom_text(aes(label = round(mvpf, 2)), hjust = -0.1, size = 3.5) +
  coord_flip(ylim = c(0, 1.7)) +
  scale_fill_manual(values = c("Kenya" = "#009E73", "United States" = "#0072B2"),
                    name = "Country") +
  labs(
    title = "MVPF Comparison: Kenya UCT vs. US Transfer Programs",
    subtitle = "Higher MVPF = greater welfare per dollar of government spending",
    x = "",
    y = "Marginal Value of Public Funds (MVPF)",
    caption = "Note: US MVPFs from Hendren & Sprung-Keyser (2020). Dashed line indicates MVPF = 1."
  ) +
  theme_mvpf +
  annotate("text", x = 1.5, y = 1.05, label = "MVPF = 1", size = 3, color = "gray40")

ggsave(file.path(fig_dir, "fig2_mvpf_comparison.pdf"), fig2, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig2_mvpf_comparison.png"), fig2, width = 9, height = 6, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 3: Sensitivity Analysis - Tornado Plot
# -----------------------------------------------------------------------------

fig3_data <- sensitivity_summary %>%
  filter(parameter != "Baseline") %>%
  mutate(
    deviation = mvpf - mvpf_direct_no_mcpf,
    direction = ifelse(deviation > 0, "Higher", "Lower"),
    parameter = str_wrap(parameter, width = 20)
  ) %>%
  arrange(abs(deviation))

baseline_mvpf <- mvpf_direct_no_mcpf

fig3 <- ggplot(fig3_data, aes(x = reorder(parameter, abs(deviation)), y = mvpf)) +
  geom_segment(aes(xend = parameter, y = baseline_mvpf, yend = mvpf),
               color = "gray70", linewidth = 1) +
  geom_point(aes(color = direction), size = 4) +
  geom_hline(yintercept = baseline_mvpf, linetype = "dashed", color = "gray40") +
  coord_flip() +
  scale_color_manual(values = c("Higher" = "#009E73", "Lower" = "#D55E00"),
                     name = "Effect on MVPF") +
  labs(
    title = "Sensitivity of MVPF to Key Assumptions",
    subtitle = paste0("Baseline MVPF = ", round(baseline_mvpf, 2)),
    x = "",
    y = "MVPF",
    caption = "Dashed line indicates baseline estimate"
  ) +
  theme_mvpf

ggsave(file.path(fig_dir, "fig3_sensitivity_tornado.pdf"), fig3, width = 9, height = 7)
ggsave(file.path(fig_dir, "fig3_sensitivity_tornado.png"), fig3, width = 9, height = 7, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 4: MVPF by Persistence and Discount Rate
# -----------------------------------------------------------------------------

# Create grid for heatmap
fig4_data <- expand.grid(
  persistence_years = c(1, 3, 5, 10),
  discount_rate = c(0.03, 0.05, 0.07, 0.10)
) %>%
  rowwise() %>%
  mutate(
    # Calculate MVPF for each combination
    consumption_gain = egger_ge_effects$recipient_effect[1] / kenya_fiscal$ppp_factor,
    vat_annual = consumption_gain * kenya_fiscal$vat_rate * 0.50,
    pv_factor = (1 - (1/(1 + discount_rate)^persistence_years)) / discount_rate,
    pv_vat = vat_annual * pv_factor * 0.5,  # With decay
    net_cost = 1000 - pv_vat - 10,  # Approx income tax
    mvpf = wtp_direct / net_cost
  ) %>%
  ungroup()

fig4 <- ggplot(fig4_data, aes(x = factor(persistence_years), y = factor(discount_rate * 100),
                               fill = mvpf)) +
  geom_tile() +
  geom_text(aes(label = round(mvpf, 2)), color = "white", fontface = "bold") +
  scale_fill_gradient2(low = "#D55E00", mid = "#F0E442", high = "#009E73",
                       midpoint = median(fig4_data$mvpf),
                       name = "MVPF") +
  labs(
    title = "MVPF by Effect Persistence and Discount Rate",
    x = "Effect Persistence (Years)",
    y = "Discount Rate (%)",
    caption = "Note: Assumes 50% consumption decay and 50% VAT coverage"
  ) +
  theme_mvpf +
  theme(legend.position = "right")

ggsave(file.path(fig_dir, "fig4_persistence_discount_heatmap.pdf"), fig4, width = 8, height = 6)
ggsave(file.path(fig_dir, "fig4_persistence_discount_heatmap.png"), fig4, width = 8, height = 6, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 5: Effect Estimates from Original Studies
# -----------------------------------------------------------------------------

fig5_data <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Total assets", "Non-agricultural revenue",
                        "Psychological wellbeing index")) %>%
  mutate(
    outcome_label = case_when(
      outcome == "Total consumption" ~ "Monthly\nConsumption",
      outcome == "Total assets" ~ "Total\nAssets",
      outcome == "Non-agricultural revenue" ~ "Non-Ag\nRevenue",
      outcome == "Psychological wellbeing index" ~ "Wellbeing\n(z-score)"
    ),
    ci_lower = treatment_effect - 1.96 * se,
    ci_upper = treatment_effect + 1.96 * se,
    # Normalize for display (different scales)
    pct_effect = treatment_effect / control_mean * 100
  )

fig5 <- ggplot(fig5_data, aes(x = outcome_label, y = treatment_effect)) +
  geom_col(fill = "#0072B2", width = 0.7) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2) +
  geom_text(aes(label = paste0("+", round(treatment_effect, 0), "\n(",
                               round(pct_effect, 0), "%)")),
            vjust = -0.5, size = 3) +
  facet_wrap(~outcome_label, scales = "free", nrow = 1) +
  labs(
    title = "Treatment Effects: GiveDirectly Kenya UCT",
    subtitle = "9-month ITT estimates from Haushofer & Shapiro (2016)",
    x = "",
    y = "Treatment Effect (USD PPP or z-score)",
    caption = "Error bars show 95% confidence intervals. Percentages are effect relative to control mean."
  ) +
  theme_mvpf +
  theme(strip.text = element_blank())

ggsave(file.path(fig_dir, "fig5_treatment_effects.pdf"), fig5, width = 10, height = 5)
ggsave(file.path(fig_dir, "fig5_treatment_effects.png"), fig5, width = 10, height = 5, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 6: Spillover Effects (GE)
# -----------------------------------------------------------------------------

fig6_data <- egger_ge_effects %>%
  filter(outcome %in% c("Consumption", "Assets", "Wage earnings", "Enterprise profits")) %>%
  pivot_longer(cols = c(recipient_effect, nonrecipient_effect),
               names_to = "group", values_to = "effect") %>%
  mutate(
    se = ifelse(group == "recipient_effect", recipient_se, nonrecipient_se),
    group_label = ifelse(group == "recipient_effect", "Recipients", "Non-Recipients"),
    ci_lower = effect - 1.96 * se,
    ci_upper = effect + 1.96 * se
  )

fig6 <- ggplot(fig6_data, aes(x = outcome, y = effect, fill = group_label)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                position = position_dodge(width = 0.8), width = 0.2) +
  scale_fill_manual(values = c("Recipients" = "#0072B2", "Non-Recipients" = "#D55E00"),
                    name = "") +
  labs(
    title = "General Equilibrium Effects: Recipients vs. Non-Recipients",
    subtitle = "18-month estimates from Egger et al. (2022)",
    x = "",
    y = "Treatment Effect (USD PPP, annualized)",
    caption = "Non-recipient effects show spillovers to households in treatment villages who did not receive transfers.\nError bars show 95% CIs."
  ) +
  theme_mvpf +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig6_ge_spillovers.pdf"), fig6, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig6_ge_spillovers.png"), fig6, width = 9, height = 6, dpi = 300)

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

cat("\n=== Figures Generated ===\n")
cat("1. fig1_mvpf_components.pdf - MVPF component breakdown\n")
cat("2. fig2_mvpf_comparison.pdf - Comparison with US policies\n")
cat("3. fig3_sensitivity_tornado.pdf - Tornado plot of sensitivities\n")
cat("4. fig4_persistence_discount_heatmap.pdf - Persistence × discount rate\n")
cat("5. fig5_treatment_effects.pdf - Original treatment effects\n")
cat("6. fig6_ge_spillovers.pdf - General equilibrium spillovers\n")
cat("\nAll figures saved to:", fig_dir, "\n")
