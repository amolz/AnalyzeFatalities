library(testthat)
library(AnalyzeFatalities)

test_that("Check file name creation", {
  expect_match(make_filename(2013),"accident_2013.csv.bz2")
})
