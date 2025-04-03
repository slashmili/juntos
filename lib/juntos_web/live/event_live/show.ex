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
  def handle_event("attend", _, %{assigns: %{current_user: nil}} = socket) do
    socket =
      push_navigate(socket, to: ~p"/users/log_in_redirect_back_to/#{socket.assigns.event.slug}")

    {:noreply, socket}
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
  def handle_event("redirect-to-google-calendar", _, socket) do
    event = socket.assigns.event
    {:ok, uri} = URI.new("https://calendar.google.com/calendar/render")
    dt_start = Calendar.strftime(event.start_datetime, "%Y%m%dT%H%M%S")
    dt_end = Calendar.strftime(event.end_datetime, "%Y%m%dT%H%M%S")

    query_params = %{
      "action" => "TEMPLATE",
      "text" => event.name,
      "details" =>
        "You are attending #{event.name}!\nVisit event page at  #{url(~p"/#{event.slug}")}",
      "dates" => "#{dt_start}/#{dt_end}",
      "ctz" => event.time_zone,
      "location" => event.location.address
    }

    url = %{uri | query: URI.encode_query(query_params)} |> URI.to_string()

    socket = redirect(socket, external: url)

    {:noreply, socket}
  end

  @impl true
  def handle_event("download-ics-file", params, socket) do
    event = socket.assigns.event

    {:ok, dts} =
      DateTime.from_naive(event.start_datetime, event.time_zone, Tzdata.TimeZoneDatabase)

    {:ok, dte} = DateTime.from_naive(event.end_datetime, event.time_zone, Tzdata.TimeZoneDatabase)

    {dts, dte} =
      if params["type"] == "android-cal" do
        {:ok, dts} = DateTime.shift_zone(dts, "Etc/UTC")

        {:ok, dte} = DateTime.shift_zone(dte, "Etc/UTC")
        {dts, dte}
      else
        {dts, dte}
      end

    events = [
      %ICalendar.Event{
        uid: event.id,
        summary: event.name,
        dtstart: dts,
        dtstamp: event.updated_at,
        dtend: dte,
        modified: event.updated_at,
        description:
          "You are attending #{event.name}!\nVisit event page at  #{url(~p"/#{event.slug}")}",
        location: event.location.address,
        sequence: 0,
        url: url(~p"/#{event.slug}"),
        organizer: "mailto:calendar-invite@juntos.now",
        attendees: [
          %{
            :original_value => "mailto:#{socket.assigns.current_user.email}",
            "CN" => "mailto:#{socket.assigns.current_user.email}",
            "CUTYPE" => "INDIVIDUAL",
            "PARTSTAT" => "ACCEPTED",
            "ROLE" => "REQ-PARTICIPANT",
            "X-NUM-GUESTS" => "0"
          }
        ],
        status: "CONFIRMED"
      }
    ]

    ics =
      %ICalendar{events: events}
      |> ICalendar.to_ics()

    {:noreply,
     push_event(socket, "download", %{
       content_type: "text/calendar",
       content_base64: Base.encode64(ics),
       filename: "invite.ics"
     })}
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
  def handle_event("toggle-calendar-dropdown", _, socket) do
    socket = assign(socket, show_add_to_calendar?: !socket.assigns.show_add_to_calendar?)
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
    <Layouts.app flash={@flash} current_user={@current_user}>
      <:breadcrumb>
        <.link navigate={~p"/"}><.icon name="material_home" class="icon-size-4" /></.link>
      </:breadcrumb>
      <:breadcrumb>
        {gettext "event"}
      </:breadcrumb>

      <style>
        body {
          background: var(--color-bg-neutral-secondary);
        }
      </style>
      <.page_wrapper>
        <.event_page>
          <.event_card event={@event} />
          <.footer_register event={@event} show={not @attending?} />
          <.footer_attend event={@event} show={@attending?} />
          <.confirm_cancellation_dialog show={@show_withdraw_prompt?} />
          <.ticket_dialog event={@event} show={@show_ticket_dialog?} />
          <.add_to_calendar event={@event} show={@show_add_to_calendar?} />
        </.event_page>
      </.page_wrapper>
    </Layouts.app>
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
    <section class="grid grid-cols-1 md:grid-cols-4 md:grid-rows-[auto_1fr_auto] lg:grid-cols-3  gap-4 bg-(--color-bg-neutral-tertiary) md:bg-(--color-bg-neutral-secondary) rounded-2xl w-full">
      {render_slot(@inner_block)}
    </section>
    """
  end

  defp event_card_grid_header(assigns) do
    ~H"""
    <div class="md:col-span-2 md:row-start-1 md:bg-(--color-bg-neutral-tertiary) md:rounded-t-2xl pt-4 px-4">
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
    <div class="md:col-span-2 md:row-start-2 md:row-span-3  md:bg-(--color-bg-neutral-tertiary) md:-mt-4 md:rounded-b-2xl px-4 h-full">
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
      <div data-role="attendee-count" class="flex items-center gap-1">
        <.icon name="material_groups_2" class="icon-size-4 size-4" />
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
          class="-ml-5 -mt-3 sm:-mt-5"
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
        <div class="grid grid-cols-1 md:grid-cols-2 md:grid-rows-[auto_1fr] gap-6 md:gap-2 mx-auto min-w-xs max-w-3xl md:max-w-5xl md:px-3">
          <div class="font-bold place-self-center md:col-start-1 md:row-start-1 md:place-self-start">
            {gettext "You are attending this event. 🎉"}
          </div>
          <div class="w-full flex flex-col gap-2 md:w-64 place-self-end md:col-start-2 md:row-span-2 ">
            <.button
              variant="secondary"
              size="lg"
              class="w-full flex items-center"
              icon_left="material_qr_code"
              phx-click="toggle-ticket-dropdown"
            >
              {gettext "View ticket"}
            </.button>
            <.button
              variant="outline"
              size="lg"
              class="w-full flex items-center"
              icon_left="material_calendar_add_on"
              phx-click="toggle-calendar-dropdown"
            >
              {gettext "Add to calendar"}
            </.button>
            <.button
              variant="outline"
              size="lg"
              class="w-full flex items-center"
              icon_left="material_share"
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
      class="bg-(--color-bg-neutral-primary) fixed bottom-0 left-0 w-full py-6 event-show-shadow border-t border-(--color-border-neutral-primary)"
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
                <.icon name="material_date_range" class="icon-size-4" /> {Calendar.strftime(
                  @event.start_datetime,
                  "%a %d. %b"
                )}
              </div>
              <div class="flex items-center gap-1">
                <.icon name="material_schedule" class="icon-size-4" /> {Calendar.strftime(
                  @event.start_datetime,
                  "%H:%M"
                )} - {Calendar.strftime(
                  @event.end_datetime,
                  "%H:%M"
                )}
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
      <.bottom_sheet
        id="withdrawButtonSheet"
        show
        on_cancel={JS.push("toggle-withdraw-dropdown")}
        close_button
      >
        <:header>
          <h2 class="text-neutral-primary text-lg font-bold">{gettext "Cancel registertion?"}</h2>
        </:header>

        <:body class="bg-(--color-bg-neutral-primary) flex flex-col gap-6">
          {gettext "Canceling means you may lose your spot, and re-registering could be unavailable if the event reaches capacity."}
          <div class="flex flex-col sm:flex-row gap-2 sm:place-self-end">
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
      <.bottom_sheet
        id="ticketBottomSheet"
        show
        on_cancel={JS.push("toggle-ticket-dropdown")}
        close_button
      >
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
          </div>
        </:body>
      </.bottom_sheet>
    </div>
    """
  end

  defp add_to_calendar(assigns) do
    ~H"""
    <div :if={@show} data-role="add-to-calendar-cta">
      <.bottom_sheet
        id="addCalButtonSheet"
        show
        on_cancel={JS.push("toggle-calendar-dropdown")}
        close_button
      >
        <:header>
          <h2 class="text-neutral-primary text-lg font-bold">{gettext "Add to calendar"}</h2>
        </:header>

        <:body class="bg-(--color-bg-neutral-primary) flex flex-col gap-6">
          <div class="flex flex-col gap-2">
            <.button
              phx-click="download-ics-file"
              phx-value-type="ical"
              variant="outline"
              phx-disable-with
              icon_left="material_calendar_add_on"
            >
              {gettext "iCal"}
            </.button>

            <.button
              phx-click="download-ics-file"
              phx-value-type="android-cal"
              variant="outline"
              phx-disable-with
              icon_left="material_android"
            >
              {gettext "Android"}
            </.button>
            <.button
              phx-click="redirect-to-google-calendar"
              icon_left="google-calendar"
              variant="outline"
              phx-disable-with
            >
              {gettext "Google Calendar"}
            </.button>
          </div>
        </:body>
      </.bottom_sheet>
    </div>
    """
  end

  defp share_button(assigns) do
    ~H"""
    <section class="absolute left-4 bottom-4 size-4 min-w-2">
      <.button type="button" icon_right="material_share" size="md" variant="secondary"></.button>
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
        <.icon name="material_date_range" class="icon-size-4" />
        {Calendar.strftime(
          @event.start_datetime,
          "%a %d. %b"
        )}
      </div>
      <div class="flex items-center gap-1">
        <.icon name="material_schedule" class="icon-size-4" />
        {Calendar.strftime(
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
      <div class="flex flex-row gap-1 items-center">
        <.icon name="material_location_on" class="icon-size-4" />
        <a
          href={"https://www.google.com/maps/search/?#{URI.encode_query(%{api: 1, query: @location.name, query_place_id: @location.id})}"}
          class="underline"
          target="_blank"
        >
          {@location.address}
        </a>
      </div>

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
        <div class="flex flex-row gap-1 items-center">
          <.icon name="material_location_on" class="icon-size-4" />
          <a
            href={"https://www.google.com/maps/search/?#{URI.encode_query(%{api: 1, query: @location.address})}"}
            class="underline"
            target="_blank"
          >
            {@location.address}
          </a>
        </div>
        """

      %{link: _} ->
        ~H"""
        <div class="flex flex-row gap-1 items-center">
          <.icon name="material_videocam" class="size-4" /> {gettext "Online Event"}
        </div>
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
      show_ticket_dialog?: false,
      show_add_to_calendar?: false
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
