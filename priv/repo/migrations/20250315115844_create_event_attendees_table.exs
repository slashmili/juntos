defmodule Juntos.Repo.Migrations.CreateEventAttendeesTable do
  use Ecto.Migration

  def change do
    create table(:event_attendees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:event_attendees, [:event_id, :user_id])
  end
end
