#!/usr/bin/env bash

set -euo pipefail

#
# Create Yolo v7 mask models for 640 and 1280 resolutions.
#

# Export to ONNX
. /venv/bin/activate

resolutions=( 640 1280 )

for resolution in "${resolutions[@]}"; do
    model_name="yolov7_$resolution"
    onnx_file="$model_name.onnx"

    echo "Running ONNX export for $model_name ..."
    cd /yolov7
    mkdir -p onnx
    python export.py \
        --include onnx \
        --weights ./yolov7-seg.pt \
        --topk-all 100 \
        --iou-thres 0.65 \
        --conf-thres 0.35 \
        --imgsz "$resolution" "$resolution" \
        --simplify

    mv yolov7-seg.onnx "$onnx_file"

    # Export to TRT
    echo "Running ONNX export for $onnx_file ..."
    cd yolov7-trt-helper
    mkdir -p /trt
    python export.py -o "/yolov7/$onnx_file" -e "/trt/$model_name.trt" -p fp16
done

chmod a+rw /trt/*
echo "Done."
