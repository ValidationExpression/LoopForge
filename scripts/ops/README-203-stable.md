# 203 长期稳定：Cursor 代理 + cursor-agent 持久化

代码来源与合并官方更新的步骤见 **[GIT-WORKFLOW.md](./GIT-WORKFLOW.md)**（`upstream` / `origin`、`main` / `deploy/203-cursor`）。

## 已部署组件

1. **mihomo**（用户级 systemd `loopforge-mihomo.service`）  
   - 配置：`${LOOPFORGE_DATA_DIR}/proxy/config.yaml`（勿提交仓库）  
   - 监听：`0.0.0.0:7890`  
   - 地理库：`proxy/geoip.metadb`、`geosite.dat`

2. **Compose 叠加**（写在 `.env` → `COMPOSE_FILE`）  
   - `compose.public-url.yaml` — 公网 URL  
   - `compose.outbound-proxy.yaml` — `HTTP_PROXY` / `HTTPS_PROXY`  
   - `compose.cursor-bundle.yaml` — 挂载 `${LOOPFORGE_DATA_DIR}/cursor-agent`

3. **cursor-agent 数据目录** — `${LOOPFORGE_DATA_DIR}/cursor-agent`（只读挂进容器）

平台启动后执行一次（重建容器后也会自动跑，可写入 cron 或 install 后手册）：

```bash
bash scripts/ops/install-cursor-bundled.sh
```

## 维护

| 操作 | 说明 |
|------|------|
| `systemctl --user status loopforge-mihomo` | 代理须 active |
| `loginctl enable-linger $USER` | 登出后 mihomo 仍运行 |
| 换订阅 | 更新 `proxy/config.yaml` 后 `systemctl --user restart loopforge-mihomo` |
| 升级 cursor-agent | 在能访问 cursor.com 的机器下载后更新 `cursor-agent/.local` |
| 完全镜像固化 | 有 buildx 后在本机或 203 上 `LOOPFORGE_YES=1 ./start.sh dev` |

`HTTP_PROXY` 应为 `http://172.18.0.1:7890`（Docker 网桥访问宿主机 mihomo）。