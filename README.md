# Why Are There Negative Numbers for My Country? 📉

An analysis repository investigating occurrence record deletions in GBIF datasets, with a focus on Poland (PL) and other countries that experienced significant record losses between January and April 2026.

## Context

According to GBIF analytics data (https://analytics-files.gbif.org/2026-04-01/global/csv/occ_publisherCountry.csv), several countries removed occurrence records between January 2026 and April 2026. Most notably:

- **Denmark (DK)**: Lost ~12.97 million records
- **Norway (NO)**: Lost ~7.34 million records
- Combined: Over 20 million records deleted

## What's in This Repository

### Analysis Scripts

- **`analyze_deleted_records.R`** - R script that analyzes the `occ_publisherCountry.csv` file to identify all countries that lost records between Jan 2026 and Apr 2026
  - Compares snapshot data from 2026-01-01 and 2026-04-01
  - Generates CSV reports of countries with record losses
  - Calculates percentage changes and total records lost

### Database Queries

- **`poland_datasets_deleted.sql`** - Trino SQL query to find specific Polish datasets that lost records
  - Queries the `hive.analytics.snapshots` table
  - Groups by dataset_id and publisher_id
  - Tracks changes across Jan, Apr, and May 2026 snapshots
  - Includes percentage changes and recovery status

## Data Sources

- **CSV Analytics**: https://analytics-files.gbif.org/2026-04-01/global/csv/occ_publisherCountry.csv
- **Trino Database**: 
  - Server: `https://c8n1.gbif.org:31843`
  - Catalog: `hive`
  - Schema: `analytics`
  - Table: `snapshots`

## Quick Start

### Analyzing Country-Level Data

```r
# Run the R analysis on the CSV file
Rscript analyze_deleted_records.R
```

This will generate:
- `countries_lost_records_jan_apr_2026.csv` - Countries that lost records
- `countries_gained_records_jan_apr_2026.csv` - Countries that gained records
- `full_comparison_jan_apr_2026.csv` - Complete comparison

### Querying Dataset-Level Data

```bash
# Query specific datasets in Trino
java -jar trino.jar --insecure \
  --server https://c8n1.gbif.org:31843 \
  --catalog hive \
  --schema analytics \
  --user gbif \
  --password \
  --file poland_datasets_deleted.sql > poland_results.txt
```

## Key Findings

### Country-Level Changes (Jan → Apr 2026)
- Total countries affected: [To be filled after running analysis]
- Total records lost globally: [To be calculated]
- Top countries by records lost:
  1. Denmark (DK): ~12,971,044 records (-16.6%)
  2. Norway (NO): ~7,340,718 records (-9.0%)

### Dataset-Level Analysis (Poland)
The SQL query identifies:
- Specific datasets that lost records
- Publisher organizations affected
- Recovery patterns (Apr → May 2026)
- Datasets with continued losses vs. recoveries

## Questions This Answers

1. **Why are there negative numbers for my country?**  
   Records are being deleted/withdrawn from datasets, showing as negative changes between snapshots.

2. **Which datasets are affected?**  
   The Trino queries identify specific dataset UUIDs and publishers.

3. **Is it recovering?**  
   By comparing May 2026 data, we can see if datasets are recovering, stable, or continuing to lose records.

4. **What's the scale of the problem?**  
   The R script calculates total impact across all countries.

## Requirements

### For R Analysis
- R (tested with R 4.x)
- Required packages:
  ```r
  install.packages(c("dplyr", "readr"))
  ```

### For Trino Queries
- Java (for Trino CLI)
- Trino CLI jar: https://repo1.maven.org/maven2/io/trino/trino-cli/
- Network access to GBIF Trino server
- Valid credentials (username: `gbif`)

## Schema Reference

### occ_publisherCountry.csv
```
snapshot,publisherCountry,occurrenceCount
2026-01-01,DK,78072754
2026-04-01,DK,65101710
```

### hive.analytics.snapshots table
```
snapshot         VARCHAR
id               BIGINT
dataset_id       VARCHAR
publisher_id     VARCHAR
publisher_country VARCHAR
[...additional taxonomy and location fields...]
```

## Contributing

Feel free to add:
- Additional country-specific queries
- Time-series visualizations
- Recovery tracking scripts
- Publisher impact reports

## License

This is analysis code for investigating GBIF data patterns. Data remains under GBIF's terms of use.

## Contact

For questions about GBIF data deletions, contact the GBIF Help Desk: https://www.gbif.org/contact-us
