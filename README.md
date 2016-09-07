# Dataset preperation
1. Path: 
2. Move to the directory, `cd /storage`
3. Convert csv-files into a raw-data txt-file on your disk
	* refer to: `convert_attribute_to_sentense_*.py`
  * **run following script**: `sh convert_attribute_to_sentense_all.sh`
	* **the resulting txt file will be used for preprocessing**
4. Shuffle dataset
	* `python shuffle_duplicate_remove.py`
4. Download this repo.: `git clone ssh:url/for/this/repo. && cd /path/to/the/git/repo.`
5. Run `./data/attribute/prepro_attribute.py`
	* **check argument** `--input_filename # output file from shuffle_duplicate_remove.py`
	* **check argument** `--output_json, # resulting output_json file. this file finally used for train/val/test`
	* **check argument** `--output_h5 # resulting output_h5 file. this file also used for train/val/test`
	* check argument `image_dim, # default: 342` 

# Training/val
1. Move to the directory, `cd /path/to/the/git/repo.`
2. Change options, `vim opts/opt_attribute.lua`
	* **check argument** `input_h5 --output h5 file of prepro_attribute.py`
	* **check argument** `input_json --output json file of prepro_attribute.py`
	* **check argument** `torch_model --path to pretrained-image encoder network`
	* check argument `gpus = {1,2,3,4}`
	* check argument for image-encoder `image_size, crop_size, crop_jitter, flip_jitter = 342, 299, true, false`
	* tune hyperparameters for the language-decoder (e.g. `rnn_size, num_rnn_layers and drop_prob_lm use_bn=false` etc)
	* tune hyperparameters for optimisation (e.g. `batch_size, optimizer, learning_rate` etc)

# Launching training/val scripts
1. Suppose you want to run on 4 gpu cards
	* `CUDA_VISIBLE_DEVICES=0,1,2,3 luajit train.lua`

# Plotting learning curve
1. Both train and val. log files are saved in your checkpoint path automatically 
	* refer to the notebook-file: http://10.202.35.109:2596/PBrain/co_work/attribute/plot_julia.html

# Evaluating precision/recall for test set
1. Prediction for test set: `CUDA_VISIBLE_DEVICES=0 th eval_attr.lua`
2. Evaluation for the prediction result: `python example/eval.py prediction_result.txt`
