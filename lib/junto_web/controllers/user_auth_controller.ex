defmodule JuntoWeb.UserAuthController do
  use JuntoWeb, :controller

  alias JuntoWeb.UserAuth

  def auth_new(conn, %{"provider" => provider}) do
    with {:ok, conn, url} <- UserAuth.external_auth_request(conn, provider) do
      redirect(conn, external: url)
    else
      {:error, :provider_not_supported} ->
        conn
        |> put_flash(:error, gettext("Invalid Auth provider"))
        |> redirect(to: ~p"/users/log_in")
    end
  end
end
