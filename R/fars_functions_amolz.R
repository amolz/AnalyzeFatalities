#' @title Print glimpse about motor vehicle accidents in the US
#'
#' @description  \code{fars_read} reads and prints dataframe of the mentioned file name from the
#'    working directory if it exists
#'
#' @details This function checks if the filename (using the \code{filename}) mentioned as the function argument
#'    exists in the working directory.
#'
#' @param filename A character string indicating the file name of dataframe and suffixed with .csv
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @return If the filename doesn't exist then this function prints that the filename does not exists. Otherwise
#'    it prints the tibble with first 10 rows and few fields in tabular form and remaining field names in text
#'
#' @note filename mentioned without quotes " " will get considered as invalid file arguments
#'
#' @examples
#' \dontrun{
#' fars_read("accident_2013.csv")
#' fars_read("accident_2015.csv")}
#'
#' @export
fars_read <- function(filename) {
  if(!file.exists(filename))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(filename, progress = FALSE)
  })
  dplyr::tbl_df(data)
}





#' @title Create and Print file name
#'
#' @description \code{make_filename} creates and prints a filename representing zipped .csv file
#'    that would contain fatalities data in a given year in the US
#'
#' @details This function converts the mentioned argument (using the \code{year}) into an integer
#' and creates a zipped .csv file name prefixed with "accident_"
#'
#' @param year Numeric or Character String represting a calendar year
#'
#' @note leaving argument blank will lead to an missing argument error as there's no default value
#'
#' @return Prints the filename of zipped .csv file
#'
#' @examples
#' \dontrun{
#' make_filename(2015)
#' make_filename("2017")
#' make_filename(17)}
#'
#' @export
make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("accident_%d.csv.bz2", year)
}





#' @title Read and Print month & year of accident data in the US in given years
#'
#' @description   Reads and Prints month and year data in the dataframes from working directory that
#'    contain fatalities data of accidents in the US in given years
#'
#' @details This function takes vector of valid years and applies make_filename
#'   and fars_read functions to read and print tibble of valid files from working directory
#'
#' @param years A vector of years where each year is a 4 digit numeric or character string
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#'
#' @inherit make_filename
#' @inherit fars_read
#'
#' @return Prints a tibble with Month and year for first 10 rows for each of the valid year inputs
#'
#' @note Function returns an error message if the years input is not a valid year
#'
#' @examples
#' \dontrun{
#' fars_read_years(c(2013,2014))
#' fars_read_years(c(2013,2014, 2015))}
#'
#' @export
fars_read_years <- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)
    tryCatch({
      dat <- fars_read(file)
      dplyr::mutate(dat, year = year) %>%
        dplyr::select(MONTH, year)
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}




#' @title Summarize number of observations
#'
#' @description This function summarizes the number of observations representing motor vehicle accidents
#'    for each month in different years
#'
#' @details This function reads one or more accident dataframes using \code{years} as input and summarizes
#'    in tabular form the number of observations for each month in different years
#'
#' @inherit fars_read_years
#' @inheritParams fars_read_years
#'
#' @importFrom dplyr bind_rows
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr %>%
#' @importFrom tidyr spread
#'
#' @return This function prints a tibble of months as rows, years as fields and number of observations
#'    as a table
#'
#' @note This function returns an error for invalid years input or no input
#'
#' @examples
#' \dontrun{
#' fars_summarize_years(c(2013))
#' fars_summarize_years(c(2013, 2014, "2015"))}
#'
#' @export
fars_summarize_years <- function(years) {
  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}




#' @title Plot map of accident locations in a year for a state in the US
#'
#' @description This function plots a map representing accident locations for a valid state number
#'    and a valid year as input
#'
#' @details This function, takes a valid state number as input (using \code{state.num}) and
#'    a valid year (using \code{year}) as inputs,
#'    creates a filename (using \code{\link{make_filename}}) that represents accidents data in the given year,
#'    reads the dataframe (using \code{\link{fars_read}}),
#'    subsets the dataframe for the given state and
#'    plots the accident locations using Latitude and Longitude data points
#'
#' @param state.num A numeric or character string represting a valid state number
#' @inheritParams make_filename
#'
#' @inherit fars_read
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#' @return Plot a map/ graphic of accident locations for a particular state in the US
#'
#' @note Functions stops or shows error message for invalid state number & year or if any argument is left blank
#'
#' @examples
#' \dontrun{
#' fars_map_state(1,2013)
#' fars_map_state("1","2014")}
#'
#' @export
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}
