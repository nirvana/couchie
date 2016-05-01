defmodule Couchie.Transcoder do
  use Bitwise

  @json_flag 0x02 <<< 24
  @json_flag_legacy 0x02

  @raw_flag  0x03 <<< 24
  @raw_flag_legacy 0x04

  @str_flag  0x04 <<< 24
  @str_flag_legacy 0x08

  #API defined by cberl_transcoder.erl

  # Encoder

  def encode_value(encoders, value) do
    do_encode_value(flag(encoders), value)
  end

  def do_encode_value(flag, value) when (flag &&& @str_flag) === @str_flag do
    do_encode_value(flag ^^^ @str_flag, value)
  end

  def do_encode_value(flag, value) when (flag &&& @json_flag) === @json_flag do
    do_encode_value(flag ^^^ @json_flag, Poison.encode!(value))
  end

  def do_encode_value(flag, value) when (flag &&& @raw_flag) === @raw_flag do
    do_encode_value(flag ^^^ @raw_flag, :erlang.term_to_binary(value))
  end

  def do_encode_value(_, value), do: value

  # Decoder

  def decode_value(flag, value) when (@raw_flag &&& flag) === @raw_flag do
    decode_value(flag ^^^ @raw_flag, :erlang.binary_to_term(value))
  end
  def decode_value(flag, value) when (@raw_flag_legacy &&& flag) === @raw_flag_legacy do
    decode_value(flag ^^^ @raw_flag_legacy, :erlang.binary_to_term(value))
  end


  def decode_value(flag, value) when (@json_flag &&& flag) === @json_flag  do
    decode_value(flag ^^^ @json_flag, Poison.decode!(value))
  end
  def decode_value(flag, value) when (flag &&& @json_flag_legacy) === @json_flag_legacy do
    decode_value(flag ^^^ @json_flag_legacy, Poison.decode!(value))
  end


  def decode_value(flag, value) when (@str_flag &&& flag) === @str_flag do
    decode_value(flag ^^^ @str_flag, value)
  end
  def decode_value(flag, value) when (flag &&& @str_flag_legacy) === @str_flag_legacy do
    decode_value(flag ^^^ @str_flag_legacy, value)
  end


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
