defmodule Goatmire.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :s3_key, :string
      add :thumbnail_key, :string
      add :dithered_key, :string
      add :alt_text, :string
      add :accept_terms, :boolean, default: false, null: false
      add :approved_at, :utc_datetime
      add :rejected_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:images, :s3_key)
  end
end
