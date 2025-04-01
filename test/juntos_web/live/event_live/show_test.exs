defmodule JuntosWeb.EventLive.ShowTest do
  use JuntosWeb.ConnCase, async: true
  import Juntos.EventsFixtures

  setup :register_and_log_in_user

  test "redirects user to log in page if user is not loggedd in " do
    conn = Phoenix.ConnTest.build_conn()
    event = event_fixture()

    conn
    |> visit("/#{event.slug}")
    |> click_button("Register")
    |> assert_has("[data-role=login-dialog]")
  end

  test "attends to an event and increase attendee count", %{conn: conn} do
    event = event_fixture()

    conn
    |> visit("/#{event.slug}")
    |> assert_has("[data-role=attendee-count]", text: "No attendee")
    |> assert_has("[data-role=register-cta]", text: "Register")
    |> click_button("Register")
    |> assert_has("#flash-success", text: "You’re in!")
    |> assert_has("[data-role=attending-cta]")
    |> assert_has("[data-role=attendee-count]", text: "1 attendee")
  end

  test "parses datetime in header", %{conn: conn} do
    event =
      event_fixture(
        start_datetime: ~N[3045-03-25 17:01:54.410367],
        end_datetime: ~N[3045-03-25 20:08:54.410367]
      )

    conn
    |> visit("/#{event.slug}")
    |> assert_has("[data-role=datetime-in-header]", text: "Tue 25. Mar")
    |> assert_has("[data-role=datetime-in-header]", text: "17:01")
    |> assert_has("[data-role=datetime-in-header]", text: "20:08")
  end

  test "parses datetime in ticket", %{conn: conn, user: user} do
    event =
      event_fixture(
        start_datetime: ~N[4025-03-01 17:01:54.410367],
        end_datetime: ~N[4025-03-01 20:08:54.410367]
      )

    Juntos.Events.add_event_attendee(event, user)

    conn
    |> visit("/#{event.slug}")
    |> click_button("View ticket")
    |> assert_has("[data-role=event-ticket-datetime]", text: "Sat 01. Mar")
    |> assert_has("[data-role=event-ticket-datetime]", text: "17:01")
    |> assert_has("[data-role=event-ticket-datetime]", text: "20:08")
  end

  setup [:create_event, :attend_to_event]

  test "renders attendee count and attending footer", %{conn: conn, event: event} do
    conn
    |> visit("/#{event.slug}")
    |> assert_has("[data-role=attendee-count]", text: "1 attendee")
    |> assert_has("[data-role=attending-cta]")
  end

  setup [:create_event, :attend_to_event]

  test "cancels a sport from an event", %{conn: conn, event: event} do
    conn
    |> visit("/#{event.slug}")
    |> click_link("Cancel registertion")
    |> click_button("Confirm cancellation")
    |> assert_has("[data-role=attendee-count]", text: "No attendee")
    |> assert_has("[data-role=register-cta]", text: "Register")
    |> assert_has("#flash-success", text: "Your registration has been canceled.")
  end

  test "doesn't confirm event cancellation", %{conn: conn, event: event} do
    conn
    |> visit("/#{event.slug}")
    |> click_link("Cancel registertion")
    |> click_button("Keep my spot")
    |> assert_has("[data-role=attending-cta]")
  end

  def create_event(_) do
    event = event_fixture()
    {:ok, %{event: event}}
  end

  def attend_to_event(%{event: event, user: user}) do
    Juntos.Events.add_event_attendee(event, user)
    :ok
  end
end
