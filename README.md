# Docker Images
Docker Images to be used with JupyterHub.  
It is adding pitct to a certain base image.  

## Docker Registry
This project uses Github container registry.  

## Build Image
When put tags version, github ci will build image and push it to github registry.

## Image list
- minimal
- datascience
- deeplearning

### minimal
Base image: jupyter/minimal-notebook  
[Dockerhub](https://hub.docker.com/r/jupyter/minimal-notebook)

### datascience
Base image: jupyter/datascience-notebook  
[Dockerhub](https://hub.docker.com/r/jupyter/datascience-notebook)

### deeplearning
Base image: cschranz/gpu-jupyter  
[Dockerhub](https://hub.docker.com/r/cschranz/gpu-jupyter), [Github](https://github.com/iot-salzburg/gpu-jupyter)  
