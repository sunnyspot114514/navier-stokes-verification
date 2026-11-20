# Navier–Stokes 形式化验核

**形式化验核通过。** 验核在 32 核、64 GiB 的 Linux 实例上完成，使用 [上游固定提交 ad53419de079](https://github.com/tristanbuckmaster/navier-stokes/tree/ad53419de079eb8f95f60313473374624a348546)。

| 验核项目 | 实测结果 |
| --- | --- |
| 源码与依赖 | 2,285 个受版本控制文件逐一匹配 Git 对象，九个依赖与锁文件一致，完成后再次核对 |
| 默认构建 | 退出码 0，耗时 58 分 13 秒 |
| 公理检查 | 27/27 个声明取得公理输出，白名单检查通过 |
| 题面对照与内核重放 | 6/6 份配置通过，覆盖 19/19 个不同定理 |
| 数值证书 | 上游未发布本次复算所需的数据和区间算术程序 |

## 定理比对

| 上游配置 | 目标数 | 内核结果 | 耗时 |
| --- | ---: | --- | --- |
| [comparator-cell-layer.json](logs/comparator-cell-layer.log.gz) | 3 | 通过 | 27 分 18 秒 |
| [comparator-certificate.json](logs/comparator-certificate.log.gz) | 9 | 通过 | 14 分 44 秒 |
| [comparator-fractional-cell-system.json](logs/comparator-fractional-cell-system.log.gz) | 1 | 通过 | 36 分 37 秒 |
| [comparator-fractional-certificate.json](logs/comparator-fractional-certificate.log.gz) | 1 | 通过 | 10 分 38 秒 |
| [comparator-fractional.json](logs/comparator-fractional.log.gz) | 2 | 通过 | 24 分 24 秒 |
| [comparator.json](logs/comparator.log.gz) | 3 | 通过 | 10 分 37 秒 |

比对器分别导出题面与解答中的目标定理，核对声明及其依赖，检查允许的公理，并以 Lean 自带内核重放解答。运行使用非特权账户和离线环境。并行组在同一实例上使用独立的工作目录，计算前后均核对上游文件和依赖提交。

## 复核材料

- [完整机器报告、逐项退出码、时间及日志 SHA-256](verification.json)
- [默认构建完整日志](logs/build.log.gz)
- [源码、上游比较配置和目标定理清单](source-inventory.json)
- [运行环境、工具链与依赖版本](environment.json)
- [每个声明实际使用的公理](axioms.json)

使用 Lean 4.33.1 和 Mathlib 提交 `0df444a360eaa60ab8c11dca51a86af692955474`。从固定提交的 `lean/` 目录可重做默认构建和上游公理查询。

```sh
lake exe cache get
LEAN_NUM_THREADS=12 lake build
lake env lean scripts/PrintAxioms.lean
```

上游的六份 `comparator*.json` 指定了目标及允许公理 `propext`、`Quot.sound` 和 `Classical.choice`。逐项比较所用的工具提交记录在机器报告中。

## 数值证书

论文第 1 页和第 4 页给出了相同的 64 位十六进制摘要。以 SHA-256 对全部 2,285 个受版本控制文件逐一比对，没有整文件匹配。论文提取文本中未找到 SHA-256 算法名称。形式定理以给定剖面、证书或满足条件的数据为前提。具体证书是否满足这些条件，仍需要原始数据及区间验算程序复核。[证书记录](certificate-check.json) · [上游说明](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/README.md)
