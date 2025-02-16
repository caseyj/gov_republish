defmodule BlueskyClient do
  def format_post_text(post_data) do
    {:ok, timestamp} = Map.get(post_data, "publish_timestamp")|> String.to_integer() |> DateTime.from_unix()
      "Post by #{Map.get(post_data, "author")} made on #{ timestamp }\n\n#{Map.get(post_data, "content")}"
  end

  def produce_post(post_data) do
    %{
      "text"=> format_post_text(post_data),
      "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "$type"=> "app.bsky.feed.post",
    }
  end

  def post(log_in_data, post_data) do
    headers = %{
      "Authorization"=> "Bearer #{Map.get(log_in_data, "accessJwt")}",
      "content-type"=>"application/json"
    }
    post_data_ammended = %{"repo"=> Map.get(log_in_data, "did"), "collection"=>"app.bsky.feed.post", "record"=>post_data}
    HTTPoison.post!(
      "https://polypore.us-west.host.bsky.network/xrpc/com.atproto.repo.createRecord",
      Poison.encode!(post_data_ammended),
      headers
    )
  end

end
