#set text(font: ("New Computer Modern", "SimSun"), size: 11pt)
#set page(numbering: "1 / 1", margin: 2.4cm)
#set par(justify: true)
#set heading(numbering: "1.")

#align(center)[
  = Component.R 函数文档
  #text(size: 10pt)[rpkgs/RHtests · R/Component.R]
]

本文档说明 `R/Component.R` 中实现的四个函数：季节项剔除 `RemoveSeasonal`、
单断点分段回归 `LS_OneBreak`、多断点分段回归 `LS_MultiBreaks`，以及最小二乘
求解内核 `lm_solve`。

== RemoveSeasonal：剔除季节循环

#quote(block: true)[
  给定观测序列 $y$ 与每个观测对应的月日 $t_"mmdd"$，返回按 $t_"mmdd"$ 升序排列的
  季节均值向量 $mu$ 与去季节后的异常序列 $"anomaly"$。
]

对每个唯一的月日 $t_j$，季节均值为

$ mu_j = 1/n_j sum_(i: t_i = t_j) y_i $

其中 $n_j$ 为该月日出现的次数（缺失值被剔除）。去季节序列为

$ a_i = y_i - mu_(j(i)) $

=== 参数

#table(
  columns: (auto, auto),
  stroke: 0.5pt,
  [*参数*], [*说明*],
  [`y`], [数值向量，观测值。],
  [`t_mmdd`], [数值向量，与 `y` 等长，各观测的月日（MMDD）。],
)

=== 返回值

列表，含两个分量：

- `mu`：按 $t_"mmdd"$ 升序排列的季节均值；
- `anomaly`：与 $y$ 等长的去季节序列。

== LS_OneBreak：单断点分段回归

#quote(block: true)[
  同斜率、不同截距的分段线性回归：在位置 $I_c$ 处允许截距跳变，
  $\[1, I_c\]$ 与 $\[I_c + 1, n\]$ 两段共用同一斜率。
]

设计矩阵为

$ D = mat(1, x_1, "I"(1 > I_c); dots.v, dots.v, dots.v; 1, x_n, "I"(n > I_c)) $

当 $I_c = "NA"$ 时退化为普通一元线性回归（仅含截距与 $x$ 两列）。参数由
`.lm.fit` 求解：

$ hat(beta) = "argmin"_beta norm(D beta - y)_2^2 $

=== 参数

#table(
  columns: (auto, auto),
  stroke: 0.5pt,
  [*参数*], [*说明*],
  [`Y`], [响应向量。],
  [`X`], [预测变量向量。],
  [`Ic`], [变点位置；`[1, Ic]` 与 `[Ic + 1, end]` 为两段。],
  [`...`], [传给 `lm_solve()`。],
)

=== 返回值

- `coef`：回归系数 $ (beta_0, beta_1, beta_2) $；
- `fitted`：拟合值；
- `resi`：残差；
- `SSE`：残差平方和。

== LS_MultiBreaks：多断点分段回归

#quote(block: true)[
  同斜率、不同截距的多断点分段回归。`Ips` 给出各段末尾位置，
  末位为序列长度；除第一段外，每段引入一个指示变量作为新的截距列。
]

设计矩阵首列为常数 1，第二列为中心化预测变量 $x - macron(x)$，
随后为各段指示列：

$ D = mat(1, x_1 - macron(x), "I"(i in S_1), dots, "I"(i in S_m); dots.v, dots.v, dots.v, dots.down, dots.v; 1, x_n - macron(x), "I"(n in S_1), dots, "I"(n in S_m)) $

其中 $S_k = \{"Ips"_k + 1, dots, "Ips"_(k+1)\}$ 为第 $k$ 段（$k = 1, dots, m$），
$m = |"Ips"| - 1$ 为断点数。

=== 参数

#table(
  columns: (auto, auto),
  stroke: 0.5pt,
  [*参数*], [*说明*],
  [`Y`], [响应向量。],
  [`X`], [预测变量向量（通常为时间）。],
  [`Ips`], [各段末尾位置，末位为序列长度。],
  [`...`], [传给 `lm_solve()`。],
)

=== 返回值

- `coef`：回归系数；
- `fitted`：拟合值；
- `resi`：残差。

== lm_solve：最小二乘内核

#quote(block: true)[
  基于 `.lm.fit` 的线性最小二乘求解器，为分段回归提供统一的拟合入口。
]

$ l = ".lm.fit"(D, y), quad hat(y) = D hat(beta), quad "SSE" = sum(l_"resi"^2) $

当 `only.SSE = TRUE` 时仅返回残差平方和（供变点搜索时快速比较）。

=== 参数

#table(
  columns: (auto, auto),
  stroke: 0.5pt,
  [*参数*], [*说明*],
  [`design`], [设计矩阵。],
  [`response`], [响应向量。],
  [`only.SSE`], [若为 `TRUE` 仅返回 `SSE`。],
  [`...`], [传给 `.lm.fit`。],
)

== 测试要点

`tests/testthat/test-Component.R` 覆盖以下情形：

+ `RemoveSeasonal`：季节均值与异常序列的正确性，以及缺失值剔除；
+ `LS_OneBreak`：$I_c = "NA"$ 退化为线性回归、含断点的精确拟合（`SSE = 0`）；
+ `LS_MultiBreaks`：多段精确拟合，注意中心化后截距为 $beta_0 + beta_1 macron(x)$；
+ `lm_solve`：系数、拟合值、残差、`SSE` 及 `only.SSE` 分支。
