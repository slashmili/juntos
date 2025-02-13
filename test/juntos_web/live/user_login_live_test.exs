defmodule JuntosWeb.UserLoginLiveTest do
  use JuntosWeb.ConnCase, async: true

  import Juntos.AccountsFixtures
  alias Juntos.Accounts

  setup %{conn: conn} do
    conn = init_test_session(conn, %{})
    %{conn: conn, user: user_fixture(confirmed_at: DateTime.utc_now())}
  end

  describe "user login" do
    test "enters existing user email and OTP and logs in", %{conn: conn, user: user} do
      conn =
        conn
        |> visit(~p"/users/log_in")
        |> fill_in("Email", with: user.email)
        |> refute_has("#user_otp_code")
        |> submit()

      otp_code = fetch_otp_code()

      conn =
        conn
        |> assert_has("#user_otp_code")
        |> fill_in("OTP Code", with: otp_code)
        |> submit()

      assert token = get_session(conn.conn, :user_token)
      assert logged_in_user = Accounts.get_user_by_session_token(token)
      assert logged_in_user.id == user.id
    end

    test "enters email with invalid OTP", %{conn: conn, user: user} do
      conn =
        conn
        |> visit(~p"/users/log_in")
        |> fill_in("Email", with: user.email)
        |> refute_has("#user_otp_code")
        |> submit()
        |> assert_has("#user_otp_code")
        |> fill_in("OTP Code", with: "012345")
        |> submit()

      refute get_session(conn.conn, :user_token)
    end

    test "enters new email and OTP and logs in", %{conn: conn} do
      new_user_email = unique_user_email()

      conn =
        conn
        |> visit(~p"/users/log_in")
        |> fill_in("Email", with: new_user_email)
        |> refute_has("#user_otp_code")
        |> submit()

      otp_code = fetch_otp_code()

      conn =
        conn
        |> assert_has("#user_otp_code")
        |> fill_in("OTP Code", with: otp_code)
        |> submit()

      assert token = get_session(conn.conn, :user_token)
      assert logged_in_user = Accounts.get_user_by_session_token(token)

      assert logged_in_user.email == new_user_email
      assert logged_in_user.confirmed_at
    end
  end
end
