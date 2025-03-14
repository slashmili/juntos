defmodule Juntos.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :cover_image, :string
      add :start_datetime, :naive_datetime, null: false
      add :end_datetime, :naive_datetime, null: false
      add :time_zone, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :location, :map

      add :creator_id, references(:users, type: :binary_id, on_delete: :nilify_all), null: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
