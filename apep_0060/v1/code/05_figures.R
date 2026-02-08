# ============================================================================
# Paper 75: The Making of a City
# 05_figures.R - Generate publication-quality figures
# ============================================================================

source("output/paper_75/code/00_packages.R")

DATA_DIR <- "output/paper_75/data"
FIG_DIR <- "output/paper_75/figures"
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

# Load data
dt <- readRDS(file.path(DATA_DIR, "sf_la_sea_1900_1910.rds"))
results <- readRDS(file.path(DATA_DIR, "analysis_results.rds"))

# Create analysis variables (same as main analysis)
dt[, `:=`(
  female = as.integer(SEX == 2),
  literate = as.integer(LIT == 2),
  foreign_born = as.integer(BPL >= 100),
  working_age = as.integer(AGE >= 18 & AGE <= 65),
  has_occupation = as.integer(!is.na(OCC1950) & OCC1950 > 0 & OCC1950 < 979)
)]

# City colors
city_colors <- c(
  "San Francisco" = "#0072B2",  # Blue (treated)
  "Los Angeles" = "#D55E00",    # Orange (control)
  "Seattle" = "#009E73"         # Green (control)
)

# ============================================================================
# Figure 1: Population Growth
# ============================================================================

msg("Creating Figure 1: Population Growth")

pop_data <- dt[, .(n = .N), by = .(city, YEAR)]
pop_data[, pop_thousands := n / 1000]

# Add 1906 earthquake annotation
p1 <- ggplot(pop_data, aes(x = YEAR, y = pop_thousands, color = city, group = city)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 1906, linetype = "dashed", color = "gray40", linewidth = 0.5) +
  annotate("text", x = 1906.5, y = 450, label = "1906\nEarthquake",
           hjust = 0, size = 3, color = "gray40") +
  scale_color_manual(values = city_colors, name = "City") +
  scale_x_continuous(breaks = c(1900, 1906, 1910)) +
  labs(
    title = "Population Growth in Western Cities, 1900-1910",
    subtitle = "San Francisco's growth stalled after the 1906 earthquake",
    x = "Year",
    y = "Population (thousands)",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA"
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig1_population_growth.pdf"), p1, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig1_population_growth.png"), p1, width = 8, height = 6, dpi = 300)

# ============================================================================
# Figure 2: Gender Composition (DiD visual)
# ============================================================================

msg("Creating Figure 2: Gender Composition DiD")

gender_data <- dt[working_age == 1, .(
  pct_male = mean(1 - female) * 100,
  n = .N
), by = .(city, YEAR)]

p2 <- ggplot(gender_data, aes(x = YEAR, y = pct_male, color = city, group = city)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 1906, linetype = "dashed", color = "gray40", linewidth = 0.5) +
  annotate("text", x = 1906.5, y = 68, label = "Earthquake",
           hjust = 0, size = 3, color = "gray40") +
  scale_color_manual(values = city_colors, name = "City") +
  scale_x_continuous(breaks = c(1900, 1906, 1910)) +
  scale_y_continuous(limits = c(45, 70)) +
  labs(
    title = "Male Share of Working-Age Population, 1900-1910",
    subtitle = "San Francisco became more male after disaster; control cities became more female",
    x = "Year",
    y = "Percent Male",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA. Working-age = 18-65."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig2_gender_did.pdf"), p2, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig2_gender_did.png"), p2, width = 8, height = 6, dpi = 300)

# ============================================================================
# Figure 3: Occupational Score Distribution
# ============================================================================

msg("Creating Figure 3: Occupational Score Distribution")

dt_occ <- dt[working_age == 1 & has_occupation == 1 & OCCSCORE > 0]

p3 <- ggplot(dt_occ, aes(x = OCCSCORE, fill = factor(YEAR))) +
  geom_density(alpha = 0.5, adjust = 1.5) +
  facet_wrap(~city, ncol = 1) +
  scale_fill_manual(values = c("1900" = "#0072B2", "1910" = "#D55E00"),
                    name = "Year") +
  labs(
    title = "Distribution of Occupational Scores, 1900 vs 1910",
    subtitle = "San Francisco's skilled workforce (right tail) declined after earthquake",
    x = "IPUMS OCCSCORE (1950-based occupational income score)",
    y = "Density",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA. Working-age adults with recorded occupation."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig3_occscore_dist.pdf"), p3, width = 8, height = 9)
ggsave(file.path(FIG_DIR, "fig3_occscore_dist.png"), p3, width = 8, height = 9, dpi = 300)

# ============================================================================
# Figure 4: Mean Occupational Score DiD
# ============================================================================

msg("Creating Figure 4: Occupational Score DiD")

occ_data <- dt_occ[, .(
  mean_occscore = mean(OCCSCORE),
  se = sd(OCCSCORE) / sqrt(.N),
  n = .N
), by = .(city, YEAR)]

p4 <- ggplot(occ_data, aes(x = YEAR, y = mean_occscore, color = city, group = city)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_occscore - 1.96*se, ymax = mean_occscore + 1.96*se),
                width = 0.5, linewidth = 0.5) +
  geom_vline(xintercept = 1906, linetype = "dashed", color = "gray40", linewidth = 0.5) +
  scale_color_manual(values = city_colors, name = "City") +
  scale_x_continuous(breaks = c(1900, 1906, 1910)) +
  labs(
    title = "Mean Occupational Score, 1900-1910",
    subtitle = "San Francisco's workforce deskilled after the earthquake",
    x = "Year",
    y = "Mean OCCSCORE",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig4_occscore_did.pdf"), p4, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig4_occscore_did.png"), p4, width = 8, height = 6, dpi = 300)

# ============================================================================
# Figure 5: Age Distribution Shifts
# ============================================================================

msg("Creating Figure 5: Age Distribution")

age_data <- dt[, .(n = .N), by = .(city, YEAR, AGE)]
age_data[, pct := n / sum(n) * 100, by = .(city, YEAR)]

# Focus on working ages
age_data_work <- age_data[AGE >= 15 & AGE <= 70]

p5 <- ggplot(age_data_work, aes(x = AGE, y = pct, color = factor(YEAR), group = YEAR)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~city, ncol = 1) +
  scale_color_manual(values = c("1900" = "#0072B2", "1910" = "#D55E00"),
                     name = "Year") +
  labs(
    title = "Age Distribution of Working-Age Population, 1900 vs 1910",
    subtitle = "All cities show aging, but SF's shift is more pronounced in prime working ages",
    x = "Age",
    y = "Percent of Total Population",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig5_age_dist.pdf"), p5, width = 8, height = 9)
ggsave(file.path(FIG_DIR, "fig5_age_dist.png"), p5, width = 8, height = 9, dpi = 300)

# ============================================================================
# Figure 6: Foreign-Born Share
# ============================================================================

msg("Creating Figure 6: Foreign-Born Share")

foreign_data <- dt[working_age == 1, .(
  pct_foreign = mean(foreign_born) * 100,
  n = .N
), by = .(city, YEAR)]

p6 <- ggplot(foreign_data, aes(x = YEAR, y = pct_foreign, color = city, group = city)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 1906, linetype = "dashed", color = "gray40", linewidth = 0.5) +
  scale_color_manual(values = city_colors, name = "City") +
  scale_x_continuous(breaks = c(1900, 1906, 1910)) +
  labs(
    title = "Foreign-Born Share of Working-Age Population, 1900-1910",
    subtitle = "San Francisco's foreign-born share declined more sharply than comparison counties",
    x = "Year",
    y = "Percent Foreign-Born",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig6_foreign_born.pdf"), p6, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig6_foreign_born.png"), p6, width = 8, height = 6, dpi = 300)

# ============================================================================
# Figure 7: Occupational Category Shifts (Horizontal Bar)
# ============================================================================

msg("Creating Figure 7: Occupational Shifts")

# Calculate occupational category shares
dt_occ[, occ_cat := fcase(
  OCC1950 %in% 0:99, "Professional",
  OCC1950 %in% 100:199, "Farmers",
  OCC1950 %in% 200:299, "Managers",
  OCC1950 %in% 300:399, "Clerical",
  OCC1950 %in% 400:499, "Sales",
  OCC1950 %in% 500:599, "Craftsmen",
  OCC1950 %in% 600:699, "Operatives",
  OCC1950 %in% 700:799, "Service",
  OCC1950 %in% 800:899, "Farm Labor",
  OCC1950 %in% 900:979, "Laborers",
  default = "Other"
)]

occ_cat_data <- dt_occ[, .(n = .N), by = .(city, YEAR, occ_cat)]
occ_cat_data[, pct := n / sum(n) * 100, by = .(city, YEAR)]

# Calculate change 1900-1910
occ_change <- dcast(occ_cat_data, city + occ_cat ~ YEAR, value.var = "pct")
setnames(occ_change, c("1900", "1910"), c("pct_1900", "pct_1910"))
occ_change[, change := pct_1910 - pct_1900]

# Focus on SF
sf_occ_change <- occ_change[city == "San Francisco" & !is.na(change)]
sf_occ_change <- sf_occ_change[order(-abs(change))]

p7 <- ggplot(sf_occ_change, aes(x = reorder(occ_cat, change), y = change, fill = change > 0)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("TRUE" = "#D55E00", "FALSE" = "#0072B2"),
                    labels = c("Decline", "Increase"), name = "") +
  labs(
    title = "Occupational Composition Change in San Francisco, 1900-1910",
    subtitle = "Skilled operatives left; manual laborers and craftsmen arrived for reconstruction",
    x = "",
    y = "Percentage Point Change",
    caption = "Source: U.S. Census Full-Count Data via IPUMS USA."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig7_occ_change.pdf"), p7, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig7_occ_change.png"), p7, width = 8, height = 6, dpi = 300)

# ============================================================================
# List all generated figures
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("Figures complete!")
msg("=" |> strrep(60))

figures <- list.files(FIG_DIR, pattern = "\\.(pdf|png)$")
msg("\nGenerated figures:")
for (f in figures) {
  msg("  ", f)
}
