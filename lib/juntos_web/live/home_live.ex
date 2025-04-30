defmodule JuntosWeb.HomeLive do
  use JuntosWeb, :live_view

  alias Juntos.Events
  @limit 5
  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        user_events: maybe_load_user_events(socket.assigns.current_scope),
        offset: 0,
        limit: @limit,
        page_title: gettext("Home")
      )

    {:ok, stream_more_events(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.page_wrapper>
        <.home_page>
          <.hero_section />
          <.events_list
            :if={@user_events != []}
            events={@user_events}
            title={gettext "My Events"}
            data-role="your-section"
            current_scope={@current_scope}
          />
          <.events_future_list
            current_scope={@current_scope}
            events={@streams.future_events}
            title={gettext "Future Events"}
            data-role="future-section"
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

  defp stream_more_events(%{assigns: %{more_events_available?: false}} = socket) do
    socket
  end

  defp stream_more_events(%{assigns: %{offset: offset, limit: limit}} = socket) do
    events =
      Events.list_future_events([
        Events.query_events_limit(limit),
        Events.query_events_offset(offset)
      ])

    offset = offset + limit

    assign(socket, offset: offset, more_events_available?: length(events) > 0)
    |> stream(:future_events, events)
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

  defp hero_section(assigns) do
    ~H"""
    <div class="md:text-center">
      <.hero align="left">
        {gettext "Let’s get together."}
        <:subtitle>
          Discover conferences and events that fit your passion, online or in-person.
        </:subtitle>
      </.hero>
    </div>
    """
  end

  defp events_list(assigns) do
    ~H"""
    <.event_title_bar title={@title} />
    <div class="flex flex-col justify-start gap-2" data-role={assigns[:"data-role"]}>
      <JuntosWeb.EventLive.Components.list_event_card
        :for={event <- Enum.take(@events, 3)}
        event={event}
        manage_event?={manage_event?(event, @current_scope)}
        past_event?={past_event?(event)}
      />
      <div
        :if={length(@events) > 3}
        class="flex w-full min-w-2xs max-w-3xl px-3 p-3 place-self-center justify-end items-center gap-1"
      >
        <.button
          variant="tertiary"
          type="link"
          size="md"
          icon_right="material_arrow_forward"
          data-role="view-more-events"
          href={~p"/home"}
        >
          {gettext "View all"}
        </.button>
      </div>
    </div>
    """
  end

  defp events_future_list(assigns) do
    ~H"""
    <.event_title_bar title={@title} />
    <div
      class="flex flex-col justify-start gap-2 [&>*:only-child]:flex"
      data-role={assigns[:"data-role"]}
      id="eventsFutureScrollBody"
      phx-update="stream"
      phx-viewport-bottom="load-more-future-events"
    >
      <JuntosWeb.EventLive.Components.list_event_card
        :for={{id, event} <- @events}
        id={id}
        event={event}
        manage_event?={manage_event?(event, @current_scope)}
        past_event?={past_event?(event)}
      />
      <div
        class="hidden w-full min-w-2xs max-w-3xl px-3 place-self-center"
        id="eventsFutureEmptyHero"
        data-role="future-section-no-event-hero"
      >
        <.hero>
          {gettext "There is no future events."}
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
    </div>
    """
  end

  def event_title_bar(assigns) do
    ~H"""
    <div class="md:place-self-center md:min-w-3xl">
      <div class="flex gap-2 items-center md:max-w-3xl w-full">
        <.icon name="material_rocket_launch" class="icon-size-4" />
        <div class="font-bold">{@title}</div>

        <div style="flex: 1 0 0 " class="grow bg-(--color-border-neutral-primary) h-[2px] "></div>
      </div>
    </div>
    """
  end

  defp maybe_load_user_events(%{user: user}) do
    Events.list_user_events(user)
  end

  defp maybe_load_user_events(_) do
    []
  end

  defp manage_event?(_, nil) do
    false
  end

  defp manage_event?(event, %{user: user}) do
    event.creator_id == user.id
  end

  defp past_event?(event) do
    NaiveDateTime.after?(NaiveDateTime.utc_now(), event.end_datetime)
  end
end
