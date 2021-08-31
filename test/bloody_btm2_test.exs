defmodule BloodyBtm2Test do
  use ExUnit.Case
  import BloodyBtm2

  test "decode encode block" do
    raw =
      "03019d8c03a9e61f90cb74420dde678dcf9141a6600a7957443196202874073edf205f9121a09e86b1b72f202cd226b1efc0a74dbaffb7d3540c4cf34de969d66254aa95c3a2c5b63551f4c041400077faa364d9e5e9cbe7d8b5bd88f03e0f45970cc93d5af16075a133cbc7d8353b67f99d32d54bb2ac13f4d639d05acf626130a3dcacac8dd4ecf42fcddecf0b0100020701000101080206003530373137000101003affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0001160014e31277f2d1c9f5e8953637fd892e4ee38346cda0000007019bbb1d010161015faa6a3ef0bfbfac5ed2d572c569d58258c43ffcd6811c9a4067170f47216d4c6affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc8adcfc6070101160014ae2c6bf48714cf0d00d77b907688ca140a6c211b006302404dda6f3535416bfef3b19aeab1e4abcda646dea9cfd48364f8f222df3ba645594415bf27bc44e7622bb0d0f13373c991653896cd2d80166dbaa30f25e0ef3a05207ce0e481489298fece45aa5f02b639f20234cf5b4d9ce532b4a2248eb707f7ed0201003effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80cab5ee01011600144fd437bd1f2e98b8079661ace2862f59489c3739000001003effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0affed70501160014ae2c6bf48714cf0d00d77b907688ca140a6c211b0000"
      |> Base.decode16!(case: :lower)

    assert decode_block(raw) |> elem(0) |> encode_block() == raw
  end

  test "entry id" do
    for {type, data, eid} <- [
          {:issuance,
           %{
             nonce_hash: <<0::64, 1::64, 2::64, 3::64>>,
             value: %{
               asset_id: <<1::64, 2::64, 3::64, 4::64>>,
               amount: 100
             },
             ordinal: 1
           }, "3012b9b6da3962bb2388cdf5db7f3b93a2b696fcc70e79bc5da1238a6d66ae73"},
          {:mux,
           %{
             sources: [
               %{
                 ref: <<0::64, 1::64, 2::64, 3::64>>,
                 value: %{
                   asset_id: <<1::64, 2::64, 3::64, 4::64>>,
                   amount: 100
                 },
                 position: 1
               }
             ],
             program: %{
               vm_version: 1,
               code: <<1, 2, 3, 4>>
             }
           }, "16c4265a8a90916434c2a904a90132c198c7ebf8512aa1ba4485455b0beff388"},
          {:original_output,
           %{
             source: %{
               ref: <<4::64, 5::64, 6::64, 7::64>>,
               value: %{
                 asset_id: <<1::64, 1::64, 1::64, 1::64>>,
                 amount: 10
               },
               position: 10
             },
             control_program: %{
               vm_version: 1,
               code: <<5, 5, 5, 5>>
             },
             state_data: [<<3, 4>>],
             ordinal: 1
           }, "63fbfda2cf0acc573f2a514ddff8ee64c33e713aebe4c85670507545c38841b2"},
          {:retirement,
           %{
             source: %{
               ref: <<4::64, 5::64, 6::64, 7::64>>,
               value: %{
                 asset_id: <<1::64, 1::64, 1::64, 1::64>>,
                 amount: 10
               },
               position: 10
             },
             ordinal: 1
           }, "538c367f7b6e1e9bf205ed0a29def84a1467c477b19812a6934e831c78c4da62"},
          {:spend,
           %{
             spent_output_id: <<0::64, 1::64, 2::64, 3::64>>,
             ordinal: 1
           }, "2761dbb13967af8944620c134e0f336bbbb26f61eb4ecd154bc034ad6155b9e8"},
          {:tx_header,
           %{
             version: 1,
             serialized_size: 100,
             time_range: 1000,
             result_ids: [<<4::64, 5::64, 6::64, 7::64>>]
           }, "ba592aa0841bd4649d9a04309e2e8497ac6f295a847cadd9de6b6f9c2d806663"}
        ] do
      assert entry_id(type, data) |> Base.encode16(case: :lower) == eid
    end
  end

  test "sig hash" do
    for {tx, sig_hash} <- [
          {
            %{
              id:
                <<13_464_118_406_972_499_748::64, 5_083_224_803_004_805_715::64,
                  16_263_625_389_659_454_272::64, 9_428_032_044_180_324_575::64>>,
              input_ids: [
                <<14_760_873_410_800_997_144::64, 1_698_395_500_822_741_684::64,
                  5_965_908_492_734_661_392::64, 9_445_539_829_830_863_994::64>>
              ]
            },
            "17dfad182df66212f6f694d774285e5989c5d9d1add6d5ce51a5930dbef360d8"
          },
          {
            %{
              id:
                <<17_091_584_763_764_411_831::64, 2_315_724_244_669_489_432::64,
                  4_322_938_623_810_388_342::64, 11_167_378_497_724_951_792::64>>,
              input_ids: [
                <<6_970_879_411_704_044_573::64, 10_086_395_903_308_657_573::64,
                  10_107_608_596_190_358_115::64, 8_645_856_247_221_333_302::64>>
              ]
            },
            "f650ba3a58f90d3a2215f6c50a692a86c621b7968bb2a059a4c8e0c819770430"
          }
        ] do
      assert sig_hashes(tx) |> Enum.at(0) |> Base.encode16(case: :lower) == sig_hash
    end
  end

  test "transaction" do
    for {_tx, hex, hash} <- [
          {
            %{
              version: 1,
              serialized_size: 5,
              inputs: [],
              outputs: []
            },
            "0701000000",
            "8e88b9cb4615128c7209dff695f68b8de5b38648bf3d44d2d0e6a674848539c9"
          }
        ] do
      raw_tx = Base.decode16!(hex, case: :lower)
      decoded = decode_tx(raw_tx) |> elem(0)

      assert decoded |> encode_tx() == raw_tx

      new_tx = map_tx(decoded) |> generate_tx()
      assert new_tx.id == Base.decode16!(hash, case: :lower)
    end
  end

  test "map_tx" do
    for tx_data <- [
          %{
            inputs: [
              spend_input(
                nil,
                Base.decode16!("fad5195a0c8e3b590b86a3c0a95e7529565888508aecca96e9aeda633002f409",
                  case: :lower
                ),
                btm_asset_id(),
                88,
                3,
                <<1>>,
                [<<2>>]
              )
            ],
            outputs: [
              original_tx_output(btm_asset_id(), 80, <<1>>, [<<2>>])
            ]
          }
        ] do
      tx = map_tx(tx_data)
      assert length(tx.result_ids) == length(tx_data.outputs)

      for {old_input, id} <- Enum.zip(tx_data.inputs, tx.input_ids) do
        new_input = tx.entries[id]

        case new_input._type do
          :spend ->
            spend_out = tx.entries[new_input.spent_output_id]
            assert spend_out.source.value.asset_id == old_input.commitment.asset_id
            assert spend_out.source.value.amount == old_input.commitment.amount
        end
      end

      for {old_out, id} <- Enum.zip(tx_data.outputs, tx.result_ids) do
        new_out = tx.entries[id]

        assert new_out.source.value.asset_id == old_out.commitment.asset_id
        assert new_out.source.value.amount == old_out.commitment.amount
        assert new_out.control_program.vm_version == 1

        assert byte_size(new_out.control_program.code) ==
                 byte_size(old_out.commitment.control_program)

        assert new_out.state_data == old_out.commitment.state_data
      end
    end
  end

  test "onchain tx" do
    block_hex =
      "03019d8c03a9e61f90cb74420dde678dcf9141a6600a7957443196202874073edf205f9121a09e86b1b72f202cd226b1efc0a74dbaffb7d3540c4cf34de969d66254aa95c3a2c5b63551f4c041400077faa364d9e5e9cbe7d8b5bd88f03e0f45970cc93d5af16075a133cbc7d8353b67f99d32d54bb2ac13f4d639d05acf626130a3dcacac8dd4ecf42fcddecf0b0100020701000101080206003530373137000101003affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0001160014e31277f2d1c9f5e8953637fd892e4ee38346cda0000007019bbb1d010161015faa6a3ef0bfbfac5ed2d572c569d58258c43ffcd6811c9a4067170f47216d4c6affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc8adcfc6070101160014ae2c6bf48714cf0d00d77b907688ca140a6c211b006302404dda6f3535416bfef3b19aeab1e4abcda646dea9cfd48364f8f222df3ba645594415bf27bc44e7622bb0d0f13373c991653896cd2d80166dbaa30f25e0ef3a05207ce0e481489298fece45aa5f02b639f20234cf5b4d9ce532b4a2248eb707f7ed0201003effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80cab5ee01011600144fd437bd1f2e98b8079661ace2862f59489c3739000001003effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0affed70501160014ae2c6bf48714cf0d00d77b907688ca140a6c211b0000"

    block = block_hex |> Base.decode16!(case: :lower) |> decode_block() |> elem(0)
    tx = Enum.at(block.txs, 1)

    tx1 =
      tx
      |> map_tx()
      |> generate_tx()

    assert tx1.id ==
             Base.decode16!("a91d1069d5bdd3e8513f7de332599a5b83a85b07a397fa4f7a2280568cb8e034",
               case: :lower
             )
  end
end
