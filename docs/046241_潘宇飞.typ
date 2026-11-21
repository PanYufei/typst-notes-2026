#set text(font: ("New Computer Modern", "SimSun"), size: 11pt)
#set page(numbering: "1 / 1", margin: 2.4cm)
#set par(justify: true)
#set heading(numbering: "1.")
#show raw: set text(font: "Consolas", size: 9.5pt)

#align(center)[
  = R 包开发作业笔记
  #text(size: 11pt)[046241 潘宇飞]
]

== 任务概述

以 `rpkgs/rpkg.template` 为模板构建一个 R 包，加入 `rpkgs/RHtests` 中
`R/Component.R` 的四个函数，使用 Typst 编写文档与测试说明，生成测试代码，
推送 GitHub 后由 Actions 自动运行 `R CMD check`，最终将编译好的 PDF 作为作业上交。

== 操作步骤

+ *克隆模板*：`git clone https://github.com/rpkgs/rpkg.template` 得到标准 R 包
  骨架（含 `DESCRIPTION`、`NAMESPACE`、`R/`、`tests/`、`.github/workflows/`）。
+ *添加函数*：将 `R/Component.R` 放入包的 `R/` 目录，其中包含
  `RemoveSeasonal`（季节项剔除）、`LS_OneBreak`（单断点分段回归）、
  `LS_MultiBreaks`（多断点分段回归）与内部函数 `lm_solve`（`.lm.fit` 求解内核）。
+ *补全导出*：为三个主函数补充 roxygen 注释与 `@export`，`lm_solve` 标注 `@noRd`；
  同步手写 `NAMESPACE` 的 `export(...)` 与 `man/*.Rd` 帮助页。
+ *编写文档*：用 Typst 编写 `docs/component.typ`，说明各函数的数学模型
  （设计矩阵、季节均值公式、最小二乘目标函数）与参数、返回值。
+ *编写测试*：`tests/testthat/test-Component.R` 覆盖七组用例，包括季节均值与
  缺失值剔除、无断点退化为线性回归、单/多断点精确拟合（`SSE = 0`）、
  `lm_solve` 的系数与 `only.SSE` 分支。
+ *推送与 CI*：在 GitHub 新建公开仓库 `typst-notes-2026`，将本地仓库的
  remote 指向新仓库并推送；仓库自带的 `R-CMD-check.yaml` 工作流在
  Windows 与 Ubuntu 上运行 `R CMD check`，约 2 至 3 分钟出结果。
+ *编译 PDF*：用 Typst 编译本笔记为 `046241_潘宇飞.pdf` 并随仓库上传。

== 存在的问题

+ *本地无 R 环境*：机器未安装 R，无法本地运行 `R CMD check` 与 `roxygen2`，
  因此 `man/*.Rd` 与 `NAMESPACE` 只能手写，正确性依赖 GitHub Actions 验证。
+ *Typst 安装受阻*：`scoop install typst` 从 GitHub Release 下载二进制时，
  连接被限速至约 20 至 30 KB/s 并反复超时；改用 npm 包 `@flukxr/typst-cli`
  （0.15.1）仅 6 秒即完成安装，问题解决。
+ *中文字体缺失*：Typst 默认字体不含汉字，需将字体回退设为 `SimSun`，
  否则中文无法渲染。
+ *Typst 语法陷阱*：`_` 在 Typst 中表示强调，文件名里的下划线必须写作 `\_`；
  矩阵函数名为 `mat` 而非 `matrix`；数学模式中的多字母变量须加引号
  （如 `"Ips"`），否则被拆成单字母连乘。
+ *GitHub 认证与网络*：SSH 22 端口被重置，`ssh.github.com:443` 可达但公钥
  未登记，`publickey` 被拒；最终改用 HTTPS + Personal Access Token 推送。
+ *模型未记 X 的中心化*：`LS_MultiBreaks` 的设计矩阵对 `X` 做了中心化，
  其截距实为 `beta_0 + beta_1 * mean(X)`，测试断言时需按此换算，否则会误判。

== 总结

本次作业完整走通了“模板 → 函数 → 文档 → 测试 → CI → 交付”的 R 包开发流程。
代码层面四个函数逻辑简单清晰，测试采用精确拟合构造（残差为零）便于断言；
工程层面主要困难集中在环境与网络，最终通过 npm 渠道安装 Typst、HTTPS PAT
推送得以解决。后续若在本地安装 R，可用 `roxygen2` 自动生成 `man/` 与
`NAMESPACE`，进一步减少手写带来的不一致风险。
