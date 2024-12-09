defmodule JuntoWeb.UserAuthControllerTest do
  use JuntoWeb.ConnCase

  test "GET /users/auth/github", %{conn: conn} do
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

  test "GET /users/auth/invalid-provider", %{conn: conn} do
    conn = get(conn, ~p"/users/auth/invalid-provider")
    assert redirected_to(conn, 302) =~ "/users/log_in"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid Auth provider"
  end
end
