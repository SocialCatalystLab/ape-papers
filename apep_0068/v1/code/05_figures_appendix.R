# ==============================================================================
# Paper 91: Credit, Social Networks, and Political Polarization
# 05_figures_appendix.R - Appendix figures (10 exhibits)
# ==============================================================================

source("00_packages.R")

# Load data
df <- readRDS("../data/analysis_data.rds")
counties_data <- readRDS("../data/counties_data.rds")

# State boundaries
states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

# ==============================================================================
# FIGURE A1: STUDENT LOAN BALANCE MAP
# ==============================================================================

cat("Creating Figure A1: Student Loan Map...\n")

figA1 <- ggplot(counties_data) +
  geom_sf(aes(fill = student_loan / 1000), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Student Loan\nBalance ($000)",
    option = "viridis",
    na.value = "grey90",
    limits = c(5, 30),
    oob = scales::squish
  ) +
  labs(
    title = "Student Loan Geography",
    subtitle = "Average student loan balance by county, 2020",
    caption = "Source: Opportunity Insights."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
  )

ggsave("../figures/figA1_student_loan_map.pdf", figA1, width = 11, height = 7)

# ==============================================================================
# FIGURE A2: MORTGAGE BALANCE MAP
# ==============================================================================

cat("Creating Figure A2: Mortgage Balance Map...\n")

figA2 <- ggplot(counties_data) +
  geom_sf(aes(fill = mortgage / 1000), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Mortgage\nBalance ($000)",
    option = "plasma",
    na.value = "grey90",
    limits = c(50, 300),
    oob = scales::squish
  ) +
  labs(
    title = "Mortgage Geography",
    subtitle = "Average mortgage balance by county, 2020",
    caption = "Source: Opportunity Insights."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
  )

ggsave("../figures/figA2_mortgage_map.pdf", figA2, width = 11, height = 7)

# ==============================================================================
# FIGURE A3: CREDIT CARD BALANCE MAP
# ==============================================================================

cat("Creating Figure A3: Credit Card Map...\n")

figA3 <- ggplot(counties_data) +
  geom_sf(aes(fill = credit_card / 1000), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Credit Card\nBalance ($000)",
    option = "cividis",
    na.value = "grey90",
    limits = c(2, 10),
    oob = scales::squish
  ) +
  labs(
    title = "Credit Card Geography",
    subtitle = "Average credit card balance by county, 2020",
    caption = "Source: Opportunity Insights."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
  )

ggsave("../figures/figA3_credit_card_map.pdf", figA3, width = 11, height = 7)

# ==============================================================================
# FIGURE A4: AUTO LOAN BALANCE MAP
# ==============================================================================

cat("Creating Figure A4: Auto Loan Map...\n")

figA4 <- ggplot(counties_data) +
  geom_sf(aes(fill = auto_loan / 1000), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    name = "Auto Loan\nBalance ($000)",
    option = "turbo",
    na.value = "grey90",
    limits = c(5, 20),
    oob = scales::squish
  ) +
  labs(
    title = "Auto Loan Geography",
    subtitle = "Average auto loan balance by county, 2020",
    caption = "Source: Opportunity Insights."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
  )

ggsave("../figures/figA4_auto_loan_map.pdf", figA4, width = 11, height = 7)

# ==============================================================================
# FIGURE A5: FRIENDING BIAS MAP
# ==============================================================================

cat("Creating Figure A5: Friending Bias Map...\n")

figA5 <- ggplot(counties_data) +
  geom_sf(aes(fill = friending_bias), color = NA) +
  geom_sf(data = states_sf, fill = NA, color = "white", linewidth = 0.3) +
  scale_fill_gradient2(
    name = "Friending Bias",
    low = "#2166AC",
    mid = "#F7F7F7",
    high = "#B2182B",
    midpoint = 0,
    limits = c(-0.2, 0.2),
    oob = scales::squish
  ) +
  labs(
    title = "Friending Bias Geography",
    subtitle = "Tendency to befriend own-SES after controlling for exposure",
    caption = "Source: Chetty et al. (2022).\nNote: Positive = prefer same-SES friends."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
  )

ggsave("../figures/figA5_friending_bias_map.pdf", figA5, width = 11, height = 7)

# ==============================================================================
# FIGURE A6: URBAN VS RURAL COMPARISON
# ==============================================================================

cat("Creating Figure A6: Urban-Rural Comparison...\n")

df_urban <- df %>%
  mutate(
    density_quartile = ntile(popdensity, 4),
    density_label = case_when(
      density_quartile == 1 ~ "Rural (Q1)",
      density_quartile == 2 ~ "Semi-Rural (Q2)",
      density_quartile == 3 ~ "Semi-Urban (Q3)",
      density_quartile == 4 ~ "Urban (Q4)"
    ),
    density_label = factor(density_label, levels = c("Rural (Q1)", "Semi-Rural (Q2)", "Semi-Urban (Q3)", "Urban (Q4)"))
  ) %>%
  filter(!is.na(density_label))

# Credit by density
p1 <- df_urban %>%
  group_by(density_label) %>%
  summarize(
    mean = mean(credit_score, na.rm = TRUE),
    se = sd(credit_score, na.rm = TRUE) / sqrt(n())
  ) %>%
  ggplot(aes(x = density_label, y = mean)) +
  geom_col(fill = apep_colors[1], alpha = 0.8) +
  geom_errorbar(aes(ymin = mean - 1.96*se, ymax = mean + 1.96*se), width = 0.2) +
  labs(title = "Credit Score", x = NULL, y = "Mean") +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# EC by density
p2 <- df_urban %>%
  group_by(density_label) %>%
  summarize(
    mean = mean(ec, na.rm = TRUE),
    se = sd(ec, na.rm = TRUE) / sqrt(n())
  ) %>%
  ggplot(aes(x = density_label, y = mean)) +
  geom_col(fill = apep_colors[3], alpha = 0.8) +
  geom_errorbar(aes(ymin = mean - 1.96*se, ymax = mean + 1.96*se), width = 0.2) +
  labs(title = "Economic Connectedness", x = NULL, y = "Mean") +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# GOP by density
p3 <- df_urban %>%
  group_by(density_label) %>%
  summarize(
    mean = mean(pct_gop_2020, na.rm = TRUE),
    se = sd(pct_gop_2020, na.rm = TRUE) / sqrt(n())
  ) %>%
  ggplot(aes(x = density_label, y = mean)) +
  geom_col(fill = apep_colors[2], alpha = 0.8) +
  geom_errorbar(aes(ymin = mean - 1.96*se, ymax = mean + 1.96*se), width = 0.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "grey50") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "GOP Vote Share 2020", x = NULL, y = "Mean") +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Delinquency by density
p4 <- df_urban %>%
  group_by(density_label) %>%
  summarize(
    mean = mean(delinquency, na.rm = TRUE),
    se = sd(delinquency, na.rm = TRUE) / sqrt(n())
  ) %>%
  ggplot(aes(x = density_label, y = mean)) +
  geom_col(fill = apep_colors[4], alpha = 0.8) +
  geom_errorbar(aes(ymin = mean - 1.96*se, ymax = mean + 1.96*se), width = 0.2) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Delinquency Rate", x = NULL, y = "Mean") +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

figA6 <- (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title = "Urban-Rural Divide: Key Variables by Population Density Quartile",
    caption = "Source: Opportunity Insights, Chetty et al. (2022), MIT Election Lab.\nNote: Error bars show 95% CI."
  )

ggsave("../figures/figA6_urban_rural.pdf", figA6, width = 11, height = 9)

# ==============================================================================
# FIGURE A7: REGIONAL BREAKDOWN
# ==============================================================================

cat("Creating Figure A7: Regional Breakdown...\n")

# Define regions
df_region <- df %>%
  mutate(
    region = case_when(
      state_fips %in% c("09", "23", "25", "33", "34", "36", "42", "44", "50") ~ "Northeast",
      state_fips %in% c("17", "18", "19", "20", "26", "27", "29", "31", "38", "39", "46", "55") ~ "Midwest",
      state_fips %in% c("01", "05", "10", "11", "12", "13", "21", "22", "24", "28", "37", "40", "45", "47", "48", "51", "54") ~ "South",
      state_fips %in% c("04", "06", "08", "16", "30", "32", "35", "41", "49", "53", "56") ~ "West",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(region))

region_summary <- df_region %>%
  group_by(region) %>%
  summarize(
    n = n(),
    credit_score = mean(credit_score, na.rm = TRUE),
    credit_se = sd(credit_score, na.rm = TRUE) / sqrt(sum(!is.na(credit_score))),
    ec = mean(ec, na.rm = TRUE),
    ec_se = sd(ec, na.rm = TRUE) / sqrt(sum(!is.na(ec))),
    gop_2020 = mean(pct_gop_2020, na.rm = TRUE),
    gop_se = sd(pct_gop_2020, na.rm = TRUE) / sqrt(sum(!is.na(pct_gop_2020))),
    delinquency = mean(delinquency, na.rm = TRUE),
    delinq_se = sd(delinquency, na.rm = TRUE) / sqrt(sum(!is.na(delinquency))),
    .groups = "drop"
  )

# Create faceted plot
region_long <- region_summary %>%
  select(region, credit_score, ec, gop_2020, delinquency) %>%
  pivot_longer(-region, names_to = "variable", values_to = "value") %>%
  mutate(
    variable = case_when(
      variable == "credit_score" ~ "Credit Score",
      variable == "ec" ~ "Econ. Connectedness",
      variable == "gop_2020" ~ "GOP Vote Share",
      variable == "delinquency" ~ "Delinquency Rate"
    ),
    variable = factor(variable, levels = c("Credit Score", "Econ. Connectedness", "GOP Vote Share", "Delinquency Rate"))
  )

figA7 <- ggplot(region_long, aes(x = region, y = value, fill = region)) +
  geom_col(alpha = 0.8) +
  facet_wrap(~variable, scales = "free_y") +
  scale_fill_manual(values = c("Northeast" = apep_colors[1], "Midwest" = apep_colors[3],
                               "South" = apep_colors[2], "West" = apep_colors[4])) +
  labs(
    title = "Regional Variation in Credit, Social Capital, and Politics",
    x = NULL,
    y = "Mean Value",
    caption = "Source: Opportunity Insights, Chetty et al. (2022), MIT Election Lab."
  ) +
  theme_apep() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("../figures/figA7_regional.pdf", figA7, width = 11, height = 8)

# ==============================================================================
# FIGURE A8: CORRELATION HEATMAP
# ==============================================================================

cat("Creating Figure A8: Correlation Heatmap...\n")

cor_vars <- df %>%
  select(
    `Credit Score` = credit_score,
    `Student Loans` = student_loan,
    `Mortgage` = mortgage,
    `Delinquency` = delinquency,
    `Econ. Connect.` = ec,
    `Friending Bias` = friending_bias,
    `Clustering` = clustering,
    `GOP 2020` = pct_gop_2020,
    `GOP Shift` = gop_change_16_24,
    `Income` = hhinc_median_2010,
    `College%` = frac_coll_2010,
    `Pop. Density` = popdensity
  ) %>%
  drop_na()

cor_mat <- cor(cor_vars)

# Convert to long format
cor_long <- as.data.frame(cor_mat) %>%
  rownames_to_column("var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "correlation") %>%
  mutate(
    var1 = factor(var1, levels = colnames(cor_mat)),
    var2 = factor(var2, levels = rev(colnames(cor_mat)))
  )

figA8 <- ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
  geom_tile(color = "white") +
  geom_text(aes(label = sprintf("%.2f", correlation)), size = 2.5) +
  scale_fill_gradient2(
    name = "Correlation",
    low = "#2166AC",
    mid = "white",
    high = "#B2182B",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  labs(
    title = "Correlation Matrix: Credit, Social Capital, and Political Variables",
    x = NULL,
    y = NULL,
    caption = "Source: Opportunity Insights, Chetty et al. (2022), MIT Election Lab."
  ) +
  theme_apep() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
    axis.text.y = element_text(size = 9),
    panel.grid = element_blank(),
    legend.position = "right"
  ) +
  coord_fixed()

ggsave("../figures/figA8_correlation_heatmap.pdf", figA8, width = 10, height = 9)

# ==============================================================================
# FIGURE A9: CHANGE 2016-2020 vs 2020-2024
# ==============================================================================

cat("Creating Figure A9: Political Shift Decomposition...\n")

figA9 <- df %>%
  filter(!is.na(gop_change_16_20) & !is.na(gop_change_20_24)) %>%
  ggplot(aes(x = gop_change_16_20, y = gop_change_20_24)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(aes(color = pct_gop_2020 > 0.5), alpha = 0.3, size = 1) +
  geom_smooth(method = "lm", color = "black", linewidth = 1) +
  scale_color_manual(values = c("TRUE" = "#B2182B", "FALSE" = "#2166AC"),
                     labels = c("TRUE" = "Trump 2020", "FALSE" = "Biden 2020"),
                     name = "2020 Winner") +
  scale_x_continuous(labels = scales::percent_format(), limits = c(-0.2, 0.2)) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(-0.2, 0.2)) +
  labs(
    title = "Political Shifts: 2016-2020 vs 2020-2024",
    subtitle = "Each point is a county",
    x = "GOP Change 2016-2020",
    y = "GOP Change 2020-2024",
    caption = "Source: MIT Election Lab.\nNote: Points in upper-right shifted toward GOP in both periods."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("../figures/figA9_shift_decomposition.pdf", figA9, width = 9, height = 8)

# ==============================================================================
# FIGURE A10: COEFFICIENT STABILITY PLOT
# ==============================================================================

cat("Creating Figure A10: Coefficient Stability...\n")

# Run models with progressively more controls
models_credit <- list(
  feols(pct_gop_2020 ~ credit_score_z, data = df),
  feols(pct_gop_2020 ~ credit_score_z + hhinc_median_2010, data = df),
  feols(pct_gop_2020 ~ credit_score_z + hhinc_median_2010 + frac_coll_2010, data = df),
  feols(pct_gop_2020 ~ credit_score_z + hhinc_median_2010 + frac_coll_2010 + share_white_2010, data = df),
  feols(pct_gop_2020 ~ credit_score_z + hhinc_median_2010 + frac_coll_2010 + share_white_2010 + popdensity, data = df)
)

models_ec <- list(
  feols(pct_gop_2020 ~ ec_z, data = df),
  feols(pct_gop_2020 ~ ec_z + hhinc_median_2010, data = df),
  feols(pct_gop_2020 ~ ec_z + hhinc_median_2010 + frac_coll_2010, data = df),
  feols(pct_gop_2020 ~ ec_z + hhinc_median_2010 + frac_coll_2010 + share_white_2010, data = df),
  feols(pct_gop_2020 ~ ec_z + hhinc_median_2010 + frac_coll_2010 + share_white_2010 + popdensity, data = df)
)

# Extract coefficients
coef_credit <- tibble(
  model = 1:5,
  controls = c("None", "+Income", "+Education", "+Race", "+Density"),
  coef = map_dbl(models_credit, ~coef(.)["credit_score_z"]),
  se = map_dbl(models_credit, ~se(.)["credit_score_z"]),
  variable = "Credit Score"
)

coef_ec <- tibble(
  model = 1:5,
  controls = c("None", "+Income", "+Education", "+Race", "+Density"),
  coef = map_dbl(models_ec, ~coef(.)["ec_z"]),
  se = map_dbl(models_ec, ~se(.)["ec_z"]),
  variable = "Econ. Connectedness"
)

coef_df <- bind_rows(coef_credit, coef_ec) %>%
  mutate(controls = factor(controls, levels = c("None", "+Income", "+Education", "+Race", "+Density")))

figA10 <- ggplot(coef_df, aes(x = controls, y = coef, color = variable, group = variable)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = coef - 1.96*se, ymax = coef + 1.96*se), width = 0.15) +
  scale_color_manual(values = c("Credit Score" = apep_colors[1], "Econ. Connectedness" = apep_colors[3])) +
  labs(
    title = "Coefficient Stability: Adding Controls",
    subtitle = "Effect of 1 SD increase on GOP vote share 2020",
    x = "Controls Added",
    y = "Coefficient",
    color = "Variable",
    caption = "Note: Error bars show 95% CI."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("../figures/figA10_coefficient_stability.pdf", figA10, width = 10, height = 7)

# ==============================================================================
# Summary
# ==============================================================================

cat("\n=== APPENDIX FIGURES COMPLETE ===\n")
cat("Saved 10 appendix figures to ../figures/\n")
cat("  figA1_student_loan_map\n")
cat("  figA2_mortgage_map\n")
cat("  figA3_credit_card_map\n")
cat("  figA4_auto_loan_map\n")
cat("  figA5_friending_bias_map\n")
cat("  figA6_urban_rural\n")
cat("  figA7_regional\n")
cat("  figA8_correlation_heatmap\n")
cat("  figA9_shift_decomposition\n")
cat("  figA10_coefficient_stability\n")
