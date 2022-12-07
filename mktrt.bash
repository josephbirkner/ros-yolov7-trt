#!/usr/bin/env bash

set -euo pipefail

#
# Create Yolo v7 mask models for 640 and 1280 resolutions.
#

. /venv/bin/activate

resolutions=( 640 1280 )

for resolution in "${resolutions[@]}"; do
    model_name="yolov7_$resolution"

    echo "Running ONNX export for $model_name ..."
    cd /yolov7
    mkdir -p onnx
    mkdir -p /trt
    python export.py \
        --include onnx engine\
        --data data/coco.yaml \
        --weights ./yolov7-seg.pt \
        --topk-per-class 100 \
        --topk-all 1000 \
        --device 0 \
        --half \
        --iou-thres 0.65 \
        --conf-thres 0.35 \
        --imgsz "$resolution" \
        --simplify \
        --verbose

    mv yolov7-seg.engine /trt/"$model_name".trt
done

chmod a+rw /trt
chmod a+rw /trt/*

echo "Done."
