defmodule JuntosWeb.EventLive.ShowTest do
  use JuntosWeb.ConnCase, async: true
  import Juntos.EventsFixtures

  setup :register_and_log_in_user

  test "attend to an event and increase attendee count", %{conn: conn} do
    event = event_fixture()

    conn
    |> visit("/#{event.slug}")
    |> assert_has("[data-role=attendee-count]", text: "No attendee")
    |> assert_has("[data-role=register-cta]", text: "Register")
    |> click_button("Register")
    |> assert_has("[data-role=attending-cta]")
    |> assert_has("[data-role=attendee-count]", text: "1 attendee")
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
