#!/bin/bash
# =============================================================================
# entrypoint.sh - Isaac Sim + JupyterLab 起動スクリプト
#
# 処理順:
#   1. Isaac Sim をバックグラウンドで起動（WebRTC ストリーミングモード）
#   2. Isaac Sim の WebRTC HTTP エンドポイント(8211)が立ち上がるまで待機
#   3. JupyterLab を起動
# =============================================================================

set -e

echo "=== Isaac Sim + JupyterLab Entrypoint ==="
echo "User: $(whoami)"
echo "Home: ${HOME}"
echo "TURN Server: ${TURN_SERVER_URI:-not set}"

# ── TURN サーバー設定の確認 ──────────────────────────────────────────────────
if [ -z "${TURN_SERVER_URI}" ]; then
    echo "WARNING: TURN_SERVER_URI is not set. WebRTC may not work from external networks."
fi

# ── Isaac Sim を Headless WebRTC ストリーミングモードで起動 ──────────────────
# Isaac Sim の実行ファイルパス（公式イメージ内の標準パス）
ISAAC_SIM_PATH="/isaac-sim"
ISAAC_SIM_BIN="${ISAAC_SIM_PATH}/runapp.sh"

if [ ! -f "${ISAAC_SIM_BIN}" ]; then
    echo "ERROR: Isaac Sim binary not found at ${ISAAC_SIM_BIN}"
    exit 1
fi

echo "=== Starting Isaac Sim in headless WebRTC mode... ==="

# Isaac Sim 起動オプション:
#   --headless:       GUIなし
#   --allow-root:     rootユーザーでの実行を許可
#   --/app/streaming/enabled=true: WebRTCストリーミングを有効化
#   --/app/window/drawMouse=true:  マウスカーソルを映像に含める
#   --/ngx/enabled=false:          DLSS無効（WebRTC環境では不要）
#   WEBRTC_TURN_SERVER_*: TURNサーバー設定を環境変数で渡す
"${ISAAC_SIM_BIN}" \
    --headless \
    --allow-root \
    --/app/streaming/enabled=true \
    --/app/streaming/webrtc/enabled=true \
    --/app/window/drawMouse=true \
    --/ngx/enabled=false \
    --/persistent/app/streaming/signalingServerPort=8211 \
    ${ISAAC_SIM_EXTRA_ARGS:-""} \
    &

ISAAC_SIM_PID=$!
echo "Isaac Sim started with PID: ${ISAAC_SIM_PID}"

# ── Isaac Sim の WebRTC エンドポイントが起動するまで待機 ──────────────────────
echo "=== Waiting for Isaac Sim WebRTC endpoint (port 8211)... ==="
TIMEOUT=300
ELAPSED=0
INTERVAL=5

while ! curl -sf "http://localhost:8211/" > /dev/null 2>&1; do
    if [ ${ELAPSED} -ge ${TIMEOUT} ]; then
        echo "ERROR: Timed out waiting for Isaac Sim (${TIMEOUT}s)"
        kill ${ISAAC_SIM_PID} 2>/dev/null || true
        exit 1
    fi
    echo "  Waiting... (${ELAPSED}/${TIMEOUT}s)"
    sleep ${INTERVAL}
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "=== Isaac Sim WebRTC endpoint is ready! ==="

# ── JupyterLab の起動 ─────────────────────────────────────────────────────────
echo "=== Starting JupyterLab... ==="

exec jupyter lab \
    --ip=0.0.0.0 \
    --port=${JUPYTER_PORT:-8888} \
    --no-browser \
    --allow-root \
    --ServerApp.token="" \
    --ServerApp.password="" \
    --ServerApp.base_url="${JUPYTERHUB_SERVICE_PREFIX:-/}" \
    --ServerApp.hub_api_url="${JUPYTERHUB_API_URL:-}" \
    --ServerApp.shutdown_no_activity_timeout=0
