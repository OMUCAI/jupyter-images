# Deepleaning Image
Deep learning package + pytct

## How to Create Dockerfile
Please pull [this](https://github.com/iot-salzburg/gpu-jupyter) repository and see **Build your own image**.
After create Dockerfile, add pytct library and change `COPY ***` to `COPY deeplearning/***`.

Be careful
```Dockerfile
COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
```
↓
```Dockerfile
COPY deeplearning/start.sh deeplearning/start-notebook.sh deeplearning/start-singleuser.sh /usr/local/bin/
```

This is how to add code-server and pytct library statement.
```Dockerfile
# install code server and extension
ENV CODE_VERSION=4.9.1
RUN curl -fOL https://github.com/coder/code-server/releases/download/v$CODE_VERSION/code-server_${CODE_VERSION}_amd64.deb \
    && dpkg -i code-server_${CODE_VERSION}_amd64.deb \
    && rm -f code-server_${CODE_VERSION}_amd64.deb 
RUN /opt/conda/bin/conda install -c conda-forge jupyter-server-proxy jupyter-vscode-proxy

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

# install vscode extension(python, jupyter)
RUN code-server --install-extension ms-python.python ms-toolsai.jupyter 

ARG PYTCT_WHL=pytct-0.7.5-cp310-cp310-manylinux_2_31_x86_64.whl
COPY pytct/${PYTCT_WHL} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${PYTCT_WHL} nbgitpuller 

USER root
RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}
```

** need curl **

Finally copy files in `.build` folder to deeplearning folder in this repository.

