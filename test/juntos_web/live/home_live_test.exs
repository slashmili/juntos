defmodule JuntosWeb.HomeLiveTest do
  use JuntosWeb.ConnCase, async: true
  import Juntos.EventsFixtures

  setup :register_and_log_in_user

  test "renders for guest user with no event" do
    build_conn()
    |> visit("/")
    |> refute_has("[data-role=your-section]", text: "")
    |> assert_has("[data-role=future-section]", text: "")
    |> assert_has("[data-role=future-section-no-event-hero]", text: "")
  end

  test "renders for logged in user with no event", %{conn: conn} do
    conn
    |> visit("/")
    |> refute_has("[data-role=your-section]", text: "")
    |> assert_has("[data-role=future-section]", text: "")
    |> assert_has("[data-role=future-section-no-event-hero]", text: "")
  end

  test "renders latest future events", %{conn: conn} do
    event_dt = NaiveDateTime.utc_now()

    Enum.each([-1, 1, 2, 3], fn index ->
      event_fixture(
        name: "Event #{index}",
        start_datetime: NaiveDateTime.shift(event_dt, hour: index),
        end_datetime: NaiveDateTime.shift(event_dt, hour: index)
      )
    end)

    conn
    |> visit("/")
    |> refute_has("[data-role=future-section]", text: "Event -1")
    |> assert_has("[data-role=future-section]", text: "Event 1")
    |> assert_has("[data-role=future-section]", text: "Event 2")
    |> assert_has("[data-role=future-section]", text: "Event 3")
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

  test "renders manage button when user has access", %{conn: conn, user: user} do
    event_fixture(
      creator: user,
      name: "My Event"
    )

    conn
    |> visit("/")
    |> assert_has("[data-role=your-section]", text: "My Event")
    |> assert_has("[data-role=manage-event-button]", text: "Manage")
  end

  test "renders without manage button when user doesn't have access", %{conn: conn} do
    event_dt = ~N[3020-04-22 17:24:56.297156]

    event_fixture(
      name: "Other Event",
      start_datetime: event_dt,
      end_datetime: event_dt
    )

    conn
    |> visit("/")
    |> assert_has("[data-role=future-section]", text: "Other Event")
    |> refute_has("[data-role=manage-event-button]", text: "Manage")
  end

  test "renders past event label", %{conn: conn, user: user} do
    event_fixture(
      creator: user,
      name: "PAST EVENT"
    )

    conn
    |> visit("/")
    |> assert_has("[data-role=your-section]", text: "PAST EVENT")
    |> assert_has("[data-role=past-event-label]")
  end
end
