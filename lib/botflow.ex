defmodule Botflow do
  def read_rss_from_file(file_path) do
    {:ok, data} = File.read(file_path)
    Parser.get_data(data)
  end

  def bluesky_login(username, pw) do
    AtProto.IdentityResolution.login_flow(username, pw)
  end

  def push_msg(rss_data, bluesky_login) do
    Enum.reduce(rss_data, [], fn data, acc ->
      acc ++ [BlueskyClient.post(bluesky_login, BlueskyClient.produce_post(data))]
    end)
  end
end
