# ============================================================================
# 05_figures.R - Publication-quality figures (v4)
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

# ── Figure 1: MVPF Components ─────────────────────────────────────────────

fig1_data <- tibble(
  component = c("WTP\n(Direct)", "Gross\nCost", "VAT\nRecapture", "Income\nTax", "Net\nCost"),
  value = c(wtp_direct, gross_cost, pv_vat, pv_income_tax, net_cost),
  type = c("WTP", "Cost", "Fiscal Ext.", "Fiscal Ext.", "Cost")
)

fig1 <- ggplot(fig1_data, aes(x = factor(component, levels = component), y = value, fill = type)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = paste0("$", round(value, 0))), vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("WTP" = "#009E73", "Cost" = "#D55E00", "Fiscal Ext." = "#0072B2")) +
  labs(x = "", y = "USD per recipient", fill = "",
       title = "MVPF Components: Kenya UCT",
       caption = "Based on Haushofer & Shapiro (2016) and Egger et al. (2022)") +
  theme_mvpf + ylim(0, 1100)

ggsave(file.path(fig_dir, "fig1_mvpf_components.pdf"), fig1, width = 8, height = 6)
ggsave(file.path(fig_dir, "fig1_mvpf_components.png"), fig1, width = 8, height = 6, dpi = 300)

# ── Figure 2: MVPF Comparison with US ─────────────────────────────────────

fig2_data <- comparison_df %>%
  filter(!is.infinite(mvpf)) %>%
  mutate(
    country = ifelse(grepl("Kenya", policy), "Kenya", "US"),
    short = case_when(
      grepl("Kenya", policy)    ~ "Kenya UCT",
      grepl("EITC", policy)     ~ "EITC",
      grepl("TANF", policy)     ~ "TANF",
      grepl("SNAP", policy)     ~ "SNAP",
      grepl("Medicaid.*adult", policy) ~ "Medicaid (adults)",
      grepl("Head", policy)     ~ "Head Start",
      TRUE ~ policy
    )
  ) %>%
  filter(short %in% c("Kenya UCT", "EITC", "TANF", "SNAP", "Medicaid (adults)", "Head Start"))

fig2 <- ggplot(fig2_data, aes(x = reorder(short, mvpf), y = mvpf, fill = country)) +
  geom_col(width = 0.65) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
  geom_text(aes(label = sprintf("%.3f", mvpf)), hjust = -0.15, size = 3.5) +
  coord_flip(ylim = c(0, 1.7)) +
  scale_fill_manual(values = c("Kenya" = "#009E73", "US" = "#0072B2"), name = "") +
  labs(x = "", y = "MVPF",
       title = "Kenya UCT vs. US Transfer Programs",
       caption = "US MVPFs from Hendren & Sprung-Keyser (2020). Dashed line: MVPF = 1.") +
  theme_mvpf

ggsave(file.path(fig_dir, "fig2_mvpf_comparison.pdf"), fig2, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig2_mvpf_comparison.png"), fig2, width = 9, height = 6, dpi = 300)

# ── Figure 3: Tornado Plot ────────────────────────────────────────────────

baseline <- sensitivity_summary$mvpf[1]

fig3_data <- sensitivity_summary %>%
  filter(!parameter %in% c("Baseline", "Lower bound", "Upper bound")) %>%
  mutate(
    deviation = mvpf - baseline,
    direction = ifelse(deviation >= 0, "Higher", "Lower"),
    parameter = str_wrap(parameter, 18)
  ) %>%
  arrange(abs(deviation))

fig3 <- ggplot(fig3_data, aes(x = reorder(parameter, abs(deviation)), y = mvpf)) +
  geom_segment(aes(xend = parameter, y = baseline, yend = mvpf), color = "gray70", linewidth = 1) +
  geom_point(aes(color = direction), size = 4) +
  geom_hline(yintercept = baseline, linetype = "dashed", color = "gray40") +
  coord_flip() +
  scale_color_manual(values = c("Higher" = "#009E73", "Lower" = "#D55E00"), name = "") +
  labs(x = "", y = "MVPF",
       title = "Sensitivity of MVPF to Key Assumptions",
       subtitle = paste0("Baseline = ", round(baseline, 3)),
       caption = "Dashed line = baseline. Each bar shows MVPF under alternative assumption.") +
  theme_mvpf +
  theme(axis.text.y = element_text(size = 9))

ggsave(file.path(fig_dir, "fig3_sensitivity_tornado.pdf"), fig3, width = 9, height = 8)
ggsave(file.path(fig_dir, "fig3_sensitivity_tornado.png"), fig3, width = 9, height = 8, dpi = 300)

# ── Figure 4: Persistence × Discount Heatmap ─────────────────────────────

fig4_data <- expand.grid(
  persistence = c(1, 3, 5, 10),
  discount = c(0.03, 0.05, 0.07, 0.10)
) %>%
  rowwise() %>%
  mutate(
    pv_fac = (1 - (1 / (1 + discount)^persistence)) / discount,
    pv_vat_i = consumption_gain_usd * 0.16 * 0.50 * pv_fac * 0.5,
    net_i = 1000 - pv_vat_i - 10,
    mvpf = wtp_direct / net_i
  ) %>%
  ungroup()

fig4 <- ggplot(fig4_data, aes(x = factor(persistence), y = factor(discount * 100), fill = mvpf)) +
  geom_tile() +
  geom_text(aes(label = round(mvpf, 3)), color = "white", fontface = "bold") +
  scale_fill_gradient2(low = "#D55E00", mid = "#F0E442", high = "#009E73",
                       midpoint = median(fig4_data$mvpf), name = "MVPF") +
  labs(x = "Persistence (years)", y = "Discount rate (%)",
       title = "MVPF by Persistence and Discount Rate") +
  theme_mvpf + theme(legend.position = "right")

ggsave(file.path(fig_dir, "fig4_persistence_discount_heatmap.pdf"), fig4, width = 8, height = 6)
ggsave(file.path(fig_dir, "fig4_persistence_discount_heatmap.png"), fig4, width = 8, height = 6, dpi = 300)

# ── Figure 5: Treatment Effects ───────────────────────────────────────────

fig5_data <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Total assets", "Non-agricultural revenue",
                         "Psychological wellbeing index")) %>%
  mutate(
    label = c("Monthly\nConsumption", "Total\nAssets", "Non-Ag\nRevenue", "Wellbeing\n(z-score)"),
    ci_lo = treatment_effect - 1.96 * se,
    ci_hi = treatment_effect + 1.96 * se,
    pct = treatment_effect / control_mean * 100
  )

fig5 <- ggplot(fig5_data, aes(x = label, y = treatment_effect)) +
  geom_col(fill = "#0072B2", width = 0.65) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2) +
  geom_text(aes(label = ifelse(abs(treatment_effect) < 1,
                               paste0("+", sprintf("%.2f", treatment_effect)),
                               paste0("+", round(treatment_effect, 0)))),
            vjust = -0.5, size = 3.5) +
  facet_wrap(~label, scales = "free", nrow = 1) +
  labs(x = "", y = "Effect (PPP or z-score)",
       title = "Treatment Effects from Haushofer & Shapiro (2016)",
       subtitle = "9-month ITT estimates, N = 1,372 households",
       caption = "Error bars: 95% CIs.") +
  theme_mvpf + theme(strip.text = element_blank())

ggsave(file.path(fig_dir, "fig5_treatment_effects.pdf"), fig5, width = 10, height = 5)
ggsave(file.path(fig_dir, "fig5_treatment_effects.png"), fig5, width = 10, height = 5, dpi = 300)

# ── Figure 6: Spillover Effects ───────────────────────────────────────────

fig6_data <- egger_ge_effects %>%
  filter(outcome %in% c("Consumption", "Assets", "Wage earnings", "Enterprise profits")) %>%
  pivot_longer(cols = c(recipient_effect, nonrecipient_effect),
               names_to = "group", values_to = "effect") %>%
  mutate(
    se_val = ifelse(group == "recipient_effect", recipient_se, nonrecipient_se),
    group_label = ifelse(group == "recipient_effect", "Recipients", "Non-Recipients"),
    ci_lo = effect - 1.96 * se_val,
    ci_hi = effect + 1.96 * se_val
  )

fig6 <- ggplot(fig6_data, aes(x = outcome, y = effect, fill = group_label)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), position = position_dodge(0.8), width = 0.2) +
  scale_fill_manual(values = c("Recipients" = "#0072B2", "Non-Recipients" = "#D55E00"), name = "") +
  labs(x = "", y = "Effect (USD PPP, annualized)",
       title = "General Equilibrium Effects",
       subtitle = "18-month estimates from Egger et al. (2022)",
       caption = "Non-recipients are households in treatment villages who did not receive transfers.") +
  theme_mvpf + theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave(file.path(fig_dir, "fig6_ge_spillovers.pdf"), fig6, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig6_ge_spillovers.png"), fig6, width = 9, height = 6, dpi = 300)

# ── Figure 7: Government Scenarios ────────────────────────────────────────

fig7_data <- gov_results %>%
  pivot_longer(cols = c(mvpf, mvpf_with_spillover), names_to = "type", values_to = "mvpf_val") %>%
  mutate(type_label = ifelse(type == "mvpf", "Direct only", "With spillovers"))

fig7 <- ggplot(fig7_data, aes(x = reorder(scenario, -mvpf_val), y = mvpf_val, fill = type_label)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray40") +
  geom_text(aes(label = sprintf("%.3f", mvpf_val)), position = position_dodge(0.8), vjust = -0.3, size = 3) +
  scale_fill_manual(values = c("Direct only" = "#0072B2", "With spillovers" = "#009E73"), name = "") +
  labs(x = "", y = "MVPF",
       title = "MVPF Under Alternative Implementation Scenarios",
       subtitle = "NGO vs. government delivery",
       caption = "Government scenarios vary admin costs (20-40%) and targeting leakage (5-20%).") +
  theme_mvpf + theme(axis.text.x = element_text(angle = 20, hjust = 1)) + ylim(0, 1.1)

ggsave(file.path(fig_dir, "fig7_government_scenarios.pdf"), fig7, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig7_government_scenarios.png"), fig7, width = 9, height = 6, dpi = 300)

# ── Figure 8: Bootstrap Distribution ─────────────────────────────────────

fig8_data <- tibble(
  Direct = mvpf_direct_boot,
  `With Spillovers` = mvpf_spillover_boot
) %>%
  pivot_longer(everything(), names_to = "Specification", values_to = "MVPF")

fig8 <- ggplot(fig8_data, aes(x = MVPF, fill = Specification)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray40") +
  scale_fill_manual(values = c("Direct" = "#0072B2", "With Spillovers" = "#009E73")) +
  labs(x = "MVPF", y = "Density",
       title = "Bootstrap Distribution of MVPF Estimates",
       subtitle = paste0("5,000 replications, ρ = 0"),
       caption = "Dashed line: MVPF = 1. Shaded densities show uncertainty from treatment effects and fiscal parameters.") +
  theme_mvpf + xlim(0.82, 1.02)

ggsave(file.path(fig_dir, "fig8_bootstrap_distribution.pdf"), fig8, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig8_bootstrap_distribution.png"), fig8, width = 8, height = 5, dpi = 300)

cat("\n=== All 8 Figures Generated ===\n")
cat("Saved to:", fig_dir, "\n")
