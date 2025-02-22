defmodule GovRepublish.Repo.Migrations.CreateRssPost do
  use Ecto.Migration

  def change do
    create table(:rss_post) do
      add :content, :string
      add :author, :string
      add :publish_timestamp,  :utc_datetime
      add :post_id, :string
    end
  end
end
