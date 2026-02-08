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
# Figure 7: Map of Technology Age by CBSA (Geographic Visualization)
# ============================================================================

cat("Figure 7: Generating CBSA maps...\n")

# Set tigris options
options(tigris_use_cache = TRUE)

# Download CBSA shapefiles
cat("  Downloading CBSA shapefiles from Census...\n")
cbsa_shapes <- tryCatch({
  core_based_statistical_areas(cb = TRUE, year = 2020, progress_bar = FALSE)
}, error = function(e) {
  cat("  Warning: Could not download CBSA shapes. Using placeholder figure.\n")
  NULL
})

if (!is.null(cbsa_shapes)) {
  # Clean CBSA code in shapes (GEOID is character)
  cbsa_shapes <- cbsa_shapes %>%
    mutate(cbsa = as.numeric(GEOID))

  # Get 2016 data for maps (key Trump year)
  df_2016 <- df %>%
    filter(year == 2016) %>%
    select(cbsa, cbsa_name, modal_age_mean, trump_share, gop_share_2008, total_votes)

  # Merge with shapes (only continental US)
  cbsa_map <- cbsa_shapes %>%
    inner_join(df_2016, by = "cbsa") %>%
    filter(!grepl("AK|HI|PR|GU|VI|AS|MP", NAME))  # Exclude non-continental

  # Calculate GOP change from 2008
  cbsa_map <- cbsa_map %>%
    mutate(gop_change_2008_2016 = trump_share - gop_share_2008)

  # Figure 7a: Map of Technology Age
  fig7a <- ggplot(cbsa_map) +
    geom_sf(aes(fill = modal_age_mean), color = NA) +
    scale_fill_viridis_c(name = "Modal Tech\nAge (years)", option = "plasma") +
    labs(
      title = "A. Technology Obsolescence by Metropolitan Area (2016)",
      subtitle = "Higher values indicate older/more obsolete technology vintages"
    ) +
    theme_void() +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 12, face = "bold"),
      plot.subtitle = element_text(size = 10)
    )

  # Figure 7b: Map of GOP Vote Change 2008->2016
  fig7b <- ggplot(cbsa_map %>% filter(!is.na(gop_change_2008_2016))) +
    geom_sf(aes(fill = gop_change_2008_2016), color = NA) +
    scale_fill_gradient2(
      name = "GOP Change\n2008-2016 (pp)",
      low = "#377EB8", mid = "white", high = "#E41A1C",
      midpoint = 0
    ) +
    labs(
      title = "B. Republican Vote Share Change, 2008-2016",
      subtitle = "Shift from McCain (2008) to Trump (2016)"
    ) +
    theme_void() +
    theme(
      legend.position = "right",
      plot.title = element_text(size = 12, face = "bold"),
      plot.subtitle = element_text(size = 10)
    )

  # Combine maps
  fig7_combined <- fig7a / fig7b +
    plot_annotation(
      title = "Geographic Distribution of Technology Age and Voting Patterns",
      caption = "Source: Technology data from Hassan et al.; Election data from MIT Election Lab.\nNote: Continental U.S. metropolitan and micropolitan areas only."
    )

  ggsave("../figures/fig7_maps.pdf",
         fig7_combined, width = 10, height = 12)

  # Figure 8: Bivariate scatter with geographic size
  fig8 <- df_2016 %>%
    filter(!is.na(gop_share_2008)) %>%
    mutate(gop_change = trump_share - gop_share_2008) %>%
    ggplot(aes(x = modal_age_mean, y = gop_change, size = total_votes)) +
    geom_point(alpha = 0.4, color = "steelblue") +
    geom_smooth(method = "lm", se = TRUE, color = "#E41A1C", linewidth = 1,
                aes(weight = total_votes)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    scale_size_continuous(range = c(1, 10), labels = scales::comma,
                          name = "Total Votes (2016)") +
    labs(
      title = "Technology Age and GOP Vote Gains, 2008-2016",
      subtitle = "Areas with older technology saw larger shifts toward Trump",
      x = "Modal Technology Age (years)",
      y = "Change in GOP Vote Share 2008-2016 (pp)",
      caption = "Note: Size proportional to total votes. Line shows population-weighted OLS fit."
    ) +
    theme(legend.position = "bottom")

  ggsave("../figures/fig8_tech_vs_change_2008.pdf",
         fig8, width = 10, height = 7)

} else {
  # Fallback if shapefiles unavailable
  fig7 <- df %>%
    filter(year == 2016) %>%
    ggplot(aes(x = modal_age_mean, y = trump_share, size = total_votes)) +
    geom_point(alpha = 0.5, color = "steelblue") +
    scale_size_continuous(range = c(1, 8), labels = scales::comma,
                          name = "Total Votes") +
    labs(
      title = "Technology Age and 2016 Trump Vote Share by CBSA Size",
      x = "Modal Technology Age (years)",
      y = "Trump Vote Share (%)",
      caption = "Note: Point size proportional to total votes cast."
    ) +
    theme(legend.position = "bottom")

  ggsave("../figures/fig7_size_scatter.pdf",
         fig7, width = 10, height = 7)
}

# ============================================================================
# Figure 9: Event-Study Style Plot (Technology Coefficient by Year)
# ============================================================================

cat("Figure 9: Event-study plot\n")

# Run separate regressions by year with 2008 baseline control
years_to_plot <- c(2012, 2016, 2020, 2024)
event_study_results <- list()

for (yr in years_to_plot) {
  df_yr <- df %>%
    filter(year == yr, !is.na(gop_share_2008))

  m_yr <- feols(trump_share ~ modal_age_mean + gop_share_2008 + log_total_votes + is_metro,
                data = df_yr, vcov = "hetero")

  event_study_results[[as.character(yr)]] <- data.frame(
    year = yr,
    coef = coef(m_yr)["modal_age_mean"],
    se = se(m_yr)["modal_age_mean"],
    n = nrow(df_yr)
  )
}

df_event <- bind_rows(event_study_results) %>%
  mutate(
    ci_low = coef - 1.96 * se,
    ci_high = coef + 1.96 * se,
    significant = ifelse(ci_low > 0 | ci_high < 0, "Yes", "No")
  )

fig9 <- df_event %>%
  ggplot(aes(x = year, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(aes(color = significant), size = 4) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high, color = significant),
                width = 0.5, linewidth = 1) +
  scale_color_manual(values = c("Yes" = "#E41A1C", "No" = "gray50"),
                     name = "p < 0.05") +
  scale_x_continuous(breaks = years_to_plot) +
  labs(
    title = "Technology Age Effect on GOP Vote Share by Election Year",
    subtitle = "Controlling for 2008 GOP share (McCain baseline) and CBSA characteristics",
    x = "Election Year",
    y = "Coefficient on Modal Tech Age\n(pp per year of tech age)",
    caption = "Note: 95% confidence intervals shown. All specifications control for\n2008 GOP share, log total votes, and metropolitan indicator."
  ) +
  theme(legend.position = "bottom")

ggsave("../figures/fig9_event_study.pdf",
       fig9, width = 8, height = 6)

# ============================================================================
# Figure 10: 2008 Baseline Control Visualization
# ============================================================================

cat("Figure 10: 2008 baseline control visualization\n")

df_2016_base <- df %>%
  filter(year == 2016, !is.na(gop_share_2008)) %>%
  mutate(
    gop_change_2008 = trump_share - gop_share_2008,
    tech_tercile = cut(modal_age_mean,
                       breaks = quantile(modal_age_mean, c(0, 1/3, 2/3, 1)),
                       labels = c("Low Tech Age", "Medium", "High Tech Age"),
                       include.lowest = TRUE)
  )

fig10 <- df_2016_base %>%
  ggplot(aes(x = gop_share_2008, y = trump_share, color = tech_tercile)) +
  geom_point(alpha = 0.4, size = 2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  scale_color_manual(values = c("Low Tech Age" = "#377EB8",
                                "Medium" = "#984EA3",
                                "High Tech Age" = "#E41A1C"),
                     name = "Technology Age Tercile") +
  labs(
    title = "2016 Trump Vote Share vs 2008 McCain Vote Share",
    subtitle = "Above the 45° line indicates GOP gains since 2008",
    x = "GOP Vote Share 2008 (%)",
    y = "Trump Vote Share 2016 (%)",
    caption = "Note: Diagonal line shows no change from 2008. CBSAs with older technology\n(red) show larger deviations above the line, indicating greater GOP gains."
  ) +
  theme(legend.position = "bottom")

ggsave("../figures/fig10_2008_baseline.pdf",
       fig10, width = 9, height = 7)

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("Figures saved to ../figures/\n")
cat("============================================\n")

list.files("../figures/", pattern = "\\.pdf$")
