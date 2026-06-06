# =============================================================================
# Isaac Sim + JupyterLab Image
# Base: NVIDIA Isaac Sim (nvcr.io/nvidia/isaac-sim)
#
# Purpose:
#   JupyterHub から起動し、ブラウザ上で Isaac Sim の WebRTC 映像を表示する。
#   jupyter-server-proxy 経由で Isaac Sim の WebRTC ストリームに接続する。
#
# Build:
#   docker build -t ghcr.io/omucai/jupyter-images/isaac-sim:latest .
#
# Push:
#   docker push ghcr.io/omucai/jupyter-images/isaac-sim:latest
#
# Requirements:
#   - NVIDIA GPU が利用可能なホストでビルド・実行すること
#   - NGC API Key が必要 (nvcr.io へのアクセス)
# =============================================================================

ARG ISAAC_SIM_VERSION=6.0.0
FROM nvcr.io/nvidia/isaac-sim:${ISAAC_SIM_VERSION}

LABEL org.opencontainers.image.title="Isaac Sim + JupyterLab"
LABEL org.opencontainers.image.description="NVIDIA Isaac Sim with JupyterLab and WebRTC streaming support"
LABEL org.opencontainers.image.source="https://github.com/omucai/helm-values"

# ビルド時は root に切り替える
USER root

# ── 環境変数 ──────────────────────────────────────────────────────────────────
# Isaac Sim EULA 自動同意（K8s環境では必須）
ENV ACCEPT_EULA=Y \
    PRIVACY_CONSENT=Y

# タイムゾーン・apt の設定
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo

# JupyterLab / ユーザー設定
# ベースイメージの isaac-sim ユーザー (UID=1234) をそのまま使用する
# /isaac-sim (パーミッション 750, 所有者 isaac-sim) へのアクセスを維持するため
ENV JUPYTER_PORT=8888 \
    JUPYTERHUB_SERVICE_PREFIX="" \
    HOME=/home/isaac-sim \
    NB_USER=isaac-sim \
    NB_UID=1234

# ── システム依存パッケージ ────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-pip \
        python3-dev \
        python3-venv \
        curl \
        wget \
        git \
        sudo \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# ── isaac-sim ユーザーのホームディレクトリとsudo権限設定 ────────────────────────
# ベースイメージでは HOME=/isaac-sim だが、JupyterLab 用に別途ホームを作成する
# /isaac-sim はアプリケーションディレクトリとして残す
RUN mkdir -p /home/isaac-sim && \
    chown isaac-sim:isaac-sim /home/isaac-sim && \
    usermod -d /home/isaac-sim isaac-sim && \
    echo "isaac-sim ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── /etc/jupyter ディレクトリを先に作成 ──────────────────────────────────────
RUN mkdir -p /etc/jupyter

# ── jupyter-server-proxy: Isaac Sim WebRTC エントリポイント設定 ──────────────
COPY isaac-sim/jupyter_server_proxy_config.py /etc/jupyter/jupyter_server_proxy_config.py

# ── Python パッケージ（pip）─────────────────────────────────────────────────
RUN pip3 install --no-cache-dir --break-system-packages \
        "jupyterlab==4.*" \
        "notebook==7.*" \
        "jupyterhub" \
        "jupyter-server-proxy==4.*" \
        "websockify" \
        "ipywidgets" \
        "ipython"

# ── JupyterLab 設定 ──────────────────────────────────────────────────────────
RUN { \
        echo "c.ServerApp.ip = '0.0.0.0'"; \
        echo "c.ServerApp.port = ${JUPYTER_PORT}"; \
        echo "c.ServerApp.open_browser = False"; \
        echo "c.ServerApp.allow_root = True"; \
        echo "c.ServerApp.tornado_settings = {'headers': {'Content-Security-Policy': \"frame-ancestors 'self' *\"}}"; \
        echo "c.ServerApp.extra_static_paths = []"; \
    } >> /etc/jupyter/jupyter_lab_config.py

# ── 起動スクリプト ────────────────────────────────────────────────────────────
COPY isaac-sim/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ── ファイル所有権調整 ─────────────────────────────────────────────────────────
RUN chown -R isaac-sim:isaac-sim /home/isaac-sim /etc/jupyter

WORKDIR /home/isaac-sim
USER isaac-sim

EXPOSE ${JUPYTER_PORT}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
