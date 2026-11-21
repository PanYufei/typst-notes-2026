# typst-notes-2026

R 包开发作业：以 `rpkg.template` 为模板，加入 `RHtests/R/Component.R` 的分段回归与季节项剔除函数。

<!-- badges: start -->
[![R-CMD-check](https://github.com/PanYufei/typst-notes-2026/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/PanYufei/typst-notes-2026/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Functions

- `RemoveSeasonal(y, t_mmdd)` — 季节项剔除
- `LS_OneBreak(Y, X, Ic)` — 单断点分段回归（同斜率、不同截距）
- `LS_MultiBreaks(Y, X, Ips)` — 多断点分段回归
- `lm_solve(design, response)` — 最小二乘求解内核（内部函数）

## Installation

``` r
remotes::install_github("PanYufei/typst-notes-2026")
```

## Docs

- `docs/component.typ` — 函数文档（Typst）
- `docs/046241_潘宇飞.typ` / `046241_潘宇飞.pdf` — 作业笔记

## Example

``` r
library(rpkg.template)

y <- c(1, 2, 3, 4, 5, 6)
t <- c(101, 101, 101, 202, 202, 202)
RemoveSeasonal(y, t)

X <- 1:10
Y <- 1 + 2 * X
LS_OneBreak(Y, X, NA)
```
