defmodule JuntosWeb.EventLive.Show do
  use JuntosWeb, :live_view
  alias Juntos.Events

  @impl true
  def mount(params, _session, socket) do
    event = Juntos.Repo.get_by(Events.Event, slug: hd(params["path"]))

    {:ok,
     socket
     |> assign(:page_title, event.name)
     |> assign(:event, event)
     |> set_toggles()}
  end

  @impl true
  def handle_event("attend", _, socket) do
    :ok = Events.add_event_attendee(socket.assigns.event, socket.assigns.current_user)
    socket = assign(socket, :attending?, !socket.assigns.attending?)
    event = Juntos.Repo.get!(Events.Event, socket.assigns.event.id)
    socket = assign(socket, :event, event)
    socket = put_flash(socket, :success, gettext("You’re in! 🎉 See you at the event."))
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-withdraw-dropdown", _, socket) do
    socket = assign(socket, :show_withdraw_prompt?, !socket.assigns.show_withdraw_prompt?)
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-ticket-dropdown", _, socket) do
    socket = assign(socket, :show_ticket_dialog?, !socket.assigns.show_ticket_dialog?)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-attendance", _, socket) do
    :ok = Events.remove_event_attendee(socket.assigns.event, socket.assigns.current_user)
    socket = assign(socket, attending?: false, show_withdraw_prompt?: false)
    event = Juntos.Repo.get!(Events.Event, socket.assigns.event.id)
    socket = assign(socket, :event, event)
    socket = put_flash(socket, :success, gettext("Your registration has been canceled."))
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      body {
        background: var(--color-bg-neutral-primary);
      }
    </style>
    <.page_wrapper>
      <.event_page>
        <.event_card event={@event} />
        <.footer_register event={@event} show={not @attending?} />
        <.footer_attend event={@event} show={@attending?} />
        <.confirm_cancellation_dialog show={@show_withdraw_prompt?} />
        <.ticket_dialog event={@event} show={@show_ticket_dialog?} />
      </.event_page>
    </.page_wrapper>
    """
  end

  def event_page(assigns) do
    ~H"""
    <div
      data-role="event-public-page"
      class="min-w-xs max-w-3xl md:max-w-5xl flex flex-col items-start p-3 gap-1.5"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  def event_card(assigns) do
    ~H"""
    <div>
      <.event_card_grid>
        <.event_card_grid_header>
          <.header event={@event} />
        </.event_card_grid_header>
        <.event_card_grid_details>
          <.cover event={@event} />
          <.event_info event={@event} />
        </.event_card_grid_details>
        <.event_card_grid_description>
          <.event_description event={@event} />
        </.event_card_grid_description>
      </.event_card_grid>
      <div class="py-25"></div>
    </div>
    """
  end

  defp event_card_grid(assigns) do
    ~H"""
    <section class="grid grid-cols-1 md:grid-cols-4 md:grid-rows-[auto_1fr_auto] lg:grid-cols-3  gap-4 bg-(--color-bg-neutral-secondary) md:bg-(--color-bg-neutral-primary) rounded-2xl w-full">
      {render_slot(@inner_block)}
    </section>
    """
  end

  defp event_card_grid_header(assigns) do
    ~H"""
    <div class="md:col-span-2 md:row-start-1 md:bg-(--color-bg-neutral-secondary) md:rounded-t-2xl pt-4 px-4">
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp event_card_grid_details(assigns) do
    ~H"""
    <div class="md:col-span-2 lg:col-span-1 md:row-span-3 md:col-start-3 flex flex-col gap-4 px-4 md:px-0">
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp event_card_grid_description(assigns) do
    ~H"""
    <div class="md:col-span-2 md:row-start-2 md:row-span-3  md:bg-(--color-bg-neutral-secondary) md:-mt-4 md:rounded-b-2xl px-4 h-full">
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp header(assigns) do
    ~H"""
    <div class="gap-4 flex flex-col">
      <div class="w-fit">
        <.datetime_header event={@event} data-role="datetime-in-header" />
      </div>

      <section class="text-lg font-bold pb-4">
        {@event.name}
      </section>
    </div>
    """
  end

  defp cover(assigns) do
    ~H"""
    <div class="flex flex-col">
      <section class="self-center md:self-start relative">
        <.event_cover_image cover_image={Events.event_cover_url(@event)} />
        <.share_button />
      </section>
    </div>
    """
  end

  defp event_info(assigns) do
    ~H"""
    <section class="flex flex-col py-2 gap-2 text-sm font-semibold">
      <div data-role="attendee-count">
        <.icon name="hero-user-group" class="size-4" />
        <span :if={@event.attendee_count == 0}>{gettext "No attendee"}</span>
        <span :if={@event.attendee_count > 0}>{@event.attendee_count} {gettext "attendees"}</span>
      </div>
      <div>
        <.location_to_html show_map={true} location={@event.location} />
      </div>
    </section>
    """
  end

  defp event_description(assigns) do
    ~H"""
    <section class="">
      <div class="flex gap-2">
        <div class="font-bold">About</div>

        <div style="flex: 1 0 0 " class="grow bg-(--color-border-neutral-primary) h-[2px] mt-3"></div>
      </div>
      <div>
        <.text_editor
          class="-ml-5 sm:-mt-8"
          id="view-event"
          name="view-event"
          value={@event.description}
        />
      </div>
    </section>
    """
  end

  defp footer_attend(assigns) do
    ~H"""
    <footer
      :if={@show}
      class="fixed bottom-0 left-0 w-full py-6 bg-(--color-bg-neutral-primary) event-show-shadow"
      data-role="attending-cta"
    >
      <section id="foo2" phx-mounted={footer_show("foo2")} class="hidden px-4">
        <div class="grid grid-cols-1 md:grid-cols-2 md:grid-rows-2 gap-6 md:gap-0 mx-auto min-w-xs max-w-3xl md:max-w-5xl md:px-3">
          <div class="font-bold place-self-center md:col-start-1 md:row-start-1 md:place-self-start">
            {gettext "You are attending this event. 🎉"}
          </div>
          <div class="w-full flex flex-col gap-2 md:w-64 place-self-end md:col-start-2 md:row-span-2 ">
            <.button
              variant="secondary"
              size="lg"
              class="w-full flex items-center"
              icon_left="hero-qr-code"
              phx-click="toggle-ticket-dropdown"
            >
              {gettext "View ticket"}
            </.button>
            <.button
              variant="outline"
              size="lg"
              class="w-full flex items-center"
              icon_left="hero-share"
            >
              {gettext "Share event"}
            </.button>
          </div>
          <div class="place-self-center md:col-start-1 md:row-start-2 md:place-self-start">
            <!-- TODO: make me a button! -->
            <a
              href="#"
              phx-click="toggle-withdraw-dropdown"
              class=" phx-click-loading:opacity-75 cursor-text"
              phx-disable-with
            >
              {gettext "Cannot join?"}
              <span class="cursor-pointer underline">{gettext "Cancel registertion"}</span>
            </a>
          </div>
        </div>
      </section>
    </footer>
    """
  end

  defp footer_register(assigns) do
    ~H"""
    <footer
      :if={@show}
      class="bg-(--color-bg-neutral-primary) fixed bottom-0 left-0 w-full py-6 event-show-shadow"
      data-role="register-cta"
    >
      <section
        class="hidden"
        id="foobar"
        phx-mounted={footer_show("foobar")}
        phx-remove={footer_hide("foobar")}
      >
        <div class="flex flex-col md:flex-row items-center justify-center mx-auto min-w-xs max-w-3xl md:max-w-5xl md:justify-between  md:px-3 ">
          <div class="flex flex-col items-center md:items-start">
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
                <.location_to_html show_map={false} location={@event.location} />
              </div>
            </div>
          </div>

          <div class="w-full px-2 pt-6 md:w-64 md:px-0" phx-change="update">
            <.button
              size="lg"
              class="phx-click-loading:opacity-75 w-full"
              phx-click="attend"
              phx-disable-with={gettext "Registering..."}
            >
              {gettext "Register"}
            </.button>
          </div>
        </div>
      </section>
    </footer>
    """
  end

  defp confirm_cancellation_dialog(assigns) do
    ~H"""
    <div :if={@show} data-role="cancellation-cta">
      <.bottom_sheet id="withdrawButtonSheet" show on_cancel={JS.push("toggle-withdraw-dropdown")}>
        <:header>
          <h2 class="text-neutral-primary text-lg font-bold">{gettext "Cancel registertion?"}</h2>
        </:header>

        <:body class="bg-(--color-bg-neutral-primary) flex flex-col gap-6">
          Canceling means you may lose your spot, and re-registering could be unavailable if the event reaches capacity.
          <div class="flex flex-col gap-2">
            <.button phx-click="toggle-withdraw-dropdown" variant="outline" phx-disable-with>
              {gettext "Keep my spot"}
            </.button>
            <.button
              variant="destructive"
              phx-click="cancel-attendance"
              phx-disable-with="Canceling ..."
            >
              {gettext "Confirm cancellation"}
            </.button>
          </div>
        </:body>
      </.bottom_sheet>
    </div>
    """
  end

  defp ticket_dialog(assigns) do
    ~H"""
    <div :if={@show} data-role="ticket-dialog">
      <.bottom_sheet id="ticketBottomSheet" show on_cancel={JS.push("toggle-ticket-dropdown")}>
        <:header>
          <div class="flex flex-col pb-6">
            <section class="flex flex-col gap-4 ">
              <div class="flex">
                <.datetime_header event={@event} data-role="event-ticket-datetime" />
              </div>
              <div class="text-lg font-bold">{@event.name}</div>
              <div class="truncate text-sm font-semibold">
                <.location_to_html show_map={false} location={@event.location} />
              </div>
            </section>
          </div>
        </:header>
        <:body class="bg-(--color-bg-neutral-primary) border-(--color-border-neutral-secondary)/30 items-center border-t-2 border-dashed pt-6">
          <div class="flex flex-col items-center gap-6">
            {raw(ticket_svg())}
            <.button variant="outline" icon_left="hero-calendar-days" class="w-full">
              {gettext "Add to calendar"}
            </.button>
          </div>
        </:body>
      </.bottom_sheet>
    </div>
    """
  end

  defp share_button(assigns) do
    ~H"""
    <section class="absolute left-4 bottom-4">
      <.button type="button" icon_right="hero-share" size="md" variant="secondary"></.button>
    </section>
    """
  end

  defp datetime_header(assigns) do
    ~H"""
    <header
      data-role={assigns[:"data-role"]}
      class="bg-(--color-bg-accent-brand-muted) rounded-full px-4 py-1.5 text-sm/5 font-medium gap-4 flex"
    >
      <div class="flex items-center gap-1">
        <.icon name="hero-calendar-days" class="size-4" /> {Calendar.strftime(
          @event.start_datetime,
          "%a %d. %b"
        )}
      </div>
      <div class="flex items-center gap-1">
        <.icon name="hero-clock" class="size-4" /> {Calendar.strftime(
          @event.start_datetime,
          "%H:%M"
        )} - {Calendar.strftime(
          @event.end_datetime,
          "%H:%M"
        )}
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

  defp location_to_html(%{location: nil} = assigns) do
    ~H"""
    {gettext "NA"}
    """
  end

  defp location_to_html(%{location: %Juntos.Events.Event.Place{}} = assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <a
        href={"https://www.google.com/maps/search/?#{URI.encode_query(%{api: 1, query: @location.name, query_place_id: @location.id})}"}
        class="underline"
        target="_blank"
      >
        <.icon name="hero-map-pin" class="size-4" /> {@location.address}
      </a>

      <div
        :if={@show_map}
        data-place={Jason.encode!(@location)}
        data-map-id={System.get_env("GMAP_MAP_ID")}
        api_key={System.get_env("GMAP_API_KEY")}
        id="showEventLocation"
        data-api-key={System.get_env("GMAP_API_KEY")}
        id="google-map"
        class="hidden md:block h-44 rounded-lg border border-(--color-border-neutral-primary)"
        phx-hook="GoogleMaps"
        phx-update="ignore"
      >
      </div>
    </div>
    """
  end

  defp location_to_html(assigns) do
    case assigns[:location] do
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

  defp footer_show(id, time \\ 0) do
    JS.show(
      to: "##{id}",
      time: time,
      transition: {"duration-300  ease-in", "opacity-0", "opacity-100"}
    )
  end

  defp footer_hide(id, time \\ 100) do
    JS.hide(
      to: "##{id}",
      time: time,
      transition: {"duration-100 ease-out", "opacity-100", "opacity-0"}
    )
  end

  defp set_toggles(socket) do
    options = [
      show_withdraw_prompt?: false,
      attending?: Events.is_attending?(socket.assigns.event, socket.assigns.current_user),
      show_ticket_dialog?: false
    ]

    assign(socket, options)
  end

  defp ticket_svg() do
    settings = %QRCode.Render.SvgSettings{background_opacity: 1.0}

    "https://juntos.now"
    |> QRCode.create(:high)
    |> QRCode.render(:svg, settings)
    |> elem(1)
  end
end
