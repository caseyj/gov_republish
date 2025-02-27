defmodule GovRepublish.CreatedBskyRecord do

  use Ecto.Schema

  schema "created_bsky_record" do
    field :uri, :string
    field :cid, :string
    belongs_to :rss_post, GovRepublish.RssPost
    timestamps()
  end

  def changeset(_created_bsky_record, params \\ %{}) do

    Map.get(params, "rss_post")
    |> Ecto.build_assoc(:bsky_post)
    |> Ecto.Changeset.cast(params, [:uri, :cid])
    |> Ecto.Changeset.validate_required([:uri, :cid])
  end

end
