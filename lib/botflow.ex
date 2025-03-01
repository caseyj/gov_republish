defmodule Botflow do
  import Ecto.Query

  @doc """
  Gets the most recent posts that have not yet been posted from the RssPost table for insertion.
  """
  def get_most_recent_posts(author) do
    query =
      from(record in GovRepublish.RssPost,
        where: record.posted == false and record.author == ^author,
        order_by: [asc: :publish_timestamp]
      )

    SqliteClient.select(query)
  end

  @doc """
  Given a raw feed of posts, and a valid log in document, format and push each post to bluesky
  """
  def push_msgs(postable_data, bluesky_login) do
    Enum.reduce(postable_data, %{:ok => [], :fail => []}, fn data, acc ->
      # TODO: hardcode for now
      Process.sleep(5000)
      cast_data = BlueskyClient.produce_post(data)

      case BlueskyClient.post(bluesky_login, cast_data) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Utils.map_append_lists(acc, :ok, [{data, body}])

        _ ->
          Utils.map_append_lists(acc, :fail, [data])
      end
    end)
  end

  @doc """
  Function that updates the original RSS Post to indicate it has been successfully posted, and creates a record of the response data for the post.
  """
  def update_successful_message({rss_post, response_string}) do
    SqliteClient.update_record(rss_post, %{:posted => true})
    {:ok, data} = Poison.decode(response_string)

    SqliteClient.insert(
      GovRepublish.CreatedBskyRecord,
      %GovRepublish.CreatedBskyRecord{},
      Map.put(data, "rss_post", rss_post)
    )
  end

  @doc """
  Iterates over successful messages and runs the update_successful_message function.
  """
  def update_successful_messages(message_map) do
    {:ok,
     Enum.reduce(
       Map.get(message_map, :ok),
       [],
       fn msg_result, acc ->
         acc ++ [update_successful_message(msg_result)]
       end
     )}
  end

  @doc """
  Runs the entire post message flow by doing the following tasks

  1. logs into bluesky
  2. fetches recently added posts from the database
  3. formats posts for pushing to bluesky
  4. pushes each post to bluesky
  5. format the responses for successful posts and adds their data to the database
  """
  def push_unpublished_messages(author, username, pw) do
    {:ok, bsky_login} = AtProto.IdentityResolution.login_flow(username, pw)

    push_msgs(get_most_recent_posts(author), bsky_login)
    |> update_successful_messages()
  end
end
