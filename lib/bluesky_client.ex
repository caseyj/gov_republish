defmodule BlueskyClient do
  @moduledoc """
  Helper functions that will format data and execute calls against bluesky.
  """

  require Logger

  @doc """
  Produces the post document using the input post data
  """
  def produce_post(post_data) do
    %{
      "text" => Map.get(post_data, "content"),
      "createdAt" => Map.get(post_data, "publish_timestamp"),
      "$type" => "app.bsky.feed.post"
    }
  end

  @doc """
  Performs the actual post behavior against bluesky with working log in data and the data to post
  """
  def post(log_in_data, post_data) do
    authenticated_request(
      log_in_data,
      AtProto.Repo.create_record(
        Map.get(log_in_data, "did"),
        "app.bsky.feed.post",
        post_data
      )
    )
  end

  @doc """
  Handles making authenticated HTTP requests for the system.

  Deals with the specifics of GET v POST and expects data formats from lib/AtProto
  """
  def authenticated_request(log_in_data, request_data) do
    headers = %{
      "Authorization" => "Bearer #{Map.get(log_in_data, "accessJwt")}",
      "content-type" => "application/json"
    }

    url =
      "#{AtProto.IdentityResolution.get_service(Map.get(log_in_data, "didDoc"))}#{Map.get(request_data,:uri)}"

    {success, response} = case Map.get(request_data, :method) do
      :GET -> HTTPoison.get(
        url,
        headers
      )
      :POST ->HTTPoison.post(
        url,
        Poison.encode!(Map.get(request_data, :request)),
        headers
      )
      _ -> {:error, "Unsupported method"}
    end
    Utils.decide_http_success(url, {success, response})
  end

end
