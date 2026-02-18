## ============================================================================
## 05_figures.R — Generate all figures
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

source("00_packages.R")
library(did)

DATA <- "../data"
FIG  <- "../figures"
dir.create(FIG, showWarnings = FALSE)

## ---- Load data ----
panel   <- readRDS(file.path(DATA, "panel_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust  <- readRDS(file.path(DATA, "robustness_results.rds"))
treatment_dates <- readRDS(file.path(DATA, "treatment_dates.rds"))

## ===================================================================
## Figure 1: Staggered adoption timeline
## ===================================================================
cat("Creating Figure 1: Adoption timeline...\n")

treat_summary <- treatment_dates[treat_date <= as.Date("2024-12-31")]
treat_summary[, treat_month := format(treat_date, "%Y-%m")]
adoption_count <- treat_summary[, .N, by = treat_month]
adoption_count[, treat_date := as.Date(paste0(treat_month, "-01"))]
adoption_count[, cumulative := cumsum(N)]
setorder(adoption_count, treat_date)
# Add start point
adoption_count <- rbind(
  data.table(treat_month = "2021-09", N = 0, treat_date = as.Date("2021-09-01"),
             cumulative = 0),
  adoption_count
)

p1 <- ggplot(adoption_count, aes(x = treat_date, y = cumulative)) +
  geom_step(linewidth = 1, color = "#2C3E50") +
  geom_point(data = adoption_count[N > 0], size = 2, color = "#2C3E50") +
  geom_vline(xintercept = as.Date("2022-04-01"), linetype = "dashed",
             color = "#E74C3C", alpha = 0.7) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "#3498DB", alpha = 0.7) +
  annotate("text", x = as.Date("2022-04-01"), y = 5, label = "ARP SPA\noption opens",
           hjust = -0.1, size = 3, color = "#E74C3C") +
  annotate("text", x = as.Date("2023-04-01"), y = 40, label = "PHE ends",
           hjust = -0.1, size = 3, color = "#3498DB") +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  scale_y_continuous(breaks = seq(0, 50, 10)) +
  labs(
    x = NULL,
    y = "Cumulative states adopted",
    title = "Staggered Adoption of 12-Month Medicaid Postpartum Extensions"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG, "fig1_adoption_timeline.pdf"), p1,
       width = 8, height = 5)

## ===================================================================
## Figure 2: Raw trends — Postpartum claims by early/late/never adopters
## ===================================================================
cat("Creating Figure 2: Raw trends...\n")

# Classify states
panel[, adoption_wave := fcase(
  cohort == 0, "Never/Late Adopter",
  cohort <= 51, "Early (by April 2022)",     # ~51 months from Jan 2018
  cohort <= 63, "Mid (May 2022 – June 2023)",
  default = "Late (July 2023+)"
)]

trends <- panel[, .(
  mean_claims_pp = mean(claims_postpartum, na.rm = TRUE),
  mean_providers_pp = mean(n_providers_postpartum, na.rm = TRUE),
  n_states = uniqueN(state)
), by = .(month_date, adoption_wave)]

p2 <- ggplot(trends, aes(x = month_date, y = mean_claims_pp,
                          color = adoption_wave, group = adoption_wave)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2022-04-01"), linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed", alpha = 0.5) +
  annotate("text", x = as.Date("2022-04-01"), y = max(trends$mean_claims_pp, na.rm = TRUE) * 0.95,
           label = "First adoptions", hjust = -0.1, size = 2.5) +
  annotate("text", x = as.Date("2023-04-01"), y = max(trends$mean_claims_pp, na.rm = TRUE) * 0.85,
           label = "PHE ends", hjust = -0.1, size = 2.5) +
  scale_color_manual(values = c("Early (by April 2022)" = "#E74C3C",
                                "Mid (May 2022 – June 2023)" = "#F39C12",
                                "Late (July 2023+)" = "#27AE60",
                                "Never/Late Adopter" = "#95A5A6")) +
  labs(
    x = NULL,
    y = "Mean postpartum claims per state-month",
    color = "Adoption timing",
    title = "Postpartum Care Claims (HCPCS 59430) by Adoption Wave"
  ) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG, "fig2_raw_trends.pdf"), p2, width = 9, height = 6)

## ===================================================================
## Figure 3: Event study — Postpartum claims (CS-DiD)
## ===================================================================
cat("Creating Figure 3: Event study (postpartum claims)...\n")

es_data <- data.table(
  event_time = results$es_pp_claims$egt,
  att        = results$es_pp_claims$att.egt,
  se         = results$es_pp_claims$se.egt
)
es_data[, ci_lo := att - 1.96 * se]
es_data[, ci_hi := att + 1.96 * se]

p3 <- ggplot(es_data, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "#E74C3C", alpha = 0.7) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#2C3E50") +
  geom_line(color = "#2C3E50", linewidth = 0.7) +
  geom_point(color = "#2C3E50", size = 1.5) +
  labs(
    x = "Months relative to adoption",
    y = "ATT (log postpartum claims)",
    title = "Event Study: Effect on Postpartum Care Claims",
    subtitle = "Callaway & Sant'Anna (2021), doubly robust, not-yet-treated control"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIG, "fig3_event_study_claims.pdf"), p3, width = 8, height = 5.5)

## ===================================================================
## Figure 4: Event study — Postpartum provider count
## ===================================================================
cat("Creating Figure 4: Event study (providers)...\n")

es_prov <- data.table(
  event_time = results$es_pp_providers$egt,
  att        = results$es_pp_providers$att.egt,
  se         = results$es_pp_providers$se.egt
)
es_prov[, ci_lo := att - 1.96 * se]
es_prov[, ci_hi := att + 1.96 * se]

p4 <- ggplot(es_prov, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "#E74C3C", alpha = 0.7) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#8E44AD") +
  geom_line(color = "#8E44AD", linewidth = 0.7) +
  geom_point(color = "#8E44AD", size = 1.5) +
  labs(
    x = "Months relative to adoption",
    y = "ATT (log distinct providers)",
    title = "Event Study: Effect on Postpartum Provider Count",
    subtitle = "Callaway & Sant'Anna (2021), doubly robust, not-yet-treated control"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIG, "fig4_event_study_providers.pdf"), p4, width = 8, height = 5.5)

## ===================================================================
## Figure 5: Event study — Contraceptive claims
## ===================================================================
cat("Creating Figure 5: Event study (contraceptive claims)...\n")

es_con <- data.table(
  event_time = results$es_contra$egt,
  att        = results$es_contra$att.egt,
  se         = results$es_contra$se.egt
)
es_con[, ci_lo := att - 1.96 * se]
es_con[, ci_hi := att + 1.96 * se]

p5 <- ggplot(es_con, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "#E74C3C", alpha = 0.7) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#27AE60") +
  geom_line(color = "#27AE60", linewidth = 0.7) +
  geom_point(color = "#27AE60", size = 1.5) +
  labs(
    x = "Months relative to adoption",
    y = "ATT (log contraceptive claims)",
    title = "Event Study: Effect on Contraceptive Service Claims",
    subtitle = "Callaway & Sant'Anna (2021), doubly robust, not-yet-treated control"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIG, "fig5_event_study_contraceptive.pdf"), p5, width = 8, height = 5.5)

## ===================================================================
## Figure 6: Placebo — Antepartum claims event study
## ===================================================================
cat("Creating Figure 6: Placebo (antepartum)...\n")

es_ante_data <- data.table(
  event_time = robust$es_ante$egt,
  att        = robust$es_ante$att.egt,
  se         = robust$es_ante$se.egt
)
es_ante_data[, ci_lo := att - 1.96 * se]
es_ante_data[, ci_hi := att + 1.96 * se]

p6 <- ggplot(es_ante_data, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "#E74C3C", alpha = 0.7) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#95A5A6") +
  geom_line(color = "#95A5A6", linewidth = 0.7) +
  geom_point(color = "#95A5A6", size = 1.5) +
  labs(
    x = "Months relative to adoption",
    y = "ATT (log antepartum claims)",
    title = "Placebo Test: Effect on Antepartum Care Claims",
    subtitle = "No effect expected — antepartum coverage unchanged by postpartum extension"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIG, "fig6_placebo_antepartum.pdf"), p6, width = 8, height = 5.5)

## ===================================================================
## Figure 7: Randomization inference distribution
## ===================================================================
cat("Creating Figure 7: RI distribution...\n")

ri_data <- data.table(perm_att = robust$perm_atts)

p7 <- ggplot(ri_data, aes(x = perm_att)) +
  geom_histogram(bins = 50, fill = "#BDC3C7", color = "white") +
  geom_vline(xintercept = robust$obs_att, color = "#E74C3C", linewidth = 1.2) +
  annotate("text", x = robust$obs_att, y = Inf,
           label = sprintf("Observed ATT = %.3f\nRI p-value = %.3f",
                           robust$obs_att, ifelse(is.na(robust$ri_pvalue), 0, robust$ri_pvalue)),
           hjust = -0.1, vjust = 1.5, size = 3.5, color = "#E74C3C") +
  labs(
    x = "Permuted ATT",
    y = "Frequency",
    title = "Randomization Inference: Distribution of Permuted ATTs",
    subtitle = "1,000 permutations of state treatment assignment"
  )

ggsave(file.path(FIG, "fig7_ri_distribution.pdf"), p7, width = 7, height = 5)

## ===================================================================
## Figure 8: Raw trends — OB/GYN providers billing Medicaid
## ===================================================================
cat("Creating Figure 8: OB/GYN provider trends...\n")

obgyn_trends <- panel[, .(
  mean_obgyn = mean(n_obgyn_billing, na.rm = TRUE)
), by = .(month_date, adoption_wave)]

p8 <- ggplot(obgyn_trends, aes(x = month_date, y = mean_obgyn,
                                color = adoption_wave, group = adoption_wave)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2022-04-01"), linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c("Early (by April 2022)" = "#E74C3C",
                                "Mid (May 2022 – June 2023)" = "#F39C12",
                                "Late (July 2023+)" = "#27AE60",
                                "Never/Late Adopter" = "#95A5A6")) +
  labs(
    x = NULL,
    y = "Mean OB/GYN providers billing Medicaid",
    color = "Adoption timing",
    title = "OB/GYN Provider Participation in Medicaid by Adoption Wave"
  ) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG, "fig8_obgyn_trends.pdf"), p8, width = 9, height = 6)

cat("\n=== All figures saved to", FIG, "===\n")
