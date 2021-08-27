defmodule BloodyBtm2Test do
  use ExUnit.Case

  test "decode encode block" do
    raw =
      "03019d8c03a9e61f90cb74420dde678dcf9141a6600a7957443196202874073edf205f9121a09e86b1b72f202cd226b1efc0a74dbaffb7d3540c4cf34de969d66254aa95c3a2c5b63551f4c041400077faa364d9e5e9cbe7d8b5bd88f03e0f45970cc93d5af16075a133cbc7d8353b67f99d32d54bb2ac13f4d639d05acf626130a3dcacac8dd4ecf42fcddecf0b0100020701000101080206003530373137000101003affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0001160014e31277f2d1c9f5e8953637fd892e4ee38346cda0000007019bbb1d010161015faa6a3ef0bfbfac5ed2d572c569d58258c43ffcd6811c9a4067170f47216d4c6affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc8adcfc6070101160014ae2c6bf48714cf0d00d77b907688ca140a6c211b006302404dda6f3535416bfef3b19aeab1e4abcda646dea9cfd48364f8f222df3ba645594415bf27bc44e7622bb0d0f13373c991653896cd2d80166dbaa30f25e0ef3a05207ce0e481489298fece45aa5f02b639f20234cf5b4d9ce532b4a2248eb707f7ed0201003effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80cab5ee01011600144fd437bd1f2e98b8079661ace2862f59489c3739000001003effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0affed70501160014ae2c6bf48714cf0d00d77b907688ca140a6c211b0000"
      |> Base.decode16!(case: :lower)

    assert BloodyBtm2.decode_block(raw) |> elem(0) |> BloodyBtm2.encode_block() == raw
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
           }, "16c4265a8a90916434c2a904a90132c198c7ebf8512aa1ba4485455b0beff388"}
        ] do
      assert BloodyBtm2.entry_id(type, data) |> Base.encode16(case: :lower) == eid
    end
  end
end
