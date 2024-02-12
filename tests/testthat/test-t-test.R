library(lubridate)

test_that("t.test", {
  df <- dplyr::tribble(
    ~timestamp, ~value,
    as_datetime("1959-09-13 18:55:41"), 1,
    as_datetime("1959-09-13 18:55:42"), 2,
    as_datetime("1959-09-13 18:55:43"), 3,
    as_datetime("1959-09-13 18:55:44"), 4,
  )

  got <- ab_split(df, "1959-09-13 18:55:42") |>
    ab_t_test()

  expect_equal(round(got$p.value, 1), 0.1)
})

test_that("value_col", {
  df <- dplyr::tribble(
    ~timestamp, ~v,
    as_datetime("1959-09-13 18:55:41"), 1,
    as_datetime("1959-09-13 18:55:42"), 2,
    as_datetime("1959-09-13 18:55:43"), 3,
    as_datetime("1959-09-13 18:55:44"), 4,
  )

  got <- ab_split(df, "1959-09-13 18:55:42") |>
    ab_t_test(value_col = "v")

  expect_equal(round(got$p.value, 1), 0.1)
})
