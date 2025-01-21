defmodule JuntosWeb.UserExternalAuthController do
  use JuntosWeb, :controller

  alias JuntosWeb.UserAuth
  alias Juntos.Accounts

  def auth_new(conn, %{"provider" => provider}) do
    with {:ok, conn} <- UserAuth.external_auth_redirect(conn, provider) do
      conn
    else
      {:error, :provider_not_supported} ->
        redirect_when_invalid_provider(conn)
    end
  end

  def callback(conn, %{"provider" => provider} = params) do
    case UserAuth.external_auth_user_log_in(conn, provider, params) do
      {:ok, conn} ->
        conn

      {:error, :provider_not_supported} ->
        redirect_when_invalid_provider(conn)

      {:error, _} ->
        redirect_when_error_with_flash(conn, gettext("Something went wrong, try again"))
    end
  end

  def new(conn, _) do
    if external_auth_user = UserAuth.external_auth_user_from_sessions(conn) do
      form = Phoenix.HTML.FormData.to_form(%{}, as: :external_auth_user)
      render(conn, :new, form: form, external_auth_user: external_auth_user)
    else
      redirect_when_error_with_flash(conn, gettext("Something went wrong, try again"))
    end
  end

  def create(conn, _) do
    external_auth_user = UserAuth.external_auth_user_from_sessions(conn)
    {:ok, user} = Accounts.register_user(external_auth_user)
    UserAuth.log_in_user(conn, user)
  end

  defp redirect_when_invalid_provider(conn) do
    redirect_when_error_with_flash(conn, gettext("Invalid Auth provider"))
  end

  defp redirect_when_error_with_flash(conn, error) do
    conn
    |> put_flash(:error, error)
    |> redirect(to: ~p"/users/log_in")
  end
end
