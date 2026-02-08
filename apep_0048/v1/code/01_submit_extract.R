# Paper 52: Submit IPUMS extract
# This script submits an IPUMS USA extract with the variables needed for urban-rural suffrage analysis

library(ipumsr)

# Set API key (should be in .Renviron or environment)
# set_ipums_api_key("YOUR_KEY", save = TRUE)

# Define the extract
extract <- define_extract_usa(
  description = "Paper 52: Urban-rural suffrage heterogeneity, 1880-1920 women",
  samples = c(
    "us1880e",  # 1880 full count
    "us1900m",  # 1900 full count  
    "us1910m",  # 1910 full count
    "us1920c"   # 1920 (100% sample available years vary)
  ),
  variables = c(
    # Identifiers
    "YEAR",
    "STATEFIP",
    "SERIAL",
    "PERNUM",
    # Key outcome
    "LABFORCE",
    # Key heterogeneity - URBAN is critical!
    "URBAN",
    # Demographics
    "SEX",
    "AGE",
    "RACE",
    "MARST",
    "NATIVITY",
    "BPL",
    # Secondary outcomes
    "OCC1950",
    "LIT",
    "SCHOOL",
    # Weights
    "PERWT"
  )
)

cat("Extract defined with", length(extract$variables), "variables.\n")
cat("Samples:", paste(extract$samples, collapse = ", "), "\n")

# Submit the extract
cat("\nSubmitting extract to IPUMS...\n")
submitted <- submit_extract(extract)
cat("Extract submitted! Number:", submitted$number, "\n")

# Save extract number for later retrieval
writeLines(as.character(submitted$number), "data/extract_number.txt")

# Wait and download
cat("\nWaiting for extract to complete (this may take 1-4 hours for full-count)...\n")
cat("You can check status at: https://usa.ipums.org/usa-action/extract_requests\n")

# Poll every 15 minutes
downloadable <- wait_for_extract(submitted, timeout = 14400)  # 4 hour timeout

if (is_extract_ready(downloadable)) {
  cat("\nExtract ready! Downloading...\n")
  download_extract(downloadable, download_dir = "data/")
  cat("Download complete!\n")
} else {
  cat("\nExtract not ready within timeout. Check IPUMS website.\n")
}
