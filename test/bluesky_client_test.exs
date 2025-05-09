defmodule BlueskyClientTest do
  require Mock

  use ExUnit.Case
  import Mock

  test "Check produce post works properly" do

    assert BlueskyClient.produce_post(%{
              "author" => "@JCParking",
              "content" =>
                "Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.",
              "publish_timestamp" => ~U[2025-02-10 12:00:26Z],
              "post_id" => "JCParking_1888920962810195985"
            }) == %{
              "text" =>
              "Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.",
              "createdAt" => ~U[2025-02-10 12:00:26Z],
              "$type" => "app.bsky.feed.post"
            }
  end

  for {input, expected} <- [
        {200, :ok},
        {299, :ok},
        {300, :error},
        {400, :error},
        {500, :error},
        {nil, :error}
      ] do
    test "Sanity check with post for input #{input}" do
      with_mock Poison,
        encode!: fn _a -> {} end do
        with_mock HTTPoison,
          post: fn _a, _b, _c ->
            if unquote(input) do
              {:ok, %HTTPoison.Response{status_code: unquote(input)}}
            else
              {:error, %HTTPoison.Error{}}
            end
          end do
          # we need the most minimal log in doc to test this funct
          log_in_data = %{
            "accessJwt" => "123",
            "did" => "did:plc:123",
            "didDoc" => %{
              "service" => [
                %{
                  "id" => "#atproto_pds",
                  "serviceEndpoint" => "https://polypore.us-west.host.bsky.network",
                  "type" => "AtprotoPersonalDataServer"
                }
              ]
            }
          }

          post_data = %{}
          {success, _} = BlueskyClient.post(log_in_data, post_data)
          assert success == unquote(expected)
        end
      end
    end
  end
end
