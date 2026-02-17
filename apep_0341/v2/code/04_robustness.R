## ============================================================================
## 04_robustness.R — Robustness checks, heterogeneity, and mechanism tests
## apep_0341 v2: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- 1. Load data ----
panel_pc <- readRDS(file.path(DATA, "did_panel_pc.rds"))
panel_em <- readRDS(file.path(DATA, "did_panel_em.rds"))
panel_hcbs <- readRDS(file.path(DATA, "did_panel_hcbs.rds"))
rc       <- readRDS(file.path(DATA, "rate_changes.rds"))
results  <- readRDS(file.path(DATA, "main_results.rds"))

panel_pc[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]
panel_em[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]
panel_hcbs[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

## ---- 2. Placebo Test: E/M Office Visits ----
cat("=== Placebo Test: E/M Visits ===\n")

placebo_em <- feols(log_providers ~ post_treat | state + time_period,
                    data = panel_em, cluster = ~state)
cat(sprintf("Placebo (E/M providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(placebo_em)["post_treat"],
            se(placebo_em)["post_treat"],
            pvalue(placebo_em)["post_treat"]))

placebo_em_claims <- feols(log_claims ~ post_treat | state + time_period,
                           data = panel_em, cluster = ~state)
cat(sprintf("Placebo (E/M claims): %.4f (SE=%.4f, p=%.4f)\n",
            coef(placebo_em_claims)["post_treat"],
            se(placebo_em_claims)["post_treat"],
            pvalue(placebo_em_claims)["post_treat"]))

## ---- 3. All-HCBS Outcome ----
cat("\n=== All-HCBS Providers ===\n")

hcbs_prov <- feols(log_providers ~ post_treat | state + time_period,
                   data = panel_hcbs, cluster = ~state)
cat(sprintf("All-HCBS providers: %.4f (SE=%.4f, p=%.4f)\n",
            coef(hcbs_prov)["post_treat"],
            se(hcbs_prov)["post_treat"],
            pvalue(hcbs_prov)["post_treat"]))

hcbs_benes <- feols(log_benes ~ post_treat | state + time_period,
                    data = panel_hcbs, cluster = ~state)
cat(sprintf("All-HCBS benes: %.4f (SE=%.4f, p=%.4f)\n",
            coef(hcbs_benes)["post_treat"],
            se(hcbs_benes)["post_treat"],
            pvalue(hcbs_benes)["post_treat"]))

## ---- 4. Heterogeneity: Individual vs. Organization ----
cat("\n=== Heterogeneity: Provider Type ===\n")

panel_pc[, log_individual := log(n_individual + 1)]
panel_pc[, log_org        := log(n_org + 1)]
panel_pc[, log_sole_prop  := log(n_sole_prop + 1)]

het_indiv <- feols(log_individual ~ post_treat | state + time_period,
                   data = panel_pc, cluster = ~state)
het_org   <- feols(log_org ~ post_treat | state + time_period,
                   data = panel_pc, cluster = ~state)
het_sole  <- feols(log_sole_prop ~ post_treat | state + time_period,
                   data = panel_pc, cluster = ~state)

cat(sprintf("Individual providers: %.4f (SE=%.4f, p=%.4f)\n",
            coef(het_indiv)["post_treat"],
            se(het_indiv)["post_treat"],
            pvalue(het_indiv)["post_treat"]))
cat(sprintf("Organization providers: %.4f (SE=%.4f, p=%.4f)\n",
            coef(het_org)["post_treat"],
            se(het_org)["post_treat"],
            pvalue(het_org)["post_treat"]))
cat(sprintf("Sole proprietors: %.4f (SE=%.4f, p=%.4f)\n",
            coef(het_sole)["post_treat"],
            se(het_sole)["post_treat"],
            pvalue(het_sole)["post_treat"]))

## ---- 5. Alternative Treatment Thresholds ----
cat("\n=== Alternative Thresholds ===\n")

for (thresh in c(0.10, 0.20, 0.25)) {
  detect_rate_change_t <- function(dt, threshold, sustain_months = 3) {
    states <- unique(dt$state)
    results_t <- list()
    for (s in states) {
      sd <- dt[state == s][order(month_date)]
      if (nrow(sd) < 12) next
      sd[, rate_smooth := frollmean(avg_paid_per_claim, n = 3, align = "right", fill = NA)]
      sd[, rate_pct_change := (rate_smooth - shift(rate_smooth, 1)) / shift(rate_smooth, 1)]
      jumps <- sd[!is.na(rate_pct_change) & rate_pct_change >= threshold]
      if (nrow(jumps) == 0) {
        results_t[[s]] <- data.table(state = s, treat_date = as.Date(NA), treated = FALSE)
        next
      }
      first_jump <- jumps[1]
      jump_date <- first_jump$month_date
      post <- sd[month_date >= jump_date][1:min(sustain_months + 1, .N)]
      pre_rate <- sd[month_date < jump_date, mean(avg_paid_per_claim, na.rm = TRUE)]
      if (nrow(post) >= sustain_months) {
        post_rate <- mean(post$avg_paid_per_claim, na.rm = TRUE)
        sustained <- (post_rate / pre_rate - 1) >= threshold * 0.5
      } else {
        sustained <- FALSE
      }
      results_t[[s]] <- data.table(state = s, treat_date = if (sustained) jump_date else as.Date(NA),
                                   treated = sustained)
    }
    rbindlist(results_t)
  }

  rc_alt <- detect_rate_change_t(
    readRDS(file.path(DATA, "panel_personal_care.rds")),
    threshold = thresh
  )

  panel_alt <- copy(panel_pc)
  panel_alt[, c("treated", "treat_date") := NULL]
  panel_alt <- merge(panel_alt, rc_alt[, .(state, treat_date, treated)],
                     by = "state", all.x = TRUE)
  panel_alt[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

  mod_alt <- feols(log_providers ~ post_treat | state + time_period,
                   data = panel_alt, cluster = ~state)
  cat(sprintf("Threshold %.0f%%: %.4f (SE=%.4f, p=%.4f) - %d treated states\n",
              thresh * 100,
              coef(mod_alt)["post_treat"],
              se(mod_alt)["post_treat"],
              pvalue(mod_alt)["post_treat"],
              sum(rc_alt$treated)))
}

## ---- 6. Excluding COVID onset (March-June 2020) ----
cat("\n=== Excluding COVID Onset ===\n")

panel_nocovid <- panel_pc[!(month_date >= "2020-03-01" & month_date <= "2020-06-30")]
nocovid_prov <- feols(log_providers ~ post_treat | state + time_period,
                      data = panel_nocovid, cluster = ~state)
cat(sprintf("Excl. COVID onset (providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(nocovid_prov)["post_treat"],
            se(nocovid_prov)["post_treat"],
            pvalue(nocovid_prov)["post_treat"]))

## ---- 7. Randomization Inference ----
cat("\n=== Randomization Inference ===\n")

set.seed(42)
n_perms <- 1000
observed_coef <- coef(results$twfe_providers)["post_treat"]

perm_coefs <- numeric(n_perms)
states <- unique(panel_pc$state)
treated_states <- rc[treated == TRUE, state]
n_treated <- length(treated_states)

for (p in seq_len(n_perms)) {
  fake_treated <- sample(states, n_treated)
  panel_perm <- copy(panel_pc)
  real_dates <- rc[treated == TRUE, treat_date]
  fake_rc <- data.table(state = fake_treated,
                        fake_treat_date = sample(real_dates, n_treated, replace = TRUE))
  panel_perm <- merge(panel_perm, fake_rc, by = "state", all.x = TRUE)
  panel_perm[, fake_post := as.integer(!is.na(fake_treat_date) & month_date >= fake_treat_date)]

  mod_perm <- tryCatch(
    feols(log_providers ~ fake_post | state + time_period,
          data = panel_perm, cluster = ~state),
    error = function(e) NULL
  )
  if (!is.null(mod_perm)) {
    perm_coefs[p] <- coef(mod_perm)["fake_post"]
  } else {
    perm_coefs[p] <- NA
  }
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(observed_coef), na.rm = TRUE)
cat(sprintf("RI p-value (two-sided): %.4f (1000 permutations)\n", ri_pvalue))

## ---- 7b. v2: RI for CS-DiD ATT ----
cat("\n=== Randomization Inference for CS-DiD ===\n")

if (!is.null(results$att_overall_prov)) {
  observed_cs_att <- results$att_overall_prov$overall.att
  month_map <- readRDS(file.path(DATA, "month_map.rds"))

  set.seed(123)
  ri_cs_coefs <- numeric(500)  # Fewer permutations for CS-DiD (computationally expensive)

  for (p in seq_len(500)) {
    fake_treated <- sample(states, n_treated)
    real_dates <- rc[treated == TRUE, treat_date]

    ## Build fake panel_q with permuted treatment
    panel_ri <- copy(panel_pc)
    panel_ri[, c("treated", "treat_date", "first_treat", "pct_change") := NULL]

    fake_rc_ri <- data.table(
      state = fake_treated,
      treat_date = sample(real_dates, n_treated, replace = TRUE),
      treated = TRUE
    )
    never_rc_ri <- data.table(
      state = setdiff(states, fake_treated),
      treat_date = as.Date(NA),
      treated = FALSE
    )
    all_rc_ri <- rbind(fake_rc_ri, never_rc_ri)
    panel_ri <- merge(panel_ri, all_rc_ri, by = "state", all.x = TRUE)
    panel_ri <- merge(panel_ri,
                      month_map[, .(treat_date = month_date, first_treat_ri = time_period)],
                      by = "treat_date", all.x = TRUE)
    panel_ri[is.na(first_treat_ri), first_treat_ri := 0]

    ## Quarterly
    panel_ri[, quarter_num := (year - 2018) * 4 + ceiling(month_num / 3)]
    panel_ri_q <- panel_ri[, .(
      log_providers = log(mean(n_providers) + 1)
    ), by = .(state, state_id, quarter_num, first_treat_ri, treated)]
    panel_ri_q[, first_treat_q := ifelse(first_treat_ri == 0, 0,
                                          ceiling(first_treat_ri / 3))]
    panel_ri_q[, first_treat_merged := ifelse(first_treat_q > 0 & first_treat_q <= 3,
                                               3L, first_treat_q)]

    ri_sc <- panel_ri_q[, .N, by = state_id]
    ri_max <- max(ri_sc$N)
    ri_bal <- panel_ri_q[state_id %in% ri_sc[N == ri_max, state_id]]

    cs_ri <- tryCatch(
      att_gt(
        yname = "log_providers", tname = "quarter_num",
        idname = "state_id", gname = "first_treat_merged",
        data = as.data.frame(ri_bal),
        control_group = "nevertreated",
        anticipation = 0, base_period = "universal"
      ),
      error = function(e) NULL
    )
    if (!is.null(cs_ri)) {
      att_ri <- tryCatch(aggte(cs_ri, type = "simple"), error = function(e) NULL)
      if (!is.null(att_ri)) ri_cs_coefs[p] <- att_ri$overall.att
      else ri_cs_coefs[p] <- NA
    } else {
      ri_cs_coefs[p] <- NA
    }
  }

  ri_cs_pvalue <- mean(abs(ri_cs_coefs) >= abs(observed_cs_att), na.rm = TRUE)
  cat(sprintf("RI p-value for CS-DiD ATT: %.4f (500 permutations)\n", ri_cs_pvalue))
} else {
  ri_cs_pvalue <- NA
  ri_cs_coefs <- NULL
}

## ---- 8. Excluding Wyoming Outlier ----
cat("\n=== Excluding Wyoming ===\n")

panel_nowy <- panel_pc[state != "WY"]
nowy_prov <- feols(log_providers ~ post_treat | state + time_period,
                   data = panel_nowy, cluster = ~state)
cat(sprintf("Excl. Wyoming (providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(nowy_prov)["post_treat"],
            se(nowy_prov)["post_treat"],
            pvalue(nowy_prov)["post_treat"]))

## ---- 9. v2: Pre-treatment lead test (placebo: shift treatment 12 months early) ----
cat("\n=== Pre-Treatment Lead Test ===\n")

panel_lead <- copy(panel_pc)
panel_lead[treated == TRUE,
           fake_treat_date := treat_date - months(12)]
panel_lead[, lead_post := as.integer(treated == TRUE &
                                      !is.na(fake_treat_date) &
                                      month_date >= fake_treat_date &
                                      month_date < treat_date)]

lead_prov <- feols(log_providers ~ lead_post | state + time_period,
                   data = panel_lead, cluster = ~state)
cat(sprintf("Placebo lead (12m early): %.4f (SE=%.4f, p=%.4f)\n",
            coef(lead_prov)["lead_post"],
            se(lead_prov)["lead_post"],
            pvalue(lead_prov)["lead_post"]))

## ---- 10. v2: State-specific linear trends sensitivity ----
cat("\n=== State-Specific Linear Trends ===\n")

panel_pc[, state_trend := state_id * time_period]
sst_prov <- tryCatch(
  feols(log_providers ~ post_treat + state_trend | state + time_period,
        data = panel_pc, cluster = ~state),
  error = function(e) { cat("SST error:", conditionMessage(e), "\n"); NULL }
)
if (!is.null(sst_prov)) {
  cat(sprintf("With state trends (providers): %.4f (SE=%.4f, p=%.4f)\n",
              coef(sst_prov)["post_treat"],
              se(sst_prov)["post_treat"],
              pvalue(sst_prov)["post_treat"]))
}

## ---- 11. v2: Rolling-mean bandwidth sensitivity ----
cat("\n=== Rolling-Mean Bandwidth Sensitivity ===\n")

for (bw in c(2, 4, 6)) {
  detect_bw <- function(dt, threshold = 0.15, sustain_months = 3, roll_n = bw) {
    states <- unique(dt$state)
    results_bw <- list()
    for (s in states) {
      sd <- dt[state == s][order(month_date)]
      if (nrow(sd) < 12) next
      sd[, rate_smooth := frollmean(avg_paid_per_claim, n = roll_n,
                                    align = "right", fill = NA)]
      sd[, rate_pct_change := (rate_smooth - shift(rate_smooth, 1)) /
                               shift(rate_smooth, 1)]
      jumps <- sd[!is.na(rate_pct_change) & rate_pct_change >= threshold]
      if (nrow(jumps) == 0) {
        results_bw[[s]] <- data.table(state = s, treat_date = as.Date(NA), treated = FALSE)
        next
      }
      first_jump <- jumps[1]
      jump_date <- first_jump$month_date
      post <- sd[month_date >= jump_date][1:min(sustain_months + 1, .N)]
      pre_rate <- sd[month_date < jump_date, mean(avg_paid_per_claim, na.rm = TRUE)]
      if (nrow(post) >= sustain_months) {
        post_rate <- mean(post$avg_paid_per_claim, na.rm = TRUE)
        sustained <- (post_rate / pre_rate - 1) >= threshold * 0.5
      } else {
        sustained <- FALSE
      }
      results_bw[[s]] <- data.table(state = s,
                                    treat_date = if (sustained) jump_date else as.Date(NA),
                                    treated = sustained)
    }
    rbindlist(results_bw)
  }

  rc_bw <- detect_bw(readRDS(file.path(DATA, "panel_personal_care.rds")))

  panel_bw <- copy(panel_pc)
  panel_bw[, c("treated", "treat_date") := NULL]
  panel_bw <- merge(panel_bw, rc_bw[, .(state, treat_date, treated)],
                    by = "state", all.x = TRUE)
  panel_bw[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

  mod_bw <- feols(log_providers ~ post_treat | state + time_period,
                  data = panel_bw, cluster = ~state)
  cat(sprintf("Bandwidth %d months: %.4f (SE=%.4f, p=%.4f) - %d treated\n",
              bw,
              coef(mod_bw)["post_treat"],
              se(mod_bw)["post_treat"],
              pvalue(mod_bw)["post_treat"],
              sum(rc_bw$treated)))
}

## ---- 12. v2: Median-based detection robustness ----
cat("\n=== Median-Based Detection ===\n")

rc_med <- readRDS(file.path(DATA, "rate_changes_median.rds"))
panel_med <- copy(panel_pc)
panel_med[, c("treated", "treat_date") := NULL]
panel_med <- merge(panel_med, rc_med[, .(state, treat_date, treated)],
                   by = "state", all.x = TRUE)
panel_med[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

mod_med <- feols(log_providers ~ post_treat | state + time_period,
                 data = panel_med, cluster = ~state)
cat(sprintf("Median detection: %.4f (SE=%.4f, p=%.4f) - %d treated\n",
            coef(mod_med)["post_treat"],
            se(mod_med)["post_treat"],
            pvalue(mod_med)["post_treat"],
            sum(rc_med$treated)))

## ---- 13. Save robustness results ----
robust_results <- list(
  placebo_em         = placebo_em,
  placebo_em_claims  = placebo_em_claims,
  hcbs_prov          = hcbs_prov,
  hcbs_benes         = hcbs_benes,
  het_indiv          = het_indiv,
  het_org            = het_org,
  het_sole           = het_sole,
  nocovid_prov       = nocovid_prov,
  nowy_prov          = nowy_prov,
  ri_pvalue          = ri_pvalue,
  ri_observed        = observed_coef,
  ri_distribution    = perm_coefs,
  ## v2: New robustness checks
  ri_cs_pvalue       = ri_cs_pvalue,
  ri_cs_distribution = if (exists("ri_cs_coefs")) ri_cs_coefs else NULL,
  lead_prov          = lead_prov,
  sst_prov           = sst_prov,
  mod_med            = mod_med
)
saveRDS(robust_results, file.path(DATA, "robust_results.rds"))

cat("\n=== Robustness checks complete ===\n")
