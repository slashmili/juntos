defmodule Junto.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Junto.Accounts

  @primary_key {:id, TypeID, autogenerate: true, prefix: "evt", type: :uuid}
  @foreign_key_type TypeID
  schema "events" do
    field :name, :string
    field :scope, Ecto.Enum, values: [:private, :public]
    field :start_datetime_utc, :utc_datetime
    field :end_datetime_utc, :utc_datetime
    field :time_zone, :string
    field :description, :string

    # virtual fields to be filled with time_zone from *_utc fields
    field :start_datetime, :utc_datetime, virtual: true
    field :end_datetime, :utc_datetime, virtual: true

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
      :scope
    ])
    |> cast_datetime(attrs)
    |> cast_embed(:location, with: &location_chageset/2)
    |> validate_required([:name, :scope])
  end

  def cast_datetime(changeset, %{start_datetime: %DateTime{}, end_datetime: %DateTime{}} = attrs) do
    start_datetime = attrs[:start_datetime]
    end_datetime = attrs[:end_datetime]

    time_zone =
      if start_datetime.time_zone == "Etc/UTC" do
        "UTC"
      else
        start_datetime.time_zone
      end

    changeset
    |> put_change(:start_datetime_utc, DateTime.shift_zone!(start_datetime, "Etc/UTC"))
    |> put_change(:end_datetime_utc, DateTime.shift_zone!(end_datetime, "Etc/UTC"))
    |> put_change(:time_zone, time_zone)
  end

  def cast_datetime(changeset, _) do
    changeset
    |> add_error(:end_datetime, "can't be blank", validation: :required)
    |> add_error(:start_datetime, "can't be blank", validation: :required)
  end

  defp location_chageset(schema, params) do
    Ecto.Changeset.cast(schema, params, [:id, :name, :address])
  end

  def put_creator(%Ecto.Changeset{} = changeset, %Accounts.User{} = creator) do
    put_assoc(changeset, :creator, creator)
  end
end
