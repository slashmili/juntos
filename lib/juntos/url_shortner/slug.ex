defmodule Juntos.UrlShortner.Slug do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "slugs" do
    field :slug, :string
    field :resource, :string
    field :resource_id, Ecto.UUID

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(slug, attrs) do
    slug
    |> cast(attrs, [:id, :slug, :resource, :resource_id])
    |> validate_required([:id, :slug, :resource, :resource_id])
  end
end
