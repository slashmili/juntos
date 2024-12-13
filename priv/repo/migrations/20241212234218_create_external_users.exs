defmodule Junto.Repo.Migrations.CreateExternalUsers do
  use Ecto.Migration

  def change do
    create table(:external_users) do
      add :sub, :string, null: false
      add :provider, :string, null: false
      add :email, :string, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:external_users, [:user_id])

    create unique_index(:external_users, [:sub, :provider])
  end
end
