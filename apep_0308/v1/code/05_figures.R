## ============================================================================
## 05_figures.R — All figures including maps
## ============================================================================

source("00_packages.R")

## ---- Load data ----
zip_total <- readRDS(file.path(DATA, "zip_total.rds"))
t1019_zip <- readRDS(file.path(DATA, "t1019_zip.rds"))
t1019_monthly <- readRDS(file.path(DATA, "t1019_monthly.rds"))
lorenz_data <- readRDS(file.path(DATA, "lorenz_data.rds"))
ny_provider_months <- readRDS(file.path(DATA, "ny_provider_months.rds"))
hhi_county <- readRDS(file.path(DATA, "hhi_county.rds"))
national_service <- readRDS(file.path(DATA, "national_service.rds"))
county_service <- readRDS(file.path(DATA, "county_service.rds"))
county_total <- readRDS(file.path(DATA, "county_total.rds"))
borough_stats <- readRDS(file.path(DATA, "borough_stats.rds"))
tenure_dist <- readRDS(file.path(DATA, "tenure_dist.rds"))
zip_monthly <- readRDS(file.path(DATA, "zip_monthly.rds"))

# Shapes
zcta_shapes <- readRDS(file.path(DATA, "ny_zcta_shapes.rds"))
county_shapes <- readRDS(file.path(DATA, "ny_county_shapes.rds"))

# ACS demographics (if available)
acs_zcta <- tryCatch(readRDS(file.path(DATA, "acs_zcta_demographics.rds")),
                      error = function(e) NULL)

## ---- Map setup ----
# Merge spending data to ZCTA shapes
zcta_shapes$zip5 <- zcta_shapes$ZCTA5CE20
map_data <- merge(zcta_shapes, zip_total, by = "zip5", all.x = TRUE)

# Merge ACS population for per-capita
if (!is.null(acs_zcta)) {
  map_data <- merge(map_data, acs_zcta[, .(zcta, total_pop, poverty_pop,
                                             median_hh_income, pop_65plus)],
                     by.x = "zip5", by.y = "zcta", all.x = TRUE)
  map_data$spending_per_cap <- ifelse(
    !is.na(map_data$total_pop) & map_data$total_pop > 0,
    map_data$total_paid / map_data$total_pop,
    NA
  )
  map_data$providers_per_10k <- ifelse(
    !is.na(map_data$total_pop) & map_data$total_pop > 0,
    map_data$n_providers / map_data$total_pop * 10000,
    NA
  )
}

# T1019 merge
map_t1019 <- merge(zcta_shapes, t1019_zip, by = "zip5", all.x = TRUE)
if (!is.null(acs_zcta)) {
  map_t1019 <- merge(map_t1019, acs_zcta[, .(zcta, total_pop)],
                      by.x = "zip5", by.y = "zcta", all.x = TRUE)
  map_t1019$t1019_per_cap <- ifelse(
    !is.na(map_t1019$total_pop) & map_t1019$total_pop > 0,
    map_t1019$t1019_paid / map_t1019$total_pop,
    NA
  )
}

# NYC bounding box for inset maps
nyc_bbox <- st_bbox(c(xmin = -74.3, ymin = 40.48, xmax = -73.68, ymax = 40.92),
                     crs = st_crs(zcta_shapes))

# County outlines for reference
county_outlines <- county_shapes

# HHI merge to county shapes
county_hhi_map <- merge(county_shapes, hhi_county,
                         by.x = "GEOID", by.y = "county_fips", all.x = TRUE)

## ============================================================================
## FIGURE 1: ZCTA Choropleth — Total Spending (Full State)
## ============================================================================

# Cap at reasonable percentile for color scale
spend_cap <- quantile(map_data$total_paid, 0.95, na.rm = TRUE)

p1 <- ggplot() +
  geom_sf(data = map_data,
          aes(fill = pmin(total_paid / 1e6, spend_cap / 1e6)),
          color = NA, linewidth = 0) +
  geom_sf(data = county_outlines, fill = NA, color = "gray60", linewidth = 0.2) +
  scale_fill_viridis_c(
    name = "Total Spending ($M)",
    option = "inferno",
    na.value = "gray90",
    labels = comma,
    trans = "sqrt"
  ) +
  labs(title = "Medicaid Provider Spending by ZIP Code, New York State",
       subtitle = "Total Spending, January 2018 \u2013 December 2024") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0.5),
    legend.position = "right",
    legend.key.height = unit(1.5, "cm")
  )

ggsave(file.path(FIG, "fig1_spending_map.png"), p1, width = 10, height = 8, dpi = 300)
ggsave(file.path(FIG, "fig1_spending_map.pdf"), p1, width = 10, height = 8)
cat("Figure 1 saved.\n")

## ============================================================================
## FIGURE 2: Spending Per Capita by ZCTA (Full State)
## ============================================================================

if (!is.null(acs_zcta)) {
  percap_cap <- quantile(map_data$spending_per_cap, 0.95, na.rm = TRUE)

  p2 <- ggplot() +
    geom_sf(data = map_data,
            aes(fill = pmin(spending_per_cap, percap_cap)),
            color = NA, linewidth = 0) +
    geom_sf(data = county_outlines, fill = NA, color = "gray60", linewidth = 0.2) +
    scale_fill_viridis_c(
      name = "Spending Per Capita ($)",
      option = "mako",
      na.value = "gray90",
      labels = comma,
      trans = "sqrt"
    ) +
    labs(title = "Medicaid Spending Per Capita by ZIP Code, New York State",
         subtitle = "Total spending (2018\u20132024) / ACS 2022 population") +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
      plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0.5),
      legend.position = "right",
      legend.key.height = unit(1.5, "cm")
    )

  ggsave(file.path(FIG, "fig2_percapita_map.png"), p2, width = 10, height = 8, dpi = 300)
  ggsave(file.path(FIG, "fig2_percapita_map.pdf"), p2, width = 10, height = 8)
  cat("Figure 2 saved.\n")
} else {
  cat("Figure 2 SKIPPED (no ACS data).\n")

  # Fallback: providers per ZIP
  p2 <- ggplot() +
    geom_sf(data = map_data,
            aes(fill = pmin(n_providers, quantile(n_providers, 0.95, na.rm = TRUE))),
            color = NA, linewidth = 0) +
    geom_sf(data = county_outlines, fill = NA, color = "gray60", linewidth = 0.2) +
    scale_fill_viridis_c(
      name = "Billing Providers",
      option = "mako",
      na.value = "gray90",
      labels = comma,
      trans = "sqrt"
    ) +
    labs(title = "Medicaid Billing Providers by ZIP Code, New York State",
         subtitle = "Unique billing NPIs, January 2018 \u2013 December 2024") +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
      plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0.5),
      legend.position = "right",
      legend.key.height = unit(1.5, "cm")
    )

  ggsave(file.path(FIG, "fig2_providers_map.png"), p2, width = 10, height = 8, dpi = 300)
  ggsave(file.path(FIG, "fig2_providers_map.pdf"), p2, width = 10, height = 8)
  cat("Figure 2 (providers fallback) saved.\n")
}

## ============================================================================
## FIGURE 3: NYC Inset — T1019 Spending by ZCTA
## ============================================================================

nyc_crop <- st_crop(map_t1019, nyc_bbox)
nyc_county_crop <- st_crop(county_outlines, nyc_bbox)

t1019_cap <- quantile(nyc_crop$t1019_paid, 0.95, na.rm = TRUE)

p3 <- ggplot() +
  geom_sf(data = nyc_crop,
          aes(fill = pmin(t1019_paid / 1e6, t1019_cap / 1e6)),
          color = "white", linewidth = 0.05) +
  geom_sf(data = nyc_county_crop, fill = NA, color = "black", linewidth = 0.4) +
  scale_fill_viridis_c(
    name = "T1019 Spending ($M)",
    option = "rocket",
    direction = -1,
    na.value = "gray95",
    labels = comma,
    trans = "sqrt"
  ) +
  labs(title = "Personal Care Spending (T1019) by ZIP Code",
       subtitle = "New York City, 2018\u20132024") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0.5),
    legend.position = "right",
    legend.key.height = unit(1.5, "cm")
  )

ggsave(file.path(FIG, "fig3_nyc_t1019_map.png"), p3, width = 9, height = 7, dpi = 300)
ggsave(file.path(FIG, "fig3_nyc_t1019_map.pdf"), p3, width = 9, height = 7)
cat("Figure 3 saved.\n")

## ============================================================================
## FIGURE 4: Lorenz Curve — Spending Concentration
## ============================================================================

# Gini coefficient
n_zip <- nrow(lorenz_data)
gini <- 1 - 2 * sum((n_zip + 1 - 1:n_zip) * sort(lorenz_data$total_paid)) /
  (n_zip * sum(lorenz_data$total_paid))

p4 <- ggplot(lorenz_data, aes(x = cum_pct_zips, y = cum_pct_spend)) +
  geom_line(color = "#2166AC", linewidth = 1.2) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray50") +
  geom_segment(aes(x = 20/n_zip*100, xend = 20/n_zip*100,
                   y = 0, yend = lorenz_data[20, cum_pct_spend]),
               linetype = "dotted", color = "#B2182B") +
  geom_segment(aes(x = 0, xend = 20/n_zip*100,
                   y = lorenz_data[20, cum_pct_spend],
                   yend = lorenz_data[20, cum_pct_spend]),
               linetype = "dotted", color = "#B2182B") +
  annotate("text", x = 40, y = 20,
           label = sprintf("Gini = %.3f\nTop 20 ZIPs = %.0f%% of spending",
                           gini, lorenz_data[20, cum_pct_spend]),
           hjust = 0, size = 4, color = "#B2182B") +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(x = "Cumulative % of ZIP Codes (ranked by spending)",
       y = "Cumulative % of Total Spending",
       title = "Lorenz Curve: Medicaid Spending Concentration Across ZIP Codes",
       subtitle = "New York State, 2018\u20132024") +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(FIG, "fig4_lorenz.png"), p4, width = 8, height = 6, dpi = 300)
ggsave(file.path(FIG, "fig4_lorenz.pdf"), p4, width = 8, height = 6)
cat("Figure 4 saved.\n")

## ============================================================================
## FIGURE 5: Service Mix — NY vs National (side-by-side bars)
## ============================================================================

# NY service mix
ny_service <- county_service[, .(ny_paid = sum(total_paid)), by = service_category]
ny_service[, ny_pct := ny_paid / sum(ny_paid) * 100]

# Merge with national
service_comp <- merge(ny_service, national_service[, .(service_category, national_pct)],
                       by = "service_category", all = TRUE)
service_comp[is.na(ny_pct), ny_pct := 0]
service_comp[is.na(national_pct), national_pct := 0]

# Top categories only
top_cats <- service_comp[order(-ny_pct)][1:8]

# Reshape for grouped bars
top_long <- melt(top_cats, id.vars = "service_category",
                  measure.vars = c("ny_pct", "national_pct"),
                  variable.name = "geography", value.name = "pct")
top_long[, geography := fifelse(geography == "ny_pct", "New York", "National")]

# Order by NY share
cat_order <- top_cats[order(-ny_pct), service_category]
top_long[, service_category := factor(service_category, levels = rev(cat_order))]

p5 <- ggplot(top_long, aes(x = service_category, y = pct, fill = geography)) +
  geom_col(position = "dodge", width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c("New York" = "#2166AC", "National" = "#D6604D"),
                     name = NULL) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(x = NULL,
       y = "Share of Total Medicaid Spending") +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = c(0.75, 0.15)
  )

ggsave(file.path(FIG, "fig5_service_mix.png"), p5, width = 9, height = 6, dpi = 300)
ggsave(file.path(FIG, "fig5_service_mix.pdf"), p5, width = 9, height = 6)
cat("Figure 5 saved.\n")

## ============================================================================
## FIGURE 6: T1019 Monthly Time Series
## ============================================================================

# Policy markers
policy_dates <- data.table(
  date = as.Date(c("2020-03-01", "2021-04-01", "2023-04-01")),
  label = c("COVID-19", "ARPA HCBS\nSpending Increase", "Medicaid\nUnwinding"),
  vjust = c(1.5, 1.5, 1.5)
)

p6 <- ggplot(t1019_monthly[month_date < "2024-12-01"],
             aes(x = month_date, y = total_paid / 1e9)) +
  geom_line(color = "#2166AC", linewidth = 0.8) +
  geom_vline(data = policy_dates, aes(xintercept = date),
             linetype = "dashed", color = "#B2182B", alpha = 0.7) +
  geom_text(data = policy_dates,
            aes(x = date, y = max(t1019_monthly$total_paid/1e9) * 0.95, label = label),
            hjust = -0.05, size = 3, color = "#B2182B") +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  scale_y_continuous(labels = dollar_format(suffix = "B")) +
  labs(x = NULL,
       y = "Monthly T1019 Spending",
       title = "Personal Care Spending (T1019) Over Time, New York State",
       subtitle = "Monthly Medicaid payments, January 2018 \u2013 November 2024") +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(FIG, "fig6_t1019_timeseries.png"), p6, width = 10, height = 5, dpi = 300)
ggsave(file.path(FIG, "fig6_t1019_timeseries.pdf"), p6, width = 10, height = 5)
cat("Figure 6 saved.\n")

## ============================================================================
## FIGURE 7: County-Level HHI Map
## ============================================================================

p7 <- ggplot() +
  geom_sf(data = county_hhi_map,
          aes(fill = pmin(hhi, 10000)),
          color = "white", linewidth = 0.3) +
  scale_fill_distiller(
    name = "HHI",
    palette = "RdYlBu",
    direction = -1,
    na.value = "gray90",
    labels = comma,
    breaks = c(0, 2500, 5000, 7500, 10000),
    limits = c(0, 10000)
  ) +
  labs(title = "Market Concentration in Personal Care (T1019) by County",
       subtitle = "Herfindahl-Hirschman Index, New York State, 2018\u20132024") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0.5),
    legend.position = "right",
    legend.key.height = unit(1.5, "cm")
  )

ggsave(file.path(FIG, "fig7_hhi_map.png"), p7, width = 10, height = 8, dpi = 300)
ggsave(file.path(FIG, "fig7_hhi_map.pdf"), p7, width = 10, height = 8)
cat("Figure 7 saved.\n")

## ============================================================================
## FIGURE 8: Provider Tenure Distribution (NY vs National comparison)
## ============================================================================

# Compute national tenure for comparison (from enriched panel)
enriched <- readRDS(file.path(DATA, "provider_panel_enriched.rds"))
enriched <- as.data.table(enriched)

if ("months_active" %in% names(enriched)) {
  nat_tenure <- enriched[, .(
    tenure_group = fcase(
      months_active == 1, "1 month",
      months_active <= 3, "2-3 months",
      months_active <= 6, "4-6 months",
      months_active <= 11, "7-11 months",
      months_active <= 18, "12-18 months",
      months_active <= 24, "19-24 months",
      months_active <= 48, "25-48 months",
      months_active <= 72, "49-72 months",
      default = "73-84 months"
    )
  )]
  nat_tenure_dist <- nat_tenure[, .N, by = tenure_group]
  nat_tenure_dist[, pct := N / sum(N) * 100]
  nat_tenure_dist[, geography := "National"]
} else {
  # Alternative: use total_months or n_months
  month_col <- intersect(names(enriched), c("total_months", "n_months", "active_months"))
  if (length(month_col) > 0) {
    setnames(enriched, month_col[1], "months_active", skip_absent = TRUE)
    nat_tenure <- enriched[, .(
      tenure_group = fcase(
        months_active == 1, "1 month",
        months_active <= 3, "2-3 months",
        months_active <= 6, "4-6 months",
        months_active <= 11, "7-11 months",
        months_active <= 18, "12-18 months",
        months_active <= 24, "19-24 months",
        months_active <= 48, "25-48 months",
        months_active <= 72, "49-72 months",
        default = "73-84 months"
      )
    )]
    nat_tenure_dist <- nat_tenure[, .N, by = tenure_group]
    nat_tenure_dist[, pct := N / sum(N) * 100]
    nat_tenure_dist[, geography := "National"]
  } else {
    nat_tenure_dist <- NULL
  }
}

tenure_order <- c("1 month", "2-3 months", "4-6 months", "7-11 months",
                   "12-18 months", "19-24 months", "25-48 months",
                   "49-72 months", "73-84 months")

ny_td <- tenure_dist[, .(tenure_group, pct = pct_providers, geography = "New York")]

if (!is.null(nat_tenure_dist)) {
  both_tenure <- rbind(ny_td, nat_tenure_dist[, .(tenure_group, pct, geography)])
} else {
  both_tenure <- ny_td
}

both_tenure[, tenure_group := factor(tenure_group, levels = tenure_order)]

p8 <- ggplot(both_tenure, aes(x = tenure_group, y = pct, fill = geography)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_manual(values = c("New York" = "#2166AC", "National" = "#D6604D"),
                     name = NULL) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(x = "Months Active in Panel (out of 84)",
       y = "% of Providers",
       title = "Provider Tenure Distribution: New York vs. National",
       subtitle = "Distribution of months with at least one claim, 2018\u20132024") +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1, size = 8),
    legend.position = c(0.8, 0.8)
  )

ggsave(file.path(FIG, "fig8_tenure.png"), p8, width = 9, height = 5.5, dpi = 300)
ggsave(file.path(FIG, "fig8_tenure.pdf"), p8, width = 9, height = 5.5)
cat("Figure 8 saved.\n")

cat("\nAll figures saved.\n")
