defmodule Junto.Accounts.AuthProviderTest do
  use ExUnit.Case, async: true

  alias Junto.Accounts.AuthProvider, as: SUT

  defp redirect_uri_fn do
    fn provider -> "http://localhost/oauth/#{provider}" end
  end

  describe "provider_types/0" do
    test "returns provider types" do
      assert SUT.provider_types() == [:google, :github]
    end
  end

  describe "request/1" do
    test "builds auth_url for github" do
      assert {:ok, %{url: auth_url}} = SUT.request(:github, redirect_uri_fn())

      assert auth_url =~ "github.com/login"
    end

    test "builds auth_url for google" do
      assert {:ok, %{url: auth_url}} =
               SUT.request(:google, redirect_uri_fn())

      assert auth_url =~ "accounts.google.com/o/oauth2"
    end

    test "includes expected redirect_uri" do
      pid = self()

      assert {:ok, _} =
               SUT.request(:google, fn provider ->
                 send(pid, {:redirect_uri, "http://foobar/oauth/#{provider}"})
                 "http://foobar/oauth/#{provider}"
               end)

      assert_receive {:redirect_uri, "http://foobar/oauth/google"}
    end
  end

  describe "callback/1" do
    @tag :skip
    test "calls github" do
      # TODO: figure out a way to test this
      config = [
        redirect_uri: "http://localhost/oauth/github",
        client_id: "github_client_id",
        client_secret: "github_client_secret",
        strategy: Assent.Strategy.Github,
        http_adapter: {Assent.HTTPAdapter.Req, plug: {Req.Test, Assent.HTTPAdapter.Req}}
      ]

      Req.Test.stub(Assent.HTTPAdapter.Req, fn conn ->
        Req.Test.json(conn, %{"celsius" => 25.0})
      end)

      assert SUT.callback(:github, %{"code" => "code"}, %{}, redirect_uri_fn(), config) == %{
               user: %{
                 "email" => "user@localhost.com",
                 "email_verified" => true,
                 "name" => "User",
                 "picture" => "https://avatars.githubusercontent.com/u/1?v=4",
                 "preferred_username" => "username",
                 "profile" => "https://github.com/username",
                 "sub" => 1
               },
               token: %{
                 "access_token" => "Py2",
                 "scope" => "read:user,user:email",
                 "token_type" => "bearer"
               }
             }
    end

    @tag :skip
    test "calls google" do
      # TODO: figure out a way to test this
      assert SUT.callback(:github, %{"code" => "code"}, %{}, redirect_uri_fn()) == %{
               user: %{
                 "email" => "user@gmail.com",
                 "email_verified" => true,
                 "family_name" => "Family",
                 "given_name" => "Giben",
                 "name" => "Giben family_name",
                 "picture" => "https://lh3.googleusercontent.com/a/AliZWw=s96-c",
                 "sub" => "113"
               },
               token: %{
                 "access_token" => "ya29boBQ0175",
                 "expires_in" => 3599,
                 "id_token" => "eyJU3nA",
                 "scope" =>
                   "https://www.googleapis.com/auth/userinfo.email openid https://www.googleapis.com/auth/userinfo.profile",
                 "token_type" => "Bearer"
               }
             }
    end
  end
end
