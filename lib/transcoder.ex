defmodule Couchie.Transcoder do
  require Bitwise
  use Jazz
  
  @cbe_json 0x02
  @cbe_raw 0x04
  @cbe_str 0x08

  #API defined by cberl_transcoder.erl
  #Currently: Ignore flags, everything goes thru jazz
  def encode_value(flags, value) do
    JSON.encode!(value)
  end

  def decode_value(flags, value) do
    JSON.decode!(value, keys: :atoms)
  end

  def flag(encoders) when is_list(encoders) do
    List.foldr(encoders, 0, fn (x, acc) -> Bitwise.bor(acc, x) end)
  end

  def flag(encoder) do
    case encoder do
      :standard -> @cbe_json
      :json -> @cbe_json
      :raw_binary -> @cbe_raw
      :str -> @cbe_str
    end
  end

end
