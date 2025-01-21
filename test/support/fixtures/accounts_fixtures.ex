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

  def valid_user_extenral_auth_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      "email" => unique_user_email(),
      "email_verified" => true,
      "name" => "User",
      "picture" => "https://avatars.githubusercontent.com/u/1?v=4",
      "preferred_username" => "username",
      "profile" => "https://github.com/username",
      "sub" => 1
    })
  end

  def user_external_auth_fixture(attrs \\ %{}) do
    provider = attrs[:provider] || attrs["provider"] || :github

    attrs
    |> valid_user_extenral_auth_attributes()
    |> Juntos.Accounts.ExternalAuthProvider.User.new(provider)
  end
end
