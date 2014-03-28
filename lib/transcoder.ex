defmodule Couchie.Transcoder do
  
  #API defined by cberl_transcoder.erl
  #Currently: Ignore flags, everything goes thru jazz

  def encode_value(_, value) do
    JSON.encode!(value)
  end
  
  def decode_value(_, value) do
    JSON.decode!(value)
  end

  def flag(list) do
    list
  end
  
  
end