defmodule JuntosWeb.EventLive.Edit do
  use JuntosWeb, :live_view
  alias Juntos.Events
  @impl true
  def mount(params, _session, socket) do
    socket =
      if event = fetch_event_for_edit(params["id"], socket.assigns.current_scope) do
        setup_socket(event, socket)
      else
        redirect_with_error(socket)
      end

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"event" => event_params}, socket) do
    event_params =
      if event_params["description_editor"] do
        Map.put(event_params, "description", event_params["description_editor"])
      else
        event_params
      end

    # event_params = maybe_set_location(event_params, socket.assigns.event_location)

    changeset = Events.change_event(%Events.Event{}, event_params) |> Map.put(:action, :validate)
    {:noreply, socket |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", params, socket) do
    # upload_result =
    #  consume_uploaded_entries(socket, :cover, fn meta, entry ->
    #    image_plug_upload =
    #      %Plug.Upload{
    #        content_type: entry.client_type,
    #        filename: entry.client_name,
    #        path: meta.path
    #      }

    #    {:postpone, image_plug_upload}
    #  end)

    # event_params =
    #  case upload_result do
    #    [image_plug_upload] ->
    #      Map.put(params["event"], "cover_image", image_plug_upload)

    #    _ ->
    #      params["event"]
    #  end

    event_params = params["event"]
    event_params = maybe_set_location(event_params, socket.assigns.event_location)

    case Events.update_event(socket.assigns.event, event_params) do
      {:ok, event} ->
        {:noreply, redirect(socket, to: ~p"/#{event.slug}")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
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
  def handle_event("toggle-sheet", _params, socket) do
    {:noreply, socket |> assign(:show_desc, !socket.assigns.show_desc)}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-time-zone-selector", _params, socket) do
    {:noreply, socket |> assign(:show_time_zone_options, !socket.assigns.show_time_zone_options)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <:breadcrumb>
        <.link navigate={~p"/"}><.icon name="material_home" class="icon-size-4" /></.link>
      </:breadcrumb>
      <:breadcrumb>
        {gettext "edit event"}
      </:breadcrumb>
      <.page_wrapper data-role="edit-event-page">
        <.event_form form={@form}>
          <.form_header />

          <.name_input name={@form[:name]} />
          <.description_input
            show_desc={@show_desc}
            description={@form[:description]}
            description_editor={@form[:description_editor]}
          />

          <.date_input form={@form} show_time_zone_options={@show_time_zone_options} />

          <.location_input form={@form} />
          <.edit_button />
        </.event_form>
      </.page_wrapper>
    </Layouts.app>
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
        {gettext "Edit your event"}
      </.hero>
    </section>
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

  defp location_input(assigns) do
    ~H"""
    <.form_item>
      <:label>{gettext "Location"}*</:label>
      <:label_body>{gettext "Go in-person or oline. Add a spot if it's in-person"}</:label_body>
      <:input>
        <JuntosWeb.EventLive.Components.location_finder
          id="editEventlocationFinder"
          api_key={System.get_env("GMAP_API_KEY")}
        />
      </:input>
    </.form_item>
    """
  end

  defp edit_button(assigns) do
    ~H"""
    <.form_item>
      <:input>
        <.button class="w-full" type="submit" phx-disable-with={gettext "Saving ..."}>
          {gettext "Save & publish"}
        </.button>
      </:input>
    </.form_item>
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

  defp setup_socket(event, socket) do
    changeset = Events.change_event(event)

    socket
    |> assign(
      event: event,
      show_desc: false,
      show_time_zone_options: false,
      event_location: event.location
    )
    |> assign_form(changeset)
  end

  defp redirect_with_error(socket) do
    socket
    |> put_flash(:error, gettext("Event not found"))
    |> push_navigate(to: ~p"/")
  end

  defp fetch_event_for_edit(id, current_scope) do
    filters = [
      Events.query_events_for_scope(current_scope),
      Events.query_events_where_id(id)
    ]

    Events.get_event(filters)
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, form: form)
  end

  defp maybe_set_location(event_params, nil) do
    event_params
  end

  defp maybe_set_location(event_params, :reset) do
    Map.put(event_params, "location", nil)
  end

  defp maybe_set_location(event_params, event_location) do
    Map.put(event_params, "location", to_location(event_location))
  end

  defp to_location(%{"type" => type, "value" => value}) do
    Map.put(value, "__type__", type)
  end

  defp to_location(_) do
    nil
  end
end
