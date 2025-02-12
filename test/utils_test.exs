defmodule UtilsTest do

  use ExUnit.Case

  for {input, expected}<- [
    {"https://nitter.privacydev.net/JCParking/status/1889283372192514151#m", "JCParking_1889283372192514151"},
    {"hello world", ""},
  ] do
    test "Show utils.get_id works correctly for string #{input} giving expected output #{expected}" do
      assert Utils.get_id(unquote(input)) == unquote(expected)
    end
  end

end
