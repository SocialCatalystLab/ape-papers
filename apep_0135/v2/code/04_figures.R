# ============================================================================
# Technology Obsolescence and Populist Voting
# 04_figures.R - Generate all figures for the paper
# ============================================================================

source("./00_packages.R")

# Load data
df <- readRDS("../data/analysis_data.rds")
models <- readRDS("../data/main_models.rds")

# Create figures directory if not exists
dir.create("../figures", showWarnings = FALSE)

cat("Generating figures...\n\n")

# ============================================================================
# Figure 1: Distribution of Modal Technology Age
# ============================================================================

cat("Figure 1: Technology age distribution\n")

fig1 <- df %>%
  ggplot(aes(x = modal_age_mean)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white", alpha = 0.8) +
  facet_wrap(~year, ncol = 3) +
  labs(
    title = "Distribution of Modal Technology Age Across U.S. Metropolitan Areas",
    subtitle = "Higher values indicate older (more obsolete) technology",
    x = "Modal Technology Age (years)",
    y = "Number of CBSAs",
    caption = "Source: Authors' calculations from modal_age.dta"
  ) +
  theme(plot.title = element_text(size = 14))

ggsave("../figures/fig1_tech_age_distribution.pdf",
       fig1, width = 10, height = 4)

# ============================================================================
# Figure 2: Scatter plot of Tech Age vs Trump Vote Share
# ============================================================================

cat("Figure 2: Tech age vs Trump share scatter\n")

fig2 <- df %>%
  ggplot(aes(x = modal_age_mean, y = trump_share)) +
  geom_point(alpha = 0.3, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE, color = "#E41A1C", linewidth = 1) +
  facet_wrap(~year, ncol = 3) +
  labs(
    title = "Technology Obsolescence and Trump Vote Share",
    subtitle = "Each point represents a Core-Based Statistical Area (CBSA)",
    x = "Modal Technology Age (years)",
    y = "Trump/Republican Vote Share (%)",
    caption = "Note: Lines show OLS fit with 95% confidence interval."
  ) +
  theme(plot.title = element_text(size = 14))

ggsave("../figures/fig2_scatter_tech_trump.pdf",
       fig2, width = 10, height = 4)

# ============================================================================
# Figure 3: Binned scatter plot (cleaner visualization)
# ============================================================================

cat("Figure 3: Binned scatter plot\n")

# Create ventiles (20 bins) of tech age
df_binned <- df %>%
  group_by(year) %>%
  mutate(tech_ventile = ntile(modal_age_mean, 20)) %>%
  group_by(year, tech_ventile) %>%
  summarize(
    mean_tech_age = mean(modal_age_mean),
    mean_trump_share = mean(trump_share),
    se_trump_share = sd(trump_share) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

fig3 <- df_binned %>%
  ggplot(aes(x = mean_tech_age, y = mean_trump_share)) +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = mean_trump_share - 1.96*se_trump_share,
                    ymax = mean_trump_share + 1.96*se_trump_share),
                width = 0.5, alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "#E41A1C", linewidth = 1) +
  facet_wrap(~year, ncol = 3) +
  labs(
    title = "Technology Age and Trump Vote Share (Binscatter)",
    subtitle = "Each point represents the mean of a ventile (5%) of CBSAs by technology age",
    x = "Mean Modal Technology Age (years)",
    y = "Mean Trump Vote Share (%)",
    caption = "Note: Error bars show 95% confidence intervals for mean vote share within each bin."
  ) +
  theme(plot.title = element_text(size = 14))

ggsave("../figures/fig3_binscatter.pdf",
       fig3, width = 10, height = 4)

# ============================================================================
# Figure 4: Technology terciles and vote shares
# ============================================================================

cat("Figure 4: Technology terciles\n")

df_terciles <- df %>%
  group_by(year, tech_tercile_label) %>%
  summarize(
    mean_trump = mean(trump_share),
    se_trump = sd(trump_share) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    tech_tercile_label = factor(tech_tercile_label,
                                 levels = c("Low (Young Tech)", "Medium", "High (Old Tech)"))
  )

fig4 <- df_terciles %>%
  ggplot(aes(x = tech_tercile_label, y = mean_trump, fill = tech_tercile_label)) +
  geom_col(position = "dodge", alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_trump - 1.96*se_trump,
                    ymax = mean_trump + 1.96*se_trump),
                width = 0.2, position = position_dodge(0.9)) +
  facet_wrap(~year) +
  scale_fill_manual(values = c("Low (Young Tech)" = "#377EB8",
                               "Medium" = "#984EA3",
                               "High (Old Tech)" = "#E41A1C")) +
  labs(
    title = "Trump Vote Share by Technology Age Category",
    subtitle = "CBSAs grouped into terciles based on modal technology age",
    x = "",
    y = "Mean Trump Vote Share (%)",
    fill = "Technology Age",
    caption = "Note: Error bars show 95% confidence intervals."
  ) +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 15, hjust = 1),
    plot.title = element_text(size = 14)
  )

ggsave("../figures/fig4_terciles.pdf",
       fig4, width = 10, height = 5)

# ============================================================================
# Figure 5: Regional heterogeneity
# ============================================================================

cat("Figure 5: Regional heterogeneity\n")

# Run regional regressions with clustered SEs
regions <- c("Northeast", "Midwest", "South", "West")
results <- list()

for (reg in regions) {
  df_reg <- df %>% filter(region == reg)
  m <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
             data = df_reg, cluster = ~cbsa)
  results[[reg]] <- data.frame(
    region = reg,
    coef = coef(m)["modal_age_mean"],
    se = se(m)["modal_age_mean"]
  )
}

df_region <- bind_rows(results) %>%
  mutate(
    region = factor(region, levels = regions),
    sig = ifelse(abs(coef/se) > 1.96, "Significant", "Not significant")
  )

fig5 <- df_region %>%
  ggplot(aes(x = region, y = coef, fill = sig)) +
  geom_col(alpha = 0.8) +
  geom_errorbar(aes(ymin = coef - 1.96*se, ymax = coef + 1.96*se),
                width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_fill_manual(values = c("Significant" = "steelblue", "Not significant" = "gray60")) +
  labs(
    title = "Technology Age Effect on Trump Vote Share by Region",
    subtitle = "Coefficient from regressing Trump share on modal technology age",
    x = "",
    y = "Coefficient (pp per year of tech age)",
    fill = "",
    caption = "Note: Error bars show 95% confidence intervals. Clustered SEs by CBSA."
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14)
  )

ggsave("../figures/fig5_regional.pdf",
       fig5, width = 8, height = 5)

# ============================================================================
# Figure 6: Gains analysis (testing for causal vs sorting)
# ============================================================================

cat("Figure 6: Gains analysis\n")

# Prepare gains data
df_controls <- df %>%
  filter(year == 2012) %>%
  select(cbsa, log_total_votes, is_metro)

df_gains <- df %>%
  select(cbsa, year, trump_share, modal_age_mean) %>%
  pivot_wider(names_from = year, values_from = c(trump_share, modal_age_mean)) %>%
  left_join(df_controls, by = "cbsa") %>%
  mutate(
    # 2012->2016 gains (Romney to Trump - the key Trump effect)
    gop_gain_2012_2016 = trump_share_2016 - trump_share_2012,
    # 2016->2020 gains (Trump to Trump)
    trump_gain_2016_2020 = trump_share_2020 - trump_share_2016
  ) %>%
  filter(!is.na(gop_gain_2012_2016))

# Panel A: 2012 tech age vs 2012-2016 gains (Romney to Trump transition)
fig6a <- df_gains %>%
  ggplot(aes(x = modal_age_mean_2012, y = gop_gain_2012_2016)) +
  geom_point(alpha = 0.3, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE, color = "#E41A1C") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    title = "A. Technology Age vs. GOP Gains (2012-2016)",
    subtitle = "Romney to Trump transition",
    x = "Modal Technology Age in 2011 (years)",
    y = "Change in GOP Vote Share (pp)"
  )

# Panel B: 2016 tech age vs 2016-2020 gains
fig6b <- df_gains %>%
  filter(!is.na(trump_gain_2016_2020)) %>%
  ggplot(aes(x = modal_age_mean_2016, y = trump_gain_2016_2020)) +
  geom_point(alpha = 0.3, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE, color = "#377EB8") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    title = "B. Technology Age vs. Trump Gains (2016-2020)",
    subtitle = "Within Trump era",
    x = "Modal Technology Age in 2015 (years)",
    y = "Change in Trump Vote Share (pp)"
  )

fig6 <- fig6a + fig6b +
  plot_annotation(
    title = "Testing Causal vs. Sorting: Technology Age and Voting Gains",
    subtitle = "Tech age predicts gains from 2012-2016 (A) but not subsequent gains (B)",
    caption = "Note: Lines show OLS fit with 95% CI. The positive effect in Panel A suggests the Trump-specific effect of old technology."
  )

ggsave("../figures/fig6_gains_vs_levels.pdf",
       fig6, width = 12, height = 5)

# ============================================================================
# Figure 7: Map of technology age and Trump share
# ============================================================================

cat("Figure 7: Skipping map (requires shape files)\n")

# Note: Full map would require CBSA shapefiles
# For now, create a simple scatter by CBSA size

fig7 <- df %>%
  filter(year == 2020) %>%
  ggplot(aes(x = modal_age_mean, y = trump_share, size = total_votes, color = is_metro)) +
  geom_point(alpha = 0.5) +
  scale_size_continuous(range = c(1, 8), labels = scales::comma,
                        name = "Total Votes") +
  scale_color_manual(values = c("TRUE" = "steelblue", "FALSE" = "coral"),
                     labels = c("TRUE" = "Metropolitan", "FALSE" = "Micropolitan"),
                     name = "CBSA Type") +
  labs(
    title = "Technology Age and 2020 Trump Vote Share by CBSA Size",
    x = "Modal Technology Age (years)",
    y = "Trump Vote Share (%)",
    caption = "Note: Point size proportional to total votes cast."
  ) +
  theme(legend.position = "bottom")

ggsave("../figures/fig7_size_scatter.pdf",
       fig7, width = 10, height = 7)

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("Figures saved to ../figures/\n")
cat("============================================\n")

list.files("../figures/", pattern = "\\.pdf$")
