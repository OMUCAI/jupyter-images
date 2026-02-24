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
    jupyterlab-spellchecker \
    jupyterlab-git \
    jupyter-server-proxy \
    jupyter-vscode-proxy \
    jupyter-ai \
    jupyterlab-lsp \
    python-lsp-server && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install VS Code extensions (python, jupyter)
RUN code-server --install-extension ms-python.python ms-toolsai.jupyter

# Install custom wheel packages (auto-install all .whl files in additional_package/)
COPY --chown=${NB_UID}:${NB_GID} additional_package/*.whl /tmp/wheels/
RUN pip install --quiet --no-cache-dir /tmp/wheels/*.whl && \
    rm -rf /tmp/wheels && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install additional pip packages from requirements.txt
COPY --chown=${NB_UID}:${NB_GID} datascience/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

WORKDIR "${HOME}"
