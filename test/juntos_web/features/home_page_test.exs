defmodule JuntosWeb.HomePageTest do
  use PhoenixTest.Case, async: true
  use JuntosWeb, :verified_routes

  @tag :feature
  test "homepage shows welcome message", %{conn: conn} do
    conn
    |> visit(~p"/")
    |> assert_has("#home", text: "")
  end
end
