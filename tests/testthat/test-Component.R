test_that("RemoveSeasonal returns seasonal means and anomalies", {
  y <- c(1, 2, 3, 4, 5, 6)
  t <- c(101, 101, 101, 202, 202, 202)

  out <- RemoveSeasonal(y, t)

  expect_equal(out$mu, c(2, 5))
  expect_equal(out$anomaly, c(-1, 0, 1, -1, 0, 1))
})

test_that("RemoveSeasonal ignores NA values", {
  y <- c(1, NA, 3, 4, 5, 6)
  t <- c(101, 101, 101, 202, 202, 202)

  out <- RemoveSeasonal(y, t)

  expect_equal(out$mu, c(2, 5))
  expect_true(is.na(out$anomaly[2]))
  expect_equal(out$anomaly[c(1, 3)], c(-1, 1))
  expect_equal(out$anomaly[4:6], c(-1, 0, 1))
})

test_that("LS_OneBreak fits a plain linear model when Ic = NA", {
  X <- 1:10
  Y <- 1 + 2 * X

  out <- LS_OneBreak(Y, X, NA)

  expect_equal(unname(out$coef), c(1, 2), tolerance = 1e-8)
  expect_equal(out$SSE, 0, tolerance = 1e-8)
})

test_that("LS_OneBreak fits a one-break piecewise model", {
  X <- 1:10
  Ic <- 5
  seg <- c(rep(0, Ic), rep(1, 10 - Ic))
  Y <- 1 + 2 * X + 3 * seg

  out <- LS_OneBreak(Y, X, Ic)

  expect_equal(unname(out$coef), c(1, 2, 3), tolerance = 1e-8)
  expect_equal(out$SSE, 0, tolerance = 1e-8)
})

test_that("LS_MultiBreaks fits a multi-break piecewise model", {
  n <- 10
  X <- 1:n
  Ips <- c(3, 7, 10)
  seg1 <- c(rep(0, 3), rep(1, 4), rep(0, 3)) # 4:7
  seg2 <- c(rep(0, 7), rep(1, 3))            # 8:10
  Y <- 1 + 2 * X + 3 * seg1 + 4 * seg2

  out <- LS_MultiBreaks(Y, X, Ips)

  # design uses centered X, so intercept = 1 + 2 * mean(X)
  expect_equal(unname(out$coef), c(1 + 2 * mean(X), 2, 3, 4), tolerance = 1e-8)
  expect_equal(out$fitted, Y, tolerance = 1e-8)
  expect_equal(out$SSE, 0, tolerance = 1e-8)
})

test_that("lm_solve returns the least squares solution", {
  X <- 1:3
  Y <- 1 + 2 * X
  design <- cbind(1, X)

  out <- lm_solve(design, Y)

  expect_equal(unname(out$coef), c(1, 2), tolerance = 1e-8)
  expect_equal(out$fitted, Y, tolerance = 1e-8)
  expect_equal(out$resi, rep(0, 3), tolerance = 1e-8)
  expect_equal(out$SSE, 0, tolerance = 1e-8)
})

test_that("lm_solve only.SSE returns just the SSE", {
  X <- 1:3
  Y <- 1 + 2 * X
  design <- cbind(1, X)

  out <- lm_solve(design, Y, only.SSE = TRUE)

  expect_named(out, "SSE")
  expect_equal(out$SSE, 0, tolerance = 1e-8)
})
