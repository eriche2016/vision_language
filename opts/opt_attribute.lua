
local input_h5 = 
  '/data2/freebee/tshirts_shirts_blous_knit_jacket_onepiece_skirts_coat_cardigan_vest_pants_leggings_shoes_bags_swimwears_hat_panties_bra.image_sentence.txt.shuffle.txt.cutoff50.h5'
local input_json = 
  '/data2/freebee/tshirts_shirts_blous_knit_jacket_onepiece_skirts_coat_cardigan_vest_pants_leggings_shoes_bags_swimwears_hat_panties_bra.image_sentence.txt.shuffle.txt.cutoff50.json'
local total_samples_train =
  721544 + 40000 + 40000
local total_samples_valid =
  40000
local total_samples_test =
  40000
local dataset_name =
  'tshirts_shirts_blous_knit_jacket_onepiece_skirts_coat_cardigan_vest_pants_leggings_shoes_bags_swimwears_hat_panties_bra'

local torch_model= 
  '/data2/ImageNet/ILSVRC2012/torch_cache/X_gpu1_resception_nag_lr0.00450_decay_start0_every160000/model_29.t7'
  --'/data2/ImageNet/ILSVRC2012/torch_cache/X_gpu1_resception_nag_lr0.00450_decay_start0_every160000/model_29.bn_removed.t7'
  --'/storage/ImageNet/ILSVRC2012/torch_cache/inception7_residual/digits_gpu1_inception-v3-2015-12-05_lr0.045_Mon_Jan_18_13_23_03_2016/model_33.bn_removed.t7'
local image_size = 342
local crop_size = 299
local crop_jitter = true
local flip_jitter = false

local rnn_size = 512
local num_rnn_layers = 2
local seq_length = 14
local input_encoding_size = 2048
local use_bn = 'original'
local init_gamma = 0.1
local rnn_type = 'lstm'
local rnn_activation = 'tanh'
local drop_prob_lm = 0.2

local batch_size = 16
local optimizer = 'adam'
local learning_rate = 0.001
local alpha = 0.9
local learning_rate_decay_seed = 
  0.9
  --0.94
local learning_rate_decay_start = 
  45096 * 12
local learning_rate_decay_every = 
  45096
local finetune_cnn_after = 0
local cnn_optimizer = 'nag'
local cnn_learning_rate = 0.001
local cnn_weight_decay = 0.00001

local gpus = {1,2,3,4}
local retrain_iter = 
  0
local embedding_model = 
  '/storage/attribute/checkpoints/tshirts_shirts_blous_knit_jacket_onepiece_skirts_coat_cardigan_vest_pants_leggings_shoes_bags_swimwears_hat_panties_bra_801544_40000_seq_length14/resception_ep29_bs16_flipfalse_croptrue_original_init_gamma0.100000_lstm_tanh_hid512_lay2_drop2.000000e-01_adam_lr1.000000e-03_seed0.90_start541152_every45096_finetune0_cnnlr1.000000e-03_cnnwc1.000000e-05_retrain_iter0/model_idresception_ep29_bs16_flipfalse_croptrue_original_init_gamma0.100000_lstm_tanh_hid512_lay2_drop2.000000e-01_adam_lr1.000000e-03_seed0.90_start541152_every45096_finetune0_cnnlr1.000000e-03_cnnwc1.000000e-05_retrain_iter0.t7'
local start_from = 
  ''
local experiment_id = string.format(
  'tsne_resception_embedding_ep29_bs%d_flip%s_crop%s_%s_init_gamma%f_%s_%s_hid%d_lay%d_drop%e_%s_%s_lr%e_seed%.2f_start%d_every%d_finetune%d_cnnlr%e_cnnwc%e_retrain_iter%d', 
  --'resception_ep29_bn_removed_bs%d_flip%s_crop%s_%s_%s_hid%d_lay%d_drop%.1f_lr%e_seed%.2f_start%d_every%d_finetune%d_cnnlr%e_cnnwc%e', 
  --'_inception-v3-2015-12-05_bn_removed_epoch33_bs%d_flip%s_crop%s_%s_%s_hidden%d_layer%d_dropout%.1f_lr%e_anneal_seed%.2f_start%d_every%d_finetune%d_cnnlr%e', 
  batch_size, 
  flip_jitter, crop_jitter, 
  use_bn, init_gamma, rnn_type, rnn_activation, rnn_size, num_rnn_layers, drop_prob_lm, 
  optimizer, cnn_optimizer, learning_rate, learning_rate_decay_seed, learning_rate_decay_start, learning_rate_decay_every,
  finetune_cnn_after, cnn_learning_rate, cnn_weight_decay,
  retrain_iter
)
local checkpoint_path = string.format(
  '/storage/attribute/checkpoints/%s_%d_%d_seq_length%d/', dataset_name, total_samples_train, total_samples_valid, seq_length
)

if start_from ~= '' and retrain_iter == 0 then
  print(string.format('retrain from %s', start_from))
  error(string.format('retrain_iter MUST NOT be zero'))
end

cmd = torch.CmdLine()
cmd:text()
cmd:text('Options')

-- Data input settings
cmd:option('-input_h5',input_h5,
  'path to the h5file containing the preprocessed dataset')
cmd:option('-input_json',input_json,
  'path to the json file containing additional info and vocab')
cmd:option('-torch_model', torch_model,
  'torch model file path')
cmd:option('-image_size', image_size, 
  'size of input image')
cmd:option('-crop_size', crop_size, 
  'size of croped input image')
cmd:option('-crop_jitter', crop_jitter, 
  'flag for flipping [false | true ]')
cmd:option('-flip_jitter', flip_jitter, 
  'flag for flipping [false | true ]')
cmd:option('-embedding_model', embedding_model, 
  'path to a model checkpoint to initialize embedding weights from. Empty = don\'t')
cmd:option('-start_from', start_from, 
  'path to a model checkpoint to initialize model weights from. Empty = don\'t')
cmd:option('-retrain_iter', retrain_iter, 
  'initial iteration number which should be set non-zero in case of retraining')

-- Model settings
cmd:option('-rnn_size', rnn_size,
  'size of the rnn in number of hidden nodes in each layer')
cmd:option('-input_encoding_size',input_encoding_size,
  'the encoding size of each token in the vocabulary, and the image.')
cmd:option('-num_rnn_layers', num_rnn_layers,
  'number of stacks of rnn layers')
cmd:option('-seq_length', seq_length,
  'number of seq. length (without EOS/SOS token)')
cmd:option('-rnn_type', rnn_type,
  'rnn type [rnn | lstm | gru]')
cmd:option('-use_bn', use_bn,
  'use bn or not [bn | original]')
cmd:option('-init_gamma', init_gamma,
  'initial gamma for BN')
cmd:option('-rnn_activation', rnn_activation,
  'activation for LSTM/RNN [tanh | relu | none]')

-- Optimization: General
cmd:option('-max_iters', -1, 
  'max number of iterations to run for (-1 = run forever)')
cmd:option('-batch_size', batch_size,
  'what is the batch size in number of images per batch? (there will be x seq_per_img sentences)')
cmd:option('-grad_clip', 0.1,
  'clip gradients at this value (note should be lower than usual 5 because we normalize grads by both batch and seq_length)')
cmd:option('-drop_prob_lm', drop_prob_lm, 
  'strength of dropout in the Language Model RNN')
cmd:option('-finetune_cnn_after', finetune_cnn_after, 
  'After what iteration do we start finetuning the CNN? (-1 = disable; never finetune, 0 = finetune from start)')
cmd:option('-seq_per_img', 1,
  'number of captions to sample for each image during training. Done for efficiency since CNN forward pass is expensive. E.g. coco has 5 sents/image')

-- Optimization: for the Language Model
cmd:option('-optim', optimizer,
  'what update to use? rmsprop|sgd|sgdmom|adagrad|adam')
cmd:option('-learning_rate', learning_rate, 'learning rate')
cmd:option('-learning_rate_decay_seed', learning_rate_decay_seed,
  'decay_factor = math.pow(opt.learning_rate_decay_seed, frac)')
cmd:option('-learning_rate_decay_start', learning_rate_decay_start, 
  'at what iteration to start decaying learning rate? (-1 = dont)')
cmd:option('-learning_rate_decay_every', learning_rate_decay_every, 
  'every how many iterations thereafter to drop LR by half?')
cmd:option('-optim_alpha', alpha,
  'alpha for adagrad/rmsprop/momentum/adam')
cmd:option('-optim_beta',0.999, 'beta used for adam')
cmd:option('-optim_epsilon',1e-8,
  'epsilon that goes into denominator for smoothing')

-- Optimization: for the CNN
cmd:option('-cnn_optim', cnn_optimizer, 'optimization to use for CNN')
cmd:option('-cnn_optim_alpha',0.9, 'alpha for momentum of CNN')
cmd:option('-cnn_optim_beta',0.999, 'beta for momentum of CNN')
cmd:option('-cnn_learning_rate', cnn_learning_rate,
  'learning rate for the CNN')
cmd:option('-cnn_weight_decay', cnn_weight_decay, 
  'L2 weight decay just for the CNN')

-- Evaluation/Checkpointing
cmd:option('-train_samples', total_samples_train - total_samples_valid - total_samples_test,
  '# of samples in training set')
cmd:option('-val_images_use', total_samples_valid,
  'how many images to use when periodically evaluating the validation loss? (-1 = all)')
cmd:option('-test_images_use',total_samples_test,
  'how many images to use when periodically evaluating the validation loss? (-1 = all)')
cmd:option('-save_checkpoint_every', math.floor((total_samples_train - total_samples_valid - total_samples_test) / batch_size), 
  'how often to save a model checkpoint?')
cmd:option('-checkpoint_path', checkpoint_path, 
  'folder to save checkpoints into (empty = this folder)')
cmd:option('-language_eval', 0, 
  'Evaluate language as well (1 = yes, 0 = no)? BLEU/CIDEr/METEOR/ROUGE_L? requires coco-caption code from Github.')
cmd:option('-tsne', 1, 'Save word-embedding vector using tsne')

-- misc
cmd:option('-gpus', gpus, '# of gpus for cnn')
cmd:option('-id', experiment_id, 
  'an id identifying this run/job. used in cross-val and appended when writing progress files')
cmd:option('-seed', 123, 
  'random number generator seed to use')
cmd:option('-display', 5,
  'display interval for train steps')

cmd:text()

local opt = cmd:parse(arg)

opt.checkpoint_path = paths.concat(opt.checkpoint_path, opt.id)
os.execute('mkdir -p '..opt.checkpoint_path)
print('===> checkpoint path: '..opt.checkpoint_path)

return opt

