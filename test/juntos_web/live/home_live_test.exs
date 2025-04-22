defmodule JuntosWeb.HomeLiveTest do
  use JuntosWeb.ConnCase, async: true
  import Juntos.EventsFixtures

  setup :register_and_log_in_user

  test "doesn't render events section when there is no event", %{conn: conn} do
    conn
    |> visit("/")
    |> refute_has("[data-role=your-section]", text: "")
    |> refute_has("[data-role=future-section]", text: "")
  end

  test "renders 3 last future events", %{conn: conn} do
    event_dt = NaiveDateTime.utc_now()

    Enum.each(1..5, fn index ->
      event_fixture(
        name: "Event #{index}",
        start_datetime: NaiveDateTime.shift(event_dt, hour: index),
        end_datetime: NaiveDateTime.shift(event_dt, hour: index)
      )
    end)

    conn
    |> visit("/")
    |> refute_has("[data-role=future-section]", text: "Event 1")
    |> refute_has("[data-role=future-section]", text: "Event 2")
    |> assert_has("[data-role=future-section]", text: "Event 3")
    |> assert_has("[data-role=future-section]", text: "Event 4")
    |> assert_has("[data-role=future-section]", text: "Event 5")
    |> assert_has("[data-role=future-section] [data-role=view-more-events]", text: "View all")
  end

  test "renders only one future events without view all button", %{conn: conn} do
    event_dt = ~N[3020-04-22 17:24:56.297156]

    _event =
      event_fixture(name: "future event!", start_datetime: event_dt, end_datetime: event_dt)

    conn
    |> visit("/")
    |> assert_has("[data-role=future-section]", text: "future event!")
    |> refute_has("[data-role=future-section] [data-role=view-more-events]", text: "View all")
  end

  test "renders 3 last user created events", %{conn: conn, user: user} do
    event_dt = ~N[3020-04-22 17:24:56.297156]

    Enum.map(1..5, fn index ->
      event_fixture(
        creator: user,
        name: "Event #{index}",
        start_datetime: NaiveDateTime.shift(event_dt, hour: index),
        end_datetime: NaiveDateTime.shift(event_dt, hour: index)
      )
    end)

    conn
    |> visit("/")
    |> refute_has("[data-role=your-section]", text: "Event 1")
    |> refute_has("[data-role=your-section]", text: "Event 2")
    |> assert_has("[data-role=your-section]", text: "Event 3")
    |> assert_has("[data-role=your-section]", text: "Event 4")
    |> assert_has("[data-role=your-section]", text: "Event 5")
    |> assert_has("[data-role=your-section] [data-role=view-more-events]", text: "View all")
  end

  test "renders only one user events without view all button", %{conn: conn, user: user} do
    _event = event_fixture(name: "my event!", creator: user)

    conn
    |> visit("/")
    |> assert_has("[data-role=your-section]", text: "my event!")
    |> refute_has("[data-role=your-section] [data-role=view-more-events]", text: "View all")
  end
end
