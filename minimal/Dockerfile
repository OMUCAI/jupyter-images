
FROM jupyter/minimal-notebook:2022-11-14

LABEL maintainer="Masahiro Konishi <konikoni428@gmail.com>"

USER root
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common utilities
    curl \
    graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install code server and extension
ENV CODE_VERSION=4.9.1
RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_arm64.deb \
    && dpkg -i code-server_${CODE_VERSION}_arm64.deb \
    && rm -f code-server_${CODE_VERSION}_arm64.deb 
RUN /opt/conda/bin/conda install -c conda-forge jupyter-server-proxy jupyter-vscode-proxy

USER ${NB_UID}

# install vscode extension(python, jupyter)
RUN code-server --install-extension ms-python.python ms-toolsai.jupyter 

# install pytct
ARG PYTCT_WHL=PyTCT-0.9.4-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
COPY pytct/${PYTCT_WHL} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${PYTCT_WHL} nbgitpuller

USER root
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

WORKDIR "${HOME}"