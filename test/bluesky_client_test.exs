defmodule BlueskyClientTest do
  require Mock

  use ExUnit.Case
  import Mock

  test "Check BlueSkyClient.format_post_test." do
    data = %{
      "author" => "@JCParking",
      "content" =>
        "Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.",
      "publish_timestamp" => "1739188826",
      "post_id" => "JCParking_1888920962810195985"
    }

    assert BlueskyClient.format_post_text(data) ==
             "Post by @JCParking made on 2025-02-10 12:00:26Z\n\nAlternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day."
  end

  test "Check produce post works properly" do
    with_mock DateTime,
      to_iso8601: fn _datetime -> "2025-02-13T03:58:24.948122Z" end,
      from_unix: fn _dt -> {:ok, "2025-02-10 12:00:26Z"} end,
      utc_now: fn -> ~U[2025-02-13 04:12:51.844268Z] end do
      assert BlueskyClient.produce_post(%{
               "author" => "@JCParking",
               "content" =>
                 "Alternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.",
               "publish_timestamp" => "1739188826",
               "post_id" => "JCParking_1888920962810195985"
             }) == %{
               "text" =>
                 "Post by @JCParking made on 2025-02-10 12:00:26Z\n\nAlternate side of the street parking / street sweeping is postponed today, Monday, February 10, 2025. Normal enforcement continues the following day.",
               "createdAt" => "2025-02-13T03:58:24.948122Z",
               "$type" => "app.bsky.feed.post"
             }
    end
  end

  test "Arbitrary data" do
    data = %{
      "text" => "hello, my first post via api in ELIXIR #botWriting",
      "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "$type" => "app.bsky.feed.post"
    }
  end
end
