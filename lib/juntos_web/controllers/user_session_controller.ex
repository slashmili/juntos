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
end
