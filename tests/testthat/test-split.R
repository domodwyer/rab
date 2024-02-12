library(lubridate)

df <- dplyr::tribble(
  ~timestamp, ~v,
  as_datetime("1959-09-13 18:55:41"), 1,
  as_datetime("1959-09-13 18:55:42"), 2,
  as_datetime("1959-09-13 18:55:43"), 3,
  as_datetime("1959-09-13 18:55:44"), 4,
)

test_that("split", {
  # Lower-bound is inclusive
  expect_equal(ab_split(df, "1959-09-13 18:55:40"), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "after",
    as_datetime("1959-09-13 18:55:42"), 2, "after",
    as_datetime("1959-09-13 18:55:43"), 3, "after",
    as_datetime("1959-09-13 18:55:44"), 4, "after",
  ))
  expect_equal(ab_split(df, "1959-09-13 18:55:41"), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "before",
    as_datetime("1959-09-13 18:55:42"), 2, "after",
    as_datetime("1959-09-13 18:55:43"), 3, "after",
    as_datetime("1959-09-13 18:55:44"), 4, "after",
  ))

  # Upper-bound is exclusive
  expect_equal(ab_split(df, "1959-09-13 18:55:43"), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "before",
    as_datetime("1959-09-13 18:55:42"), 2, "before",
    as_datetime("1959-09-13 18:55:43"), 3, "before",
    as_datetime("1959-09-13 18:55:44"), 4, "after",
  ))
  expect_equal(ab_split(df, "1959-09-13 18:55:44"), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "before",
    as_datetime("1959-09-13 18:55:42"), 2, "before",
    as_datetime("1959-09-13 18:55:43"), 3, "before",
    as_datetime("1959-09-13 18:55:44"), 4, "before",
  ))
})

test_that("split out-of-bounds", {
  # Split point way before
  expect_equal(ab_split(df, "1959-09-13 18:00:00"), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "after",
    as_datetime("1959-09-13 18:55:42"), 2, "after",
    as_datetime("1959-09-13 18:55:43"), 3, "after",
    as_datetime("1959-09-13 18:55:44"), 4, "after",
  ))

  # Split point way after
  expect_equal(ab_split(df, "1959-09-13 19:00:00"), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "before",
    as_datetime("1959-09-13 18:55:42"), 2, "before",
    as_datetime("1959-09-13 18:55:43"), 3, "before",
    as_datetime("1959-09-13 18:55:44"), 4, "before",
  ))
})

test_that("split with b_start", {
  expect_equal(ab_split(
    df,
    "1959-09-13 18:55:41",
    b_start = "1959-09-13 18:55:44"
  ), dplyr::tribble(
    ~timestamp, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "before",
    as_datetime("1959-09-13 18:55:42"), 2, "ignored",
    as_datetime("1959-09-13 18:55:43"), 3, "ignored",
    as_datetime("1959-09-13 18:55:44"), 4, "after",
  ))
})

test_that("split with timestamp_col", {
  df <- dplyr::tribble(
    ~other_time, ~v,
    as_datetime("1959-09-13 18:55:41"), 1,
    as_datetime("1959-09-13 18:55:42"), 2,
    as_datetime("1959-09-13 18:55:43"), 3,
    as_datetime("1959-09-13 18:55:44"), 4,
  )

  expect_equal(ab_split(
    df,
    "1959-09-13 18:55:42",
    timestamp_col = "other_time"
  ), dplyr::tribble(
    ~other_time, ~v, ~period,
    as_datetime("1959-09-13 18:55:41"), 1, "before",
    as_datetime("1959-09-13 18:55:42"), 2, "before",
    as_datetime("1959-09-13 18:55:43"), 3, "after",
    as_datetime("1959-09-13 18:55:44"), 4, "after",
  ))
})
