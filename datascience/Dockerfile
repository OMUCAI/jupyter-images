# syntax=docker/dockerfile:1
# hadolint global ignore=DL3006
ARG BASE_IMAGE=quay.io/jupyter/datascience-notebook:x86_64-python-3.13
FROM ${BASE_IMAGE}

LABEL maintainer="Masahiro Konishi <konikoni428@gmail.com>"

USER root
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common utilities
    curl \
    graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install latest code-server
RUN CODE_VERSION=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | grep '"tag_name":' | sed 's/.*"v\([0-9.]*\)".*/\1/') \
    && curl -fOL "https://github.com/coder/code-server/releases/download/v${CODE_VERSION}/code-server_${CODE_VERSION}_amd64.deb" \
    && dpkg -i "code-server_${CODE_VERSION}_amd64.deb" \
    && rm -f "code-server_${CODE_VERSION}_amd64.deb"

USER ${NB_UID}

# Install JupyterLab extensions via mamba
RUN mamba install --yes -c conda-forge \
    jupyterlab-git \
    jupyter-server-proxy \
    jupyter-vscode-proxy \
    jupyterlab-lsp \
    python-lsp-server && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install jupyter-ai v3 (beta) via pip (not yet available on conda-forge)
RUN pip install --no-cache-dir --pre "jupyter-ai>=3.0.0b9" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Configure JupyterLab LSP defaults.
# Suppress pycodestyle warnings that are incompatible with Jupyter notebooks:
#   E265 - block comment should start with '# ' (triggers on commented-out magics like #%matplotlib)
#   E302 - expected 2 blank lines (cells contain short snippets; 2 blank lines looks sparse)
#   E303 - too many blank lines (notebooks use blank lines between cells/sections)
#   E305 - expected 2 blank lines after function/class definition (same reason as E302)
#   E402 - module level import not at top of file (imports often follow markdown cells)
# NOTE: COPY always runs as root, so we switch to root here to create the file
USER root
RUN mkdir -p "${CONDA_DIR}/share/jupyter/lab/settings"
COPY <<EOF ${CONDA_DIR}/share/jupyter/lab/settings/overrides.json
{
  "@jupyter-lsp/jupyterlab-lsp:plugin": {
    "language_servers": {
      "pylsp": {
        "serverSettings": {
          "pylsp": {
            "plugins": {
              "pycodestyle": {
                "ignore": ["E265", "E302", "E303", "E305", "E402"],
                "maxLineLength": 120
              }
            }
          }
        }
      }
    }
  }
}
EOF
RUN fix-permissions "${CONDA_DIR}/share/jupyter/lab/settings"

USER ${NB_UID}
# Install VS Code extensions into a cache directory outside the home directory.
# (JupyterHub mounts a PVC over /home/jovyan at startup, which would erase any
# extensions installed directly into ~/.local/share/code-server/extensions.)
# A before-notebook.d hook copies them into the user's home on every container start.
ENV VSCODE_EXT_CACHE=/opt/conda/code-server-extensions
RUN mkdir -p "${VSCODE_EXT_CACHE}" && \
    code-server --extensions-dir="${VSCODE_EXT_CACHE}" --install-extension ms-python.python && \
    code-server --extensions-dir="${VSCODE_EXT_CACHE}" --install-extension ms-toolsai.jupyter && \
    fix-permissions "${VSCODE_EXT_CACHE}"

# Register a startup hook that copies cached extensions into the user's home directory.
# cp -rn skips files that already exist, preserving any user-installed extensions.
COPY --chmod=755 <<EOF /usr/local/bin/before-notebook.d/10-init-vscode-extensions.sh
#!/bin/bash
mkdir -p \${HOME}/.local/share/code-server/extensions
cp -rn ${VSCODE_EXT_CACHE}/. \${HOME}/.local/share/code-server/extensions/
EOF

# Install custom wheel packages (auto-install all .whl files in additional_package/)
RUN --mount=type=bind,source=additional_package,target=/tmp/wheels \
    pip install --quiet --no-cache-dir /tmp/wheels/*.whl && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install additional pip packages from requirements.txt
RUN --mount=type=bind,source=datascience/requirements.txt,target=/tmp/requirements.txt \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

WORKDIR "${HOME}"
