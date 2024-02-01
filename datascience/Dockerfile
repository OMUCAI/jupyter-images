
FROM jupyter/datascience-notebook:2022-11-14

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
RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_VERSION}_amd64.deb \
    && rm -f code-server_${CODE_VERSION}_amd64.deb 
RUN /opt/conda/bin/conda install -c conda-forge jupyter-server-proxy jupyter-vscode-proxy

USER ${NB_UID}

# install vscode extension(python, jupyter)
RUN code-server --install-extension ms-python.python ms-toolsai.jupyter 

# Overwrite latest version by github action
ARG PYTCT_WHL=pytct-0.7.5-cp310-cp310-manylinux_2_31_x86_64.whl
COPY pytct/${PYTCT_WHL} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${PYTCT_WHL} nbgitpuller 

# install scglib
ARG SCG_ROBOT_LIB=SCGRobotLib-1.0.2-py3-none-any.whl
COPY scglib/${SCG_ROBOT_LIB} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${SCG_ROBOT_LIB}

# install experiment
ARG EXPERIMENT=experiment-1.0-py3-none-any.whl
COPY experiment/${EXPERIMENT} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${EXPERIMENT}

USER root
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}
WORKDIR "${HOME}"
