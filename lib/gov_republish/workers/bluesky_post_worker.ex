defmodule GovRepublish.Workers.BlueskyPostWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {:ok, data} = File.read(Map.get(args, "settings_file"))
    {:ok, data_parsed} = Poison.decode(data)
    user = Map.get(data_parsed, "bluesky-handle")
    pw = Map.get(data_parsed, "bluesky-pw")
    author = Map.get(data_parsed, "author")
    Botflow.push_unpublished_messages(author, user, pw)
  end
end
