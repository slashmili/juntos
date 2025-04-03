defmodule JuntosWeb.HomeLive do
  use JuntosWeb, :live_view

  alias Juntos.Events
  @impl true
  def mount(_params, _session, socket) do
    events = Juntos.Repo.all(Events.Event)

    {:ok,
     socket
     |> assign(events: events, page_title: gettext("Home"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      body {
        background: var(--color-bg-neutral-secondary);
      }
    </style>

    <Layouts.app flash={@flash} current_user={@current_user}>
      <.page_wrapper>
        <.home_page>
          <.hero_section />
          <div class="md:place-self-center md:min-w-3xl">
            <div class="flex gap-2 items-center md:max-w-3xl w-full">
              <.icon name="material_rocket_launch" class="icon-size-4" />
              <div class="font-bold">{gettext "Future events"}</div>

              <div style="flex: 1 0 0 " class="grow bg-(--color-border-neutral-primary) h-[2px] ">
              </div>
            </div>
          </div>

          <.future_events events={@events} />
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

  defp future_events(assigns) do
    ~H"""
    <div class="flex flex-col justify-start gap-4">
      <.event_card :for={event <- @events} event={event} />
    </div>
    """
  end

  defp event_card(assigns) do
    ~H"""
    <div
      class="flex w-full min-w-2xs max-w-3xl rounded-2xl border-1 border-(--color-border-neutral-primary) bg-(--color-bg-neutral-primary)/50 backdrop-blur-lg shadow-xl dark:shadow-slate-100/5 shadow-slate-900/4 px-3 place-self-center hover:bg-(--color-bg-neutral-primary-hover)"
    >
      <div class="py-3  pr-1">
        <.link navigate={~p"/#{@event.slug}"}>
          <.event_cover_image cover_image={Events.event_cover_url(@event)} />
        </.link>
      </div>
      <div class="grow flex flex-col pl-1  py-3">
        <div class="text-sm flex items-center gap-1">
          <.icon name="material_date_range" class="icon-size-4 bg-(--color-bg-accent-brand-muted)" />
          8. Feb <span class="px-1"></span>
          <.icon
            name="material_schedule"
            class="icon-size-4 bg-(--color-bg-accent-brand-muted) rounded-full"
          /> 20:00
        </div>
        <div class="grow font-bold text-base  flex flex flex-col justify-center">
          <.link navigate={~p"/#{@event.slug}"}>
            {@event.name}
          </.link>
        </div>
        <div class="flex items-center text-sm gap-1">
          <.icon name="material_location_on" class="icon-size-4" /> Berlin, Germany
        </div>
      </div>
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
