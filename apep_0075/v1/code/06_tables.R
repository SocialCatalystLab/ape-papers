# =============================================================================
# 06_tables.R
# Generate all tables for the paper
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

source("output/paper_102/code/00_packages.R")

# Load data
state_year <- read_csv(file.path(data_dir, "state_year_panel.csv"), show_col_types = FALSE)
state_chars <- read_csv(file.path(data_dir, "state_characteristics_2010.csv"), show_col_types = FALSE)

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

message("Creating Table 1: Summary statistics...")

# Summary by treatment status
sum_stats <- state_year %>%
  filter(year >= 2010, year <= 2019) %>%
  group_by(ever_treated) %>%
  summarize(
    # Sample
    n_state_years = n(),
    n_states = n_distinct(state),

    # Employment outcomes
    mean_emp_lowwage = mean(emp_rate_lowwage, na.rm = TRUE),
    sd_emp_lowwage = sd(emp_rate_lowwage, na.rm = TRUE),
    mean_emp_all = mean(emp_rate_all, na.rm = TRUE),
    sd_emp_all = sd(emp_rate_all, na.rm = TRUE),
    mean_lfp = mean(lfp_rate_all, na.rm = TRUE),

    # Demographics
    mean_female = mean(pct_female, na.rm = TRUE),
    mean_black = mean(pct_black, na.rm = TRUE),
    mean_hispanic = mean(pct_hispanic, na.rm = TRUE),
    mean_hs_or_less = mean(pct_hs_or_less, na.rm = TRUE),

    # Minimum wage
    mean_mw = mean(eff_mw, na.rm = TRUE),
    sd_mw = sd(eff_mw, na.rm = TRUE),

    .groups = "drop"
  ) %>%
  mutate(
    group = ifelse(ever_treated, "Treated States", "Control States")
  )

# Create formatted table
tab1 <- sum_stats %>%
  select(
    group,
    n_states,
    mean_emp_lowwage, sd_emp_lowwage,
    mean_emp_all,
    mean_lfp,
    mean_mw, sd_mw,
    mean_female, mean_black, mean_hispanic, mean_hs_or_less
  ) %>%
  t() %>%
  as.data.frame()

names(tab1) <- c("Control", "Treated")
tab1$Variable <- c(
  "Number of States",
  "Emp. Rate (Low-Wage 65+)", "  SD",
  "Emp. Rate (All 65+)",
  "LFP Rate (All 65+)",
  "Effective Min. Wage ($)", "  SD",
  "% Female", "% Black", "% Hispanic", "% HS or Less"
)

# Reorder and format
tab1 <- tab1 %>%
  select(Variable, Control, Treated)

write_csv(tab1, file.path(tab_dir, "table1_summary_stats.csv"))

# LaTeX output
sink(file.path(tab_dir, "table1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Treatment Status}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("& Control & Treated \\\\\n")
cat("& States & States \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{3}{l}{\\textit{Panel A: Sample}} \\\\\n")
cat(sprintf("Number of States & %d & %d \\\\\n",
            as.numeric(tab1[tab1$Variable == "Number of States", "Control"]),
            as.numeric(tab1[tab1$Variable == "Number of States", "Treated"])))
cat("\\midrule\n")
cat("\\multicolumn{3}{l}{\\textit{Panel B: Employment Outcomes (2010-2019)}} \\\\\n")
cat(sprintf("Employment Rate (Low-Wage 65+) & %.3f & %.3f \\\\\n",
            as.numeric(tab1[tab1$Variable == "Emp. Rate (Low-Wage 65+)", "Control"]),
            as.numeric(tab1[tab1$Variable == "Emp. Rate (Low-Wage 65+)", "Treated"])))
cat(sprintf("Employment Rate (All 65+) & %.3f & %.3f \\\\\n",
            as.numeric(tab1[tab1$Variable == "Emp. Rate (All 65+)", "Control"]),
            as.numeric(tab1[tab1$Variable == "Emp. Rate (All 65+)", "Treated"])))
cat(sprintf("LFP Rate (All 65+) & %.3f & %.3f \\\\\n",
            as.numeric(tab1[tab1$Variable == "LFP Rate (All 65+)", "Control"]),
            as.numeric(tab1[tab1$Variable == "LFP Rate (All 65+)", "Treated"])))
cat("\\midrule\n")
cat("\\multicolumn{3}{l}{\\textit{Panel C: Demographics}} \\\\\n")
cat(sprintf("\\%% Female & %.1f & %.1f \\\\\n",
            as.numeric(tab1[tab1$Variable == "% Female", "Control"]) * 100,
            as.numeric(tab1[tab1$Variable == "% Female", "Treated"]) * 100))
cat(sprintf("\\%% Black & %.1f & %.1f \\\\\n",
            as.numeric(tab1[tab1$Variable == "% Black", "Control"]) * 100,
            as.numeric(tab1[tab1$Variable == "% Black", "Treated"]) * 100))
cat(sprintf("\\%% Hispanic & %.1f & %.1f \\\\\n",
            as.numeric(tab1[tab1$Variable == "% Hispanic", "Control"]) * 100,
            as.numeric(tab1[tab1$Variable == "% Hispanic", "Treated"]) * 100))
cat(sprintf("\\%% HS or Less & %.1f & %.1f \\\\\n",
            as.numeric(tab1[tab1$Variable == "% HS or Less", "Control"]) * 100,
            as.numeric(tab1[tab1$Variable == "% HS or Less", "Treated"]) * 100))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Note: Sample includes all state-years from 2010-2019. Treated states are those that raised their minimum wage above the federal \\$7.25 floor during the study period. Low-wage elderly workers are defined as those aged 65+ with high school education or less working in service or retail occupations.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  Saved table1_summary_stats.tex")

# =============================================================================
# Table 2: Main Results
# =============================================================================

message("Creating Table 2: Main results...")

# Run regressions
m1 <- feols(
  emp_rate_lowwage ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

m2 <- feols(
  emp_rate_lowwage ~ log_eff_mw | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

m3 <- feols(
  emp_rate_lowedu ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

m4 <- feols(
  emp_rate_all ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

m5 <- feols(
  emp_rate_highedu ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

# Export to LaTeX
etable(m1, m2, m3, m4, m5,
       tex = TRUE,
       style.tex = style.tex("aer"),
       headers = c("Low-Wage", "Log(MW)", "Low-Edu", "All 65+", "High-Edu (Placebo)"),
       fitstat = ~ r2 + n,
       title = "Effect of Minimum Wage Increases on Elderly Employment",
       label = "tab:main_results",
       notes = "State and year fixed effects included. Standard errors clustered by state in parentheses. Low-wage sample: 65+ with HS or less in service/retail. * p<0.1, ** p<0.05, *** p<0.01.",
       file = file.path(tab_dir, "table2_main_results.tex"))

message("  Saved table2_main_results.tex")

# =============================================================================
# Table 3: Robustness Checks
# =============================================================================

message("Creating Table 3: Robustness...")

robustness <- read_csv(file.path(data_dir, "robustness_results.csv"), show_col_types = FALSE)

# Format for LaTeX
sink(file.path(tab_dir, "table3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("Specification & Coefficient & Std. Error \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(robustness)) {
  stars <- ifelse(robustness$p_value[i] < 0.01, "***",
                  ifelse(robustness$p_value[i] < 0.05, "**",
                         ifelse(robustness$p_value[i] < 0.1, "*", "")))
  cat(sprintf("%s & %.4f%s & (%.4f) \\\\\n",
              robustness$specification[i],
              robustness$coefficient[i],
              stars,
              robustness$std_error[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Note: All specifications include state and year fixed effects with standard errors clustered by state. * p<0.1, ** p<0.05, *** p<0.01.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  Saved table3_robustness.tex")

# =============================================================================
# Summary
# =============================================================================

message("\n=== Tables Complete ===")
message("All tables saved to: ", tab_dir)
list.files(tab_dir)
