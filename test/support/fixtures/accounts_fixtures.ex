defmodule Juntos.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Juntos.Accounts` context.
  """

  alias Juntos.Accounts
  alias Juntos.Repo

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    if attrs[:confirmed_at] do
      user
      |> Accounts.User.confirm_changeset()
      |> Repo.update!()
    else
      user
    end
  end
end
