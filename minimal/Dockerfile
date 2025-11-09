FROM quay.io/jupyter/minimal-notebook:x86_64-python-3.13

LABEL maintainer="Masahiro Konishi <konikoni428@gmail.com>"

USER root
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common utilities
    curl \
    graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install latest code server and extension
RUN CODE_VERSION=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | grep '"tag_name":' | sed 's/.*"v\([0-9.]*\)".*/\1/') \
    && curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_VERSION}_amd64.deb \
    && rm -f code-server_${CODE_VERSION}_amd64.deb
RUN /opt/conda/bin/conda install -c conda-forge jupyterlab-spellchecker jupyterlab-git jupyter-server-proxy jupyter-vscode-proxy

USER ${NB_UID}

# install vscode extension(python, jupyter)
RUN code-server --install-extension ms-python.python ms-toolsai.jupyter 

# install scglib, experiment
ARG SCG_ROBOT_LIB=SCGRobotLib-1.0.2-py3-none-any.whl
ARG EXPERIMENT=experiment-1.0-py3-none-any.whl
COPY additional_package/*.whl /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${SCG_ROBOT_LIB} /tmp/${EXPERIMENT}
# install additional 
COPY minimal/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

USER root
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

WORKDIR "${HOME}"
