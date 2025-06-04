defmodule Workers.BlueskyPostWorkerTest do
  import Mock
  use GovRepublish.ObanCase

  test "Show BluskyPostWorker works" do
    with_mock File,
      read: fn _a ->
        {:ok,
         "{\"author\": \"@JCParking\",\"bluesky-user\": \"email\",\"bluesky-handle\": \"hello\",\"bluesky-pw\": \"hello\"}"}
      end do
      with_mock Botflow,
        push_unpublished_messages: fn _a, _b, _c -> {:ok, []} end do
        {status, _data} =
          perform_job(GovRepublish.Workers.BlueskyPostWorker, %{
            "settings_file" => "config/secrets/jcparking_bot.json"
          })

        assert status == :ok
      end
    end
  end
end
