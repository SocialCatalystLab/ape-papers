# ==============================================================================
# Paper 91: Credit, Social Networks, and Political Polarization
# 03_figures_main.R - Main manuscript figures (10 exhibits)
# ==============================================================================

source("00_packages.R")

# Load data
df <- readRDS("../data/analysis_data.rds")
counties_data <- readRDS("../data/counties_data.rds")
friendship_matrix <- readRDS("../data/friendship_matrix.rds")

# State boundaries for maps
states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

# ==============================================================================
# FIGURE 1: CREDIT SCORE MAP OF AMERICA
# ==============================================================================

cat("Creating Figure 1: Credit Score Map...\n")

fig1 <- ggplot(counties_data) +
  geom_sf(aes(fill = credit_score), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Average Credit Score",
    option = "plasma",
    na.value = "grey90",
    limits = c(600, 750),
    oob = scales::squish,
    labels = scales::number_format(accuracy = 1)
  ) +
  labs(
    title = "The Credit Score Map of America",
    subtitle = "County-level average credit scores, 2020",
    caption = "Source: Opportunity Insights Credit Access Data (2020).\nNote: Scores winsorized at 600-750 for visualization."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2.5, "cm"),
    legend.key.height = unit(0.4, "cm"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig1_credit_score_map.pdf", fig1, width = 12, height = 8)
ggsave("../figures/fig1_credit_score_map.png", fig1, width = 12, height = 8, dpi = 300)

# ==============================================================================
# FIGURE 2: ECONOMIC CONNECTEDNESS MAP
# ==============================================================================

cat("Creating Figure 2: Economic Connectedness Map...\n")

fig2 <- ggplot(counties_data) +
  geom_sf(aes(fill = ec), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Economic Connectedness",
    option = "mako",
    direction = -1,
    na.value = "grey90",
    limits = c(0.5, 1.5),
    oob = scales::squish
  ) +
  labs(
    title = "The Social Capital Map of America",
    subtitle = "Economic connectedness: share of high-SES friends among low-SES individuals",
    caption = "Source: Chetty et al. (2022), Social Capital II.\nNote: Higher values indicate more cross-class friendships. Values winsorized at 0.5-1.5."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2.5, "cm"),
    legend.key.height = unit(0.4, "cm"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig2_economic_connectedness_map.pdf", fig2, width = 12, height = 8)
ggsave("../figures/fig2_economic_connectedness_map.png", fig2, width = 12, height = 8, dpi = 300)

# ==============================================================================
# FIGURE 3: DELINQUENCY RATE MAP
# ==============================================================================

cat("Creating Figure 3: Delinquency Rate Map...\n")

fig3 <- ggplot(counties_data) +
  geom_sf(aes(fill = delinquency), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Delinquency Rate",
    option = "rocket",
    direction = -1,
    na.value = "grey90",
    limits = c(0.3, 0.8),
    oob = scales::squish,
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    title = "America's Credit Divide: Debt Delinquency",
    subtitle = "Share of individuals with any delinquent debt, 2020",
    caption = "Source: Opportunity Insights Credit Access Data (2020).\nNote: Values winsorized at 30%-80% for visualization."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2.5, "cm"),
    legend.key.height = unit(0.4, "cm"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig3_delinquency_map.pdf", fig3, width = 12, height = 8)
ggsave("../figures/fig3_delinquency_map.png", fig3, width = 12, height = 8, dpi = 300)

# ==============================================================================
# FIGURE 4: THE FRIENDSHIP MATRIX (100x100 SES)
# ==============================================================================

cat("Creating Figure 4: Friendship Matrix Heatmap...\n")

# Reshape to long format
fm_long <- friendship_matrix %>%
  pivot_longer(
    cols = starts_with("friend_prob"),
    names_to = "friend_percentile",
    values_to = "probability"
  ) %>%
  mutate(
    friend_percentile = as.numeric(gsub("friend_prob_p", "", friend_percentile))
  )

fig4 <- ggplot(fm_long, aes(x = own_ses_percentile, y = friend_percentile, fill = probability)) +
  geom_tile() +
  scale_fill_viridis_c(
    name = "Friendship\nProbability",
    option = "inferno",
    limits = c(0, 0.025),
    oob = scales::squish
  ) +
  scale_x_continuous(breaks = c(1, 25, 50, 75, 100), expand = c(0, 0)) +
  scale_y_continuous(breaks = c(1, 25, 50, 75, 100), expand = c(0, 0)) +
  labs(
    title = "The Friendship Matrix: Who Befriends Whom in America?",
    subtitle = "Probability of friendship by socioeconomic status percentile",
    x = "Own SES Percentile",
    y = "Friend's SES Percentile",
    caption = "Source: Chetty et al. (2022), Social Capital II.\nNote: Based on 21 billion Facebook friendships. Diagonal pattern shows homophily (like befriends like)."
  ) +
  coord_fixed() +
  theme_apep() +
  theme(
    legend.position = "right",
    legend.key.height = unit(2, "cm"),
    panel.grid = element_blank(),
    axis.line = element_blank()
  )

ggsave("../figures/fig4_friendship_matrix.pdf", fig4, width = 9, height = 8)
ggsave("../figures/fig4_friendship_matrix.png", fig4, width = 9, height = 8, dpi = 300)

# ==============================================================================
# FIGURE 5: CREDIT SCORE VS ECONOMIC CONNECTEDNESS
# ==============================================================================

cat("Creating Figure 5: Credit-Social Capital Correlation...\n")

fig5 <- ggplot(df, aes(x = ec, y = credit_score)) +
  geom_point(aes(size = pop2018), alpha = 0.3, color = apep_colors[1]) +
  geom_smooth(method = "lm", color = apep_colors[2], linewidth = 1.5, se = TRUE, fill = apep_colors[2], alpha = 0.2) +
  scale_size_continuous(
    name = "Population",
    range = c(0.5, 5),
    labels = scales::comma,
    guide = guide_legend(override.aes = list(alpha = 0.7))
  ) +
  labs(
    title = "Credit Access and Social Capital Move Together",
    subtitle = sprintf("Correlation: r = %.2f (N = %s counties)",
                       cor(df$credit_score, df$ec, use = "complete.obs"),
                       scales::comma(sum(!is.na(df$credit_score) & !is.na(df$ec)))),
    x = "Economic Connectedness",
    y = "Average Credit Score",
    caption = "Source: Opportunity Insights Credit Access (2020) and Social Capital II (2022).\nNote: Point size proportional to county population."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave("../figures/fig5_credit_social_capital.pdf", fig5, width = 10, height = 7)
ggsave("../figures/fig5_credit_social_capital.png", fig5, width = 10, height = 7, dpi = 300)

# ==============================================================================
# FIGURE 6: GOP VOTE SHARE 2020 MAP
# ==============================================================================

cat("Creating Figure 6: GOP Vote Share 2020 Map...\n")

fig6 <- ggplot(counties_data) +
  geom_sf(aes(fill = pct_gop_2020), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_gradient2(
    name = "GOP Vote Share",
    low = "#2166AC",     # Blue for Democratic
    mid = "#F7F7F7",     # White for 50%
    high = "#B2182B",    # Red for Republican
    midpoint = 0.5,
    limits = c(0.1, 0.9),
    oob = scales::squish,
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    title = "America's Political Geography: 2020 Presidential Election",
    subtitle = "County-level Republican vote share",
    caption = "Source: MIT Election Data and Science Lab.\nNote: Values winsorized at 10%-90% for visualization."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2.5, "cm"),
    legend.key.height = unit(0.4, "cm"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig6_gop_2020_map.pdf", fig6, width = 12, height = 8)
ggsave("../figures/fig6_gop_2020_map.png", fig6, width = 12, height = 8, dpi = 300)

# ==============================================================================
# FIGURE 7: CHANGE IN GOP VOTE SHARE 2016-2024
# ==============================================================================

cat("Creating Figure 7: Political Shift 2016-2024 Map...\n")

fig7 <- ggplot(counties_data) +
  geom_sf(aes(fill = gop_change_16_24), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_gradient2(
    name = "GOP Shift",
    low = "#2166AC",     # Blue for shift toward Democrats
    mid = "#F7F7F7",     # White for no change
    high = "#B2182B",    # Red for shift toward Republicans
    midpoint = 0,
    limits = c(-0.15, 0.15),
    oob = scales::squish,
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    title = "America's Political Shift: 2016 to 2024",
    subtitle = "Change in Republican vote share over three presidential elections",
    caption = "Source: MIT Election Data and Science Lab.\nNote: Positive values indicate shift toward Republicans. Values winsorized at +/-15pp."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2.5, "cm"),
    legend.key.height = unit(0.4, "cm"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig7_gop_shift_16_24_map.pdf", fig7, width = 12, height = 8)
ggsave("../figures/fig7_gop_shift_16_24_map.png", fig7, width = 12, height = 8, dpi = 300)

# ==============================================================================
# FIGURE 8: CREDIT SCORE AND POLITICAL POLARIZATION
# ==============================================================================

cat("Creating Figure 8: Credit Score and Politics...\n")

# Create binned scatter
df_binned_credit <- df %>%
  filter(!is.na(credit_score) & !is.na(pct_gop_2020)) %>%
  mutate(credit_bin = cut(credit_score, breaks = 20)) %>%
  group_by(credit_bin) %>%
  summarize(
    credit_score = mean(credit_score),
    pct_gop_2020 = mean(pct_gop_2020),
    n = n(),
    .groups = "drop"
  )

fig8 <- ggplot() +
  # Raw data
  geom_point(data = df, aes(x = credit_score, y = pct_gop_2020),
             alpha = 0.15, color = "grey50", size = 1) +
  # Binned means
  geom_point(data = df_binned_credit, aes(x = credit_score, y = pct_gop_2020, size = n),
             color = apep_colors[1], alpha = 0.9) +
  # Fit line
  geom_smooth(data = df, aes(x = credit_score, y = pct_gop_2020),
              method = "lm", color = apep_colors[2], linewidth = 1.5, se = TRUE, fill = apep_colors[2], alpha = 0.2) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_size_continuous(name = "N Counties", range = c(2, 8), guide = "none") +
  labs(
    title = "Credit Access and Political Alignment",
    subtitle = sprintf("Correlation: r = %.2f",
                       cor(df$credit_score, df$pct_gop_2020, use = "complete.obs")),
    x = "Average Credit Score",
    y = "GOP Vote Share 2020",
    caption = "Source: Opportunity Insights (2020), MIT Election Lab.\nNote: Large points show binned means. Line shows OLS fit."
  ) +
  theme_apep()

ggsave("../figures/fig8_credit_politics.pdf", fig8, width = 9, height = 7)
ggsave("../figures/fig8_credit_politics.png", fig8, width = 9, height = 7, dpi = 300)

# ==============================================================================
# FIGURE 9: ECONOMIC CONNECTEDNESS AND POLITICAL POLARIZATION
# ==============================================================================

cat("Creating Figure 9: Economic Connectedness and Politics...\n")

# Create binned scatter
df_binned_ec <- df %>%
  filter(!is.na(ec) & !is.na(pct_gop_2020)) %>%
  mutate(ec_bin = cut(ec, breaks = 20)) %>%
  group_by(ec_bin) %>%
  summarize(
    ec = mean(ec),
    pct_gop_2020 = mean(pct_gop_2020),
    n = n(),
    .groups = "drop"
  )

fig9 <- ggplot() +
  # Raw data
  geom_point(data = df, aes(x = ec, y = pct_gop_2020),
             alpha = 0.15, color = "grey50", size = 1) +
  # Binned means
  geom_point(data = df_binned_ec, aes(x = ec, y = pct_gop_2020, size = n),
             color = apep_colors[3], alpha = 0.9) +
  # Fit line
  geom_smooth(data = df, aes(x = ec, y = pct_gop_2020),
              method = "lm", color = apep_colors[2], linewidth = 1.5, se = TRUE, fill = apep_colors[2], alpha = 0.2) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_size_continuous(name = "N Counties", range = c(2, 8), guide = "none") +
  labs(
    title = "Social Capital and Political Alignment",
    subtitle = sprintf("Correlation: r = %.2f",
                       cor(df$ec, df$pct_gop_2020, use = "complete.obs")),
    x = "Economic Connectedness",
    y = "GOP Vote Share 2020",
    caption = "Source: Chetty et al. (2022), MIT Election Lab.\nNote: Higher EC indicates more cross-class friendships. Large points show binned means."
  ) +
  theme_apep()

ggsave("../figures/fig9_ec_politics.pdf", fig9, width = 9, height = 7)
ggsave("../figures/fig9_ec_politics.png", fig9, width = 9, height = 7, dpi = 300)

# ==============================================================================
# FIGURE 10: MULTIDIMENSIONAL CLUSTERING
# ==============================================================================

cat("Creating Figure 10: County Typology...\n")

# Create county typology based on credit, EC, and politics
df_cluster <- df %>%
  filter(!is.na(credit_score_z) & !is.na(ec_z) & !is.na(pct_gop_2020)) %>%
  mutate(
    high_credit = credit_score_z > 0,
    high_ec = ec_z > 0,
    trump_county = pct_gop_2020 > 0.5,
    county_type = case_when(
      high_credit & high_ec & !trump_county ~ "Affluent Blue (High Credit, High EC, Democratic)",
      high_credit & high_ec & trump_county ~ "Prosperous Red (High Credit, High EC, Republican)",
      high_credit & !high_ec & !trump_county ~ "Urban Isolated (High Credit, Low EC, Democratic)",
      high_credit & !high_ec & trump_county ~ "Suburban Red (High Credit, Low EC, Republican)",
      !high_credit & high_ec & !trump_county ~ "Connected Blue (Low Credit, High EC, Democratic)",
      !high_credit & high_ec & trump_county ~ "Rural Connected (Low Credit, High EC, Republican)",
      !high_credit & !high_ec & !trump_county ~ "Struggling Blue (Low Credit, Low EC, Democratic)",
      !high_credit & !high_ec & trump_county ~ "Struggling Red (Low Credit, Low EC, Republican)"
    )
  )

# Join to shapefile
counties_cluster <- counties_data %>%
  left_join(df_cluster %>% select(fips, county_type), by = "fips")

# Define colors
type_colors <- c(
  "Affluent Blue (High Credit, High EC, Democratic)" = "#2166AC",
  "Urban Isolated (High Credit, Low EC, Democratic)" = "#92C5DE",
  "Connected Blue (Low Credit, High EC, Democratic)" = "#4393C3",
  "Struggling Blue (Low Credit, Low EC, Democratic)" = "#D1E5F0",
  "Prosperous Red (High Credit, High EC, Republican)" = "#B2182B",
  "Suburban Red (High Credit, Low EC, Republican)" = "#F4A582",
  "Rural Connected (Low Credit, High EC, Republican)" = "#D6604D",
  "Struggling Red (Low Credit, Low EC, Republican)" = "#FDDBC7"
)

fig10 <- ggplot(counties_cluster) +
  geom_sf(aes(fill = county_type), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_manual(
    name = "County Type",
    values = type_colors,
    na.value = "grey90"
  ) +
  labs(
    title = "America's Divided Counties: A Typology",
    subtitle = "Classification based on credit access, social capital, and 2020 vote",
    caption = "Source: Opportunity Insights, Chetty et al. (2022), MIT Election Lab.\nNote: 'High' = above median. Grey = missing data."
  ) +
  theme_void() +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 8),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  ) +
  guides(fill = guide_legend(ncol = 2))

ggsave("../figures/fig10_county_typology.pdf", fig10, width = 14, height = 9)
ggsave("../figures/fig10_county_typology.png", fig10, width = 14, height = 9, dpi = 300)

# ==============================================================================
# Summary
# ==============================================================================

cat("\n=== MAIN FIGURES COMPLETE ===\n")
cat("Saved 10 figures to ../figures/\n")
cat("  fig1_credit_score_map\n")
cat("  fig2_economic_connectedness_map\n")
cat("  fig3_delinquency_map\n")
cat("  fig4_friendship_matrix\n")
cat("  fig5_credit_social_capital\n")
cat("  fig6_gop_2020_map\n")
cat("  fig7_gop_shift_16_24_map\n")
cat("  fig8_credit_politics\n")
cat("  fig9_ec_politics\n")
cat("  fig10_county_typology\n")
