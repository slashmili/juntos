defmodule JuntosWeb.UserEventsLive do
  use JuntosWeb, :live_view
  alias Juntos.Events
  @limit 20
  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        offset: 0,
        limit: @limit,
        page_title: gettext("My Events")
      )

    if socket.assigns.current_user do
      {:ok, stream_more_events(socket)}
    else
      {:ok, redirect(socket, to: ~p"/users/log_in")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.page_wrapper>
        <.home_page>
          <.events_list
            events={@streams.user_events}
            title={gettext "Your events"}
            data-role="your-section"
            current_user={@current_user}
            more_events_available?={@more_events_available?}
          />
        </.home_page>
      </.page_wrapper>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("load-more-future-events", _, socket) do
    {:noreply, stream_more_events(socket)}
  end

  def home_page(assigns) do
    ~H"""
    <div
      data-role="home-page"
      class="flex flex-col max-w-3xl md:max-w-5xl w-full px-4 gap-6 justify-center"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp events_list(assigns) do
    ~H"""
    <JuntosWeb.HomeLive.event_title_bar title={@title} />
    <div
      class="flex flex-col justify-start gap-2 [&>*:only-child]:flex"
      data-role={assigns[:"data-role"]}
      id="eventsScrollBody"
      phx-update="stream"
      phx-viewport-bottom="load-more-future-events"
    >
      <JuntosWeb.HomeLive.event_card
        :for={{id, event} <- @events}
        id={id}
        event={event}
        manage_event?={manage_event?(event, @current_user)}
        past_event?={past_event?(event)}
      />
      <.no_event_hero />
    </div>
    """
  end

  defp no_event_hero(assigns) do
    ~H"""
    <div
      class="hidden w-full min-w-2xs max-w-3xl px-3 place-self-center"
      id="eventsEmptyHero"
      data-role="your-section-no-event-hero"
    >
      <.hero>
        {gettext "You haven’t joined or created any events yet."}
        <:subtitle>
          {gettext "Discover something that inspires you or be the spark that brings people together.
          It only takes a few steps to get started."}
        </:subtitle>
        <:body>
          <div class="flex justify-center">
            <.button href={~p"/new"} type="link" size="md" variant="primary">
              {gettext "Create an event"}
            </.button>
          </div>
        </:body>
      </.hero>
    </div>
    """
  end

  defp stream_more_events(%{assigns: %{more_events_available?: false}} = socket) do
    socket
  end

  defp stream_more_events(%{assigns: %{offset: offset, limit: limit}} = socket) do
    events =
      Events.list_user_events(
        socket.assigns.current_user,
        [
          Events.query_events_limit(limit),
          Events.query_events_offset(offset)
        ]
      )

    offset = offset + limit

    socket
    |> assign(offset: offset, more_events_available?: length(events) > 0)
    |> stream(:user_events, events)
  end

  defp manage_event?(_, nil) do
    false
  end

  defp manage_event?(event, user) do
    event.creator_id == user.id
  end

  defp past_event?(event) do
    NaiveDateTime.after?(NaiveDateTime.utc_now(), event.end_datetime)
  end
end
