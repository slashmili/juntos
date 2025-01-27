defmodule JuntosWeb.EventLive.NewTest do
  use JuntosWeb.ConnCase, async: true

  setup :register_and_log_in_user

  test "saves new event and redirects to event's page", %{conn: conn} do
    conn
    |> visit("/new")
    |> fill_in("Event name", with: "My Event", exact: false)
    |> fill_in("#event_start_datetime", "Event Date", with: "2020-09-01T01:01", exact: false)
    |> fill_in("#event_end_datetime", "", with: "2020-09-01T01:10")
    |> fill_in("#event_time_zone", "", with: "UTC")
    |> click_button("Create Event")
    |> assert_has("[data-role=event-public-page]", text: "My Event")
  end

  test "renders error when required data is missing", %{conn: conn} do
    conn
    |> visit("/new")
    |> click_button("Create Event")
    |> assert_has("[data-role=error-for-input]", text: "be blank")
  end
end
