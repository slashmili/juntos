defmodule Junto.Accounts.ExternalUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Junto.Accounts.User

  schema "external_users" do
    field :sub, :string
    field :provider, :string
    field :email, :string
    belongs_to :user, User, type: :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(external_user, attrs) do
    external_user
    |> cast(attrs, [:sub, :provider, :email])
    |> validate_required([:sub, :provider, :email])
    |> foreign_key_constraint(:user_id)
  end
end
