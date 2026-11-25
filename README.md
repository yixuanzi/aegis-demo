# aegis-demo

AegisAIDR 客户演示的环境、脚本和测试数据。故事线：**看得见 → 抓得住 → 说得清 → 拦得下 → 管得住**。

> 全部凭据都是公开示例值。外链「下载」统一指向本仓库的 `raw.githubusercontent.com`，托管的脚本只打印一行，没有任何副作用；「上传/外发」目标是保留域名 `.example`，永远解析不出去。

## 快速开始

```bash
git clone https://github.com/yixuanzi/aegis-demo.git ~/aegis-demo
cd ~/aegis-demo
scripts/prepare.sh        # 检查依赖 → 生成 env → 生成演示项目 → 备份 settings.json → 两套自检
```

前置条件：`git`、`jq`、`node`，以及已安装的 `aegis-sensor`（演示终端通过控制台「探针安装」页安装）。

## 目录

| 路径 | 内容 |
| --- | --- |
| `docs/demo-guide.zh-CN.md` | 完整演示脚本：准备清单、6 幕时间线、15 分钟精简版、常见问答 |
| `docs/attack-scenarios.zh-CN.md` | 攻击场景清单 A1–A6、B1–B13，及 A6（Agent 篡改监控 Hook）详解 |
| `env/demo.env.example` | 演示环境变量（项目路径、GitHub 仓库、探针地址、规则目录等） |
| `env/shop-api.env.template` | 演示项目 `.env` 的内容（假凭据，A2/B5 的诱饵） |
| `template/shop-api/` | 演示项目模板：投毒 `README.md`、`CONTRIBUTING.md` 和示例业务数据 |
| `scripts/prepare.sh` | 演示前一键准备 |
| `scripts/setup-demo-project.sh` | 生成演示项目到 `~/aegis-demo/shop-api` |
| `scripts/replay.sh` | `check` 彩排自检；`send` 现场兜底回放 |
| `scripts/replay-extended.sh` | 扩展场景 B1–B13 自检 |
| `scripts/backup-claude-settings.sh` | A6 演示前备份、演示后恢复 `~/.claude/settings.json` |
| `scripts/bootstrap.sh`、`scripts/payload.sh` | 托管在 GitHub 的无害「外链下载」脚本 |
| `data/scenarios.json` | 全部场景的机器可读版本（提示词、命令、预期命中规则） |
| `data/prompts.zh-CN.txt` | 现场要输入的全部提示词 |
| `data/rulesets/demo-block.json` | 阻断规则集合 `demo-block` 的勾选清单 |
| `data/policies/` | 第 5 幕策略字段与 Hook 安装参数 |
| `data/hook-payloads/` | 每个场景一份示例 Hook 载荷，可直接喂给 `aegis-sensor hook` |
| `data/mcp/prompts.zh-CN.txt` | 第 6 幕 MCP 问答提示词 |

## 配置

```bash
cp env/demo.env.example env/demo.env   # prepare.sh 会自动生成
```

常改的几项：

| 变量 | 说明 |
| --- | --- |
| `DEMO_PROJECT` | 演示项目目录，默认 `~/aegis-demo/shop-api` |
| `DEMO_REPO` | 托管下载脚本的 GitHub 仓库，默认 `yixuanzi/aegis-demo`；fork 后改成自己的 |
| `AEGIS_SENSOR_BIN` | 探针路径，留空用 `PATH` 里的 |
| `AEGIS_INGEST_URL` | `replay.sh send` 的接收地址，默认 `http://127.0.0.1:15799/v1/records` |
| `AEGIS_RULES_DIR` | 内置规则目录（AegisAIDR 源码仓库的 `rules/`），`replay.sh check` 的阻断检查需要 |

## 验证

`scripts/prepare.sh` 通过时应看到：核心场景 9 条 finding、`enforce deny / deny / deny / allow`，扩展场景 13 条全部 `ok`。验证环境：aegis-sensor 0.2.36（schema 0.9.0）。

这些自检只证明规则会命中、阻断规则会拒绝，不代表真实模型一定会照着提示词去做。现场前仍需在演示机上用真实 Agent 彩排一遍。
