require 'nn'
require 'nngraph'

local SCRNN = {}
function SCRNN.scrnn(input_size, output_size, rnn_size, num_layer, dropout, activation)
  dropout = dropout or 0.5
  
  -- there are n+1 inputs (hiddens on each layer and x)
  local inputs = {}
  table.insert(inputs, nn.Identity()()) -- x
  for L = 1,num_layer do
    table.insert(inputs, nn.Identity()()) -- prev_h[L]
  end

  local x, input_size_L
  local outputs = {}
  for L = 1,num_layer do
    local prev_h = inputs[L+1]
    if L == 1 then 
      x = inputs[1]
      input_size_L = input_size
    else 
      x = outputs[L-1] 
      if dropout > 0 then 
        x = nn.Dropout(dropout)(x):annotate{name='drop_'..L}
       end -- apply dropout, if any
      input_size_L = rnn_size
    end
    -- get g
    local i2h = nn.Linear(input_size_L, rnn_size)(x)
    local h2h = nn.Linear(rnn_size, rnn_size)(prev_h)
    local next_g
    if activation == 'tanh' then
      next_g = nn.Tanh(true)(nn.CAddTable(){i2h, h2h})
    elseif activation == 'relu' then
      next_g = nn.ReLU(true)(nn.CAddTable(){i2h, h2h})
    elseif activation == 'none' then
      next_g = nn.CAddTable(){i2h, h2h}
    else
      io.flush(error(string.format(
        'check scrnn_activation: %s', activation)))
    end
    -- get h (identity shrotcut)
    local next_h
    if activation == 'tanh' then
      next_h = nn.Tanh(true)(nn.CAddTable(){prev_h, next_g})
    elseif activation == 'relu' then
      next_h = nn.ReLU(true)(nn.CAddTable(){prev_h, next_g})
    elseif activation == 'none' then
      next_h = nn.CAddTable(){prev_h, next_g}
    else
      io.flush(error(string.format(
        'check scrnn_activation: %s', activation)))
    end
    table.insert(outputs, next_h)
  end

  -- set up the decoder
  local top_h = outputs[#outputs]
  if dropout > 0 then 
    top_h = nn.Dropout(dropout)(top_h):annotate{name='drop_final'}
  end
  local proj = nn.Linear(rnn_size, output_size)(top_h):annotate{name='decoder'}
  local logsoft = nn.LogSoftMax()(proj)
  table.insert(outputs, logsoft)

  return nn.gModule(inputs, outputs)
end

return SCRNN

