defmodule JuntoWeb.EventLive.Home do
  use JuntoWeb, :live_view
  alias Junto.Events

  @impl true
  def mount(_params, _session, socket) do
    events = Events.all()

    {:ok,
     socket
     |> assign(events: events)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <header class="flex dark:text-white pt-2 pl-2">
      <h2 class="text-2xl font-bold">{gettext "Events"}</h2>
      <section class="grow flex justify-end pr-4 text-sm">
        <div class="relative">
          <div class="flex dark:bg-black/20 min-w-52 rounded-md h-full">
            <button
              id="upcommingEventSlider"
              type="button"
              class="py-1 px-2  rounded-md basis-1/2 animated h-full"
              phx-click={
                JS.set_attribute({"style", "left: 0%"}, to: "#eventTimeline")
                |> JS.toggle_class("dark:text-white/50", to: "#pastEventSlider")
                |> JS.toggle_class("dark:text-white/50", to: "#upcommingEventSlider")
              }
            >
              {gettext "Upcoming"}
            </button>
            <button
              id="pastEventSlider"
              type="button"
              class="py-1 px-2  rounded-md basis-1/2 animated dark:text-white/50 dark:hover:text-white h-full"
              phx-click={
                JS.set_attribute({"style", "left: 50%"}, to: "#eventTimeline")
                |> JS.toggle_class("dark:text-white/50", to: "#pastEventSlider")
                |> JS.toggle_class("dark:text-white/50", to: "#upcommingEventSlider")
              }
            >
              {gettext "Past"}
            </button>
            <div
              style="left: 0%"
              id="eventTimeline"
              class="py-1 px-2 absolute  animated dark:bg-white/20 rounded-md h-full min-w-[104px]"
            >
            </div>
          </div>
        </div>
      </section>
    </header>
    <div class="px-4" id="eventListWrapper" phx-hook="EventGroupByDate">
      <ul>
        <div :for={event <- @events} class="pt-4" data-role="event">
          <div
            class="hidden"
            data-start-date={Junto.Chrono.Formatter.strftime(event.start_datetime, "%Y-%m-%d")}
          >
            <span class="text-lg dark:text-white">
              {Junto.Chrono.Formatter.strftime(event.start_datetime, "%b %-d")}
            </span>
            <span class="text-lg dark:text-white/40">
              {Junto.Chrono.Formatter.strftime(event.start_datetime, "%A")}
            </span>
          </div>
          <li>
            <.event_card event={event} />
          </li>
        </div>
      </ul>
    </div>
    <script>
    </script>
    """
  end

  def event_card(assigns) do
    ~H"""
    <div class="px-4 py-4 flex flex-col animated dark:bg-black/30 rounded-md border dark:border-white/40 dark:hover:border-white/80 cursor-pointer">
      <div class="flex">
        <div class="flex-auto">
          <div class="text-base dark:text-white/40">
            {Junto.Chrono.Formatter.to_hh_mm_str(@event.start_datetime)}
          </div>
          <div class="text-xl dark:text-white font-semibold">{@event.name}</div>
          <div :if={@event.location} class="text-base dark:text-white/40">
            <.icon name="hero-map-pin" class="w-4 h-4" />
            {@event.location && @event.location.name}
          </div>
        </div>
        <div>
          <picture class="">
            <source type="image/webp" srcset="images/junto-sample-banner.webp" />
            <img
              class="object-cover rounded-xl w-36 min-w-36 max-w-60"
              src="images/junto-sample-banner.png"
            />
          </picture>
        </div>
      </div>
    </div>
    """
  end
end
