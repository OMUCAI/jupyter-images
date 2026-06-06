"""
jupyter_server_proxy_config.py
Isaac Sim の WebRTC ストリーミングエンドポイントを
JupyterLab の /isaac-sim/ パスにリバースプロキシする設定。

Isaac Sim 6.x は起動後に以下のポートで HTTP を待ち受ける:
  - 49100 (TCP): WebRTC シグナリングポート (旧バージョンでは 8211)
  - 47998 (UDP): WebRTC メディアストリームポート

このファイルは /etc/jupyter/ に配置し、JupyterLab 起動時に自動読み込みされる。
"""

# jupyter-server-proxy の設定
# https://jupyter-server-proxy.readthedocs.io/en/latest/server-process.html

c.ServerProxy.servers = {
    "isaac-sim": {
        # Isaac Sim 6.x の WebRTC シグナリングポートへプロキシ
        # (Isaac Sim 4.x では 8211 を使用していたが 6.x では 49100 に変更)
        "port": 49100,
        # JupyterLab のランチャーに表示するアイコン・ラベル
        "launcher_entry": {
            "enabled": True,
            "title": "Isaac Sim (WebRTC)",
            "icon_path": "",
        },
        # Isaac Sim はローカルホストで動作する（同一Pod内）
        "local_only": True,
        # WebSocket のプロキシも有効化（WebRTC シグナリング用）
        "websocket": True,
        # タイムアウト設定（Isaac Sim は起動が遅い）
        "timeout": 300,
        # ヘルスチェックパスは省略（Isaac Sim は / でOK）
        "absolute_url": False,
    }
}
