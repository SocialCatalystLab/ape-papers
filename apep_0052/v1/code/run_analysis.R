# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# run_analysis.R - Simplified analysis script combining key analyses
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# 1. LOAD AND PREPARE DATA
# ==============================================================================
cat("=== Loading Analysis Data ===\n")

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Loaded: %d place-years, %d places\n",
            nrow(analysis), n_distinct(analysis$st_fips)))

# Filter for balanced sample
df <- analysis %>%
  group_by(st_fips) %>%
  filter(n() >= 3) %>%
  ungroup() %>%
  mutate(
    place_id = as.numeric(factor(st_fips)),
    state_fips = substr(st_fips, 1, 2)
  )

cat(sprintf("  Analysis sample: %d place-years, %d places\n",
            nrow(df), n_distinct(df$st_fips)))

# ==============================================================================
# 2. TWFE ESTIMATES (Simple DiD)
# ==============================================================================
cat("\n=== TWFE Estimates ===\n")

# Main outcomes
twfe_individual <- feols(
  individualizing ~ treat_post | place_id + year,
  data = df,
  cluster = ~state_fips
)

twfe_binding <- feols(
  binding ~ treat_post | place_id + year,
  data = df,
  cluster = ~state_fips
)

twfe_ratio <- feols(
  log_univ_comm ~ treat_post | place_id + year,
  data = df,
  cluster = ~state_fips
)

# Print results
cat("\n  TWFE Results:\n")
etable(twfe_individual, twfe_binding, twfe_ratio,
       headers = c("Individualizing", "Binding", "Log Univ/Comm"),
       fitstat = ~ r2 + n)

# Individual foundations
twfe_care <- feols(care_p ~ treat_post | place_id + year, data = df, cluster = ~state_fips)
twfe_fairness <- feols(fairness_p ~ treat_post | place_id + year, data = df, cluster = ~state_fips)
twfe_loyalty <- feols(loyalty_p ~ treat_post | place_id + year, data = df, cluster = ~state_fips)
twfe_authority <- feols(authority_p ~ treat_post | place_id + year, data = df, cluster = ~state_fips)
twfe_sanctity <- feols(sanctity_p ~ treat_post | place_id + year, data = df, cluster = ~state_fips)

# ==============================================================================
# 3. CREATE EVENT STUDY DATA (Manual)
# ==============================================================================
cat("\n=== Event Study (Manual) ===\n")

# Create event time variables
df_es <- df %>%
  filter(treated) %>%
  mutate(rel_year = year - treat_year) %>%
  filter(rel_year >= -3, rel_year <= 4)

# Run event study regression
es_individual <- feols(
  individualizing ~ i(rel_year, ref = -1) | place_id + year,
  data = df_es,
  cluster = ~state_fips
)

es_binding <- feols(
  binding ~ i(rel_year, ref = -1) | place_id + year,
  data = df_es,
  cluster = ~state_fips
)

# Extract coefficients for plotting
extract_es <- function(model, outcome_name) {
  coefs <- coef(model)
  ses <- se(model)

  # Extract rel_year coefficients
  rel_years <- as.numeric(gsub("rel_year::", "", names(coefs)))

  data.frame(
    outcome = outcome_name,
    time = rel_years,
    att = coefs,
    se = ses
  )
}

es_data <- bind_rows(
  extract_es(es_individual, "Individualizing"),
  extract_es(es_binding, "Binding")
) %>%
  # Add reference period (0 by definition)
  bind_rows(
    data.frame(outcome = c("Individualizing", "Binding"),
               time = c(-1, -1), att = c(0, 0), se = c(0, 0))
  ) %>%
  arrange(outcome, time)

write_csv(es_data, "data/event_study_data.csv")
cat("  Event study data saved\n")

# ==============================================================================
# 4. SUMMARY STATISTICS
# ==============================================================================
cat("\n=== Summary Statistics ===\n")

summary_stats <- df %>%
  summarise(
    `N place-years` = n(),
    `N places` = n_distinct(st_fips),
    `N states` = n_distinct(state_fips),
    `Years` = paste(min(year), "-", max(year)),
    `Mean broadband rate` = mean(broadband_rate, na.rm = TRUE),
    `SD broadband rate` = sd(broadband_rate, na.rm = TRUE),
    `Mean individualizing` = mean(individualizing, na.rm = TRUE),
    `Mean binding` = mean(binding, na.rm = TRUE),
    `Pct treated` = mean(treated) * 100
  )

print(summary_stats)

# ==============================================================================
# 5. SAVE RESULTS
# ==============================================================================
cat("\n=== Saving Results ===\n")

# Main results table
results_table <- tibble(
  Outcome = c("Individualizing", "Binding", "Log Univ/Comm",
              "Care", "Fairness", "Loyalty", "Authority", "Sanctity"),
  ATT = c(coef(twfe_individual)["treat_post"],
          coef(twfe_binding)["treat_post"],
          coef(twfe_ratio)["treat_post"],
          coef(twfe_care)["treat_post"],
          coef(twfe_fairness)["treat_post"],
          coef(twfe_loyalty)["treat_post"],
          coef(twfe_authority)["treat_post"],
          coef(twfe_sanctity)["treat_post"]),
  SE = c(se(twfe_individual)["treat_post"],
         se(twfe_binding)["treat_post"],
         se(twfe_ratio)["treat_post"],
         se(twfe_care)["treat_post"],
         se(twfe_fairness)["treat_post"],
         se(twfe_loyalty)["treat_post"],
         se(twfe_authority)["treat_post"],
         se(twfe_sanctity)["treat_post"]),
  Estimator = "TWFE"
) %>%
  mutate(
    t_stat = ATT / SE,
    p_value = 2 * (1 - pnorm(abs(t_stat))),
    sig = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    )
  )

print(results_table)
write_csv(results_table, "tables/main_results.csv")

# Save R objects
save(twfe_individual, twfe_binding, twfe_ratio,
     twfe_care, twfe_fairness, twfe_loyalty, twfe_authority, twfe_sanctity,
     es_individual, es_binding,
     file = "data/analysis_results.RData")

cat("\n=== Analysis Complete ===\n")

# ==============================================================================
# 6. GENERATE FIGURES
# ==============================================================================
cat("\n=== Generating Figures ===\n")

# Figure 1: Broadband adoption
fig1a <- df %>%
  group_by(year) %>%
  summarise(mean_bb = mean(broadband_rate, na.rm = TRUE),
            se = sd(broadband_rate, na.rm = TRUE) / sqrt(n()),
            .groups = "drop") %>%
  ggplot(aes(x = year, y = mean_bb)) +
  geom_ribbon(aes(ymin = mean_bb - 1.96*se, ymax = mean_bb + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_hline(yintercept = 0.70, linetype = "dashed", color = "grey40") +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(title = "Figure 1: Broadband Adoption Over Time",
       x = "Year", y = "Broadband Subscription Rate") +
  theme_apep()

ggsave("figures/fig1_broadband.pdf", fig1a, width = 8, height = 5)
ggsave("figures/fig1_broadband.png", fig1a, width = 8, height = 5, dpi = 300)

# Figure 2: Trends by treatment status
fig2 <- df %>%
  mutate(group = ifelse(treated, "Treated", "Never Treated")) %>%
  group_by(year, group) %>%
  summarise(
    individualizing = mean(individualizing, na.rm = TRUE),
    binding = mean(binding, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(c(individualizing, binding), names_to = "outcome", values_to = "value") %>%
  ggplot(aes(x = year, y = value, color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~outcome, scales = "free_y", ncol = 1,
             labeller = labeller(outcome = c(individualizing = "Individualizing",
                                              binding = "Binding"))) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
  labs(title = "Figure 2: Moral Foundations by Treatment Status",
       x = "Year", y = "Score (per 1,000 words)",
       color = "", linetype = "") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/fig2_trends.pdf", fig2, width = 8, height = 8)
ggsave("figures/fig2_trends.png", fig2, width = 8, height = 8, dpi = 300)

# Figure 3: Event study - Individualizing
es_ind <- es_data %>% filter(outcome == "Individualizing")

fig3 <- ggplot(es_ind, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(title = "Figure 3: Event Study — Individualizing Foundations",
       subtitle = "Effect of crossing 70% broadband threshold",
       x = "Years Relative to Treatment",
       y = "ATT") +
  theme_apep()

ggsave("figures/fig3_event_individual.pdf", fig3, width = 8, height = 5)
ggsave("figures/fig3_event_individual.png", fig3, width = 8, height = 5, dpi = 300)

# Figure 4: Event study - Binding
es_bind <- es_data %>% filter(outcome == "Binding")

fig4 <- ggplot(es_bind, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(title = "Figure 4: Event Study — Binding Foundations",
       subtitle = "Effect of crossing 70% broadband threshold",
       x = "Years Relative to Treatment",
       y = "ATT") +
  theme_apep()

ggsave("figures/fig4_event_binding.pdf", fig4, width = 8, height = 5)
ggsave("figures/fig4_event_binding.png", fig4, width = 8, height = 5, dpi = 300)

# Figure 5: Coefficient plot for all foundations
fig5 <- results_table %>%
  filter(Outcome %in% c("Care", "Fairness", "Loyalty", "Authority", "Sanctity")) %>%
  mutate(
    Type = ifelse(Outcome %in% c("Care", "Fairness"), "Individualizing", "Binding"),
    Outcome = factor(Outcome, levels = c("Care", "Fairness", "Loyalty", "Authority", "Sanctity"))
  ) %>%
  ggplot(aes(x = Outcome, y = ATT, color = Type)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_pointrange(aes(ymin = ATT - 1.96*SE, ymax = ATT + 1.96*SE), size = 0.8) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
  labs(title = "Figure 5: Effects on Individual Moral Foundations",
       x = "", y = "Treatment Effect (ATT)",
       color = "Foundation Type") +
  theme_apep() +
  coord_flip()

ggsave("figures/fig5_foundations.pdf", fig5, width = 8, height = 5)
ggsave("figures/fig5_foundations.png", fig5, width = 8, height = 5, dpi = 300)

cat("  Figures saved to figures/\n")

# ==============================================================================
# 7. GENERATE TABLES (LaTeX)
# ==============================================================================
cat("\n=== Generating Tables ===\n")

# Table 1: Summary statistics
tab1 <- df %>%
  summarise(
    across(c(broadband_rate, individualizing, binding, care_p, fairness_p,
             loyalty_p, authority_p, sanctity_p, n_meetings),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE),
                min = ~min(., na.rm = TRUE),
                max = ~max(., na.rm = TRUE)))
  ) %>%
  pivot_longer(everything()) %>%
  separate(name, into = c("variable", "stat"), sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = stat, values_from = value) %>%
  mutate(across(where(is.numeric), ~round(., 4)))

write_csv(tab1, "tables/tab1_summary.csv")

# Table 3: Main results (LaTeX)
setFixest_dict(c(treat_post = "Treated $\\times$ Post"))

etable(twfe_individual, twfe_binding, twfe_ratio,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Effect of Broadband on Moral Foundations",
       label = "tab:main",
       file = "tables/tab3_main.tex")

cat("  Tables saved to tables/\n")

cat("\n=== All Analysis and Output Generation Complete ===\n")
