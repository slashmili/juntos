defmodule Juntos.Repo.Migrations.CreateSlugs do
  use Ecto.Migration

  def change do
    create table(:slugs) do
      add :slug, :string, null: false
      add :resource, :string, null: false
      add :resource_id, :uuid, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:slugs, :slug)
  end
end
