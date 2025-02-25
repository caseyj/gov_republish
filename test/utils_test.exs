defmodule UtilsTest do
  use ExUnit.Case

  for {input, expected} <- [
        {"https://nitter.privacydev.net/JCParking/status/1889283372192514151#m",
         "JCParking_1889283372192514151"},
        {"hello world", ""}
      ] do
    test "Show utils.get_id works correctly for string #{input} giving expected output #{expected}" do
      assert Utils.get_id(unquote(input)) == unquote(expected)
    end
  end

  test "Show Utils.parse_date_to_map provides correct output for \"Mon, 10 Feb 2025 18:28:16 GMT\"" do
    assert Utils.parse_date_to_map("Mon, 10 Feb 2025 18:28:16 GMT", %{}, "publish_timestamp") == %{"publish_timestamp"=>~U[2025-02-10 18:28:16Z]}
  end
  test "Show Utils.parse_date_to_map provides correct output for \"Not a Date\"" do
    assert Utils.parse_date_to_map("Not a Date", %{}, "publish_timestamp") == %{:error=>["Unable to parse date for input \"Not a Date\", resulting error: \"Could not parse \"Not a Date\"\""]}
  end
  test "Show Utils.parse_date_to_map provides correct output for \"Not a Date\", with second error in map" do
    assert Utils.parse_date_to_map("Not a Date", %{:error=>["hello_world"]}, "publish_timestamp") == %{:error=>["hello_world","Unable to parse date for input \"Not a Date\", resulting error: \"Could not parse \"Not a Date\"\""]}
  end

  for {input, expected} <- [
    {"/example/file/path.txt", {:filepath, "/example/file/path.txt"}},
    {"http://example.com", {:url, "http://example.com"}}
  ]do
    test "Show url_or_file gives correct results for input \"#{input}\"" do
      assert Utils.url_or_file(unquote(input)) == unquote(expected)
    end
  end

  for {success, status_code, expected} <- [
    {:ok, 200, :ok},
    {:ok, 299, :ok},
    {:ok, 300, :error},
    {:ok, 400, :error},
    {:ok, 500, :error},
    {:error, nil, :error},
  ] do
    test "Checking Utils.decide_http_success successful with given inputs #{success}, #{status_code}" do
      if unquote(status_code) do
        {success_criteria, _} = Utils.decide_http_success("hello world", {unquote(success), %HTTPoison.Response{status_code: unquote(status_code)}})
        assert success_criteria == unquote(expected)
      else
        {success_criteria, _} = Utils.decide_http_success("hello world", {unquote(success), %HTTPoison.Error{}})
        assert success_criteria == unquote(expected)
      end
    end
  end
end
