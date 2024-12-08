defmodule Junto.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Junto.Accounts

  @primary_key {:id, TypeID, autogenerate: true, prefix: "evt", type: :uuid}
  @foreign_key_type TypeID
  schema "events" do
    field :name, :string
    field :scope, Ecto.Enum, values: [:private, :public]
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :timezone, :string
    field :description, :string

    embeds_one :location, Location, primary_key: false, on_replace: :delete do
      field :id, :string
      field :name, :string
      field :address, :string
    end

    belongs_to :creator, Accounts.User, type: :binary_id
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [
      :name,
      :description,
      :scope,
      :start_datetime,
      :end_datetime,
      :timezone
    ])
    |> cast_embed(:location, with: &location_chageset/2)
    |> validate_required([:name, :scope, :start_datetime, :end_datetime, :timezone])
  end

  defp location_chageset(schema, params) do
    Ecto.Changeset.cast(schema, params, [:id, :name, :address])
  end

  def put_creator(%Ecto.Changeset{} = changeset, %Accounts.User{} = creator) do
    put_assoc(changeset, :creator, creator)
  end
end
