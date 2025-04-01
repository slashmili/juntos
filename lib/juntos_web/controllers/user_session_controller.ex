defmodule JuntosWeb.UserSessionController do
  use JuntosWeb, :controller

  alias Juntos.Accounts
  alias JuntosWeb.UserAuth

  def create(conn, params) do
    %{"email" => email, "otp_token" => otp_token} = params["user"]
    user = Accounts.get_user_by_email(email)

    {:ok, _user_token} = Accounts.validate_user_with_otp(user, otp_token)

    conn
    |> put_flash(:info, "Welcome!")
    |> UserAuth.log_in_user(user)
  end

  def log_in_redirect_back_to(conn, params) do
    conn
    |> put_flash(:error, "You must log in to access this page.")
    |> put_session(:user_return_to, ~p"/#{params["event_slug"]}")
    |> redirect(to: ~p"/users/log_in")
    |> halt()
  end
end
