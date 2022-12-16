#!/usr/bin/env bash

image_name=ghcr.io/providentia-project/ros-yolov7-trt

docker build -t $image_name .

if [[ $1 == push ]]; then
    docker push $image_name
fi
