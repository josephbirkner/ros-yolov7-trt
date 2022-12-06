# Docker Container for ROS and YoloV7-based TensorRT instance segmentation

To be used as a base for further containers, which depend on the combination
of YoloV7 TensorRT-models and ROS.

## How to use?

Run the container as follows:

```bash
docker pull `ghcr.io/josephbirkner/ros-yolov7-trt`
docker run --rm -it --gpus all ghcr.io/josephbirkner/ros-yolov7-trt bash
```

To build Tensor-RT models, invoke the `./mktrt.bash` command.
The script will create Tensor-RT versions of the Yolov7-Segmentation model
for 640x640 and 1280x1280 resolutions. After running the script, you will
find the converted TensorRT models under the `/trt/yolov7_<resolution>.trt` path.

## Thanks

- Original YoloV7 Repo: https://github.com/WongKinYiu/yolov7
- First helper repo (the one this was forked from): https://github.com/leandro-svg/Yolov7_Segmentation_Tensorrt
- Second helper repo, linked as submodule: https://github.com/Linaom1214/TensorRT-For-YOLO-Series

