defmodule GovRepublish.Workers.BlueskyPostWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {is_file, data} = Utils.map_contains_required_keys(args, ["settings_file"])
    if is_file == :ok do
      {:ok, data} = File.read(Map.get(args, "settings_file"))
      {:ok, data_parsed} = Poison.decode(data)
      _confirm_keys(data_parsed)
    else
      _confirm_keys(args)
    end
  end

  def _confirm_keys(data_map) do
    {:ok, data_map} = Utils.map_contains_required_keys(data_map, ["bluesky-handle", "bluesky-pw", "author"])
      _perform_action(data_map)
  end

  def _perform_action(data_parsed) do
    user = Map.get(data_parsed, "bluesky-handle")
    pw = Map.get(data_parsed, "bluesky-pw")
    author = Map.get(data_parsed, "author")
    Botflow.push_unpublished_messages(author, user, pw)
  end

end
