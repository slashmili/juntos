defmodule JuntoWeb.UserAuthControllerTest do
  use JuntoWeb.ConnCase, async: false

  alias Junto.Accounts
  import Mox
  import Junto.AccountsFixtures

  describe "GET /users/auth/:provider" do
    test "redirects when provider is configured and provided", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/github")
      assert redirect_to_url = redirected_to(conn, 302)
      assert redirect_to_url =~ "https://github.com"

      uri = URI.parse(redirect_to_url)
      params = uri.query |> URI.query_decoder() |> Enum.to_list() |> Map.new()

      assert %{
               "client_id" => "github_client_id",
               "redirect_uri" => "http://localhost:4002/users/auth/github/callback",
               "response_type" => "code",
               "scope" => "read:user,user:email",
               "state" => state
             } = params

      assert get_session(conn, :auth_initiated) == state
    end

    test "redirects with error flash when invalid provider is provided", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/invalid-provider")
      assert redirected_to(conn, 302) =~ "/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid Auth provider"
    end
  end

  describe "GET /users/auth/:provider/callback" do
    test "redirects user to /users/auth/register path", %{conn: conn} do
      Junto.Accounts.AuthProvider.Mock
      |> expect(:callback, fn :github, _params, _session_params, _redirect_uri_fn ->
        {:ok, external_auth_user_github()}
      end)

      conn = get(conn, ~p"/users/auth/github/callback")
      assert redirected_to(conn, 302) =~ "/users/auth/register"
      assert JuntoWeb.UserAuth.external_user_from_sessions(conn)
    end

    test "redirects with error flash when invalid provider is provided", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/invalid-provider/callback")
      assert redirected_to(conn, 302) =~ "/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid Auth provider"
    end

    test "logs in user when a user with same email exists", %{conn: conn} do
      user = user_fixture()
      external_auth_user = external_auth_user_github(%{"email" => user.email})

      Junto.Accounts.AuthProvider.Mock
      |> expect(:callback, fn :github, _params, _session_params, _redirect_uri_fn ->
        {:ok, external_auth_user}
      end)

      conn = get(conn, ~p"/users/auth/github/callback")
      assert token = get_session(conn, :user_token)
      assert Accounts.get_user_by_session_token(token)
    end
  end

  describe "GET /users/auth/register" do
    test "redirects user to /users/log_in when session not set", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/register")
      assert redirected_to(conn, 302) =~ "users/log_in"
    end

    test "renders confirmation form", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, %{})
      external_auth_user = external_auth_user_fixture()

      conn =
        JuntoWeb.UserAuth.external_user_set_sessions(conn, external_auth_user)

      conn = get(conn, ~p"/users/auth/register")
      assert html_response(conn, 200) =~ external_auth_user.email
    end

    test "logs in user when user exists", %{conn: conn} do
      user = user_fixture()

      external_auth_user = external_auth_user_fixture(%{"email" => user.email})

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> JuntoWeb.UserAuth.external_user_set_sessions(external_auth_user)
        |> get(~p"/users/auth/register")

      assert token = get_session(conn, :user_token)
      assert Accounts.get_user_by_session_token(token)
    end
  end
end
