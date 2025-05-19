defmodule JuntosWeb.EventLive.EditTest do
  use JuntosWeb.ConnCase, async: true
  import Juntos.EventsFixtures

  setup :register_and_log_in_user

  test "redirects to log in page when user is not logged in", %{} do
    event = event_fixture()

    build_conn()
    |> visit(~p"/events/#{event}/edit")
    |> assert_path(~p"/users/log_in")
  end

  test "redirects / when user doesn't have access to edit an event", %{conn: conn} do
    event = event_fixture()

    conn
    |> visit(~p"/events/#{event}/edit")
    |> assert_has("#flash-group", text: "Event not found")
    |> assert_path(~p"/")
  end

  test "renders edit form when user has access", %{conn: conn, user: user} do
    event = event_fixture(creator: user)

    conn
    |> visit(~p"/events/#{event}/edit")
    |> assert_has("[data-role=edit-event-page]")
  end
end
