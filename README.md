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
- tensorflow

### minimal
Base image: jupyter/minimal-notebook  
[Dockerhub](https://hub.docker.com/r/jupyter/minimal-notebook)

### datascience
Base image: jupyter/datascience-notebook  
[Dockerhub](https://hub.docker.com/r/jupyter/datascience-notebook)

### deeplearning
Base image: jupyter/pytorch-notebook (CUDA 12)  
[Quay.io](https://quay.io/repository/jupyter/pytorch-notebook), [Github](https://github.com/jupyter/docker-stacks)  

### tensorflow
Base image: jupyter/tensorflow-notebook (CUDA)  
[Quay.io](https://quay.io/repository/jupyter/tensorflow-notebook), [Github](https://github.com/jupyter/docker-stacks)  
