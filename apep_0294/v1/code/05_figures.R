## ============================================================================
## 05_figures.R — All figures for the T-MSIS overview paper
## Uses pre-computed panels from 02_clean_data.R (no full dataset in memory)
## ============================================================================

source("00_packages.R")

DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE)

# Load pre-computed panels (all small, fit in memory)
panel_monthly <- readRDS(file.path(DATA, "panel_monthly.rds"))
panel_national <- readRDS(file.path(DATA, "panel_national.rds"))
panel_hcpcs <- readRDS(file.path(DATA, "panel_hcpcs.rds"))
panel_billing <- readRDS(file.path(DATA, "panel_billing.rds"))
provider_panel <- readRDS(file.path(DATA, "provider_panel.rds"))
new_entrants <- readRDS(file.path(DATA, "new_entrants.rds"))
exiting <- readRDS(file.path(DATA, "exiting.rds"))

has_state <- file.exists(file.path(DATA, "panel_state.rds"))
if (has_state) panel_state <- readRDS(file.path(DATA, "panel_state.rds"))
has_shapes <- file.exists(file.path(DATA, "state_shapes.rds"))

# Color palette — Medicaid blue as anchor
med_blue <- "#1565C0"
med_light <- "#64B5F6"
med_dark <- "#0D47A1"
accent_orange <- "#E65100"
accent_teal <- "#00695C"
covid_red <- "#C62828"

# Category colors
cat_colors <- c(
  "HCBS/State (T-codes)" = "#1565C0",
  "Behavioral Health (H-codes)" = "#00695C",
  "Temporary/State (S-codes)" = "#6A1B9A",
  "CPT Professional Services" = "#E65100",
  "Drugs (J-codes)" = "#AD1457",
  "Ambulance/DME (A-codes)" = "#4E342E",
  "CMS Procedures (G-codes)" = "#546E7A",
  "DME (E-codes)" = "#827717",
  "Orthotics/Prosthetics (L-codes)" = "#37474F",
  "Other" = "#9E9E9E"
)

## =========================================================================
## FIGURE 1: Monthly Medicaid Spending — The Big Picture
## =========================================================================
cat("Creating Figure 1: Monthly spending time series...\n")

# Exclude December 2024 (incomplete due to claims processing lag)
fig1_data <- panel_national[!(year == 2024 & month_num == 12)][order(month_date)]
fig1_data[, paid_billions := total_paid / 1e9]

covid_start <- as.Date("2020-03-01")
arpa_date <- as.Date("2021-04-01")
unwinding_date <- as.Date("2023-04-01")

p1 <- ggplot(fig1_data, aes(x = month_date, y = paid_billions)) +
  annotate("rect",
           xmin = as.Date("2020-03-01"), xmax = as.Date("2020-07-01"),
           ymin = -Inf, ymax = Inf, fill = covid_red, alpha = 0.08) +
  geom_vline(xintercept = arpa_date, linetype = "dashed", color = "grey50", linewidth = 0.4) +
  geom_vline(xintercept = unwinding_date, linetype = "dashed", color = accent_orange, linewidth = 0.4) +
  geom_line(color = med_blue, linewidth = 0.9) +
  geom_point(color = med_blue, size = 0.6, alpha = 0.5) +
  annotate("text", x = as.Date("2020-05-01"), y = max(fig1_data$paid_billions) * 0.95,
           label = "COVID-19", size = 2.8, color = covid_red, fontface = "italic") +
  annotate("text", x = arpa_date + 60, y = max(fig1_data$paid_billions) * 0.85,
           label = "ARPA\nHCBS", size = 2.5, color = "grey40", fontface = "italic", hjust = 0) +
  annotate("text", x = unwinding_date + 60, y = max(fig1_data$paid_billions) * 0.75,
           label = "Medicaid\nUnwinding", size = 2.5, color = accent_orange, fontface = "italic", hjust = 0) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = dollar_format(suffix = "B"), expand = expansion(mult = c(0.02, 0.08))) +
  labs(
    title = "Monthly Medicaid Provider Spending, 2018\u20132024",
    subtitle = "Total payments to all billing providers across FFS, managed care, and CHIP",
    x = NULL, y = "Total Paid (Billions)",
    caption = "Source: T-MSIS Medicaid Provider Spending Data (HHS, 2026). December 2024 excluded (claims processing lag)."
  )

ggsave(file.path(FIGS, "fig1_monthly_spending.pdf"), p1, width = 8, height = 4.5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig1_monthly_spending.png"), p1, width = 8, height = 4.5, dpi = 300)

## =========================================================================
## FIGURE 2: Service Composition — Stacked Area
## =========================================================================
cat("Creating Figure 2: Service composition over time...\n")

# Exclude December 2024 (incomplete due to claims processing lag)
fig2_data <- panel_monthly[!(year == 2024 & month_num == 12), .(paid = sum(total_paid)), by = .(month_date, hcpcs_category)]
fig2_data[, paid_billions := paid / 1e9]

cat_order <- fig2_data[, .(total = sum(paid)), by = hcpcs_category][order(-total)]$hcpcs_category
fig2_data[, hcpcs_category := factor(hcpcs_category, levels = rev(cat_order))]

p2 <- ggplot(fig2_data, aes(x = month_date, y = paid_billions, fill = hcpcs_category)) +
  geom_area(alpha = 0.85) +
  scale_fill_manual(values = cat_colors, name = "Service Category") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = dollar_format(suffix = "B"), expand = expansion(mult = c(0, 0.03))) +
  labs(
    title = "Medicaid Spending by Service Category, 2018\u20132024",
    subtitle = "Medicaid-specific codes (T, H, S) account for over half of total spending",
    x = NULL, y = "Monthly Spending (Billions)",
    caption = "Source: T-MSIS. HCPCS codes classified by prefix: T (HCBS/state), H (behavioral), S (temporary/state), numeric (CPT)."
  ) +
  guides(fill = guide_legend(nrow = 3, reverse = TRUE)) +
  theme(legend.text = element_text(size = 7),
        legend.key.size = unit(0.4, "cm"))

ggsave(file.path(FIGS, "fig2_service_composition.pdf"), p2, width = 9, height = 5.5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig2_service_composition.png"), p2, width = 9, height = 5.5, dpi = 300)

## =========================================================================
## FIGURE 3: Top 10 HCPCS Codes — Horizontal Bar
## =========================================================================
cat("Creating Figure 3: Top HCPCS codes...\n")

top_codes <- head(panel_hcpcs, 10)
top_codes[, paid_billions := total_paid / 1e9]
top_codes[, label := paste0(hcpcs_code, " \u2014 ", hcpcs_detail)]
top_codes[, label := factor(label, levels = rev(label))]

p3 <- ggplot(top_codes, aes(x = paid_billions, y = label)) +
  geom_col(fill = med_blue, width = 0.7) +
  geom_text(aes(label = paste0("$", round(paid_billions, 1), "B")),
            hjust = -0.1, size = 3, color = "grey30") +
  scale_x_continuous(labels = dollar_format(suffix = "B"),
                     expand = expansion(mult = c(0, 0.25))) +
  labs(
    title = "Top 10 HCPCS Codes by Total Medicaid Spending",
    subtitle = "Personal care (T1019) alone exceeds $120 billion over the panel",
    x = "Total Paid (Billions)", y = NULL,
    caption = "Source: T-MSIS, 2018\u20132024. T1019 = personal care per 15 min; T2016 = habilitation residential per diem."
  )

ggsave(file.path(FIGS, "fig3_top_hcpcs.pdf"), p3, width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig3_top_hcpcs.png"), p3, width = 8, height = 5, dpi = 300)

## =========================================================================
## FIGURE 4: Provider Growth and Churn
## =========================================================================
cat("Creating Figure 4: Provider entry and exit...\n")

# Use pre-computed panel_national (has n_providers) and new_entrants/exiting
fig4_data <- copy(panel_national[, .(month_date, n_providers)])
setorder(fig4_data, month_date)

fig4_data <- merge(fig4_data, new_entrants[, .(month_date, new_providers)],
                   by = "month_date", all.x = TRUE)
fig4_data <- merge(fig4_data, exiting[, .(month_date, exiting_providers)],
                   by = "month_date", all.x = TRUE)
fig4_data[is.na(new_providers), new_providers := 0]
fig4_data[is.na(exiting_providers), exiting_providers := 0]

max_month <- max(fig4_data$month_date)

p4a <- ggplot(fig4_data, aes(x = month_date, y = n_providers / 1000)) +
  geom_line(color = med_blue, linewidth = 0.8) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = comma_format(suffix = "K")) +
  labs(title = "Active Billing Providers per Month",
       x = NULL, y = "Providers (Thousands)")

p4b <- ggplot(fig4_data[month_date > as.Date("2018-06-01") & month_date < max_month], aes(x = month_date)) +
  geom_col(aes(y = new_providers), fill = accent_teal, alpha = 0.7, width = 25) +
  geom_col(aes(y = -exiting_providers), fill = covid_red, alpha = 0.7, width = 25) +
  geom_hline(yintercept = 0, color = "grey40") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = comma) +
  labs(title = "Monthly Provider Entry and Exit",
       subtitle = "Green = new entrants; Red = last observed billing month",
       x = NULL, y = "Providers")

p4 <- p4a / p4b +
  plot_annotation(
    title = "The Medicaid Provider Workforce, 2018\u20132024",
    caption = "Source: T-MSIS. Provider = unique billing NPI. Entry = first billing month. Exit = last billing month before data end.",
    theme = theme(plot.title = element_text(face = "bold", size = 13))
  )

ggsave(file.path(FIGS, "fig4_provider_dynamics.pdf"), p4, width = 8, height = 7, device = cairo_pdf)
ggsave(file.path(FIGS, "fig4_provider_dynamics.png"), p4, width = 8, height = 7, dpi = 300)

## =========================================================================
## FIGURE 5: Provider Size Distribution (Log Scale)
## =========================================================================
cat("Creating Figure 5: Provider size distribution...\n")

p5 <- ggplot(provider_panel[total_paid > 0], aes(x = total_paid)) +
  geom_histogram(fill = med_blue, alpha = 0.7, bins = 80, color = "white", linewidth = 0.1) +
  scale_x_log10(labels = dollar_format(scale = 1, accuracy = 1),
                breaks = 10^(2:9)) +
  annotation_logticks(sides = "b") +
  labs(
    title = "Distribution of Total Medicaid Payments by Provider, 2018\u20132024",
    subtitle = "Extreme right skew: a small number of providers account for most spending",
    x = "Total Payments (log scale)", y = "Number of Providers",
    caption = "Source: T-MSIS. Each bar represents a bin of providers grouped by total cumulative payments."
  )

ggsave(file.path(FIGS, "fig5_provider_size.pdf"), p5, width = 7, height = 4.5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig5_provider_size.png"), p5, width = 7, height = 4.5, dpi = 300)

## =========================================================================
## FIGURE 6: Panel Balance — Provider Tenure Histogram
## =========================================================================
cat("Creating Figure 6: Panel balance...\n")

p6 <- ggplot(provider_panel, aes(x = active_months)) +
  geom_histogram(fill = med_blue, alpha = 0.7, binwidth = 3, color = "white", linewidth = 0.1) +
  geom_vline(xintercept = 84, linetype = "dashed", color = accent_orange) +
  annotate("text", x = 80, y = Inf, label = "Full panel\n(84 months)",
           vjust = 1.5, hjust = 1, size = 3, color = accent_orange) +
  scale_x_continuous(breaks = seq(0, 84, 12)) +
  labs(
    title = "Distribution of Provider Tenure in T-MSIS Panel",
    subtitle = "Highly unbalanced: most providers appear for fewer than 12 months",
    x = "Active Months (out of 84)", y = "Number of Providers",
    caption = "Source: T-MSIS. Active months = months with at least one claim."
  )

ggsave(file.path(FIGS, "fig6_panel_balance.pdf"), p6, width = 7, height = 4.5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig6_panel_balance.png"), p6, width = 7, height = 4.5, dpi = 300)

## =========================================================================
## FIGURE 7: Billing Structure — Organizational Relationships
## =========================================================================
cat("Creating Figure 7: Billing structure...\n")

billing_data <- panel_billing[, .(billing_structure,
                                   pct = round(total_paid / sum(total_paid) * 100, 1))]
billing_data[, billing_structure := factor(billing_structure,
  levels = c("Self-billing (billing = servicing)",
             "Solo (no servicing NPI)",
             "Organization billing (billing != servicing)"))]

p7 <- ggplot(billing_data, aes(x = pct, y = billing_structure)) +
  geom_col(fill = med_blue, width = 0.6) +
  geom_text(aes(label = paste0(pct, "%")), hjust = -0.1, size = 3.5) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15)),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "Share of Medicaid Spending by Billing Structure",
    subtitle = "The billing\u2013servicing NPI relationship reveals organizational hierarchies",
    x = "Share of Total Paid", y = NULL,
    caption = "Source: T-MSIS. Self-billing = billing NPI equals servicing NPI. Organization = different NPIs."
  )

ggsave(file.path(FIGS, "fig7_billing_structure.pdf"), p7, width = 7, height = 3.5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig7_billing_structure.png"), p7, width = 7, height = 3.5, dpi = 300)

## =========================================================================
## FIGURE 8: State Map of Medicaid Provider Spending
## =========================================================================
if (has_state && has_shapes) {
  cat("Creating Figure 8: State spending map...\n")

  states_sf <- readRDS(file.path(DATA, "state_shapes.rds"))

  # Filter to valid US state abbreviations only (panel_state has junk like taxonomy codes)
  valid_states <- c(state.abb, "DC", "PR", "VI", "GU", "AS", "MP")
  state_clean <- panel_state[state %in% valid_states]

  # Total spending by state (all years)
  state_totals <- state_clean[, .(total_paid = sum(total_paid),
                                   n_providers = max(n_providers)), by = state]

  # Load ACS population — merge via state abbreviation lookup
  acs_path <- file.path(DATA, "acs_state_pop.csv")
  if (file.exists(acs_path)) {
    acs <- fread(acs_path)
    # Create abbreviation column in ACS using built-in R lookups
    state_lookup <- data.table(
      state_name = c(state.name, "District of Columbia", "Puerto Rico"),
      state_abbr = c(state.abb, "DC", "PR")
    )
    acs <- merge(acs, state_lookup, by = "state_name", all.x = TRUE)
    state_totals <- merge(state_totals, acs[, .(state_abbr, total_pop, state_fips)],
                          by.x = "state", by.y = "state_abbr", all.x = TRUE)
    state_totals[, paid_per_capita := total_paid / total_pop]
    state_totals[, providers_per_100k := n_providers / total_pop * 100000]
  }

  # Merge with shapes via STUSPS (state abbreviation in shapefile)
  map_data <- merge(states_sf, state_totals, by.x = "STUSPS", by.y = "state", all.x = TRUE)

  # Shift AK/HI
  map_data_shifted <- tigris::shift_geometry(map_data)

  if ("paid_per_capita" %in% names(map_data_shifted)) {
    p8 <- ggplot(map_data_shifted) +
      geom_sf(aes(fill = paid_per_capita / 1000), color = "white", linewidth = 0.2) +
      scale_fill_viridis_c(option = "mako", direction = -1, na.value = "grey90",
                           labels = dollar_format(suffix = "K"),
                           name = "Spending\nper Capita\n($K)") +
      labs(
        title = "Cumulative Medicaid Provider Spending per Capita, 2018\u20132024",
        subtitle = "Geographic variation reflects differences in Medicaid generosity, HCBS use, and managed care",
        caption = "Source: T-MSIS joined to NPPES (state). Per capita using ACS 2022 total population."
      ) +
      theme_void(base_size = 11) +
      theme(
        plot.title = element_text(face = "bold", size = 12, hjust = 0),
        plot.subtitle = element_text(size = 9, color = "grey40"),
        plot.caption = element_text(size = 7, color = "grey50"),
        legend.position = c(0.92, 0.3)
      )

    ggsave(file.path(FIGS, "fig8_state_spending_map.pdf"), p8, width = 9, height = 6, device = cairo_pdf)
    ggsave(file.path(FIGS, "fig8_state_spending_map.png"), p8, width = 9, height = 6, dpi = 300)
  }

  # Provider density map
  if ("providers_per_100k" %in% names(map_data_shifted)) {
    p8b <- ggplot(map_data_shifted) +
      geom_sf(aes(fill = providers_per_100k), color = "white", linewidth = 0.2) +
      scale_fill_viridis_c(option = "rocket", direction = -1, na.value = "grey90",
                           name = "Providers\nper 100K") +
      labs(
        title = "Medicaid Billing Providers per 100,000 Population, 2018\u20132024",
        subtitle = "Provider density varies by more than an order of magnitude across states",
        caption = "Source: T-MSIS (billing NPIs) joined to NPPES (state). Population from ACS 2022."
      ) +
      theme_void(base_size = 11) +
      theme(
        plot.title = element_text(face = "bold", size = 12, hjust = 0),
        plot.subtitle = element_text(size = 9, color = "grey40"),
        plot.caption = element_text(size = 7, color = "grey50"),
        legend.position = c(0.92, 0.3)
      )

    ggsave(file.path(FIGS, "fig8b_provider_density_map.pdf"), p8b, width = 9, height = 6, device = cairo_pdf)
    ggsave(file.path(FIGS, "fig8b_provider_density_map.png"), p8b, width = 9, height = 6, dpi = 300)
  }
} else {
  cat("Skipping map figures (no state panel or shapefile data).\n")
}

## =========================================================================
## FIGURE 10: COVID Impact — Claims Dip and Recovery
## =========================================================================
cat("Creating Figure 10: COVID impact...\n")

jan2020 <- panel_national[month_date == as.Date("2020-01-01")]$total_claims
fig10_data <- panel_national[year %in% 2019:2021]
fig10_data[, claims_index := total_claims / jan2020 * 100]

p10 <- ggplot(fig10_data, aes(x = month_date, y = claims_index)) +
  annotate("rect",
           xmin = as.Date("2020-03-01"), xmax = as.Date("2020-07-01"),
           ymin = -Inf, ymax = Inf, fill = covid_red, alpha = 0.08) +
  geom_hline(yintercept = 100, linetype = "dotted", color = "grey60") +
  geom_line(color = med_blue, linewidth = 0.9) +
  geom_point(color = med_blue, size = 1.5) +
  annotate("text", x = as.Date("2020-04-15"), y = min(fig10_data$claims_index) + 3,
           label = sprintf("%.0f%%\ndrop", 100 - min(fig10_data$claims_index)),
           size = 3, color = covid_red, fontface = "bold") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y") +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "COVID-19 Disruption in Medicaid Claims",
    subtitle = "Indexed to January 2020 = 100. Claims recovered by summer 2020 and exceeded pre-pandemic levels.",
    x = NULL, y = "Claims Index (Jan 2020 = 100)",
    caption = "Source: T-MSIS. Shaded region = initial COVID-19 disruption (March\u2013June 2020)."
  )

ggsave(file.path(FIGS, "fig10_covid_impact.pdf"), p10, width = 7, height = 4.5, device = cairo_pdf)
ggsave(file.path(FIGS, "fig10_covid_impact.png"), p10, width = 7, height = 4.5, dpi = 300)

## =========================================================================
## FIGURE 11: HCPCS Code Diversity Over Time
## =========================================================================
cat("Creating Figure 11: Code diversity...\n")

# Use panel_national which already has n_hcpcs per month
code_diversity <- panel_national[, .(month_date, n_hcpcs)]
setorder(code_diversity, month_date)

p11 <- ggplot(code_diversity, aes(x = month_date, y = n_hcpcs)) +
  geom_line(color = med_blue, linewidth = 0.8) +
  geom_point(color = med_blue, size = 0.8) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Growth in HCPCS Code Diversity",
    subtitle = "More procedure codes billed each year \u2014 expanding service categories and billing complexity",
    x = NULL, y = "Unique HCPCS Codes per Month",
    caption = "Source: T-MSIS. Count of distinct HCPCS codes with at least one claim per month."
  )

ggsave(file.path(FIGS, "fig11_code_diversity.pdf"), p11, width = 7, height = 4, device = cairo_pdf)
ggsave(file.path(FIGS, "fig11_code_diversity.png"), p11, width = 7, height = 4, dpi = 300)

## =========================================================================
## FIGURE 12: Provider Type Composition (from NPPES enrichment)
## =========================================================================
cat("Creating Figure 12: Provider type composition...\n")

ppe <- readRDS(file.path(DATA, "provider_panel_enriched.rds"))

type_summary <- ppe[!is.na(entity_type), .(
  n = .N,
  total_paid = sum(total_paid)
), by = .(provider_type = fifelse(entity_type == "1", "Individual", "Organization"))]
type_summary[, pct_paid := total_paid / sum(total_paid) * 100]
type_summary[, pct_n := n / sum(n) * 100]

type_long <- melt(type_summary, id.vars = "provider_type",
                  measure.vars = c("pct_n", "pct_paid"),
                  variable.name = "metric", value.name = "pct")
type_long[, metric := fifelse(metric == "pct_n", "Share of Providers", "Share of Spending")]

p12 <- ggplot(type_long, aes(x = metric, y = pct, fill = provider_type)) +
  geom_col(position = "stack", width = 0.6) +
  geom_text(aes(label = sprintf("%.0f%%", pct)),
            position = position_stack(vjust = 0.5), size = 4, color = "white", fontface = "bold") +
  scale_fill_manual(values = c("Individual" = med_blue, "Organization" = accent_teal),
                    name = "Entity Type") +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Individual vs. Organizational Providers in Medicaid",
    subtitle = "Organizations dominate spending; individuals dominate headcount",
    x = NULL, y = "Percentage",
    caption = "Source: T-MSIS joined to NPPES. Entity Type 1 = Individual, Type 2 = Organization."
  )

ggsave(file.path(FIGS, "fig12_provider_types.pdf"), p12, width = 6, height = 4, device = cairo_pdf)
ggsave(file.path(FIGS, "fig12_provider_types.png"), p12, width = 6, height = 4, dpi = 300)

rm(ppe)
gc()

cat("\n=== All figures saved to", FIGS, "===\n")
cat("Files:\n")
for (f in sort(list.files(FIGS))) cat("  ", f, "\n")
