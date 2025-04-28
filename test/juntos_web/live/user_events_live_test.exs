defmodule JuntosWeb.UserEventsLiveTest do
  use JuntosWeb.ConnCase, async: true
  import Juntos.EventsFixtures

  setup :register_and_log_in_user

  test "redirect to log in when user not logged in" do
    build_conn()
    |> visit("/home")
    |> assert_has("[data-role=login-dialog]")
  end

  test "renders for logged in user with no event", %{conn: conn} do
    conn
    |> visit("/home")
    |> assert_has("[data-role=your-section]", text: "")
    |> assert_has("[data-role=your-section-no-event-hero]", text: "")
  end

  test "renders for logged in user with event", %{conn: conn, user: user} do
    _event = event_fixture(name: "my event!", creator: user)

    conn
    |> visit("/home")
    |> assert_has("[data-role=your-section]", text: "my event!")
    |> assert_has("[data-role=manage-event-button]", text: "Manage")
  end
end
