defmodule Botflow do

  import Ecto.Query

  def get_most_recent_posts(author) do
    query = from record in GovRepublish.RssPost,
      where: record.posted == false and record.author == ^author,
      order_by: [asc: :createdAt ]
    SqliteClient.select(query)
  end

  @doc """
  Conducts a log in operation with bluesky providing a log in DID.
  """
  def bluesky_login(username, pw) do
    AtProto.IdentityResolution.login_flow(username, pw)
  end

  @doc """
  Given a raw feed of posts in
  """
  def push_msgs(postable_data, bluesky_login) do
    Enum.reduce(postable_data, %{:ok=>[], :fail=>[]}, fn data, acc ->
      cast_data = BlueskyClient.produce_post(data)
      case BlueskyClient.post(bluesky_login, cast_data) do
        {:ok, %HTTPoison.Response{status_code: 200}} -> Map.get_and_update(acc, :ok, fn lst -> lst ++ [data] end)
        _-> Map.get_and_update(acc, :fail, fn lst -> lst ++ [data] end)
      end
    end)
  end

  def push_unpublished_messages(author, username, pw) do
    {:ok, bsky_login} = bluesky_login(username, pw)
    data = get_most_recent_posts(author)
    push_msgs(data, bsky_login)

  end
end
