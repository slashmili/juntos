defmodule Junto.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :scope, :string, null: false
      add :start_datetime_utc, :utc_datetime, null: false
      add :end_datetime_utc, :utc_datetime, null: false
      add :time_zone, :string, null: false
      add :description, :string
      add :location, :map

      add :creator_id, references(:users, type: :binary_id, on_delete: :nilify_all), null: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
