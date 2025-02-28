defmodule GovRepublish.Workers.BlueskyPostWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    user = Map.get(args, "bluesky-user")
    pw = Map.get(args, "bluesky-pw")
    author = Map.get(args, "author")
    Botflow.push_unpublished_messages(author, user, pw)
  end
end
