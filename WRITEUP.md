# Commands

Create symlink to OpenVINO install directory in /home/workspace:
`ln -s /opt/intel/openvino_2019.3.376/ openvino`

Download TF models:
`python openvino/deployment_tools/tools/model_downloader/downloader.py --list ./models.txt`

# Scripts

Convert to IR (mass_convert_tf_ir.sh):
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
        -o IRs/$i
    rm -rf $i
done


Trim dates from IR folder names (date_trim.sh):
#!/bin/bash

# Removes 11 characters and a trailing slash (if exists) 
# from the end of the given file or folder name

pretrim=${@%/}
mv $pretrim ${pretrim::(-11)}



# Project Write-Up


## Explaining Custom Layers

I'm behind schedule, so I didn't think it would be a good idea to make things more complicated than they need to be. Therefore, I chose not to use custom layers.

Some of the potential reasons for handling custom layers are:
- If you wanted to get some performance that you couldn't get without the custom layers
- If you wanted to get some feature that you couldn't get without the custom layers


## Comparing Model Performance

My method(s) to compare models before and after conversion to Intermediate Representations were...

The difference between model accuracy pre- and post-conversion was...

The size of the model pre- and post-conversion was...

The inference time of the model pre- and post-conversion was...

## Assess Model Use Cases

Some of the potential use cases of the people counter app are:
- Counting the number of people in line at a store
- Counting the number of people that come into a business
- Counting the number of people who enter a sporting event

Each of these use cases would be useful because:
- Wait times could be calculated, and staffing adjusted accordingly
- It would be possible to calculate the number of people who came into the store, but didn't buy anything
- It would be possible to determine if the venue had exceeded its occupancy limit

## Assess Effects on End User Needs

Lighting, model accuracy, and camera focal length/image size have different effects on a deployed edge model. The potential effects of each of these are as follows...
- Adequate lighting is necessary in order to achieve enough contrast that the model can make accurate inferences.
- Model accuracy is important because if it's not accurate, then you can't make accurate calculations from the data. 
- If the image isn't in focus, then the model won't be able to make accurate inferences. 

## Model Research

[This heading is only required if a suitable model was not found after trying out at least three
different models. However, you may also use this heading to detail how you converted 
a successful model.]

In investigating potential people counter models, I tried each of the following three models:

- Model 1: [Name]
  - [Model Source]
  - I converted the model to an Intermediate Representation with the following arguments...
  - The model was insufficient for the app because...
  - I tried to improve the model for the app by...
  
- Model 2: [Name]
  - [Model Source]
  - I converted the model to an Intermediate Representation with the following arguments...
  - The model was insufficient for the app because...
  - I tried to improve the model for the app by...

- Model 3: [Name]
  - [Model Source]
  - I converted the model to an Intermediate Representation with the following arguments...
  - The model was insufficient for the app because...
  - I tried to improve the model for the app by...
