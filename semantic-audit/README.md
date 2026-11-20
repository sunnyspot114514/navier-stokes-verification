# NS 形式化语义审计

审计对象是 Alpöge–Buckmaster 仓库的固定提交 `ad53419de079eb8f95f60313473374624a348546`，重点是经典三维、无外力 Navier–Stokes 方程。**在核查的核心证明链中，没有发现把经典方程换成分数阶方程、把爆破结论直接放进证书假设，或把附录 B 的转置算子换成另一个算子的证据。论文的定量结论与公开 Lean 定理的覆盖范围有实质差别。** [上游提交](https://github.com/tristanbuckmaster/navier-stokes/tree/ad53419de079eb8f95f60313473374624a348546) · [原验核报告](../verification.json)

## 附录 B 的两份题面

上游比对配置使用 35 行的 `CellLayerTheorems.lean`。它从证明库导入 `StatementDefs`。仓库还提供 7,086 行的 `CellLayerChallenge.lean`，供读者集中阅读相同目标的定义和声明。我们只把配置中的 `challenge_module` 换成长版，保留原解答、三个定理名和公理白名单。在两个工作目录中，官方 Comparator 均以退出码 **1** 停在 `Breakdown.AdjointDefect.transposeApply` 的依赖声明比较，未进入这次额外运行的解答内核重放。原配置的成功结果与这两次额外运行分别留档。[上游配置](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/comparator-cell-layer.json) · [短版入口](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerTheorems.lean#L1) · [长版入口](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerChallenge.lean#L7027) · [比对器判定代码](https://github.com/leanprover/comparator/blob/3927ad383f208ae977c340a91c48ac9b497d2097/Comparator/Compare.lean#L50) · [运行记录](results.json)

两份源码的转置公式逐字相同。对任意线性映射 $K$、向量 $z$ 和坐标 $j$，我们分别在两个环境中证明了 $(K^\mathsf{T}z)_j=\langle Ke_j,z\rangle$。严格比较遇到的是一个辅助证明的名字，一边引用 `traceFreeConst._proof_2`，另一边引用 `labelPhase._proof_1`。二者证明同一个小型数值命题。[长版公式](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerChallenge.lean#L3521) · [库内公式](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/CertCell/StatementDefs.lean#L2717) · [长版坐标检验](TransposeLong.lean) · [库内坐标检验](TransposeLibrary.lean)

| 对三个定理的类型及可达项目声明所做的检查 | 实测结果 |
| --- | --- |
| 定理类型与宇宙参数 | 3/3 原样相同 |
| 两边合计可达的项目声明名 | 2,075 个，其中 2,066 个同名 |
| 同名声明的严格表示差异 | 95 个，类型和其余声明元数据相同，差异在定义体 |
| 证明名称归一后重比定义体 | 95/95 完全一致。涉及 11 个辅助证明名、4 种命题，例如 `2 + 1 ≠ 0` |
| 用 Lean 内核检查原定义体的可定义等价 | 95/95 在两个临时环境中均成立 |

这里的归一只针对**类型相同的已证明定理**。9 个只在一侧存在的名字使用原有证明体，经另一侧内核重新类型检查后才加入临时环境。未增加公理，也未改写被比较的函数。另用同一检查接口确认两个环境都拒绝把自然数 0 与 1 视作相等。上表的范围是三个目标所引用的项目声明，Mathlib 和工具链版本固定。[检查程序](AuditInterfaces.lean) · [逐声明结果、辅助证明类型和公理](closure.json) · [首次严格比对日志](logs/strict-main.log.gz) · [独立副本日志](logs/strict-replica.log.gz)

## 论文与公开 Lean 定理的边界

**定理 1.1。** 论文第 3 页陈述了存在一条在有限时间前光滑的解。在全空间，它给出 $\|\nabla u(t)\|_{L^2}$ 的双边爆破速率 $(1-t)^{-1/4}$ 及相对于指定剖面的误差界。环面上有对应的 $H^1$ 估计和局部逼近界。Lean 的两条顶层结论分别排除了全空间能量一致有界的全局光滑解、环面速度保持周期的全局光滑解。每条结论都为每个正黏度给出相应的光滑无散初值。两条受检声明均不输出爆破速率或逼近指定剖面的误差。库内确有中间的有限时间构造，例如环面 `TorusBlowup` 给出有限时刻前范数无界的温和解。论文 §1.5 与上游说明也交代了两种表述的差别。[论文第 2–3、9–10 页](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/paper/finite-time-blow-up-navier-stokes.pdf) · [顶层定义](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Challenge.lean#L35) · [环面中间定理的定义](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/Torus/StatementsSmooth.lean#L44) · [作者对照说明](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/README.md#L35)

剖面的输入也有差别。论文 (1.3) 列出速度及一阶导数衰减，Lean 还明确要求二阶导数及压力梯度的衰减。论文 Remark 1.2 讨论二阶导数，上游说明另给出压力梯度的分析理由。本次复现没有把这些外部论证算作顶层声明之间已经通过的等价转换。[论文第 2–3 页](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/paper/finite-time-blow-up-navier-stokes.pdf) · [剖面定义](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Challenge.lean#L51) · [作者说明](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/README.md#L25)

**定理 7.1 与推论 7.2。** 论文第 35 页给出与同一个参数相联系的平滑剖面、恒等空间变换、与候选场的距离和约束 (7.38)，以及所有指定对称性 (7.39)。公开的 `extended_certificate_orbit` 输出一个弱剖面的存在性。沿证明向下追踪，构造确实取了证书的周期 `d.period q`，速度取候选场加扰动，时间重标后选用恒等变换。库中还有弱剖面推出平滑剖面的定理。本次 Lean 测试把它们接成了“给定扩展证书，存在平滑剖面且两种定性爆破结论成立”。该合取的类型没有为给定证书返回 (7.38) 的逐项误差与 (7.39) 的全部对称性。[论文第 35、44 页](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/paper/finite-time-blow-up-navier-stokes.pdf) · [受检声明](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/ExtendedCertificateChallenge.lean#L265) · [实际选取的场及周期](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/Cert/ExtendedSigmaProfileOfHeld.lean#L232) · [恒等变换](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/Cert/Rescale.lean#L85) · [平滑化桥梁](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/CertTorus/Main.lean#L8) · [附加 Lean 测试](SemanticProbes.lean)

**一般证书的输入条件。** 论文 §7.2 要求近似剖面及其时间、空间一阶导数在参数集合上连续。Lean 要求对参数、时间、空间联合 $C^1$，并对弱空间二阶导数加衰减界。仅有参数连续性不能推出对参数可微，例如 $a\mapsto |a|$ 在零点。论文 (7.17) 允许两两正交、范数有上界的行场。单个零行可满足这条局部条件，Lean 的原始行编码要求每个现有行自配对为 1，零行不能原样使用。这两个小例子只区分相应条款。论文附录 B 的具体构造另行给出联合 $C^1$ 的场，且 (B.11) 将归一化行与正权重分开，解释了具体数据为何可能满足更强条件。它们是否实际满足，仍取决于数据。[论文第 31–32、52–53 页](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/paper/finite-time-blow-up-navier-stokes.pdf) · [联合正则性](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/ExtendedCertificateChallenge.lean#L126) · [行场与权重](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/ExtendedCertificateChallenge.lean#L162) · [实测公理输出](logs/probes.log)

**构造中确实改动的一个量。** 从单元条件得到扩展证书的中间结论是 `∃ b, IsExtendedCertificate {D.cert with decay := b}`。代码重选了衰减上界。在这次记录更新中，剖面、周期、对称集、压力梯度和作用场均可由 Lean 以 `rfl` 确认保持相同。存在性结论只需要某个合适上界。若要核准外部数据文件里填的特定衰减常数，仍需为那个数单独提供证据。[实际构造](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/CellReduction/CellLayerBreakdownCompose.lean#L171) · [字段检查](SemanticProbes.lean)

## 循环前提、方程和数值边界

- 从附录 B 的 `CellSystemCondition` 出发，检查其定义、构造子及类型所引用的 2,048 个项目声明，没有到达空间爆破、环面爆破、强剖面存在或弱剖面存在这四个具名结论。参数中心 0 一定在有效扩展证书的参数域内，严格非平凡条件还排除了该点的近似剖面恒为零。这里检查的是可识别的循环引用及两种具体的空洞情形，不能由此推出十五项条件联合可满足。残差界和非平凡性在单元层输入中仍是明确前提。[十五项条件](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerChallenge.lean#L7027) · [残差界](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerChallenge.lean#L6935) · [非平凡性](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerChallenge.lean#L6966) · [依赖结果](closure.json)
- 从经典单元层的空间与环面合取定理，实际追到 30,959 个项目声明，包括 25,485 个定理体。证明链经过扩展证书、弱剖面与环面平滑化，没有到达所检查的分数阶爆破目标。以另一个 $\alpha=501/500$ 的定理作正对照，程序确实追到了分数阶空间、环面结论。对实际速度方程还独立核对了零外力、三维普通拉普拉斯项和压力符号。环面公开结论只要求速度周期，库中用移动坐标变换处理压力的非周期部分。[物理方程](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Challenge.lean#L26) · [分数阶目标](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Solution.lean#L319) · [环面压力处理](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/Breakdown/Torus/Reduction.lean#L23) · [实际依赖路径](proof-routes.json)
- 用有理数区间重新推算了论文第 70 页的标量界，包括 $M<0.01695$ 和 $\varepsilon<0.0075$。这些界与文中列出的不等式相符。论文同页还说明并未逐条写出全部单元条件，例如压力规范、局部到全局未知量的装配。当前仓库没有具体数值证书及其区间验算程序，仍无法从论文的若干汇总数字确认那个实例满足全部 Lean 前提。[论文第 4、56、70 页](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/paper/finite-time-blow-up-navier-stokes.pdf) · [标量核算](printed-bounds.json) · [具体证书的已有核查](../certificate-check.json)

## 复现

使用上游固定版本和已经完成默认构建的 `lean/` 目录，将下方 `$AUDIT` 指向本报告所在目录。官方严格检查复用原验核中的非特权 Comparator、Landrun 和 lean4export 环境。补充配置预期复现上文的退出码 1，以下 Lean 语义测试均预期退出 0。[补充配置](comparator-standalone-cell-layer.json) · [机器结果](results.json) · [审计文件 SHA-256](SHA256SUMS)

```sh
lake env lean "$AUDIT/SemanticProbes.lean"
lake env lean "$AUDIT/TransposeLong.lean"
lake env lean "$AUDIT/TransposeLibrary.lean"
lake env lean --run "$AUDIT/AuditInterfaces.lean"
lake env lean --run "$AUDIT/ProofRoutes.lean"
python3 "$AUDIT/check_printed_bounds.py"
```

一次以 root 启动的附加测试触发了 Lake 对 Mathlib 缓存的重新获取。已从先前验过的副本恢复锁定版本并通过 Git 对象检查。第二次严格比对和成功的语义测试均在独立、非特权的环境执行。结束时三个工作目录的上游受控文件、九个依赖提交及工作树均已复查，`Solution.olean` 和 Mathlib 根编译对象的 SHA-256 在三处分别一致。[运行与恢复记录](results.json)
