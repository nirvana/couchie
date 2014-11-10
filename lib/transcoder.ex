defmodule Couchie.Transcoder do
  use Bitwise

  @json_flag 0x2
  @raw_flag  0x4
  @str_flag  0x8

  #API defined by cberl_transcoder.erl

  # Encoder

  def encode_value(encoders, value),
    do: do_encode_value(flag(encoders), value)

  def do_encode_value(flag, value) when (flag &&& @str_flag) === @str_flag,
    do: do_encode_value(flag ^^^ @str_flag, value)

  def do_encode_value(flag, value) when (flag &&& @json_flag) === @json_flag,
    do: do_encode_value(flag ^^^ @json_flag, Poison.encode!(value))

  def do_encode_value(flag, value) when (flag &&& @raw_flag) === @raw_flag,
    do: do_encode_value(flag ^^^ @raw_flag, :erlang.term_to_binary(value))

  def do_encode_value(_, value), do: value

  # Decoder

  def decode_value(flag, value) when (@raw_flag &&& flag) === @raw_flag,
    do: decode_value(flag ^^^ @raw_flag, :erlang.binary_to_term(value))

  def decode_value(flag, value) when (@json_flag &&& flag) === @json_flag,
    do: decode_value(flag ^^^ @json_flag, Poison.decode!(value, keys: :atoms))

  def decode_value(flag, value) when (@str_flag &&& flag) === @str_flag,
    do: decode_value(flag ^^^ @str_flag, value)

  def decode_value(_, value), do: value

  def flag(encoders) when is_list(encoders) do
    List.foldr(encoders, 0, &Bitwise.bor(&2, &1))
  end

  def flag(encoder) do
    case encoder do
      :standard -> @json_flag
      :json -> @json_flag
      :raw_binary -> @raw_flag
      :str -> @str_flag
    end
  end

end
