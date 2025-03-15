defmodule Juntos.Events.Event do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed

  alias Juntos.{Accounts, Chrono, Events}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "events" do
    field :name, :string
    field :cover_image, Events.Uploaders.CoverImage.Type
    field :start_datetime, :naive_datetime
    field :end_datetime, :naive_datetime
    field :time_zone, :string, default: "UTC"
    field :description, :string, default: ""
    field :description_editor, :string, virtual: true
    field :slug, :string
    field :attendee_count, :integer, default: 0

    polymorphic_embeds_one :location,
      types: [
        place: Juntos.Events.Event.Place,
        url: Juntos.Events.Event.Url,
        address: Juntos.Events.Event.Address
      ],
      on_type_not_found: :raise,
      on_replace: :update

    belongs_to :creator, Accounts.User, type: :binary_id
    timestamps type: :utc_datetime_usec
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
    |> cast_attachments(attrs, [:cover_image], allow_paths: true)
    |> validate_inclusion(:time_zone, Chrono.TimeZone.known_timezones())
    |> cast_polymorphic_embed(:location,
      request: true
    )
    |> validate_required([:name, :start_datetime, :end_datetime, :time_zone, :slug])
  end

  def put_creator(%Ecto.Changeset{} = changeset, %Accounts.User{} = creator) do
    put_assoc(changeset, :creator, creator)
  end
end

defmodule Juntos.Events.Event.Place do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :string
    field :name, :string
    field :address, :string
  end

  def changeset(place, params) do
    cast(place, params, [:id, :name, :address])
  end
end

defmodule Juntos.Events.Event.Url do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :link, :string
  end

  def changeset(place, params) do
    cast(place, params, [:link])
  end
end

defmodule Juntos.Events.Event.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :address, :string
  end

  def changeset(place, params) do
    cast(place, params, [:address])
  end
end
