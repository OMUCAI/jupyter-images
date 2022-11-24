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

This is how to add pytct library statement.
```Dockerfile
COPY pytct/${PYTCT_WHL} /tmp/
RUN pip install --quiet --no-cache-dir /tmp/${PYTCT_WHL} && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
```

Finally copy files in `.build` folder to deeplearning folder in this repository.

