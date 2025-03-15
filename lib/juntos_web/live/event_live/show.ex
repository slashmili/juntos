defmodule JuntosWeb.EventLive.Show do
  use JuntosWeb, :live_view
  alias Juntos.Events

  @impl true
  def mount(params, _session, socket) do
    event = Juntos.Repo.get_by(Events.Event, slug: hd(params["path"]))

    {:ok,
     socket
     |> assign(:page_title, event.name)
     |> assign(:event, event)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      data-role="event-public-page"
      class="min-w-xs max-w-3xl flex flex-col items-start p-3 gap-1.5"
    >
      <.event_card event={@event} />
    </div>
    """
  end

  def event_card(assigns) do
    ~H"""
    <div>
      <section class="flex-1 flex p-4 flex-col gap-4 bg-(--color-bg-neutral-secondary) rounded-2xl w-full">
        <.header event={@event} />
        <.cover event={@event} />
        <.event_info event={@event} />
        <.event_description event={@event} />
      </section>
      <div class="py-20"></div>
      <.footer event={@event} />
    </div>
    """
  end

  defp header(assigns) do
    ~H"""
    <section class="text-lg font-bold pb-4 border-b-1 border-(--color-border-neutral-primary)">
      {@event.name}
    </section>
    """
  end

  defp cover(assigns) do
    ~H"""
    <section class="self-center relative">
      <.event_cover_image cover_image={Events.event_cover_url(@event)} />
      <.datetime_header />
      <.share_button />
    </section>
    """
  end

  defp event_info(assigns) do
    ~H"""
    <section class="flex flex-col py-2 gap-0.5 border-b-1 border-(--color-border-neutral-primary) text-sm font-semibold">
      <div><.icon name="hero-user-group" class="size-4" /> 102 {gettext "attendees"}</div>
      <div>
        <.location_to_html location={@event.location} />
      </div>
    </section>
    """
  end

  defp event_description(assigns) do
    ~H"""
    <section class="py-4">
      <div>About</div>
      <div>
        <.text_editor class="-ml-5" id="view-event" name="view-event" value={@event.description} />
      </div>
    </section>
    """
  end

  defp footer(assigns) do
    ~H"""
    <footer class="fixed bottom-0 left-0 w-full py-6 flex items-center justify-center flex-col bg-(--color-bg-neutral-primary)">
      <div class="flex gap-4  font-bold">
        <div class="flex items-center gap-1">
          <.icon name="hero-calendar-days" class="size-4" /> Sat 8. Feb
        </div>
        <div class="flex items-center gap-1">
          <.icon name="hero-clock" class="size-4" /> 20:00 - 22:00
        </div>
      </div>
      <div class="font-medium">
        <div>
          <.location_to_html location={@event.location} />
        </div>
      </div>
      <div class="w-full px-2 pt-6">
        <.button size="lg" class="w-full">
          {gettext "Register"}
        </.button>
      </div>
    </footer>
    """
  end

  defp share_button(assigns) do
    ~H"""
    <section class="absolute right-2 bottom-2">
      <.button type="button" icon_right="hero-share" size="md" variant="secondary"></.button>
    </section>
    """
  end

  defp datetime_header(assigns) do
    ~H"""
    <header class="bg-(--color-bg-accent-brand-muted) absolute top-2 left-2 rounded-full px-4 py-1.5 text-sm/5 font-medium gap-4 flex">
      <div class="flex items-center gap-1">
        <.icon name="hero-calendar-days" class="size-4" /> Sat 8. Feb
      </div>
      <div class="flex items-center gap-1">
        <.icon name="hero-clock" class="size-4" /> 20:00 - 22:00
      </div>
    </header>
    """
  end

  defp event_cover_image(%{cover_image: %{media_type: :gif}} = assigns) do
    ~H"""
    <picture class="max-w-lg">
      <img src={@cover_image.original} class="aspect-square rounded-lg" />
    </picture>
    """
  end

  defp event_cover_image(assigns) do
    ~H"""
    <picture class="max-w-lg">
      <source srcset={@cover_image.webp} type="image/webp" />
      <img src={@cover_image.jpg} class="aspect-square rounded-lg" />
    </picture>
    """
  end

  defp location_to_html(assigns) do
    case assigns[:location] do
      nil ->
        ~H"""
        {gettext "NA"}
        """

      %{id: _} ->
        ~H"""
        <a
          href={"https://www.google.com/maps/search/?#{URI.encode_query(%{api: 1, query: @location.name, query_place_id: @location.id})}"}
          class="underline"
          target="_blank"
        >
          <.icon name="hero-map-pin" class="size-4" /> {@location.address}
        </a>
        """

      %{address: _} ->
        ~H"""
        <a
          href={"https://www.google.com/maps/search/?#{URI.encode_query(%{api: 1, query: @location.address})}"}
          class="underline"
          target="_blank"
        >
          <.icon name="hero-map-pin" class="size-4" /> {@location.address}
        </a>
        """

      %{link: _} ->
        ~H"""
        <.icon name="hero-video-camera" class="size-4" /> {gettext "Online Event"}
        """
    end
  end
end
