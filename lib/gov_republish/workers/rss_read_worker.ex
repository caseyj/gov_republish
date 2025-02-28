defmodule GovRepublish.Workers.RssReadWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {:ok, data} = File.read(Map.get(args, "settings_file"))
    {:ok, settings} = Poison.decode(data)
    {:ok, rss_data} = RssClient.get_rss_feed(Map.get(settings, "twitter-endpoint"))
    RssClient.add_records_to_db(rss_data)
  end
end
