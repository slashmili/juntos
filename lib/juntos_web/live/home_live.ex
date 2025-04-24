defmodule JuntosWeb.HomeLive do
  use JuntosWeb, :live_view

  alias Juntos.Events
  @limit 5
  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        user_events: maybe_load_user_events(socket.assigns.current_user),
        offset: 0,
        limit: @limit,
        page_title: gettext("Home")
      )

    {:ok, stream_more_events(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.page_wrapper>
        <.home_page>
          <.hero_section />
          <.events_list
            :if={@user_events != []}
            events={@user_events}
            title={gettext "Your events"}
            data-role="your-section"
            current_user={@current_user}
          />
          <.events_future_list
            current_user={@current_user}
            events={@streams.future_events}
            title={gettext "Future events"}
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
      <.event_card
        :for={event <- Enum.take(@events, 3)}
        event={event}
        manage_event?={manage_event?(event, @current_user)}
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
      <.event_card
        :for={{id, event} <- @events}
        id={id}
        event={event}
        manage_event?={manage_event?(event, @current_user)}
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
    <div
      :if={@more_events_available?}
      class="flex w-full min-w-2xs max-w-3xl place-self-center mx-auto text-sm "
      id="load-more-future-events-bottom"
    >
      <.icon name="material_refresh" class="icon-size-6 animate-spin" /> {gettext "Loading more events..."}
    </div>
    """
  end

  attr :id, :string, required: false, default: nil
  attr :event, :any, required: true
  attr :past_event?, :boolean, required: false, default: false
  attr :manage_event?, :boolean, required: false, default: false

  defp event_card(assigns) do
    ~H"""
    <.link navigate={~p"/#{@event.slug}"} id={@id}>
      <div class="flex w-full min-w-2xs max-w-3xl rounded-2xl border-1 border-(--color-border-neutral-primary) bg-(--color-bg-neutral-primary)/50 backdrop-blur-lg shadow-xl dark:shadow-slate-100/1 shadow-slate-900/4 px-3 place-self-center  hover:border-(--color-border-neutral-secondary)/50 animated cursor-pointer">
        <div class="py-3  pr-1 flex-shrink-0">
          <.event_cover_image cover_image={Events.event_cover_url(@event)} />
        </div>
        <div class="grow flex flex-col pl-1  py-3">
          <div class="flex [&>*:first-child]:grow">
            <.event_card_schedule event={@event} past_event?={@past_event?} />
            <div class=" flex-shrink-0">
              <.event_manage_button
                :if={@manage_event?}
                manage_event?={@manage_event?}
                past_event?={@past_event?}
              />
            </div>
          </div>
          <div class="grow font-bold text-base  flex flex flex-col justify-center">
            <.link navigate={~p"/#{@event.slug}"}>
              {@event.name}
            </.link>
          </div>
          <div class="flex">
            <div class="grow flex items-center text-sm gap-1">
              <.icon name="material_location_on" class="icon-size-4" /> Berlin, Germany
            </div>
            <.event_past_label :if={@past_event?} />
          </div>
        </div>
      </div>
    </.link>
    """
  end

  defp event_title_bar(assigns) do
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

  defp event_manage_button(assigns) do
    ~H"""
    <div data-role="manage-event-button">
      <.button
        href="mange/event"
        type="link"
        size="sm"
        variant={(@past_event? && "outline") || "secondary"}
      >
        {gettext "Manage"}
      </.button>
    </div>
    """
  end

  defp event_past_label(assigns) do
    ~H"""
    <div class="flex-shrink-0" data-role="past-event-label">
      <div class="py-1 px-2 rounded-full border border-(--color-border-neutral-primary) bg-(--color-bg-neutral-secondary) text-xs font-medium">
        Past event
      </div>
    </div>
    """
  end

  defp event_card_schedule(assigns) do
    ~H"""
    <div class="grow text-sm flex items-center gap-1">
      <.icon
        name="material_date_range"
        class={[
          "icon-size-4 bg-(--color-bg-accent-brand-muted) rounded-full p-0.5",
          @past_event? == true && "bg-(--color-bg-status-disabled)"
        ]}
      /> {datetime_to_short_date(@event.start_datetime)} <span class="px-1"></span>
      <.icon
        name="material_schedule"
        class={[
          "icon-size-4 bg-(--color-bg-accent-brand-muted) rounded-full p-0.5",
          @past_event? == true && "bg-(--color-bg-status-disabled)"
        ]}
      /> {datetime_to_hh_mm(@event.start_datetime)}
    </div>
    """
  end

  defp event_cover_image(%{cover_image: %{media_type: :gif}} = assigns) do
    ~H"""
    <picture class="">
      <img src={@cover_image.original} class="size-27 md:size-29 aspect-square rounded-lg" />
    </picture>
    """
  end

  defp event_cover_image(assigns) do
    ~H"""
    <picture class="">
      <source srcset={@cover_image.webp} type="image/webp" />
      <img src={@cover_image.jpg} class="size-27 md:size-29 aspect-square rounded-lg" />
    </picture>
    """
  end

  defp maybe_load_user_events(nil) do
    []
  end

  defp maybe_load_user_events(user) do
    Events.list_user_events(user)
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
