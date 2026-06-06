# Isaac Sim JupyterLab Image

JupyterHub から起動できる NVIDIA Isaac Sim + JupyterLab の統合イメージ。

## ファイル構成

```
isaac-sim/
├── Dockerfile                      # メインのDockerfile
├── entrypoint.sh                   # 起動スクリプト（Isaac Sim → JupyterLab の順に起動）
├── jupyter_server_proxy_config.py  # Isaac Sim WebRTC をJupyterLab内にプロキシする設定
└── README.md                       # このファイル
```

## ビルド手順

### 前提条件

- NVIDIA GPU ドライバーがインストール済みのホスト
- `nvcr.io` (NVIDIA NGC) へのアクセス権（NGC API Key が必要）

### NGC ログイン

```bash
docker login nvcr.io
# Username: $oauthtoken
# Password: <NGC_API_KEY>
```

### ビルド

```bash
cd isaac-sim/

# Isaac Sim バージョンを指定してビルド
docker build \
  --build-arg ISAAC_SIM_VERSION=6.0.0 \
  -t ghcr.io/omucai/jupyter-images/isaac-sim:latest \
  -t ghcr.io/omucai/jupyter-images/isaac-sim:6.0.0 \
  .
```

> **注意:** Isaac Sim イメージは非常に大きい（50GB+）。ビルドには十分な時間とディスク容量が必要。

### プッシュ

```bash
docker push ghcr.io/omucai/jupyter-images/isaac-sim:latest
docker push ghcr.io/omucai/jupyter-images/isaac-sim:6.0.0
```

## Isaac Sim バージョン確認

最新の安定版は NGC カタログで確認:
https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim/tags

## 環境変数（JupyterHub から注入される値）

| 変数名 | 説明 |
|---|---|
| `ACCEPT_EULA` | Isaac Sim EULA 同意（`Y` 固定） |
| `PRIVACY_CONSENT` | Isaac Sim プライバシー同意（`Y` 固定） |
| `TURN_SERVER_URI` | TURN サーバーの URI |
| `TURN_AUTH_SECRET` | TURN 認証シークレット |
| `TURN_REALM` | TURN レルム |

## ポート

| ポート | 用途 |
|---|---|
| `8888` | JupyterLab |
| `8211` | Isaac Sim WebRTC ストリーミング（Pod内部のみ、proxy経由でアクセス） |
