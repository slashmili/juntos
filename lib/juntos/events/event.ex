defmodule Juntos.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Juntos.{Accounts, Chrono}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field :name, :string
    field :cover_image, :string
    field :start_datetime, :naive_datetime
    field :end_datetime, :naive_datetime
    field :time_zone, :string
    field :description
    field :slug, :string

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
      :start_datetime,
      :end_datetime,
      :time_zone,
      :slug
    ])
    |> validate_inclusion(:time_zone, Chrono.TimeZone.known_timezones())
    |> cast_embed(:location, with: &location_chageset/2)
    |> validate_required([:name, :start_datetime, :end_datetime, :time_zone, :slug])
  end

  defp location_chageset(schema, params) do
    Ecto.Changeset.cast(schema, params, [:id, :name, :address])
  end

  def put_creator(%Ecto.Changeset{} = changeset, %Accounts.User{} = creator) do
    put_assoc(changeset, :creator, creator)
  end
end
