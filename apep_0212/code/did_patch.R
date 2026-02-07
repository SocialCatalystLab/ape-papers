################################################################################
# did_patch.R
# Patches did::compute.aggte and did::compute.att_gt to fix data.table
# get() incompatibility with data.table >= 1.16.x / R >= 4.5
#
# Bug: did 2.3.0 uses get(gname) inside data.table [.data.table, but
# modern data.table no longer intercepts get() in i expressions, causing
# "invalid first argument" errors.
#
# Fix: Replace get(gname) with data[[gname]] patterns.
################################################################################

patch_did_for_datatable <- function() {

  # --- Patch compute.aggte ---
  # The failing line is:
  #   dt[get(gname) == Inf, `:=`((gname), 0)]
  # Replace with:
  #   data.table::set(dt, which(is.infinite(dt[[gname]])), gname, 0)

  original_compute_aggte <- did:::compute.aggte
  src <- deparse(original_compute_aggte, width.cutoff = 500)

  # Find and replace the problematic line
  for (i in seq_along(src)) {
    if (grepl("dt\\[get\\(gname\\)", src[i])) {
      src[i] <- "        data.table::set(dt, which(is.infinite(dt[[gname]])), gname, 0)"
    }
  }

  patched <- eval(parse(text = paste(src, collapse = "\n")))
  environment(patched) <- asNamespace("did")
  assignInNamespace("compute.aggte", patched, ns = "did")

  # --- Patch compute.att_gt ---
  # Multiple lines use get(gname), get(tname), get(idname)
  # These are all inside data.table expressions
  # Replace: get(gname) -> data[[gname]]
  # Replace: get(tname) -> data[[tname]]
  # Replace: get(idname) -> data[[idname]]

  original_compute_att_gt <- did:::compute.att_gt
  src2 <- deparse(original_compute_att_gt, width.cutoff = 500)

  for (i in seq_along(src2)) {
    # Replace get(gname) with data[[gname]]
    src2[i] <- gsub("get\\(gname\\)", "data[[gname]]", src2[i])
    src2[i] <- gsub("get\\(tname\\)", "data[[tname]]", src2[i])
    src2[i] <- gsub("get\\(idname\\)", "data[[idname]]", src2[i])
  }

  patched2 <- eval(parse(text = paste(src2, collapse = "\n")))
  environment(patched2) <- asNamespace("did")
  assignInNamespace("compute.att_gt", patched2, ns = "did")

  cat("  did package patched for data.table compatibility.\n")
}

patch_did_for_datatable()
