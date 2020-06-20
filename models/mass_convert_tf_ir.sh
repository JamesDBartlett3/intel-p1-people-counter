#!/bin/bash

# Takes 2 arguments: 
#    1) Pattern to match 
#    2) model_type_support.json filename

# Ex: ./mass_convert_tf_ir.sh "mask_rcnn" mask_rcnn_support.json

# Common TF object detection model zoo support.json files: 
#    ssd_v2_support.json
#    faster_rcnn_support.json
#    mask_rcnn_support.json
#    rfcn_support.json

for i in $(ls | grep $1)
do
    mo_tf.py --input_model $i/frozen_inference_graph.pb \
        --tensorflow_object_detection_api_pipeline_config $i/pipeline.config \
        --reverse_input_channels --tensorflow_use_custom_operations_config \
        ../openvino/deployment_tools/model_optimizer/extensions/front/tf/$2 \
        -o IRs/${i::(-11)} # removes trailing date from folder name, to save space
    rm -rf $i
done
