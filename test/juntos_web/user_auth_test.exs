defmodule JuntosWeb.AuthUserTest do
  use JuntosWeb.ConnCase, async: false
  use Mimic.DSL

  import Juntos.AccountsFixtures

  alias JuntosWeb.UserAuth, as: SUT
  alias Juntos.Accounts

  @remember_me_cookie "_juntos_web_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, JuntosWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "log_in_user/3" do
    test "stores the user token in the session", %{conn: conn, user: user} do
      conn = SUT.log_in_user(conn, user)
      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Accounts.get_user_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, user: user} do
      conn = conn |> put_session(:to_be_removed, "value") |> SUT.log_in_user(user)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, user: user} do
      conn = conn |> put_session(:user_return_to, "/hello") |> SUT.log_in_user(user)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, user: user} do
      conn = conn |> fetch_cookies() |> SUT.log_in_user(user, %{"remember_me" => "true"})
      assert get_session(conn, :user_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 5_184_000
    end
  end

  describe "external_auth_redirect/2" do
    test "stores external auth request in the session", %{conn: conn} do
      {:ok, conn} = SUT.external_auth_redirect(conn, "github")
      assert redirected_to(conn) =~ "github.com"
      assert get_session(conn, :external_auth_state)
    end

    test "returns error with invalid provider", %{conn: conn} do
      assert {:error, :provider_not_supported} = SUT.external_auth_redirect(conn, "foobuz")
    end
  end

  describe "external_auth_user_log_in/3" do
    test "logs in the user when user already exists", %{conn: conn, user: user} do
      expect Assent.Strategy.Github.callback(_config, _params) do
        {:ok, %{user: expected_github_response(user.email)}}
      end

      assert {:ok, conn} = SUT.external_auth_user_log_in(conn, "github", %{})

      assert token = get_session(conn, :user_token)
      assert Accounts.get_user_by_session_token(token)
    end

    test "redirects user to /users/auth/register and set inflight session ", %{
      conn: conn
    } do
      expect Assent.Strategy.Github.callback(_config, _params) do
        {:ok, %{user: expected_github_response("foo@bar.com")}}
      end

      assert {:ok, conn} = SUT.external_auth_user_log_in(conn, "github", %{})

      assert redirected_to(conn) == ~p"/users/auth/register"

      assert get_session(conn, :external_auth_inflight) =~ "foo@bar.com"
    end

    test "returns error when invalid data provided", %{
      conn: conn
    } do
      assert {:error, :provider_not_supported} =
               SUT.external_auth_user_log_in(conn, "foobar", %{})
    end
  end

  def expected_github_response(email) do
    valid_user_extenral_auth_attributes(%{"email" => email})
  end
end
