defmodule RssClient do

  def _get_rss_feed_url(endpoint) do
    case HTTPoison.get(endpoint) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      _ -> {:error, "Error retrieving RSS feed from src #{endpoint}"}
    end
  end

  def _get_rss_feed_file(file_path) do
    case File.read(file_path) do
      {:ok,  body} -> {:ok, body}
      _ -> {:error, "Error retrieving RSS feed from src #{file_path}"}
    end
  end

  def get_rss_feed(string) do
    case Utils.url_or_file(string) do
      {:filepath, path} -> _get_rss_feed_file(path)
      {:url, string} -> _get_rss_feed_url(string)
    end
  end

  def add_records_to_db(rss_data) do
    Enum.reduce(elem(Parser.get_data(rss_data),1), [], fn datum, acc ->
      acc ++ [SqliteClient.insert(GovRepublish.RssPost, %GovRepublish.RssPost{}, datum)]
    end)
  end

end
