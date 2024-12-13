defmodule JuntoWeb.UserAuthController do
  use JuntoWeb, :controller

  alias JuntoWeb.UserAuth

  def auth_new(conn, %{"provider" => provider}) do
    with {:ok, conn, url} <- UserAuth.external_auth_request(conn, provider) do
      redirect(conn, external: url)
    else
      {:error, :provider_not_supported} ->
        redirect_when_invalid_provider(conn)
    end
  end

  def callback(conn, %{"provider" => provider} = params) do
    case UserAuth.external_auth_callback(provider, params) do
      {:ok, external_user} ->
        case UserAuth.attempt_to_log_in_external_user(conn, external_user) do
          {:ok, conn} ->
            conn

          {:error, :no_user_found} ->
            conn
            |> UserAuth.external_user_set_sessions(external_user)
            |> redirect(to: ~p"/users/auth/register")
        end

      {:error, :faild_to_get_user} ->
        redirect_when_error_with_flash(conn, gettext("Something went wrong, try again"))

      {:error, :provider_not_supported} ->
        redirect_when_invalid_provider(conn)
    end
  end

  def new(conn, _) do
    if external_user = UserAuth.external_user_from_sessions(conn) do
      case UserAuth.attempt_to_log_in_external_user(conn, external_user) do
        {:ok, conn} ->
          conn

        _ ->
          form = Phoenix.HTML.FormData.to_form(%{}, as: :external_user)
          render(conn, :new, form: form, external_user: external_user)
      end
    else
      redirect_when_error_with_flash(conn, gettext("Something went wrong, try again"))
    end
  end

  def create(conn, _parmas) do
    with external_user when not is_nil(external_user) <-
           UserAuth.external_user_from_sessions(conn),
         {:ok, user} <- Junto.Accounts.create_user_by_external_auth_user(external_user) do
      UserAuth.log_in_user(conn, user)
    else
      _ ->
        redirect_when_error_with_flash(conn, gettext("Something went wrong, try again"))
    end
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
