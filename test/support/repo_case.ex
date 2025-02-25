defmodule GovRepublish.RepoCase do
  @moduledoc """
  Helper module for testing database interactions

  see: https://hexdocs.pm/ecto/testing-with-ecto.html
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias GovRepublish.Repo

      import Ecto
      import Ecto.Query
      import GovRepublish.RepoCase

    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(GovRepublish.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end
end
