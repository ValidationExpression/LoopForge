# Fork 工作流（ValidationExpression/LoopForge）

## 远程含义

| 名称 | 地址 | 用途 |
|------|------|------|
| `upstream` | Tencent/LoopForge | 拉官方更新 |
| `origin` | ValidationExpression/LoopForge | 推送自己的分支 |

`main` 跟踪 `upstream/main`，自用补丁在 **`deploy/203-cursor`**。

## 日常：跟官方 bug 修复

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main    # 或 git pull --ff-only upstream main
git push origin main                 # 可选：同步 fork 上的 main
```

## 把官方合进自用分支

```bash
git checkout deploy/203-cursor
git merge main
# 有冲突则解决后 git add … && git commit
git push -u origin deploy/203-cursor
```

## 203 部署

- Compose 叠加见 `README-203-stable.md`（代理、`cursor-agent` 数据卷）。
- `proxy/config.yaml`、`.env` 里的密钥**不要提交**。