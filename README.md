# Navier–Stokes 形式化验核记录

**默认构建和 27 个声明的公理检查均通过，六份配置的题面比对与内核重放正在运行。** 验核对象为 [上游固定提交](https://github.com/tristanbuckmaster/navier-stokes/tree/ad53419de079eb8f95f60313473374624a348546)。

指定实例上，`lake build` 用时 58 分 13 秒，退出码为 `0`，Lake 报告全部 10,987 项任务完成。对解答执行上游公理查询后，27 个声明的输出均只使用三项获准公理。[完整构建日志](logs/build.log.gz) · [各声明的公理](axioms.json)

指定 Linux 实例上检出的 2,285 个受版本控制文件，其 Git blob 哈希和可执行位均与提交 `ad53419de079eb8f95f60313473374624a348546` 一致。Git 树为 `96db4860a29e55ea2dc3fb8929e76f128fcc1712`。

| 源码清点项目 | 实测结果 |
| --- | ---: |
| Lean 源文件 | 2,271 |
| Lean 源文件行数（含空行和注释） | 616,060 |
| 比对配置 / 不重复的目标定理 | 6 / 19 |
| 上游公理打印脚本列举的声明 | 27 |

锁定版本为 Lean 4.33.1 和 Mathlib 提交 `0df444a360eaa60ab8c11dca51a86af692955474`。[机器可读清单](source-inventory.json) 包含定理名称、配置、依赖和论文 PDF 的 SHA-256。在 Linux 上运行 `python3 scripts/source-audit.py /path/to/upstream` 可重做源码核对。

论文第 1 页与第 4 页给出相同的 64 位十六进制证书摘要。实例使用 SHA-256 比对了全部 2,285 个受版本控制文件，无整文件匹配。论文提取文本中未找到 SHA-256 算法名称。相关记录见[证书检查](certificate-check.json)和[运行环境](environment.json)。

论文所述数值证书及配套区间算术程序未随此提交发布。要验证具体数据满足形式定理的假设，还需要这些材料。[上游对验核范围的说明](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/README.md)
