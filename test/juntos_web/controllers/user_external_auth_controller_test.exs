defmodule JuntosWeb.UserAuthControllerTest do
  use JuntosWeb.ConnCase, async: false
  use Mimic.DSL
  import Juntos.AccountsFixtures
  alias Juntos.Accounts

  setup %{conn: conn} do
    conn = init_test_session(conn, %{})

    %{conn: conn}
  end

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
               "state" => _
             } = params
    end

    test "redirects with error flash when invalid provider is provided", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/invalid-provider")
      assert redirected_to(conn, 302) =~ "/users/log_in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid Auth provider"
    end
  end

  describe "GET /users/auth/:provider/callback" do
    test "redirects new user to /users/auth/register path", %{conn: conn} do
      expect Assent.Strategy.Github.callback(_config, _params) do
        {:ok, %{user: valid_user_extenral_auth_attributes()}}
      end

      conn = get(conn, ~p"/users/auth/github/callback")
      assert redirected_to(conn, 302) =~ "/users/auth/register"

      assert %{email: _} =
               JuntosWeb.UserAuth.external_auth_user_from_sessions(conn)
    end
  end

  describe "GET /users/auth/register" do
    test "renders form for new external auth users", %{conn: conn} do
      user = user_external_auth_fixture()
      conn = put_session(conn, :external_auth_inflight, Jason.encode!(user))
      conn = get(conn, ~p"/users/auth/register")

      assert html_response(conn, 200) =~ user.name
      assert html_response(conn, 200) =~ user.email
    end

    test "redirects to login page when session is not set", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/register")

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "POST /users/auth/register" do
    test "creates user new user & logs in", %{conn: conn} do
      user = user_external_auth_fixture()

      conn =
        conn
        |> put_session(:external_auth_inflight, Jason.encode!(user))
        |> post(~p"/users/auth/register", %{})

      assert token = get_session(conn, :user_token)
      assert Accounts.get_user_by_session_token(token)
      assert Accounts.get_user_by_email(user.email)
      assert redirected_to(conn) =~ ~p"/"
    end

    test "redirects to login page when session is not set", %{conn: conn} do
      conn = get(conn, ~p"/users/auth/register")

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end
end
