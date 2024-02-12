#' Categorise measurements in a dataframe by splitting rows into "before" and
#' "after" samples, with an optional delay period between them.
#'
#' This category label is stored in a new column added as "df$period".
#'
#' @param df A dataframe containing timeseries measurements.
#' @param a_end An inclusive timestamp defining the end of the A / "before"
#' samples.
#' @param b_start An inclusive timestamp defining the start of the B / "after"
#' samples, defaulting to all values after "a_end".
#' @param timestamp_col The timestamp column name (defaults to "timestamp").
#' @returns Input dataframe with a new "period" char column.
#' @examples
#' library(dplyr)
#' library(lubridate)
#'
#' # Your dataframe containing a timestamp
#' df <- tribble(
#'   ~timestamp, ~value,
#'   as_datetime("1959-09-13 13:00:00"), 1,
#'   as_datetime("1959-09-13 14:00:00"), 2,
#'   as_datetime("1959-09-13 15:00:00"), 3,
#' )
#'
#' # Everything before the given timestamp (in column "timestamp") is "before",
#' # and all other measurements are labelled "after":
#' df |> ab_split("1959-09-13 14:42:00")
#'
#' # Add an additional "ignored" category between 2 and 3 PM.
#' #
#' # This is useful to later filter out measurements taken during a changeover.
#' df |> ab_split(a_end = "1959-09-13 12:00", b_start = "1959-09-13 15:00")
#' @export
ab_split <- function(df, a_end, b_start = NA, timestamp_col = "timestamp") {
  if (is.na(b_start)) {
    b_start <- a_end
  }
  a_end <- lubridate::as_datetime(a_end)
  b_start <- lubridate::as_datetime(b_start)
  df <- df |>
    dplyr::mutate(
      period = dplyr::case_when(
        get({{ timestamp_col }}) <= a_end ~ "before",
        get({{ timestamp_col }}) >= b_start ~ "after",
        TRUE ~ "ignored"
      )
    )
  return(df)
}

#' A wrapper over the standard library "stats::t.test" comparing the A & B
#' samples.
#'
#' @param df A dataframe previously split using "ab_split()".
#' @param value_col The value column name to test (defaults to "value").
#' @returns The "stats::t.test()" return value.
#' @export
ab_t_test <- function(df, value_col = "value") {
  # nolint start: object_usage_linter
  before <- df |>
    dplyr::filter(period == "before") |>
    dplyr::pull(get({{ value_col }}))
  after <- df |>
    dplyr::filter(period == "after") |>
    dplyr::pull(get({{ value_col }}))
  # nolint end
  out <- stats::t.test(before, after)
  if (out$p.value < 0.05) {
    message("==> statistically significant change between A & B samples")
  }
  return(out)
}
