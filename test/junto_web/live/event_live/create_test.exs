defmodule JuntoWeb.EventLive.CreateTest do
  use JuntoWeb.ConnCase, async: true

  alias JuntoWeb.EventLive.Create, as: SUT
  import Junto.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    conn = log_in_user(conn, user_fixture())
    {:ok, %{conn: conn}}
  end

  test "renders create-event view", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/create")

    assert lv.module == SUT
    assert is_pid(lv.pid)
    assert has_element?(lv, ~s/[data-role=create-event]/)
  end

  test "renders error when page is submitted with invalid input", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/create")

    lv
    |> form("#createEventForm", create_event_form: %{name: nil, start_date: nil, end_date: nil})
    |> render_submit()

    assert has_element?(lv, "[data-role=error_create_event_form_name]")
    assert has_element?(lv, "[data-role=error_create_event_form_start_date]")
    assert has_element?(lv, "[data-role=error_create_event_form_end_date]")
  end

  test "stores event", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/create")

    params = %{
      name: "Hello 👋"
    }

    {:ok, lv, _html} =
      lv
      |> form("#createEventForm", create_event_form: params)
      |> render_submit()
      |> follow_redirect(conn, ~p"/home")

    assert has_element?(lv, "[data-role=event-card]", params.name)
  end
end
