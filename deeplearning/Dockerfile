FROM cschranz/gpu-jupyter:v1.6_cuda-12.0_ubuntu-22.04_python-only

LABEL maintainer="Masahiro Konishi <konikoni428@gmail.com>"

# Graphviz is already installed

USER root

# install latest code server and extension
RUN CODE_VERSION=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | grep '"tag_name":' | sed 's/.*"v\([0-9.]*\)".*/\1/') \
    && curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_VERSION}_amd64.deb \
    && rm -f code-server_${CODE_VERSION}_amd64.deb
RUN /opt/conda/bin/conda install -c conda-forge jupyter-server-proxy jupyter-vscode-proxy

USER ${NB_UID}

# install vscode extension(python, jupyter)
RUN code-server --install-extension ms-python.python ms-toolsai.jupyter 

# install pytct, scglib, experiment
# Set latest version by github action
ARG PYTCT_WHL
ARG SCG_ROBOT_LIB=SCGRobotLib-1.0.2-py3-none-any.whl
ARG EXPERIMENT=experiment-1.0-py3-none-any.whl
COPY additional_package/*.whl /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${PYTCT_WHL} /tmp/${SCG_ROBOT_LIB} /tmp/${EXPERIMENT}
# install additional 
COPY deeplearning/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

USER root
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}
WORKDIR "${HOME}"
