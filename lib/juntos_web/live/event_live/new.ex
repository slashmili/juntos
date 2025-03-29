defmodule JuntosWeb.EventLive.New do
  use JuntosWeb, :live_view
  alias Juntos.Events
  alias Juntos.Chrono.TimeZone

  @impl true
  def mount(_params, _session, socket) do
    viewer_time_zone = get_time_zone(socket)
    changeset = Events.change_event(%Events.Event{}, %{time_zone: viewer_time_zone.zone_name})

    {:ok,
     socket
     |> assign(:uploaded_cover, [])
     |> assign(:event_location, nil)
     |> assign(:show_desc, false)
     |> assign(:show_time_zone_options, false)
     |> assign(:page_title, "Create a new event")
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .gif .png .webp), max_entries: 1)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"event" => event_params}, socket) do
    event_params =
      if event_params["description_editor"] do
        Map.put(event_params, "description", event_params["description_editor"])
      else
        event_params
      end

    event_params =
      Map.put(event_params, "location", to_location(socket.assigns.event_location))

    changeset = Events.change_event(%Events.Event{}, event_params) |> Map.put(:action, :validate)
    {:noreply, socket |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-sheet", _params, socket) do
    {:noreply, socket |> assign(:show_desc, !socket.assigns.show_desc)}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-time-zone-selector", _params, socket) do
    {:noreply, socket |> assign(:show_time_zone_options, !socket.assigns.show_time_zone_options)}
  end

  @impl Phoenix.LiveView
  def handle_event("location-finder", %{"type" => "place"} = location, socket) do
    {:noreply, assign(socket, :event_location, location)}
  end

  @impl Phoenix.LiveView
  def handle_event("location-finder", %{"type" => "url", "value" => value} = url, socket) do
    {:noreply, assign(socket, :event_location, %{url | "value" => %{"link" => value}})}
  end

  @impl Phoenix.LiveView
  def handle_event("location-finder", %{"type" => "address", "value" => value} = address, socket) do
    {:noreply, assign(socket, :event_location, %{address | "value" => %{"address" => value}})}
  end

  @impl Phoenix.LiveView
  def handle_event("location-finder", %{"type" => "reset"}, socket) do
    {:noreply, assign(socket, :event_location, nil)}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", params, socket) do
    upload_result =
      consume_uploaded_entries(socket, :cover, fn meta, entry ->
        image_plug_upload =
          %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          }

        {:postpone, image_plug_upload}
      end)

    event_params =
      case upload_result do
        [image_plug_upload] ->
          Map.put(params["event"], "cover_image", image_plug_upload)

        _ ->
          params["event"]
      end

    event_params = Map.put(event_params, "location", to_location(socket.assigns.event_location))

    case Events.create_event(event_params, socket.assigns.current_user) do
      {:ok, event} ->
        {:noreply, redirect(socket, to: ~p"/#{event.slug}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.page_wrapper>
      <.event_form form={@form}>
        <.form_header />
        <.name_input name={@form[:name]} />
        <.description_input
          show_desc={@show_desc}
          description={@form[:description]}
          description_editor={@form[:description_editor]}
        />
        <.cover_input form={@form} uploads={@uploads} />
        <.date_input form={@form} show_time_zone_options={@show_time_zone_options} />
        <.location_input form={@form} />
        <.create_button />
      </.event_form>
    </.page_wrapper>
    """
  end

  defp create_button(assigns) do
    ~H"""
    <.form_item>
      <:input>
        <.button class="w-full" type="submit">{gettext "Create Event"}</.button>
      </:input>
    </.form_item>
    """
  end

  defp location_input(assigns) do
    ~H"""
    <.form_item>
      <:label>{gettext "Location"}*</:label>
      <:label_body>{gettext "Go in-person or oline. Add a spot if it's in-person"}</:label_body>
      <:input>
        <JuntosWeb.EventLive.Components.location_finder
          id="newEventlocationFinder"
          api_key={System.get_env("GMAP_API_KEY")}
        />
      </:input>
    </.form_item>
    """
  end

  defp date_input(assigns) do
    ~H"""
    <.form_item>
      <:label>
        <.label_for field={@form[:start_datetime]}>
          {gettext "Event Date"}*
        </.label_for>
        <.label_for field={@form[:end_datetime]} class="hidden">
          {gettext "Event End Date"}*
        </.label_for>
      </:label>
      <:input>
        <JuntosWeb.EventLive.Components.datepicker
          show_time_zone_options={@show_time_zone_options}
          id="new-event-datepicker"
          start_datetime_field={@form[:start_datetime]}
          end_datetime_field={@form[:end_datetime]}
          time_zone_field={@form[:time_zone]}
          on_cancel={JS.push("toggle-time-zone-selector")}
        />
      </:input>
    </.form_item>
    """
  end

  defp name_input(assigns) do
    ~H"""
    <.form_item>
      <:label>
        <.content_text>
          <.label_for field={@name}>
            {gettext "Event name"}*
          </.label_for>
          <:subtitle>
            {gettext "Give your event a clear and engaging name (e.g., 'Berlin UX Meetup')"}
          </:subtitle>
        </.content_text>
      </:label>
      <:input>
        <.input field={@name} placeholder={gettext "Event name"} phx-debounce="1000" />
      </:input>
    </.form_item>
    """
  end

  defp description_input(assigns) do
    ~H"""
    <div class="hidden">
      <.input field={@description} type="text" />
    </div>
    <.form_item>
      <:label>
        <.content_text>
          {gettext "Description"}*
        </.content_text>
      </:label>
      <:input>
        <JuntosWeb.EventLive.Components.description_editor
          description_editor={@description_editor}
          value={@description.value}
          show_desc={@show_desc}
        />
      </:input>
    </.form_item>
    """
  end

  defp cover_input(assigns) do
    ~H"""
    <.form_item>
      <:label>
        <.content_text>
          <label for={@uploads.cover.ref}>{gettext "Cover image"}</label>
          <:subtitle>{gettext "Skip the upload? We'll pick a cool image for you!"}</:subtitle>
        </.content_text>
      </:label>
      <:input>
        <div :if={@uploads.cover.entries == []} class="w-full">
          <label for={@uploads.cover.ref}>
            <JuntosWeb.EventLive.Components.upload_image_area upload_ref={@uploads.cover.ref} />
          </label>
        </div>
        <section class="">
          <article :for={entry <- @uploads.cover.entries} class="upload-entry flex flex-col gap-2">
            <figure>
              <.live_img_preview entry={entry} class="w-md border-line rounded-lg border" />
            </figure>
            <div class="flex gap-1">
              <.icon name="hero-photo" class="text-accent-brand" />
              <span class="text-neutral-primary grow truncate">{entry.client_name}</span>
              <button
                type="button"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label="cancel"
                class="w-4 cursor-pointer"
              >
                <.icon name="hero-trash" class="text-accent-brand w-4" />
              </button>
            </div>
          </article>
          <.live_file_input class="hidden" upload={@uploads.cover} />
          <p :for={err <- upload_errors(@uploads.cover)} class="alert alert-danger">
            {err}
          </p>
        </section>
      </:input>
    </.form_item>
    """
  end

  defp event_form(assigns) do
    ~H"""
    <div class="flex w-full min-w-[320px] flex-col" data-role="new-event">
      <!--<div class="max-w-6xl  pt-6 px-4 pb-4  w-[764px] flex flex-col gap-4" data-role="new-event">-->
      <.simple_form for={@form} phx-change="validate" phx-submit="save" id="createEvent">
        <div class="flex flex-col items-center gap-4 px-4">
          {render_slot(@inner_block)}
        </div>
      </.simple_form>
    </div>
    """
  end

  defp form_header(assigns) do
    ~H"""
    <section class="flex w-full max-w-md flex-col  items-center sm:max-w-lg md:max-w-3xl">
      <.hero align="left">
        {gettext "Create a new event"}
      </.hero>
    </section>
    """
  end

  slot :label, required: false
  slot :label_body, required: false
  slot :input, required: true

  defp form_item(assigns) do
    ~H"""
    <div class="border-(--color-border-neutral-primary) flex w-full max-w-md flex-col gap-2 border-b-1 py-6 last:border-b-0 sm:max-w-lg md:max-w-3xl md:flex-row md:justify-between">
      <section class="md:basis-4/10 flex w-full flex-col">
        <div class="text-neutral-primary font-bold">{render_slot(@label)}</div>
        <div class="text-neutral-secondary text-sm">{render_slot(@label_body)}</div>
      </section>
      <section class="md:basis-md  flex sm:justify-end">
        {render_slot(@input)}
      </section>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, form: form)
  end

  defp to_location(%{"type" => type, "value" => value}) do
    Map.put(value, "__type__", type)
  end

  defp to_location(_) do
    nil
  end

  defp get_time_zone(socket) do
    case TimeZone.get_time_zone(
           get_connect_params(socket)["timeZone"],
           DateTime.utc_now()
         ) do
      {:ok, time_zone} -> time_zone
      _ -> TimeZone.get_time_zone("UTC", DateTime.utc_now()) |> elem(1)
    end
  end
end
