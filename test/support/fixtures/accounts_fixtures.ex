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

  def fetch_otp_code do
    import Swoosh.TestAssertions
    import ExUnit.Assertions
    test_pid = self()

    assert_email_sent(fn email ->
      otp_pattern = ~r/One-Time-Code:\s*\n\s*(\w+)\s*\n/
      token_pattern = ~r{confirm/([\w-]+)\n\n}

      [[_, otp_code]] = Regex.scan(otp_pattern, email.text_body)

      [[_, otp_token]] = Regex.scan(token_pattern, email.text_body)
      send(test_pid, {:otp_code, otp_code})
      send(test_pid, {:otp_token, otp_token})
    end)

    assert_received({:otp_code, otp_code})
    # assert_received({:otp_token, otp_token})
    otp_code
  end
end
