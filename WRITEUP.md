
---
# Useful Shell Commands
  
Create symlink to OpenVINO install directory in /home/workspace (shortens the commands for mo.py significantly):  
`ln -s /opt/intel/openvino_2019.3.376/ openvino`
  
Download TF models:  
`python openvino/deployment_tools/tools/model_downloader/downloader.py --list ./models.txt`
  
---
  
# Scripts I Wrote
  
## Mass Convert TF to IR  
  
>mass_convert_tf_ir.sh

```
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

```

## Trim Dates From IR Folders  
  
>date_trim.sh 

```
#!/bin/bash

# Removes 11 characters and a trailing slash (if exists) 
# from the end of the given file or folder name

pretrim=${@%/}
mv $pretrim ${pretrim::(-11)}
```
---
  
# Project Write-Up

## Notes to Instructor

I decided early on in the process to base my project on the starter code from Intel's official [intel-iot-devkit/people-counter-python](https://github.com/intel-iot-devkit/people-counter-python) repo on GitHub, rather than the starter code from the [udacity/nd131-openvino-fundamentals-project-starter](https://github.com/udacity/nd131-openvino-fundamentals-project-starter) repo, because I found Intel's comments more instructive, and the general workflow more to my liking.
  
## Explaining Custom Layers
  
I'm behind schedule, so I didn't think it would be a good idea to make things more complicated than they need to be. Therefore, I chose not to use custom layers.  
That being said, some of the potential reasons for handling custom layers are:  
- Increased model performance 
- Better model specialization for specific use cases and scenarios
  
## Comparing Model Performance
  
### Methods

I created a notebook in Google Colab with code to run my chosen model in both TensorFlow and OpenVINO, and compare their performance side-by-side
- I based my TensorFlow inference code on [object_detection_tutorial.ipynb from the TensorFlow repo on GitHub](https://github.com/tensorflow/models/blob/master/research/object_detection/colab_tutorials/colab_tutorials/object_detection_tutorial.ipynb)
- I based my OpenVINO inference code on [demo.ipynb from the OpenDevLibrary repo on GitHub](https://github.com/alihussainia/OpenDevLibrary/blob/master/demo.ipynb)

### Metrics

- Model Precision
  - Pre-Conversion: COCO mAP[^1] = 22 (from the [TensorFlow docs on GitHub](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md))
  - Post-Conversion: I was unable to calculate COCO mAP[^1] value post-conversion
- Model Size
  - Pre-Conversion: 201 MB
  - Post-Conversion: 65 MB
- Model Inference Time (graphic & values from [this article](https://mc.ai/how-to-run-tensorflow-object-detection-model-faster-with-intel-graphics/) on MC.AI)
  ![inference_time](https://cdn-images-1.medium.com/freeze/max/1000/0*eMnKV_K4cvjh5-3b.png)
  - Pre-Conversion (on GPU): 65.2
  - Post-Conversion (FP32 on GPU): 41.9
  
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
  
In investigating potential people counter models, I tried each of the following models:  

#### Model 1: [faster_rcnn_inception_v2_coco]
  - Source: [TensorFlow Object Detection Model Zoo](http://download.tensorflow.org/models/object_detection/faster_rcnn_inception_v2_coco_2018_01_28.tar.gz)  
  - I used my custom [mass_convert_tf_ir.sh](#mass-convert-tf-to-ir) script to convert the model to an Intermediate Representation.
  - The model was insufficient for the app because it had unsupported layers, so it wouldn't run.
  - I haven't yet figured out how to deal with unsupported layers, so I couldn't get any further with this model, and I moved on to the next one.

#### Model 2: [mask_rcnn_inception_v2_coco]
  - Source: [TensorFlow Object Detection Model Zoo](http://download.tensorflow.org/models/object_detection/mask_rcnn_inception_v2_coco_2018_01_28.tar.gz)  
  - I used my custom [mass_convert_tf_ir.sh](#mass-convert-tf-to-ir) script to convert the model to an Intermediate Representation.
  - The model was insufficient for the app because it had unsupported layers, so it wouldn't run.
  - I haven't yet figured out how to deal with unsupported layers, so I couldn't get any further with this model, and I moved on to the next one.

#### Model 3: [ssd_mobilenet_v1_coco]
  - Source: [TensorFlow Object Detection Model Zoo](http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v1_coco_2018_01_28.tar.gz)  
  - I used my custom [mass_convert_tf_ir.sh](#mass-convert-tf-to-ir) script to convert the model to an Intermediate Representation.
  - The model was insufficient for the app because the accuracy was barely better than chance.
  - I improved the model for the app by upgrading to v2 [ssd_mobilenet_v2_coco](#model-4-ssd_mobilenet_v2_coco).

#### Model 4: [ssd_mobilenet_v2_coco]
  - Source: [TensorFlow Object Detection Model Zoo](http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz)  
  - I used my custom [mass_convert_tf_ir.sh](#mass-convert-tf-to-ir) script to convert the model to an Intermediate Representation  
  - This model achieved what I consider to be acceptable performance, though I'll admit that I was expecting better accuracy from a pre-trained model. 
  - I observed a number of idiosyncrasies in the model's behavior, some of which I was able to deal with, and others not. Here are a few of my observations: 
    - With default settings, it couldn't draw a consistent bounding box around any given subject for the whole time they were in-frame. The bounding boxes would flicker on and off.
    - It was particularly bad at recognizing two specific subjects, and to a lesser degree, subjects wearing darker-colored clothing. 
    - The severity of the flicker also appeared to have a non-linear relationship to the magnitude of the subject's motion in-frame. It tended to perform quite poorly at the higher end of the range of recorded subject velocities, somewhat better at the opposite end of the range, and it seemed at its best when the subject was moving, but not too quickly. I suspect that there is a certain degree of bias trained into the model, expecting that human subjects are nearly always in motion, to an extent. In most contexts, this kind of bias is probably beneficial, as it would tend to ignore stationary objects that merely look like humans, such as statues, posters, mannequins, etc. However, there are many other potential applications for specialized Edge AI human detection technology, which would be hindered if the underlying model tended to ignore humans moving at the far ends of the velocity range -- such as intrusion detection, law enforcement, healthcare, and sports, to name a few.
  - How I improved the model for the app:
    - Lowered the confidence threshold necessary to register a detection and trigger a bounding box
    - Added conditional logic to the count incrementer, to reduce the frequency of double-counting a single subject, using:
      - The bounding box's last known intersection with either the bottom or right edge of the frame
      - A rolling average of detections from the last 30 frames to counteract jitter
  - How I would have liked to improve the app, if I had more time:
    - Using a 3/4 majority of the following metrics to classify each detection event as "unique" or "duplicate":
      - Confidence threshold
      - Bounding box distance from edge of frame
      - Bounding box distance from location of last detection
      - Miliseconds since last detection

---
