defmodule Workers.RssReadWorkerTest do
  import Mock
  use GovRepublish.ObanCase

  test "Show RSS Read works" do
    with_mock File,
      read: fn _a -> {:ok, "{\"twitter-endpoint\": \"0.0.0.0:8080/JCParking/rss\"}"} end do
      with_mock RssClient,
        get_rss_feed: fn _data -> {:ok, %{}} end,
        add_records_to_db: fn _b -> {:ok, []} end do
        {status, _user} =
          perform_job(GovRepublish.Workers.RssReadWorker, %{
            "settings_file" => "config/secrets/jcparking_bot.json"
          })

        assert status == :ok
      end
    end
  end
end
