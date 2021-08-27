defmodule BloodyBtm2.Serializer do
  use Bitwise

  # string_serialize and int_serialize is common with most utxo struct chain, above is same to others
  # only read_uvarint is different
  def string_serialize(str) do
    (byte_size(str) |> int_serialize()) <> str
  end

  def put_ext_string(str), do: string_serialize(str)

  def int_serialize(int) when is_integer(int) and int < 0xFD do
    <<int::unsigned-little-integer-size(8)>>
  end

  def int_serialize(int) when is_integer(int) and int <= 0xFFFF do
    <<0xFD, int::unsigned-little-integer-size(16)>>
  end

  def int_serialize(int) when is_integer(int) and int <= 0xFFFF_FFFF do
    <<0xFE, int::unsigned-little-integer-size(32)>>
  end

  def int_serialize(int) when is_integer(int) and int > 0xFFFF_FFFF do
    <<0xFF, int::unsigned-little-integer-size(64)>>
  end

  def string_deserialize(data) do
    {script_bytes, data} = int_deserialize(data)
    <<signature_script::bytes-size(script_bytes), data::binary>> = data
    {script_bytes, signature_script, data}
  end

  def int_deserialize(<<data::unsigned-integer-size(8), remaining::binary>>) do
    {data, remaining}
  end

  def int_deserialize(<<0xFD, data::unsigned-little-integer-size(16), remaining::binary>>) do
    {data, remaining}
  end

  def int_deserialize(<<0xFE, data::unsigned-little-integer-size(32), remaining::binary>>) do
    {data, remaining}
  end

  def int_deserialize(<<0xFF, data::unsigned-native-integer-size(64), remaining::binary>>) do
    {data, remaining}
  end

  def put_uvarint(n) when is_integer(n), do: gen_varint(n, <<>>)

  defp gen_varint(n, data) when n >= 0x80 do
    gen_varint(n >>> 7, data <> <<(n &&& 0x7F) ||| 0x80>>)
  end

  defp gen_varint(n, data), do: data <> <<n>>

  @spec get_uvarint(binary) :: {integer, binary}
  def get_uvarint(binary), do: :erlang.binary_to_list(binary) |> read_uvarint()

  @spec get_ext_string(binary) :: {binary, binary}
  def get_ext_string(binary) do
    {_, str, data} = string_deserialize(binary)
    {str, data}
  end

  def read_uvarint(amount, i \\ 0, s \\ 0, x \\ 0, r \\ 1)

  def read_uvarint(amount, i, s, x, r) when r == 1 do
    [b | amount] = amount

    if b < 0x80 do
      if i > 9 || (i == 9 && b > 1) do
        read_uvarint(amount, 0, 0, x, 0)
      else
        read_uvarint(amount, 0, 0, bor(x, b <<< s), 0)
      end
    else
      x = bor(x, band(b, 0x7F) <<< s)
      s = s + 7
      i = i + 1
      read_uvarint(amount, i, s, x, 1)
    end
  end

  def read_uvarint(amount, _, _, x, r) when r == 0 do
    {x, amount |> :erlang.list_to_binary()}
  end
end
