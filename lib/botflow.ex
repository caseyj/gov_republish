defmodule Botflow do
  alias Ecto.Query.Builder.From
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
  def update_successful_message({rss_post, parsed_response}) do
    SqliteClient.update_record(rss_post, %{:posted => true})

    SqliteClient.insert(
      GovRepublish.CreatedBskyRecord,
      %GovRepublish.CreatedBskyRecord{},
      Map.put(parsed_response, "rss_post", rss_post)
    )
  end

  def update_successful_message_parse({rss_post, response_string}) do
    {:ok, data} = Poison.decode(response_string)
    update_successful_message({rss_post, data})
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
         acc ++ [update_successful_message_parse(msg_result)]
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

  @doc """
  Logs into Bluesky and pulls a feed. Each post in the feed is then checked to see if its in our post tracking database.

  """
  def get_feed_updates(author, username, pw) do
    {:ok, bsky_login} = AtProto.IdentityResolution.login_flow(username, pw)
    {:ok, feed_data} = BlueskyClient.authenticated_request(bsky_login, AtProto.Feed.get_author_feed(username))
    {:ok, parsed_feed_data} = Poison.decode(feed_data)
    raw_feed_data_to_row_components(parsed_feed_data, username, author)
    |>Enum.map(fn row -> rectify_missing_records(row) end)

  end

  def raw_feed_data_to_row_components(data, queried_author, tw_handle) do
    Enum.reduce(Map.get(data, "feed"), [], fn(dat, acc) ->
      data_main = Map.get(dat, "post")
      record = Map.get(data_main, "record")
      if Map.get(Map.get(data_main, "author"), "handle") == queried_author do
        acc ++ [
          %{
            :post_content=>%{
              :author=>tw_handle,
              :content=>Map.get(record, "text"),
              :publish_timestamp=>Map.get(record, "createdAt"),
            },
            :post_meta=>%{
              "cid"=>Map.get(data_main, "cid"),
              "uri"=>Map.get(data_main, "uri")
            }
        }
      ]
    else
      acc
    end
    end)
  end

  def cid_uri_in_db(post_meta) do
    cid = Map.get(post_meta, "cid")
    uri = Map.get(post_meta, "uri")
    query = from(record in GovRepublish.CreatedBskyRecord,
    where: record.cid == ^cid and record.uri == ^uri
    )
    data = SqliteClient.select(query)
    if length(data) == 0 do
      {false, nil}
    else
      {true, data}
    end
  end

  def post_in_db(post_content) do
    author = Map.get(post_content, :author)
    content = Map.get(post_content, :content)
    publish_timestamp = Map.get(post_content, :publish_timestamp)
    query = from(record in GovRepublish.RssPost,
     where: record.author == ^author and record.content == ^content and record.publish_timestamp == ^publish_timestamp
    )
    data= SqliteClient.select(query)
    if length(data) == 0 do
      {false, nil}
    else
      {true, data}
    end
  end

  @doc """
  Used in order to make sure we have a record of posts already made by a user on bluesky and do not double post.
  """
  def rectify_missing_records(row_components) do
    post_content = Map.get(row_components, :post_content)
    post_meta = Map.get(row_components, :post_meta)
    {content_result, content_data} = post_in_db(post_content)
    {:ok, content_data_found} = case content_result do
      true -> {:ok, hd(content_data)}
      false -> SqliteClient.insert(GovRepublish.RssPost, %GovRepublish.RssPost{}, post_content)
    end
    {meta_result, _meta_data} = cid_uri_in_db(post_meta)
    case meta_result do
      true -> {:ok}
      false -> update_successful_message({content_data_found, post_meta})
    end
  end

end
