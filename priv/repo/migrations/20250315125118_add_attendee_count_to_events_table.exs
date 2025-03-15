defmodule Juntos.Repo.Migrations.AddAttendeeCountToEventsTable do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :attendee_count, :integer, default: 0
    end
  end
end
