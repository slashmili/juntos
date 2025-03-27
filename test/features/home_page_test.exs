defmodule JuntosWeb.HomePageTest do
  use PhoenixTest.Playwright.Case, async: true
  use JuntosWeb, :verified_routes

  @moduletag :playwright
  @moduletag slow_mo: :timer.seconds(1)

  @tag :feature
  test "homepage shows welcome message", %{conn: conn} do
    conn
    |> visit(~p"/users/log_in")
    |> fill_in("Email", with: "foo-otp@example.com")
    |> submit()
    |> fill_in("OTP Code", with: "123456")
    # TODO: how to get the otp code!
    |> submit()
    |> assert_has("#flash-info", text: "Welcome")
  end
end
