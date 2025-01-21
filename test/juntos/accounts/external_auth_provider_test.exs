defmodule Juntos.Account.ExternalAuthProviderTest do
  use ExUnit.Case, async: true
  use Mimic.DSL

  import Juntos.AccountsFixtures
  alias Juntos.Accounts.ExternalAuthProvider, as: SUT

  describe "provider_types" do
    test "lists providers" do
      assert SUT.provider_types() == [:google, :github]
    end
  end

  describe "authorize_url/1" do
    test "builds auth_url for github" do
      assert {:ok, %{url: auth_url}} = SUT.authorize_url(:github, redirect_uri_fn())

      assert auth_url =~ "github.com/login"
      assert auth_url =~ "github_client_id"
    end

    test "builds auth_url for google" do
      assert {:ok, %{url: auth_url}} =
               SUT.authorize_url(:google, redirect_uri_fn())

      assert auth_url =~ "accounts.google.com/o/oauth2"
    end
  end

  describe "get_user/1" do
    test "gets user info from github" do
      expected_response = valid_user_extenral_auth_attributes(%{"email" => "user@localhost.com"})

      expect Assent.Strategy.Github.callback(_config, _params) do
        {:ok, %{user: expected_response}}
      end

      assert {:ok,
              %Juntos.Accounts.ExternalAuthProvider.User{
                email: "user@localhost.com",
                sub: "1",
                name: "User",
                email_verified: true,
                picture: "https://avatars.githubusercontent.com/u/1?v=4",
                provider: :github
              }} =
               SUT.user_info(
                 :github,
                 %{"code" => "code", "state" => "foo-state"},
                 "foo-state",
                 redirect_uri_fn()
               )
    end

    test "returns error from github" do
      expect Assent.Strategy.Github.callback(_config, _params) do
        {:error, %Assent.InvalidResponseError{}}
      end

      assert {:error, :invalid_response} =
               SUT.user_info(
                 :github,
                 %{"code" => "code", "state" => "foo-state"},
                 "foo-state",
                 redirect_uri_fn()
               )
    end
  end

  defp redirect_uri_fn do
    fn provider -> "http://localhost/oauth/#{provider}" end
  end
end
