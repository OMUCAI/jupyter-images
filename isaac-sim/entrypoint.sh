#!/bin/bash
# =============================================================================
# entrypoint.sh - Isaac Sim + JupyterLab 起動スクリプト
#
# 処理順:
#   1. Isaac Sim をバックグラウンドで起動（headless WebRTC ストリーミングモード）
#   2. Isaac Sim の WebRTC シグナリングエンドポイントが立ち上がるまで待機
#   3. JupyterLab を起動
#
# Isaac Sim 6.x:
#   - runheadless.sh: headless WebRTC ストリーミング起動
#   - 環境変数 ISAACSIM_SIGNAL_PORT (デフォルト 49100) でシグナリングポート指定
#   - 環境変数 ISAACSIM_STREAM_PORT (デフォルト 47998) でストリームポート指定
#   - 環境変数 ISAACSIM_HOST で公開 IP 指定
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
ISAAC_SIM_PATH="/isaac-sim"
ISAAC_SIM_BIN="${ISAAC_SIM_PATH}/runheadless.sh"

if [ ! -f "${ISAAC_SIM_BIN}" ]; then
    echo "ERROR: Isaac Sim binary not found at ${ISAAC_SIM_BIN}"
    echo "  Available files in ${ISAAC_SIM_PATH}:"
    ls -la "${ISAAC_SIM_PATH}"/*.sh 2>/dev/null || echo "  (no .sh files found)"
    exit 1
fi

echo "=== Starting Isaac Sim in headless WebRTC mode... ==="

# シグナリングポート（runheadless.sh が ISAACSIM_SIGNAL_PORT 環境変数を参照する）
ISAACSIM_SIGNAL_PORT="${ISAACSIM_SIGNAL_PORT:-49100}"
export ISAACSIM_SIGNAL_PORT

"${ISAAC_SIM_BIN}" \
    ${ISAAC_SIM_EXTRA_ARGS:-} \
    &

ISAAC_SIM_PID=$!
echo "Isaac Sim started with PID: ${ISAAC_SIM_PID}"

# ── Isaac Sim の WebRTC シグナリングエンドポイントが起動するまで待機 ───────────
echo "=== Waiting for Isaac Sim WebRTC signaling endpoint (port ${ISAACSIM_SIGNAL_PORT})... ==="
TIMEOUT=300
ELAPSED=0
INTERVAL=5

while ! curl -sf "http://localhost:${ISAACSIM_SIGNAL_PORT}/" > /dev/null 2>&1; do
    # Isaac Sim プロセスが死んでいないか確認
    if ! kill -0 ${ISAAC_SIM_PID} 2>/dev/null; then
        echo "ERROR: Isaac Sim process (PID ${ISAAC_SIM_PID}) has exited unexpectedly."
        exit 1
    fi
    if [ ${ELAPSED} -ge ${TIMEOUT} ]; then
        echo "ERROR: Timed out waiting for Isaac Sim (${TIMEOUT}s)"
        kill ${ISAAC_SIM_PID} 2>/dev/null || true
        exit 1
    fi
    echo "  Waiting... (${ELAPSED}/${TIMEOUT}s)"
    sleep ${INTERVAL}
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "=== Isaac Sim WebRTC signaling endpoint is ready! ==="

# ── JupyterLab の起動 ─────────────────────────────────────────────────────────
echo "=== Starting JupyterLab... ==="

exec jupyter lab \
    --ip=0.0.0.0 \
    --port=${JUPYTER_PORT:-8888} \
    --no-browser \
    --ServerApp.token="" \
    --ServerApp.password="" \
    --ServerApp.base_url="${JUPYTERHUB_SERVICE_PREFIX:-/}" \
    --ServerApp.hub_api_url="${JUPYTERHUB_API_URL:-}" \
    --ServerApp.shutdown_no_activity_timeout=0
