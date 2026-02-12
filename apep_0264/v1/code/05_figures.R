## 05_figures.R — Generate all figures
## Paper: "The Quiet Life Goes Macro" (apep_0243)

source("00_packages.R")

cat("=== GENERATING FIGURES ===\n")

panel <- readRDS("../data/analysis_panel.rds")

# ============================================================
# FIGURE 1: Map of BC statute adoption timing
# ============================================================

cat("--- Figure 1: Adoption map ---\n")

states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

treatment <- readRDS("../data/treatment_dates.rds")

states_map <- states_sf %>%
  left_join(treatment %>% mutate(bc_year_plot = ifelse(bc_year == 0, NA, bc_year)),
            by = c("STATEFP" = "state_fips"))

p1 <- ggplot(states_map) +
  geom_sf(aes(fill = bc_year_plot), color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Year Adopted",
    option = "plasma",
    na.value = "grey85",
    direction = -1,
    breaks = c(1985, 1988, 1991, 1994, 1997)
  ) +
  labs(
    title = "Staggered Adoption of Business Combination Statutes",
    caption = "Grey = never adopted. Source: Karpoff & Wittry (2018)."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2.5, "cm"),
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 1)
  )

ggsave("../figures/fig1_adoption_map.pdf", p1, width = 10, height = 7)
cat("  Saved fig1_adoption_map.pdf\n")

# ============================================================
# FIGURE 2: Treatment rollout histogram
# ============================================================

cat("--- Figure 2: Rollout histogram ---\n")

cohorts <- treatment %>%
  filter(bc_year > 0) %>%
  count(bc_year, name = "n_states")

p2 <- ggplot(cohorts, aes(x = bc_year, y = n_states)) +
  geom_col(fill = apep_colors[1], alpha = 0.8, width = 0.7) +
  geom_text(aes(label = n_states), vjust = -0.5, size = 3.5) +
  scale_x_continuous(breaks = 1985:1997) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Treatment Rollout: States Adopting BC Statutes by Year",
    subtitle = sprintf("%d states adopted between 1985-1997; %d never adopted",
                       sum(cohorts$n_states), 18),
    x = "Year of Adoption",
    y = "Number of States"
  ) +
  theme_apep()

ggsave("../figures/fig2_rollout.pdf", p2, width = 8, height = 5)
cat("  Saved fig2_rollout.pdf\n")

# ============================================================
# FIGURE 3: Raw outcome trends (treated vs never-treated)
# ============================================================

cat("--- Figure 3: Raw trends ---\n")

trends <- panel %>%
  filter(year >= 1988, year <= 2019) %>%
  mutate(group = ifelse(treated == 1, "BC Statute States", "Never-Treated States")) %>%
  group_by(group, year) %>%
  summarise(
    avg_size = mean(avg_estab_size, na.rm = TRUE),
    payroll_pw = mean(payroll_per_worker, na.rm = TRUE),
    .groups = "drop"
  )

p3a <- ggplot(trends, aes(x = year, y = avg_size, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 1987.5, linetype = "dashed", color = "grey50", alpha = 0.7) +
  annotate("text", x = 1987.5, y = max(trends$avg_size, na.rm = TRUE) * 0.98,
           label = "Modal adoption\nyear", hjust = 1.1, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2], name = "") +
  labs(
    title = "Average Establishment Size",
    x = "Year", y = "Employees per Establishment"
  ) +
  theme_apep()

p3b <- ggplot(trends %>% filter(!is.na(payroll_pw)),
              aes(x = year, y = payroll_pw, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 1987.5, linetype = "dashed", color = "grey50", alpha = 0.7) +
  scale_color_manual(values = apep_colors[1:2], name = "") +
  labs(
    title = "Payroll per Employee ($000s)",
    x = "Year", y = "Annual Payroll per Employee"
  ) +
  theme_apep()

p3 <- p3a / p3b + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave("../figures/fig3_raw_trends.pdf", p3, width = 9, height = 10)
cat("  Saved fig3_raw_trends.pdf\n")

# ============================================================
# FIGURE 4: Event Study — Average Establishment Size
# ============================================================

cat("--- Figure 4: Event study (establishment size) ---\n")

es_size <- readRDS("../data/es_size.rds")

es_df <- data.frame(
  time = es_size$egt,
  att = es_size$att.egt,
  se = es_size$se.egt
) %>%
  filter(time >= -8, time <= 15)

p4 <- ggplot(es_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Effect of BC Statute Adoption on Average Establishment Size",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to BC Statute Adoption",
    y = "ATT (log average establishment size)",
    caption = "Note: Reference period is t = -1. Never-treated states as control group."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 15, 2))

ggsave("../figures/fig4_es_size.pdf", p4, width = 9, height = 5.5)
cat("  Saved fig4_es_size.pdf\n")

# ============================================================
# FIGURE 5: Event Study — Payroll per Employee (Wage Proxy)
# ============================================================

cat("--- Figure 5: Event study (wages) ---\n")

if (file.exists("../data/es_wage.rds")) {
  es_wage <- readRDS("../data/es_wage.rds")

  es_wage_df <- data.frame(
    time = es_wage$egt,
    att = es_wage$att.egt,
    se = es_wage$se.egt
  ) %>%
    filter(time >= -8, time <= 15)

  p5 <- ggplot(es_wage_df, aes(x = time, y = att)) +
    geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                alpha = 0.15, fill = apep_colors[2]) +
    geom_point(color = apep_colors[2], size = 2.5) +
    geom_line(color = apep_colors[2], linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    labs(
      title = "Effect of BC Statute Adoption on Payroll per Employee",
      subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
      x = "Years Relative to BC Statute Adoption",
      y = "ATT (log payroll per employee)",
      caption = "Note: Payroll per employee = annual payroll / employment from CBP."
    ) +
    theme_apep() +
    scale_x_continuous(breaks = seq(-8, 15, 2))

  ggsave("../figures/fig5_es_wage.pdf", p5, width = 9, height = 5.5)
  cat("  Saved fig5_es_wage.pdf\n")
}

# ============================================================
# FIGURE 6: Event Study — Net Entry Rate
# ============================================================

cat("--- Figure 6: Event study (net entry) ---\n")

es_nr <- readRDS("../data/es_nr.rds")

es_nr_df <- data.frame(
  time = es_nr$egt,
  att = es_nr$att.egt,
  se = es_nr$se.egt
) %>%
  filter(time >= -8, time <= 15)

p6 <- ggplot(es_nr_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.15, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2.5) +
  geom_line(color = apep_colors[3], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Effect of BC Statute Adoption on Net Establishment Entry",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to BC Statute Adoption",
    y = "ATT (net entry rate)",
    caption = "Note: Net entry = (establishments_t - establishments_{t-1}) / establishments_{t-1}."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 15, 2))

ggsave("../figures/fig6_es_entry.pdf", p6, width = 9, height = 5.5)
cat("  Saved fig6_es_entry.pdf\n")

# ============================================================
# FIGURE 7: Robustness — Drop lobbying states
# ============================================================

cat("--- Figure 7: Robustness event study ---\n")

if (file.exists("../data/rob_es_no_lobby.rds") && file.exists("../data/rob_es_nyt.rds")) {
  es_no_lobby <- readRDS("../data/rob_es_no_lobby.rds")
  es_nyt <- readRDS("../data/rob_es_nyt.rds")

  rob_df <- bind_rows(
    data.frame(time = es_size$egt, att = es_size$att.egt, se = es_size$se.egt,
               spec = "Baseline (never-treated)") %>% filter(time >= -8, time <= 15),
    data.frame(time = es_no_lobby$egt, att = es_no_lobby$att.egt, se = es_no_lobby$se.egt,
               spec = "Drop lobbying states") %>% filter(time >= -8, time <= 15),
    data.frame(time = es_nyt$egt, att = es_nyt$att.egt, se = es_nyt$se.egt,
               spec = "Not-yet-treated controls") %>% filter(time >= -8, time <= 15)
  )

  p7 <- ggplot(rob_df, aes(x = time, y = att, color = spec, shape = spec)) +
    geom_point(size = 2, position = position_dodge(0.4)) +
    geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                  width = 0.3, position = position_dodge(0.4), alpha = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = apep_colors[1:3], name = "Specification") +
    scale_shape_manual(values = c(16, 17, 15), name = "Specification") +
    labs(
      title = "Robustness: Event Study under Alternative Specifications",
      subtitle = "Effect on log average establishment size",
      x = "Years Relative to BC Statute Adoption",
      y = "ATT"
    ) +
    theme_apep() +
    theme(legend.position = "bottom") +
    scale_x_continuous(breaks = seq(-8, 15, 2))

  ggsave("../figures/fig7_robustness_es.pdf", p7, width = 9, height = 6)
  cat("  Saved fig7_robustness_es.pdf\n")
}

# ============================================================
# FIGURE 8: Randomization Inference
# ============================================================

cat("--- Figure 8: Randomization inference ---\n")

if (file.exists("../data/rob_ri.rds")) {
  ri <- readRDS("../data/rob_ri.rds")

  ri_df <- data.frame(att = ri$perm_atts[!is.na(ri$perm_atts)])

  p8 <- ggplot(ri_df, aes(x = att)) +
    geom_histogram(bins = 40, fill = "grey70", color = "white", alpha = 0.8) +
    geom_vline(xintercept = ri$actual_att, color = apep_colors[2],
               linewidth = 1.2, linetype = "solid") +
    annotate("text", x = ri$actual_att, y = Inf,
             label = sprintf("Actual ATT = %.4f\np = %.3f",
                             ri$actual_att, ri$ri_pvalue),
             vjust = 2, hjust = -0.1, size = 3.5, color = apep_colors[2]) +
    labs(
      title = "Randomization Inference: Distribution of Placebo ATTs",
      subtitle = "500 permutations of treatment assignment",
      x = "Permuted ATT (log average establishment size)",
      y = "Count",
      caption = sprintf("p-value = %.3f (fraction of permuted |ATT| >= actual |ATT|).",
                         ri$ri_pvalue)
    ) +
    theme_apep()

  ggsave("../figures/fig8_ri.pdf", p8, width = 8, height = 5)
  cat("  Saved fig8_ri.pdf\n")
}

cat("\n=== ALL FIGURES GENERATED ===\n")
