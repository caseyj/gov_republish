defmodule BlueskyClient do
  @moduledoc """
  Helper functions that will format data and execute calls against bluesky.
  """

  @doc """
  Formats a text post given a map with fields `publish_timestamp`, `content`, and `author`.

  Returns a string with data in it
  """
  def format_post_text(post_data) do
    "Post by #{Map.get(post_data, "author")} made on #{Map.get(post_data, "publish_timestamp")}\n\n#{Map.get(post_data, "content")}"
  end

  @doc """
  Produces the post document using the input post data
  """
  def produce_post(post_data) do
    %{
      "text" => format_post_text(post_data),
      "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "$type" => "app.bsky.feed.post"
    }
  end

  @doc """
  Performs the actual post behavior against bluesky with working log in data and the data to post
  """
  def post(log_in_data, post_data) do
    headers = %{
      "Authorization" => "Bearer #{Map.get(log_in_data, "accessJwt")}",
      "content-type" => "application/json"
    }

    post_data_ammended = %{
      "repo" => Map.get(log_in_data, "did"),
      "collection" => "app.bsky.feed.post",
      "record" => post_data
    }

    url =
      "#{AtProto.IdentityResolution.get_service(Map.get(log_in_data, "didDoc"))}/xrpc/com.atproto.repo.createRecord"

    {success, response} =
      HTTPoison.post(
        url,
        Poison.encode!(post_data_ammended),
        headers
      )

    Utils.decide_http_success(url, {success, response})
  end
end
