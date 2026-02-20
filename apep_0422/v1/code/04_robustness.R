## ============================================================================
## 04_robustness.R — Robustness checks and placebo tests
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

source(file.path(dirname(sys.frame(1)$ofile), "00_packages.R"))

district <- fread(file.path(data_dir, "district_analysis.csv"))
panel    <- fread(file.path(data_dir, "panel_analysis.csv"))

cat("=== Robustness Checks ===\n\n")

# ═══════════════════════════════════════════════════════════════════════════════
# R1: Placebo Treatment — Electricity gap should NOT predict health changes
# ═══════════════════════════════════════════════════════════════════════════════

cat("── R1. Placebo Treatment (electricity gap) ──\n")

placebo_diarrhea <- lm(delta_diarrhea ~ electricity_gap + baseline_sanitation +
                         baseline_water + baseline_female_literate + factor(state_code),
                       data = district)
cat("Placebo (electricity gap → Δ diarrhea):\n")
cat("  β =", round(coef(placebo_diarrhea)["electricity_gap"], 3),
    ", SE =", round(sqrt(vcovHC(placebo_diarrhea, type = "HC1")["electricity_gap", "electricity_gap"]), 3),
    ", p =", round(coeftest(placebo_diarrhea, vcov. = vcovHC(placebo_diarrhea, type = "HC1"))["electricity_gap", 4], 3),
    "\n")

placebo_stunting <- lm(delta_stunting ~ electricity_gap + baseline_sanitation +
                         baseline_water + baseline_female_literate + factor(state_code),
                       data = district)
cat("Placebo (electricity gap → Δ stunting):\n")
cat("  β =", round(coef(placebo_stunting)["electricity_gap"], 3),
    ", SE =", round(sqrt(vcovHC(placebo_stunting, type = "HC1")["electricity_gap", "electricity_gap"]), 3),
    ", p =", round(coeftest(placebo_stunting, vcov. = vcovHC(placebo_stunting, type = "HC1"))["electricity_gap", 4], 3),
    "\n\n")

# ═══════════════════════════════════════════════════════════════════════════════
# R2: Placebo Outcome — Clean fuel gap should NOT predict vaccination change
# ═══════════════════════════════════════════════════════════════════════════════

cat("── R2. Placebo Outcome (vaccination — not fuel-related) ──\n")

placebo_vacc <- lm(delta_vaccination ~ ujjwala_exposure + baseline_electricity +
                     baseline_sanitation + baseline_water + baseline_female_literate +
                     factor(state_code), data = district)
cat("Placebo (fuel gap → Δ vaccination):\n")
cat("  β =", round(coef(placebo_vacc)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(placebo_vacc, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", p =", round(coeftest(placebo_vacc, vcov. = vcovHC(placebo_vacc, type = "HC1"))["ujjwala_exposure", 4], 3),
    "\n")

placebo_inst_births <- lm(delta_institutional_births ~ ujjwala_exposure + baseline_electricity +
                            baseline_sanitation + baseline_water + baseline_female_literate +
                            factor(state_code), data = district)
cat("Placebo (fuel gap → Δ institutional births):\n")
cat("  β =", round(coef(placebo_inst_births)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(placebo_inst_births, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", p =", round(coeftest(placebo_inst_births, vcov. = vcovHC(placebo_inst_births, type = "HC1"))["ujjwala_exposure", 4], 3),
    "\n\n")

# ═══════════════════════════════════════════════════════════════════════════════
# R3: Covariate Balance by Exposure Tercile
# ═══════════════════════════════════════════════════════════════════════════════

cat("── R3. Covariate Balance by Exposure Tercile ──\n")

balance_vars <- c("nfhs4_val_electricity", "nfhs4_val_improved_sanitation",
                  "nfhs4_val_improved_water", "nfhs4_val_institutional_births",
                  "nfhs4_val_female_literate", "nfhs4_val_full_vaccination")

balance_results <- data.table()
for (v in balance_vars) {
  if (v %in% names(district) & "exposure_tercile" %in% names(district)) {
    dt <- district[!is.na(get(v)) & !is.na(exposure_tercile)]
    means <- dt[, .(mean_val = mean(get(v), na.rm = TRUE),
                    n = .N), by = exposure_tercile]
    anova_p <- tryCatch({
      mod <- lm(reformulate("exposure_tercile", response = v), data = dt)
      anova(mod)$`Pr(>F)`[1]
    }, error = function(e) NA_real_)

    for (i in 1:nrow(means)) {
      balance_results <- rbind(balance_results, data.table(
        variable = gsub("nfhs4_val_", "", v),
        tercile = means$exposure_tercile[i],
        mean = round(means$mean_val[i], 1),
        n = means$n[i],
        f_test_p = round(anova_p, 3)
      ))
    }
  }
}

if (nrow(balance_results) > 0) {
  cat(format(balance_results, justify = "left"), sep = "\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# R4: Controlling for Sanitation (SBM) and Water (JJM)
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── R4. Controlling for Contemporaneous Programs ──\n")

# Diarrhea with SBM + JJM controls
rob_diarrhea_full <- lm(delta_diarrhea ~ ujjwala_exposure + delta_sanitation + delta_water +
                          baseline_electricity + baseline_female_literate +
                          factor(state_code), data = district)
cat("Diarrhea (controlling for Δ sanitation + Δ water):\n")
cat("  β_fuel =", round(coef(rob_diarrhea_full)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rob_diarrhea_full, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3), "\n")
cat("  β_sanit =", round(coef(rob_diarrhea_full)["delta_sanitation"], 3), "\n")
cat("  β_water =", round(coef(rob_diarrhea_full)["delta_water"], 3), "\n")

# Stunting with SBM + JJM controls
rob_stunting_full <- lm(delta_stunting ~ ujjwala_exposure + delta_sanitation + delta_water +
                          baseline_electricity + baseline_female_literate +
                          factor(state_code), data = district)
cat("Stunting (controlling for Δ sanitation + Δ water):\n")
cat("  β_fuel =", round(coef(rob_stunting_full)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rob_stunting_full, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════════
# R5: Horse Race — All Infrastructure Gaps Simultaneously
# ═══════════════════════════════════════════════════════════════════════════════

cat("── R5. Horse Race: Fuel vs Electricity vs Sanitation vs Water ──\n")

horse_diarrhea <- lm(delta_diarrhea ~ ujjwala_exposure + electricity_gap +
                       sanitation_gap + water_gap + baseline_female_literate +
                       factor(state_code), data = district)
cat("Horse race (Δ diarrhea):\n")
for (v in c("ujjwala_exposure", "electricity_gap", "sanitation_gap", "water_gap")) {
  if (v %in% names(coef(horse_diarrhea))) {
    cat("  ", v, ": β =", round(coef(horse_diarrhea)[v], 3),
        ", SE =", round(sqrt(vcovHC(horse_diarrhea, type = "HC1")[v, v]), 3), "\n")
  }
}

horse_stunting <- lm(delta_stunting ~ ujjwala_exposure + electricity_gap +
                       sanitation_gap + water_gap + baseline_female_literate +
                       factor(state_code), data = district)
cat("Horse race (Δ stunting):\n")
for (v in c("ujjwala_exposure", "electricity_gap", "sanitation_gap", "water_gap")) {
  if (v %in% names(coef(horse_stunting))) {
    cat("  ", v, ": β =", round(coef(horse_stunting)[v], 3),
        ", SE =", round(sqrt(vcovHC(horse_stunting, type = "HC1")[v, v]), 3), "\n")
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# R6: Non-linear Exposure — Quartile Dummies
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── R6. Non-linear Exposure (quartile dummies) ──\n")

district[, exposure_quartile := cut(ujjwala_exposure,
  breaks = quantile(ujjwala_exposure, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE),
  labels = c("Q1 (low)", "Q2", "Q3", "Q4 (high)"),
  include.lowest = TRUE)]

rob_quart_diarrhea <- lm(delta_diarrhea ~ exposure_quartile + baseline_electricity +
                           baseline_sanitation + baseline_water + baseline_female_literate +
                           factor(state_code), data = district)
cat("Diarrhea by exposure quartile (ref: Q1-low):\n")
quart_coefs <- coef(rob_quart_diarrhea)
quart_se <- sqrt(diag(vcovHC(rob_quart_diarrhea, type = "HC1")))
for (q in c("Q2", "Q3", "Q4 (high)")) {
  qname <- paste0("exposure_quartile", q)
  if (qname %in% names(quart_coefs)) {
    cat("  ", q, ": β =", round(quart_coefs[qname], 3),
        ", SE =", round(quart_se[qname], 3), "\n")
  }
}

rob_quart_fuel <- lm(delta_clean_fuel ~ exposure_quartile + baseline_electricity +
                       baseline_sanitation + baseline_water + baseline_female_literate +
                       factor(state_code), data = district)
cat("Clean fuel by exposure quartile (ref: Q1-low):\n")
quart_coefs <- coef(rob_quart_fuel)
quart_se <- sqrt(diag(vcovHC(rob_quart_fuel, type = "HC1")))
for (q in c("Q2", "Q3", "Q4 (high)")) {
  qname <- paste0("exposure_quartile", q)
  if (qname %in% names(quart_coefs)) {
    cat("  ", q, ": β =", round(quart_coefs[qname], 3),
        ", SE =", round(quart_se[qname], 3), "\n")
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# R7: Leave-One-State-Out Sensitivity
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── R7. Leave-One-State-Out (diarrhea + clean fuel) ──\n")

states <- unique(district$state_code[!is.na(district$state_code)])
loso_results <- data.table()

for (s in states) {
  dt_sub <- district[state_code != s & !is.na(delta_diarrhea) & !is.na(ujjwala_exposure)]
  n_states_sub <- length(unique(dt_sub$state_code))
  if (nrow(dt_sub) > 30 & n_states_sub > 1) {
    mod <- feols(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                baseline_sanitation + baseline_water | state_code,
                data = dt_sub, se = "hetero")
    beta_val <- coef(mod)["ujjwala_exposure"]
    se_val <- se(mod)["ujjwala_exposure"]
    loso_results <- rbind(loso_results, data.table(
      state_dropped = s,
      outcome = "diarrhea",
      beta = round(beta_val, 3),
      se = round(se_val, 3),
      n = nrow(dt_sub)
    ))
  }
}

# Also for first stage
loso_fs <- data.table()
for (s in states) {
  dt_sub <- district[state_code != s & !is.na(delta_clean_fuel) & !is.na(ujjwala_exposure)]
  n_states_sub <- length(unique(dt_sub$state_code))
  if (nrow(dt_sub) > 30 & n_states_sub > 1) {
    mod <- feols(delta_clean_fuel ~ ujjwala_exposure + baseline_electricity +
                baseline_sanitation + baseline_water | state_code,
                data = dt_sub, se = "hetero")
    beta_val <- coef(mod)["ujjwala_exposure"]
    se_val <- se(mod)["ujjwala_exposure"]
    loso_fs <- rbind(loso_fs, data.table(
      state_dropped = s,
      outcome = "clean_fuel",
      beta = round(beta_val, 3),
      se = round(se_val, 3),
      n = nrow(dt_sub)
    ))
  }
}

loso_all <- rbind(loso_results, loso_fs)

cat("  Diarrhea β range: [", min(loso_results$beta), ",", max(loso_results$beta), "]\n")
cat("  Clean fuel β range: [", min(loso_fs$beta), ",", max(loso_fs$beta), "]\n")

# ═══════════════════════════════════════════════════════════════════════════════
# Save robustness objects
# ═══════════════════════════════════════════════════════════════════════════════

save(placebo_diarrhea, placebo_stunting, placebo_vacc, placebo_inst_births,
     rob_diarrhea_full, rob_stunting_full,
     horse_diarrhea, horse_stunting,
     rob_quart_diarrhea, rob_quart_fuel,
     balance_results, loso_all,
     file = file.path(data_dir, "robustness_objects.RData"))

cat("\n=== Robustness Checks Complete ===\n")
