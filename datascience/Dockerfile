
FROM jupyter/datascience-notebook:2022-11-14

LABEL maintainer="Masahiro Konishi <konikoni428@gmail.com>"

USER root
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # Common utilities
    graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

ARG PYTCT_WHL=pytct-0.7.5-cp310-cp310-manylinux_2_31_x86_64.whl

COPY pytct/${PYTCT_WHL} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${PYTCT_WHL} && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN pip install --quiet --no-cache-dir nbgitpuller && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

WORKDIR "${HOME}"