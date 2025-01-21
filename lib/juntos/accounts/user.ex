defmodule Juntos.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Juntos.Accounts

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :name, :string
    field :confirmed_at, :naive_datetime

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of email Otherwise
  databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour.

  ## Options

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ [])

  def registration_changeset(
        user,
        %Accounts.ExternalAuthProvider.User{} = external_user,
        opts
      ) do
    attrs = Map.from_struct(external_user)

    user
    |> cast(attrs, [:email, :name])
    |> confirm_changeset()
    |> validate_email(opts)
  end

  def registration_changeset(user, attrs, opts) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_email(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Juntos.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end
