# ============================================================================
# Technology Obsolescence and Populist Voting
# 05_tables.R - Generate all tables for the paper
# ============================================================================

source("./00_packages.R")

# Load data and models
df <- readRDS("../data/analysis_data.rds")
models <- readRDS("../data/main_models.rds")

# Create tables directory if not exists
dir.create("../tables", showWarnings = FALSE)

cat("Generating tables...\n\n")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("Table 1: Summary statistics\n")

# Key variables summary
summary_stats <- df %>%
  summarize(
    `Trump Vote Share (%)` = sprintf("%.1f (%.1f)", mean(trump_share), sd(trump_share)),
    `Modal Technology Age` = sprintf("%.1f (%.1f)", mean(modal_age_mean), sd(modal_age_mean)),
    `Total Votes (000s)` = sprintf("%.0f (%.0f)", mean(total_votes)/1000, sd(total_votes)/1000),
    `Metropolitan (%)` = sprintf("%.1f", mean(is_metro) * 100)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Mean (SD)")

# By year
summary_by_year <- df %>%
  group_by(year) %>%
  summarize(
    `Trump Vote Share (%)` = sprintf("%.1f (%.1f)", mean(trump_share), sd(trump_share)),
    `Modal Technology Age` = sprintf("%.1f (%.1f)", mean(modal_age_mean), sd(modal_age_mean)),
    `N (CBSAs)` = as.character(n_distinct(cbsa)),
    .groups = "drop"
  )

# Write as LaTeX
sink("../tables/tab1_summary.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & 2016 & 2020 & 2024 \\\\\n")
cat("\\hline\n")
cat(sprintf("Trump Vote Share (\\%%) & %s & %s & %s \\\\\n",
            summary_by_year$`Trump Vote Share (%)`[1],
            summary_by_year$`Trump Vote Share (%)`[2],
            summary_by_year$`Trump Vote Share (%)`[3]))
cat(sprintf("Modal Technology Age & %s & %s & %s \\\\\n",
            summary_by_year$`Modal Technology Age`[1],
            summary_by_year$`Modal Technology Age`[2],
            summary_by_year$`Modal Technology Age`[3]))
cat(sprintf("N (CBSAs) & %s & %s & %s \\\\\n",
            summary_by_year$`N (CBSAs)`[1],
            summary_by_year$`N (CBSAs)`[2],
            summary_by_year$`N (CBSAs)`[3]))
cat("\\hline\n")
cat("\\multicolumn{4}{l}{\\footnotesize Standard deviations in parentheses.} \\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

# ============================================================================
# Table 2: Main Results
# ============================================================================

cat("Table 2: Main regression results\n")

# Re-estimate main models for clean table
m1 <- feols(trump_share ~ modal_age_mean, data = df, cluster = ~cbsa)
m2 <- feols(trump_share ~ modal_age_mean | year, data = df, cluster = ~cbsa)
m3 <- feols(trump_share ~ modal_age_mean + log_total_votes | year, data = df, cluster = ~cbsa)
m4 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year, data = df, cluster = ~cbsa)
m5 <- feols(trump_share ~ modal_age_mean | cbsa + year, data = df, cluster = ~cbsa)

# Create coefficient map
cm <- c(
  "modal_age_mean" = "Modal Technology Age",
  "log_total_votes" = "Log Total Votes",
  "is_metroTRUE" = "Metropolitan"
)

# Generate LaTeX table
modelsummary(
  list("(1)" = m1, "(2)" = m2, "(3)" = m3, "(4)" = m4, "(5)" = m5),
  coef_map = cm,
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "adj.r.squared", "FE: year", "FE: cbsa"),
  output = "../tables/tab2_main_results.tex",
  title = "Technology Age and Trump Vote Share",
  notes = c("Standard errors clustered by CBSA in parentheses.",
            "Dependent variable: Trump vote share (\\%)."),
  escape = FALSE
)

# ============================================================================
# Table 3: By Election Year
# ============================================================================

cat("Table 3: By election year\n")

m_2016 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro,
                data = filter(df, year == 2016), vcov = "hetero")
m_2020 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro,
                data = filter(df, year == 2020), vcov = "hetero")
m_2024 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro,
                data = filter(df, year == 2024), vcov = "hetero")

modelsummary(
  list("2016" = m_2016, "2020" = m_2020, "2024" = m_2024),
  coef_map = cm,
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared"),
  output = "../tables/tab3_by_year.tex",
  title = "Technology Age Effect by Election Year",
  notes = c("Heteroskedasticity-robust standard errors in parentheses.",
            "Dependent variable: Trump vote share (\\%)."),
  escape = FALSE
)

# ============================================================================
# Table 4: Robustness - Metro vs Micro
# ============================================================================

cat("Table 4: Metro vs Micro\n")

m_metro <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
                 data = filter(df, is_metro == TRUE), cluster = ~cbsa)
m_micro <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
                 data = filter(df, is_metro == FALSE), cluster = ~cbsa)

modelsummary(
  list("Metropolitan" = m_metro, "Micropolitan" = m_micro),
  coef_map = c("modal_age_mean" = "Modal Technology Age",
               "log_total_votes" = "Log Total Votes"),
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "FE: year"),
  output = "../tables/tab4_metro_micro.tex",
  title = "Technology Age Effect by CBSA Type",
  notes = c("Standard errors clustered by CBSA in parentheses.",
            "All models include year fixed effects."),
  escape = FALSE
)

# ============================================================================
# Table 5: Regional Heterogeneity
# ============================================================================

cat("Table 5: Regional heterogeneity\n")

m_ne <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
              data = filter(df, region == "Northeast"), cluster = ~cbsa)
m_mw <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
              data = filter(df, region == "Midwest"), cluster = ~cbsa)
m_s <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
             data = filter(df, region == "South"), cluster = ~cbsa)
m_w <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
             data = filter(df, region == "West"), cluster = ~cbsa)

modelsummary(
  list("Northeast" = m_ne, "Midwest" = m_mw, "South" = m_s, "West" = m_w),
  coef_map = c("modal_age_mean" = "Modal Technology Age",
               "log_total_votes" = "Log Total Votes"),
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "FE: year"),
  output = "../tables/tab5_regional.tex",
  title = "Technology Age Effect by Census Region",
  notes = c("Standard errors clustered by CBSA in parentheses.",
            "All models include year fixed effects."),
  escape = FALSE
)

# ============================================================================
# Table 6: Gains Analysis (Causal vs Sorting)
# ============================================================================

cat("Table 6: Gains analysis\n")

# Prepare data
df_controls <- df %>%
  filter(year == 2016) %>%
  select(cbsa, log_total_votes, is_metro)

df_gains <- df %>%
  select(cbsa, year, trump_share, modal_age_mean) %>%
  pivot_wider(names_from = year, values_from = c(trump_share, modal_age_mean)) %>%
  left_join(df_controls, by = "cbsa") %>%
  mutate(
    trump_gain_2016_2020 = trump_share_2020 - trump_share_2016,
    trump_gain_2020_2024 = trump_share_2024 - trump_share_2020
  ) %>%
  filter(!is.na(trump_gain_2016_2020))

m_level <- lm(trump_share_2016 ~ modal_age_mean_2016 + log_total_votes + is_metro, data = df_gains)
m_gain1 <- lm(trump_gain_2016_2020 ~ modal_age_mean_2016 + log_total_votes + is_metro, data = df_gains)
m_gain2 <- lm(trump_gain_2020_2024 ~ modal_age_mean_2020 + log_total_votes + is_metro,
              data = filter(df_gains, !is.na(trump_gain_2020_2024)))

modelsummary(
  list("Level (2016)" = m_level, "Gain (2016-20)" = m_gain1, "Gain (2020-24)" = m_gain2),
  coef_map = c("modal_age_mean_2016" = "Modal Tech Age (2016)",
               "modal_age_mean_2020" = "Modal Tech Age (2020)",
               "log_total_votes" = "Log Total Votes",
               "is_metroTRUE" = "Metropolitan"),
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared"),
  output = "../tables/tab6_gains.tex",
  title = "Technology Age: Levels vs. Gains Analysis",
  notes = c("Standard errors in parentheses.",
            "Column 1: 2016 Trump vote share level.",
            "Columns 2-3: Change in Trump vote share."),
  escape = FALSE
)

# ============================================================================
# Table 7: Population-Weighted Results
# ============================================================================

cat("Table 7: Population-weighted results\n")

m_unweight <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                    data = df, cluster = ~cbsa)
m_weight <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                  data = df, weights = ~total_votes, cluster = ~cbsa)

modelsummary(
  list("Unweighted" = m_unweight, "Population-Weighted" = m_weight),
  coef_map = cm,
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "FE: year"),
  output = "../tables/tab7_weighted.tex",
  title = "Population-Weighted Results",
  notes = c("Standard errors clustered by CBSA in parentheses.",
            "Column 2 weights by total votes cast."),
  escape = FALSE
)

# ============================================================================
# Table 8: Alternative Technology Measures
# ============================================================================

cat("Table 8: Alternative technology measures\n")

m_median <- feols(trump_share ~ modal_age_median + log_total_votes + is_metro | year,
                  data = df, cluster = ~cbsa)
m_p75 <- feols(trump_share ~ modal_age_p75 + log_total_votes + is_metro | year,
               data = df, cluster = ~cbsa)
m_p25 <- feols(trump_share ~ modal_age_p25 + log_total_votes + is_metro | year,
               data = df, cluster = ~cbsa)

modelsummary(
  list("Median" = m_median, "75th Pctl" = m_p75, "25th Pctl" = m_p25),
  coef_map = c("modal_age_median" = "Modal Age (Median)",
               "modal_age_p75" = "Modal Age (75th pctl)",
               "modal_age_p25" = "Modal Age (25th pctl)",
               "log_total_votes" = "Log Total Votes",
               "is_metroTRUE" = "Metropolitan"),
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "FE: year"),
  output = "../tables/tab8_alt_measures.tex",
  title = "Alternative Technology Age Measures",
  notes = c("Standard errors clustered by CBSA in parentheses."),
  escape = FALSE
)

# ============================================================================
# Table 9: Clustering Robustness
# ============================================================================

cat("Table 9: Clustering robustness\n")

m_cbsa <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                data = df, cluster = ~cbsa)
m_state <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                 data = df, cluster = ~state_cluster)
m_twoway <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                  data = df, cluster = ~cbsa + state_cluster)

modelsummary(
  list("CBSA" = m_cbsa, "State" = m_state, "Two-Way" = m_twoway),
  coef_map = cm,
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "FE: year"),
  output = "../tables/tab9_clustering.tex",
  title = "Clustering Robustness",
  notes = c("Different clustering strategies for spatial dependence."),
  escape = FALSE
)

# ============================================================================
# Table 10: Industry Controls
# ============================================================================

cat("Table 10: Industry controls\n")

m_base <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                data = df, cluster = ~cbsa)
m_nsec <- feols(trump_share ~ modal_age_mean + n_sectors + log_total_votes + is_metro | year,
                data = df, cluster = ~cbsa)

modelsummary(
  list("Baseline" = m_base, "+ Sectors" = m_nsec),
  coef_map = c("modal_age_mean" = "Modal Technology Age",
               "n_sectors" = "N Industry Sectors",
               "log_total_votes" = "Log Total Votes",
               "is_metroTRUE" = "Metropolitan"),
  stars = c('*' = .05, '**' = .01, '***' = .001),
  gof_map = c("nobs", "r.squared", "FE: year"),
  output = "../tables/tab10_industry.tex",
  title = "Industry Structure Controls",
  notes = c("Standard errors clustered by CBSA in parentheses."),
  escape = FALSE
)

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("Tables saved to ../tables/\n")
cat("============================================\n")

list.files("../tables/", pattern = "\\.tex$")
