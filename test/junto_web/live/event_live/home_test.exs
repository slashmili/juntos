defmodule JuntoWeb.EventLive.HomeTest do
  use JuntoWeb.ConnCase, async: true

  alias JuntoWeb.EventLive.Home, as: SUT
  import Junto.AccountsFixtures
  import Junto.EventsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    {:ok, %{conn: conn, user: user}}
  end

  test "renders home view", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/home")

    assert lv.module == SUT
    assert has_element?(lv, ~s/[data-role=event-home]/)
  end

  test "renders upcoming events by default", %{conn: conn, user: user} do
    create_past_and_future_events(user)

    {:ok, lv, _html} = live(conn, ~p"/home")
    assert has_element?(lv, ~s/[data-role=event-card]/, "upcoming")
    refute has_element?(lv, ~s/[data-role=event-card]/, "past")
  end

  test "renders past/upcoming events when toggle buttons pressed", %{conn: conn, user: user} do
    create_past_and_future_events(user)

    {:ok, lv, _html} = live(conn, ~p"/home")

    assert lv
           |> element("#pastEventSlider")
           |> render_click()

    assert has_element?(lv, ~s/[data-role=event-card]/, "past")
    refute has_element?(lv, ~s/[data-role=event-card]/, "upcoming")

    assert lv
           |> element("#upcommingEventSlider")
           |> render_click()

    assert has_element?(lv, ~s/[data-role=event-card]/, "upcoming")
    refute has_element?(lv, ~s/[data-role=event-card]/, "past")
  end

  defp create_past_and_future_events(creator) do
    event_fixture(
      name: "upcoming",
      creator: creator,
      end_datetime: DateTime.shift(DateTime.utc_now(), %Duration{hour: 1})
    )

    event_fixture(
      name: "past",
      creator: creator,
      end_datetime: DateTime.shift(DateTime.utc_now(), %Duration{hour: -1})
    )

    :ok
  end
end
