defmodule GovRepublish.Repo.Migrations.CreateRssPost do
  use Ecto.Migration

  def change do
    create table(:rss_post) do
      add :content, :string, size: 300
      add :author, :string
      add :publish_timestamp, :utc_datetime
      add :post_id, :string
      add :posted, :boolean, default: false

      timestamps()
    end
    create unique_index(:rss_post, [:post_id])
  end
end
