# AnalyzeFatalities

The goal of AnalyzeFatalities is to provide set of functions that help to easily analyze fatailities data for different years, months and their spatial spread.

## Example

This is a basic example which shows a function to get a summary of number of accidents by year and month with just the year as input to the function.

``` r
fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}

# Example
fars_summarize_years(c(2013))

```
