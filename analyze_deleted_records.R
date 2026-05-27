# Analysis of GBIF Occurrence Records Deleted Between January 2026 and April 2026
# Script analyzes which countries lost occurrence records during this period

library(dplyr)
library(readr)
library(tidyr)

# Read the CSV file
cat("Reading data...\n")
data <- read_csv("occ_publisherCountry.csv", show_col_types = FALSE)

# Filter for the two snapshots of interest
jan_2026 <- data %>%
  filter(snapshot == "2026-01-01") %>%
  select(publisherCountry, jan_count = occurrenceCount)

apr_2026 <- data %>%
  filter(snapshot == "2026-04-01") %>%
  select(publisherCountry, apr_count = occurrenceCount)

# Join the two datasets and calculate the change
comparison <- jan_2026 %>%
  full_join(apr_2026, by = "publisherCountry") %>%
  mutate(
    jan_count = replace_na(jan_count, 0),
    apr_count = replace_na(apr_count, 0),
    change = apr_count - jan_count,
    pct_change = ifelse(jan_count > 0, (change / jan_count) * 100, NA)
  )

# Filter for countries that lost records (negative change)
countries_lost_records <- comparison %>%
  filter(change < 0) %>%
  arrange(change) %>%  # Sort by change (most negative first)
  mutate(
    records_lost = abs(change),
    pct_change = round(pct_change, 2)
  ) %>%
  select(
    publisherCountry,
    jan_2026_count = jan_count,
    apr_2026_count = apr_count,
    records_lost,
    pct_change
  )

# Display summary statistics
cat("\n=================================================\n")
cat("SUMMARY: Countries that LOST records (JAN 2026 - APR 2026)\n")
cat("=================================================\n\n")

cat(sprintf("Total countries that lost records: %d\n", nrow(countries_lost_records)))
cat(sprintf("Total records lost across all countries: %s\n", 
            format(sum(countries_lost_records$records_lost), big.mark = ",")))
cat(sprintf("\nTop 10 countries by records lost:\n\n"))

# Display the top 10 countries
top_10 <- countries_lost_records %>%
  head(10)

print(top_10, n = 10)

# Also check countries that gained records
countries_gained_records <- comparison %>%
  filter(change > 0) %>%
  arrange(desc(change)) %>%
  mutate(
    records_gained = change,
    pct_change = round(pct_change, 2)
  ) %>%
  select(
    publisherCountry,
    jan_2026_count = jan_count,
    apr_2026_count = apr_count,
    records_gained,
    pct_change
  )

cat("\n\n=================================================\n")
cat("For reference: Countries that GAINED records\n")
cat("=================================================\n\n")
cat(sprintf("Total countries that gained records: %d\n", nrow(countries_gained_records)))
cat(sprintf("Total records gained across all countries: %s\n", 
            format(sum(countries_gained_records$records_gained), big.mark = ",")))

# Export full results to CSV files
write_csv(countries_lost_records, "countries_lost_records_jan_apr_2026.csv")
write_csv(countries_gained_records, "countries_gained_records_jan_apr_2026.csv")
write_csv(comparison, "full_comparison_jan_apr_2026.csv")

cat("\n\n=================================================\n")
cat("Output files created:\n")
cat("=================================================\n")
cat("  - countries_lost_records_jan_apr_2026.csv\n")
cat("  - countries_gained_records_jan_apr_2026.csv\n")
cat("  - full_comparison_jan_apr_2026.csv\n\n")

# Verify Denmark and Norway specifically
cat("=================================================\n")
cat("Verification of Denmark and Norway:\n")
cat("=================================================\n\n")

dk_no <- countries_lost_records %>%
  filter(publisherCountry %in% c("DK", "NO"))

print(dk_no)

cat(sprintf("\nDenmark + Norway combined lost: %s records\n", 
            format(sum(dk_no$records_lost), big.mark = ",")))
