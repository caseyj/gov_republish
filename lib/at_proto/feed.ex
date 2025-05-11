defmodule AtProto.Feed do

  @moduledoc """
  Feed based helper functions for AtProto

  From https://docs.bsky.app/docs/api/
  """

  @doc """
  Generates the necessary data to consume an author feed from bluesky.
  """
  def get_author_feed(actor, limit \\ 50, cursor \\ nil, filter \\ :posts_with_replies, include_pins \\ true) do

    request = %{
      :actor=> actor,
      :limit=> limit,
      :cursor=>cursor,
      :filter=>filter,
      :includePins=>include_pins
    } |> Utils.remove_nils_from_map()
    |> URI.encode_query()

    action = "app.bsky.feed.getAuthorFeed"
    uri = "/xrpc/app.bsky.feed.getAuthorFeed?#{request}"
    %{
      :uri=> uri,
      :method=> :GET,
      :action => action
    }
  end

end
