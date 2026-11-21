# 无外力 NS 数值证书与验算程序的公开检索

检索截止北京时间 2026 年 11 月 21 日 22:55。对象是 Alpöge 与 Buckmaster 的无外力 Navier–Stokes 爆破论文，以及作者所称用于验证附录 B 的 128 位 Arb/FLINT 区间算术程序。

**在本次检查的公开渠道中，没有找到可取得的原始证书，也没有找到作者的配套验算程序。** 原实例没有启动数值复算。固定提交的 `CellSystemCondition` 有 15 个顶层字段，本次独立数值确认 0 项，15 项均保留为“未评估”。此前的 Lean 证明重放仍按其原有的条件命题解读。[十五项条件](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/lean/CellLayerChallenge.lean#L7027-L7046) · [此前的形式验核](../../verification.json)

## 哈希核对到哪一步

论文第 1 页和第 4 页给出的证书摘要均为 `3f7a335b84b6c7631742cacc5343dfcd11cf72f5221ff79b2b9268790b4b22c5`。重新读取固定提交的 79 页 PDF，文件自身的 SHA-256 为 `4a01929b2f8a595637bbbe1dfef9724e5de768d31283d62415ce045e2ed69901`。PDF 没有内嵌文件，97 个外部 URI 注释位于第 75–79 页，未发现指向目标证书或验算源码的直链。论文文本没有注明这个 64 位十六进制摘要的算法，本轮明确使用 SHA-256 查找和比对。[论文原件](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/paper/finite-time-blow-up-navier-stokes.pdf) · [原提交逐文件比对记录](../../certificate-check.json)

GitHub 全文代码搜索返回两份含有这串字符的第三方文本。对原始文件字节计算 SHA-256，两者均与目标不同。完整值和固定版本链接均在机器记录中。本仓库此前公开的证书检查 JSON 本身也含有摘要，却没有出现在此次全文搜索返回中，可直接看到索引覆盖的边界。[检索证据](evidence.json) · [已知公开文本](../../certificate-check.json)

| 全文搜索命中 | SHA-256 前 16 位 | 文件内容 |
| --- | --- | --- |
| [evidence-c.md](https://github.com/Develata/AI-Barking/blob/f84795d2f999f5214f94de698e7d3142f56f2cff/docs/2611/1120/sources/evidence-c.md) | `36ecbe4b4f621bfa` | 引用论文的第三方笔记 |
| [c-ns-pdf.txt](https://github.com/Develata/AI-Barking/blob/f84795d2f999f5214f94de698e7d3142f56f2cff/docs/2611/1120/sources/c-ns-pdf.txt) | `ab2af7b9549f6aa6` | 论文的纯文本转录 |

另用完整摘要直接查询 Software Heritage 的内容接口，两次均返回 HTTP 404。同一接口对已知对照文件返回 HTTP 200 及正确摘要。这个结果只说明该档案此次没有返回这个内容对象。[按目标摘要查询](https://archive.softwareheritage.org/api/1/content/sha256:3f7a335b84b6c7631742cacc5343dfcd11cf72f5221ff79b2b9268790b4b22c5/)

## 作者发布渠道和其他存档

| 核查渠道 | 实际返回 |
| --- | --- |
| 作者公告与网页 | Buckmaster 的 Mastodon 公告把无外力 NS 链接指向原 GitHub，另一条链接是 Euler 论文。公告无附件。查阅了他的 NYU 主页和出版物列表，以及 Alpöge 的主页。[作者公告](https://mastodon.social/@tristanbuckmaster/117649035783718539) · [NYU 出版物](https://cims.nyu.edu/~tristanb/publications/) · [Alpöge 主页](https://alpo.ge/) |
| GitHub 发布渠道 | 上游主分支仍为 `ad53419`，无公开 Release、标签或列出的 Actions 构件。两个作者账号共列出 29 个公开仓库、0 个公开 Gist。24 个直接公开分叉的默认分支均指向同一提交，唯一额外分支只改 README。上游 issue #3 正在询问证书发布日期，查询时有 0 条评论。[发布页](https://github.com/tristanbuckmaster/navier-stokes/releases) · [分叉](https://github.com/tristanbuckmaster/navier-stokes/forks) · [PR 文件](https://github.com/tristanbuckmaster/navier-stokes/pull/4/files) · [issue #3](https://github.com/tristanbuckmaster/navier-stokes/issues/3) |
| 数据与软件登记 | 对 Zenodo、DataCite、Figshare 分别使用作者、题名或摘要检索，并检查了 Harvard Dataverse、Dryad、OSF、Hugging Face 和 GitLab。DataCite 双作者查询仅返回另一篇关于受迫 IPM 的预印本。Zenodo 的 Buckmaster 姓氏结果共 36 条，已检查两页。检索式、计数和可重访的 API 地址见[机器记录](evidence.json)。 |
| 预印本与复现入口 | aiXiv 的该论文条目指向原 GitHub，其 “Reproduce” 页面用于提交复现报告。arXiv 联合查询和 Hexagon 作者、题名查询未给出这份证书。Hexagon 上相近的条目研究 Leray–Hopf 解的非唯一性。[aiXiv 复现入口](https://aixiv.online/reproduce/2611.02204) · [Hexagon 相近条目](https://hexagonmath.org/2611.00143v1) |
| 验算源码 | 另外检索了 `CellSystemCondition` 与 `FLINT`、`Buckmaster` 与 `arb.h`、原仓库名与 `FLINT` 等组合，返回结果中未定位到这项区间验算程序。作者在上游说明中把它列为单独的计算。[作者对数值计算的说明](https://github.com/tristanbuckmaster/navier-stokes/blob/ad53419de079eb8f95f60313473374624a348546/README.md) · [源码检索式和命中路径](evidence.json) |

## 数值复算状态

要把本次状态改为“通过”，还需取得作者标明摘要对象和算法的原始文件，对**同一份字节**核对摘要，再用配套验算程序在原实例产生可复核的区间结果。验算输出还需能对应固定 Lean 提交中的全部 15 组条件，包括跨单元的恒等式、界、残差和非平凡性。机器记录列出了这 15 个字段及本轮状态。[逐项状态](evidence.json) · [条件的语义审计](../../semantic-audit/README.md)

这是一份有截止时间的公开检索记录。未被索引、未公开分享或在此后发布的材料，仍可能改变结果。
