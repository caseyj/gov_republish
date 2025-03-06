defmodule RssClient do
  @moduledoc """
  Functions defined here assist with getting data from an RSS feed that is fed either by a file location or a URL.
  """

  @doc """
  Helper function that handles getting an RSS document from a URL.

  Will provide an :ok for a 2XX error message, and an :error for others
  """
  def _get_rss_feed_url(endpoint) do
    Utils.decide_http_success(endpoint, HTTPoison.get(endpoint))
  end

  @spec _get_rss_feed_file(
          binary()
          | maybe_improper_list(
              binary() | maybe_improper_list(any(), binary() | []) | char(),
              binary() | []
            )
        ) :: {:error, <<_::64, _::_*8>>} | {:ok, binary()}
  @doc """
  Gets the RSS data from a file and returns a tuple with the success status and data as a string.
  """
  def _get_rss_feed_file(file_path) do
    case File.read(file_path) do
      {:ok, body} ->
        {:ok, body}

      {:error, msg} ->
        {:error, "Error retrieving RSS feed from src #{file_path}, error message: \"#{msg}\""}
    end
  end

  @doc """
  Function that takes in a string input and retrieves data either from a file or a URL
  """
  def get_rss_feed(string) do
    case Utils.url_or_file(string) do
      {:filepath, path} -> _get_rss_feed_file(path)
      {:url, string} -> _get_rss_feed_url(string)
    end
  end

  def add_records_to_db(rss_data) do
    {:ok, data} = Parser.get_data(rss_data)

    {:ok,
     Enum.reduce(data, [], fn datum, acc ->
       acc ++ [SqliteClient.insert(GovRepublish.RssPost, %GovRepublish.RssPost{}, datum)]
     end)}
  end
end
