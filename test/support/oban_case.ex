defmodule GovRepublish.ObanCase do
  use ExUnit.CaseTemplate
  use GovRepublish.RepoCase

  using do
    quote do
      use Oban.Testing, repo: GovRepublish.Repo
    end
  end
end
