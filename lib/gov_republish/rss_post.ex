defmodule GovRepublish.RssPost do
  use Ecto.Schema

  schema "rss_post" do
    field(:content, :string)
    field(:author, :string)
    field(:publish_timestamp, :utc_datetime)
    field(:post_id, :string)
    field(:posted, :boolean, default: false)
    has_one(:bsky_post, GovRepublish.CreatedBskyRecord)
    timestamps()
  end

  def changeset(rss_post, params \\ %{}) do
    rss_post
    |> Ecto.Changeset.cast(params, [:content, :author, :publish_timestamp, :post_id])
    |> Ecto.Changeset.validate_required([:content, :author, :publish_timestamp])
  end
end
