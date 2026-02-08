# =============================================================================
# Paper 83: Social Security at 62 and Civic Engagement (Revision of apep_0081)
# 03_main_analysis.R - Main RDD analysis with discrete-RD corrections
# =============================================================================
#
# KEY REVISION: This paper addresses the discrete running variable problem.
# Age is observed in integer years (16 values: 55-70), so standard RD
# asymptotics (which assume continuous running variable) may not hold.
# We implement multiple inference approaches:
#   1. Standard rdrobust (baseline, potentially overstates precision)
#   2. Clustered SEs by age (accounts for age-cell dependence)
#   3. Clustered SEs by age x year
#   4. Age-cell-level estimation (collapse to cells)
# See Kolesar & Rothe (2018, AER) for methodological details.
# =============================================================================

source("00_packages.R")

cat("=" %>% strrep(70), "\n")
cat("Main RDD Analysis: Social Security at 62 and Time Use\n")
cat("WITH DISCRETE-RD CORRECTIONS\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# Load data
# -----------------------------------------------------------------------------

atus <- readRDS(paste0(data_dir, "atus_analysis.rds"))
cat("Loaded", nrow(atus), "observations\n")
cat("Age range:", min(atus$age), "-", max(atus$age), "\n")
cat("Number of unique age values:", length(unique(atus$age)), "\n\n")

# Create centered age and interaction terms
atus <- atus %>%
  mutate(
    age_centered = age - 62,  # Center at cutoff
    age_x_post = age_centered * post62,
    age_year = interaction(age, year, drop = TRUE)  # For clustering
  )

# -----------------------------------------------------------------------------
# 1. Descriptive: Age-Cell Means (Critical for Discrete RD)
# -----------------------------------------------------------------------------

cat("--- 1. Age-Cell Level Summary Statistics ---\n")

# Mean outcomes by age (this is the level at which identification operates)
by_age <- atus %>%
  group_by(age) %>%
  summarise(
    n = n(),
    # Volunteering
    volunteer_rate = mean(any_volunteer),
    volunteer_mins = mean(volunteer_mins),
    # Grandchild care
    grandchild_rate = mean(any_care_grandchild),
    grandchild_mins = mean(care_nonhh_child_mins),
    # Total pro-social
    prosocial_rate = mean(any_prosocial),
    prosocial_mins = mean(total_prosocial_mins),
    # SEs (within-cell)
    volunteer_se = sd(any_volunteer) / sqrt(n()),
    # Treatment indicator
    post62 = first(post62),
    age_centered = first(age_centered),
    .groups = "drop"
  )

cat("\nAge-cell summary:\n")
print(by_age %>% select(age, n, volunteer_rate, volunteer_se, post62))

# Age-cell level means for cell-level estimation
by_age_year <- atus %>%
  group_by(age, year) %>%
  summarise(
    n = n(),
    volunteer_rate = mean(any_volunteer),
    volunteer_mins = mean(volunteer_mins),
    grandchild_rate = mean(any_care_grandchild),
    prosocial_rate = mean(any_prosocial),
    female = mean(female),
    college = mean(college),
    white = mean(white),
    married = mean(married, na.rm = TRUE),
    weekday = mean(weekday),
    post62 = first(post62),
    age_centered = first(age_centered),
    .groups = "drop"
  ) %>%
  mutate(age_x_post = age_centered * post62)

cat("\nNumber of age-year cells:", nrow(by_age_year), "\n")
cat("Years covered:", min(by_age_year$year), "-", max(by_age_year$year), "\n\n")

# -----------------------------------------------------------------------------
# 2. Descriptive Figures
# -----------------------------------------------------------------------------

cat("--- 2. Creating Discontinuity Plots ---\n")

# Plot 1: Volunteering Rate by Age with CIs
p_vol_rate <- ggplot(by_age, aes(x = age, y = volunteer_rate * 100)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = apep_colors["primary"]) +
  geom_errorbar(
    aes(ymin = (volunteer_rate - 1.96*volunteer_se) * 100,
        ymax = (volunteer_rate + 1.96*volunteer_se) * 100),
    width = 0.2, color = apep_colors["primary"]
  ) +
  geom_smooth(data = filter(by_age, age < 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  geom_smooth(data = filter(by_age, age >= 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  labs(
    title = "Volunteering Rate by Age",
    subtitle = "ATUS 2003-2023, Ages 55-70 (N = 57,900)",
    x = "Age",
    y = "Percent Volunteering (%)",
    caption = "Note: Dashed line at age 62 (SS early retirement eligibility). Error bars show 95% CI."
  ) +
  scale_x_continuous(breaks = seq(55, 70, 2)) +
  theme_apep()

ggsave(paste0(fig_dir, "fig1_volunteer_rate_raw.pdf"), p_vol_rate, width = 8, height = 5)
ggsave(paste0(fig_dir, "fig1_volunteer_rate_raw.png"), p_vol_rate, width = 8, height = 5, dpi = 300)
cat("Saved: fig1_volunteer_rate_raw.pdf\n")

# Plot 2: Volunteering Minutes
p_vol_mins <- ggplot(by_age, aes(x = age, y = volunteer_mins)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = apep_colors["primary"]) +
  geom_smooth(data = filter(by_age, age < 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  geom_smooth(data = filter(by_age, age >= 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  labs(
    title = "Minutes Volunteering by Age",
    subtitle = "ATUS 2003-2023, Ages 55-70",
    x = "Age",
    y = "Minutes per Day"
  ) +
  scale_x_continuous(breaks = seq(55, 70, 2)) +
  theme_apep()

ggsave(paste0(fig_dir, "fig2_volunteer_mins_raw.pdf"), p_vol_mins, width = 8, height = 5)
cat("Saved: fig2_volunteer_mins_raw.pdf\n")

# -----------------------------------------------------------------------------
# 3. RDD Estimation using rdrobust (BASELINE - May Overstate Precision)
# -----------------------------------------------------------------------------

cat("\n--- 3. Baseline rdrobust Estimates (Standard Inference) ---\n")
cat("WARNING: Standard rdrobust assumes continuous running variable.\n")
cat("         With 16 discrete age values, SEs may be too small.\n\n")

# Primary outcome: Any volunteering
cat("=== Primary Outcome: Any Volunteering ===\n")
rd_vol <- rdrobust(
  y = atus$any_volunteer,
  x = atus$age,
  c = 62,
  kernel = "triangular",
  all = TRUE
)
print(summary(rd_vol))

# Save RDD plot data
rd_vol_plot <- rdplot(
  y = atus$any_volunteer,
  x = atus$age,
  c = 62,
  title = "RDD: Volunteering at Age 62",
  x.label = "Age",
  y.label = "Probability of Volunteering"
)
ggsave(paste0(fig_dir, "fig3_rdd_volunteer.pdf"), rd_vol_plot$rdplot, width = 8, height = 5)
cat("Saved: fig3_rdd_volunteer.pdf\n")

# Secondary outcomes
cat("\n=== Secondary Outcome: Volunteering Minutes ===\n")
rd_vol_mins <- rdrobust(
  y = atus$volunteer_mins,
  x = atus$age,
  c = 62,
  kernel = "triangular",
  all = TRUE
)
print(summary(rd_vol_mins))

cat("\n=== Secondary Outcome: Any Grandchild Care ===\n")
rd_care <- rdrobust(
  y = atus$any_care_grandchild,
  x = atus$age,
  c = 62,
  kernel = "triangular",
  all = TRUE
)
print(summary(rd_care))

cat("\n=== Secondary Outcome: Any Pro-Social Activity ===\n")
rd_prosocial <- rdrobust(
  y = atus$any_prosocial,
  x = atus$age,
  c = 62,
  kernel = "triangular",
  all = TRUE
)
print(summary(rd_prosocial))

# -----------------------------------------------------------------------------
# 4. Parametric RDD with CLUSTERED Standard Errors
# -----------------------------------------------------------------------------

cat("\n--- 4. Parametric RDD with Clustered Standard Errors ---\n")
cat("Clustering accounts for within-age-cell correlation.\n")
cat("This is more appropriate for discrete running variables.\n\n")

# Model 1: HC1 (heteroskedasticity-robust, ignores clustering)
m1_hc1 <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus,
  vcov = "HC1"
)

# Model 2: Clustered by age (16 clusters)
m2_age <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus,
  cluster = ~age
)

# Model 3: Clustered by age x year (~336 clusters)
m3_age_year <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus,
  cluster = ~age_year
)

# Model 4: With controls, clustered by age
m4_controls_age <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post +
    female + college + white + married + weekday,
  data = atus,
  cluster = ~age
)

# Model 5: With controls + year FE, clustered by age
m5_fe_age <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post +
    female + college + white + married + weekday | year,
  data = atus,
  cluster = ~age
)

# Display comparison
cat("\n=== Comparison: HC1 vs Clustered SEs ===\n")
etable(m1_hc1, m2_age, m3_age_year, m4_controls_age, m5_fe_age,
       headers = c("HC1", "Cluster: Age", "Cluster: Age×Year",
                   "+Controls (Age)", "+Year FE (Age)"),
       keep = c("post62"),
       fitstat = c("n", "r2"))

# Note the SE inflation when clustering by age
cat("\nKey observation:\n")
cat("  HC1 SE for post62:         ", round(m1_hc1$se[1], 4), "\n")
cat("  Clustered(age) SE:         ", round(m2_age$se[1], 4), "\n")
cat("  Ratio (clustered/HC1):     ", round(m2_age$se[1] / m1_hc1$se[1], 2), "x\n\n")

# -----------------------------------------------------------------------------
# 5. Age-Cell-Level Estimation (Collapsed Data)
# -----------------------------------------------------------------------------

cat("\n--- 5. Age-Cell-Level Estimation ---\n")
cat("Collapse data to age-year cells. This directly shows precision.\n\n")

# Weighted regression on age-year cells
m_cell <- lm(
  volunteer_rate ~ post62 + age_centered + age_x_post,
  data = by_age_year,
  weights = n
)
m_cell_robust <- coeftest(m_cell, vcov = vcovHC(m_cell, type = "HC1"))

cat("Cell-level regression (weighted by cell size):\n")
print(m_cell_robust)

# Also run on age-level cells (16 observations only!)
m_age_only <- lm(
  volunteer_rate ~ post62 + age_centered + I(age_centered * post62),
  data = by_age,
  weights = n
)
m_age_robust <- coeftest(m_age_only, vcov = vcovHC(m_age_only, type = "HC1"))

cat("\n16-observation age-cell regression:\n")
print(m_age_robust)
cat("\nWARNING: With only 16 observations, this is very low power.\n")

# -----------------------------------------------------------------------------
# 6. Summary Table with Multiple Inference Methods
# -----------------------------------------------------------------------------

cat("\n--- 6. Summary: Effect of SS Eligibility on Volunteering ---\n")

inference_summary <- data.frame(
  Method = c(
    "rdrobust (standard)",
    "Parametric, HC1 SEs",
    "Parametric, cluster(age)",
    "Parametric, cluster(age×year)",
    "With controls, cluster(age)",
    "Cell-level (age×year), weighted"
  ),
  Estimate = c(
    rd_vol$coef[1],
    coef(m1_hc1)["post62"],
    coef(m2_age)["post62"],
    coef(m3_age_year)["post62"],
    coef(m4_controls_age)["post62"],
    coef(m_cell)["post62"]
  ),
  SE = c(
    rd_vol$se[1],
    m1_hc1$se[1],
    m2_age$se[1],
    m3_age_year$se[1],
    m4_controls_age$se[1],
    m_cell_robust[2, 2]
  ),
  stringsAsFactors = FALSE
)

inference_summary$CI_Low <- inference_summary$Estimate - 1.96 * inference_summary$SE
inference_summary$CI_High <- inference_summary$Estimate + 1.96 * inference_summary$SE
inference_summary$Significant <- ifelse(
  inference_summary$CI_Low > 0 | inference_summary$CI_High < 0, "Yes", "No"
)

cat("\nRDD Estimates for Any Volunteering (Post-62 Effect):\n")
print(inference_summary, row.names = FALSE)

# Note which methods find significance
cat("\nMethods finding significance at 5%: ",
    sum(inference_summary$Significant == "Yes"), "/",
    nrow(inference_summary), "\n")

# -----------------------------------------------------------------------------
# 7. Secondary Outcomes with Clustered SEs
# -----------------------------------------------------------------------------

cat("\n--- 7. Secondary Outcomes with Clustered SEs ---\n")

# Volunteering minutes
m_mins <- feols(
  volunteer_mins ~ post62 + age_centered + age_x_post +
    female + college + white + married + weekday | year,
  data = atus,
  cluster = ~age
)

# Grandchild care
m_grandchild <- feols(
  any_care_grandchild ~ post62 + age_centered + age_x_post +
    female + college + white + married + weekday | year,
  data = atus,
  cluster = ~age
)

# Pro-social
m_prosocial <- feols(
  any_prosocial ~ post62 + age_centered + age_x_post +
    female + college + white + married + weekday | year,
  data = atus,
  cluster = ~age
)

cat("\nSecondary Outcomes (clustered SEs by age):\n")
etable(m5_fe_age, m_mins, m_grandchild, m_prosocial,
       headers = c("Any Vol.", "Vol. Mins", "Grandchild", "Pro-Social"),
       keep = c("post62"),
       fitstat = c("n", "r2"))

# -----------------------------------------------------------------------------
# 8. Save All Results
# -----------------------------------------------------------------------------

cat("\n--- 8. Saving Results ---\n")

results <- list(
  # Baseline rdrobust
  rd_volunteer = rd_vol,
  rd_volunteer_mins = rd_vol_mins,
  rd_grandchild = rd_care,
  rd_prosocial = rd_prosocial,
  # Parametric models with various SEs
  parametric_hc1 = m1_hc1,
  parametric_cluster_age = m2_age,
  parametric_cluster_age_year = m3_age_year,
  parametric_controls_cluster = m4_controls_age,
  parametric_fe_cluster = m5_fe_age,
  # Cell-level
  cell_level = m_cell,
  cell_level_robust = m_cell_robust,
  # Summary table
  inference_summary = inference_summary,
  # By-age data
  by_age = by_age,
  by_age_year = by_age_year
)
saveRDS(results, paste0(data_dir, "rdd_results.rds"))

# Save summary tables
write_csv(inference_summary, paste0(tab_dir, "table_inference_comparison.csv"))
write_csv(by_age, paste0(tab_dir, "table_by_age.csv"))

# Create main results table for paper
main_table <- data.frame(
  Outcome = c("Any Volunteering", "Volunteering Minutes",
              "Any Grandchild Care", "Any Pro-Social"),
  # rdrobust estimates
  rdrobust_Est = c(rd_vol$coef[1], rd_vol_mins$coef[1],
                   rd_care$coef[1], rd_prosocial$coef[1]),
  rdrobust_SE = c(rd_vol$se[1], rd_vol_mins$se[1],
                  rd_care$se[1], rd_prosocial$se[1]),
  # Parametric with clustered SEs
  Param_Est = c(
    coef(m5_fe_age)["post62"],
    coef(m_mins)["post62"],
    coef(m_grandchild)["post62"],
    coef(m_prosocial)["post62"]
  ),
  Param_SE_cluster = c(
    m5_fe_age$se["post62"],
    m_mins$se["post62"],
    m_grandchild$se["post62"],
    m_prosocial$se["post62"]
  )
)

cat("\nMain Results Table:\n")
print(main_table)
write_csv(main_table, paste0(tab_dir, "table1_main_results.csv"))

cat("\n" , "=" %>% strrep(70), "\n")
cat("Main analysis complete!\n")
cat("Key finding: With clustered SEs, effect is ",
    ifelse(inference_summary$Significant[5] == "Yes",
           "still significant", "no longer significant at 5%"), "\n")
cat("=" %>% strrep(70), "\n")
