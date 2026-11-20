# Fork 工作流：官方更新 + 自用补丁

自用仓库：[ValidationExpression/LoopForge](https://github.com/ValidationExpression/LoopForge)（fork 自 [Tencent/LoopForge](https://github.com/Tencent/LoopForge)）。

目标：**`main` 跟官方修 bug**，**`deploy/203-cursor`** 保留 203 / Cursor / 代理等自用改动。

---

## 三个地方分别是什么

| 地方 | 作用 | 比喻 |
|------|------|------|
| **upstream**（Tencent） | 只读官方源码 | 出版社原版 |
| **origin**（你的 fork） | 保存你愿意长期留着的版本 | 家里笔记本 |
| **本机工作目录** | 改代码、部署 203 | 厨房 |

本机 Git 远程约定（已配置）：

| 远程名 | 地址 | 用途 |
|--------|------|------|
| `upstream` | `https://github.com/Tencent/LoopForge.git` | `fetch` 官方，一般不要 `push` |
| `origin` | `https://github.com/ValidationExpression/LoopForge.git` | `push` 自己的 `main` / `deploy/203-cursor` |

分支约定：

| 分支 | 用途 |
|------|------|
| `main` | 跟踪 `upstream/main`，尽量只合并官方，不在此堆自用大改 |
| `deploy/203-cursor` | Dockerfile 内置 Cursor、compose 叠加、ops 脚本等自用补丁 |

**不要提交**：`proxy/config.yaml` 订阅、`.env` 里的密钥、机场账号等（见 [README-203-stable.md](./README-203-stable.md)）。

---

## 首次在本机配置远程（新克隆时做一次）

若 `git remote -v` 里只有 Tencent、没有自己的 fork：

```bash
cd LoopForge
git remote rename origin upstream    # 若当前 origin 指向 Tencent
git remote add origin https://github.com/ValidationExpression/LoopForge.git
git fetch upstream
git branch --set-upstream-to=upstream/main main
```

---

## 第一次把官方最新 + 自用分支弄齐（已完成可跳过）

官方已经比本机新时：

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git checkout -b deploy/203-cursor    # 若分支尚不存在
# 在 deploy/203-cursor 上提交自用改动后：
git push -u origin main
git push -u origin deploy/203-cursor
```

合并自用改动与新版 `main` 时若冲突，常见文件：`Dockerfile`、`internal/runtime/cli_ondemand.go`、`conversation_sandbox.go`。原则：**安装脚本与官方 #1077 对齐，保留镜像内置 Cursor 与 `cli_bundled.go` 逻辑**。

---

## 网络正常时：推到 GitHub（fork）

本机有提交但 fork 上还没有时执行：

```powershell
cd d:\AI_Code_Project\LoopForge   # 或你的仓库路径
git push -u origin main
git push -u origin deploy/203-cursor
```

- `main`：与腾讯 `main` 对齐，便于在 GitHub 上点 **Sync fork** 时对照。
- `deploy/203-cursor`：**203 与自用 PC 日常应 checkout 的分支**。

GitHub 网页上也可：**Sync fork**（从 Tencent 同步到 fork 的 `main`），本机再 `git fetch origin` + `git merge --ff-only origin main` 亦可（与 `upstream` 等价，前提是 fork 的 main 已同步）。

---

## 日常四步：既要官方修 bug，又要保留自用功能

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main
# 可选：git push origin main

git checkout deploy/203-cursor
git merge main
# 若有冲突：改文件 → git add … → git commit
git push origin deploy/203-cursor
```

简洁记忆：**官方 → main → 合进 deploy → push 到 origin**。

---

## 203 / 其他机器拉哪条分支

长期部署（含 Cursor 镜像与 compose 叠加）：

```bash
git clone -b deploy/203-cursor https://github.com/ValidationExpression/LoopForge.git
```

服务器上更新：

```bash
cd LoopForge
git fetch origin
git checkout deploy/203-cursor
git pull --ff-only origin deploy/203-cursor
# 再按 README-203-stable.md 重启 compose / 跑 install-cursor-bundled.sh
```

---

## 可选：GitHub 默认分支

若希望打开 fork 默认就是自用版：仓库 **Settings → Default branch** 改为 `deploy/203-cursor`。  
仍建议保持 `main` 与腾讯一致，方便 Sync fork。

---

## 冲突是什么、怎么少踩坑

**冲突** = 官方和你都改了同一段代码，合并时 Git 要你选留哪边。

减少冲突的做法：

- 自用功能集中在 `deploy/203-cursor`，`main` 不直接改。
- 部署差异尽量用 **compose 叠加** 和 **`.env`**，少改 `internal/`。
- 必须改 runtime 时，改动集中在 `cli_bundled.go`、Dockerfile、少量 toolchain。

---

## 与 203 运维文档的关系

- 代理、mihomo、cursor 数据卷、compose 变量：见 **[README-203-stable.md](./README-203-stable.md)**。
- 代码版本与 fork 合并节奏：本文档。