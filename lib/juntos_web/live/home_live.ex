defmodule JuntosWeb.HomeLive do
  use JuntosWeb, :live_view

  alias Juntos.Events
  @impl true
  def mount(_params, _session, socket) do
    events = Juntos.Repo.all(Events.Event)

    {:ok,
     socket
     |> assign(
       user_events: [Enum.random(events)],
       future_events: Enum.take(events, 4),
       events: events,
       page_title: gettext("Home")
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.page_wrapper>
        <.home_page>
          <.hero_section />
          <.events_list :if={@user_events != []} events={@user_events} title={gettext "Your events"} />
          <.events_list
            :if={@future_events != []}
            events={@future_events}
            title={gettext "Future events"}
          />
        </.home_page>
      </.page_wrapper>
    </Layouts.app>
    """
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
    <div class="flex flex-col justify-start gap-2">
      <.event_card :for={event <- Enum.take(@events, 3)} event={event} />
      <div
        :if={length(@events) > 3}
        class="flex w-full min-w-2xs max-w-3xl px-3 p-3 place-self-center justify-end items-center gap-1"
      >
        <.button variant="tertiary" type="link" size="md" icon_right="material_arrow_forward">
          {gettext "View all"}
        </.button>
      </div>
    </div>
    """
  end

  attr :event, :any, required: true
  attr :past_event?, :boolean, required: false, default: false
  attr :manage_event?, :boolean, required: false, default: false

  defp event_card(assigns) do
    ~H"""
    <.link navigate={~p"/#{@event.slug}"}>
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
            <div :if={@past_event?} class="flex-shrink-0">
              <div class="py-1 px-2 rounded-full border border-(--color-border-neutral-primary) bg-(--color-bg-neutral-secondary) text-xs font-medium">
                Past event
              </div>
            </div>
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
    <.button :if={not @past_event?} href="mange/event" type="link" size="sm" variant="secondary">
      {gettext "Manage"}
    </.button>
    <.button :if={@past_event?} href="mange/event" type="link" size="sm" variant="outline">
      {gettext "Manage"}
    </.button>
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
end
