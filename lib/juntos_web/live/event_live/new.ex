defmodule JuntosWeb.EventLive.New do
  use JuntosWeb, :live_view
  alias Juntos.Events

  @impl true
  def mount(_params, _session, socket) do
    changeset = Events.change_event()

    {:ok,
     socket
     |> assign(:uploaded_cover, [])
     |> assign(:page_title, "Create a new event")
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .gif .png .webp), max_entries: 1)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
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
        <.cover_input form={@form} uploads={@uploads} />
        <.date_input form={@form} />
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
      <:input></:input>
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
        <div class="flex justify-end">
          <JuntosWeb.EventLive.Components.datepicker
            id="new-event-datepicker"
            start_datetime_field={@form[:start_datetime]}
            end_datetime_field={@form[:end_datetime]}
            time_zone_field={@form[:time_zone]}
          />
        </div>
      </:input>
    </.form_item>
    """
  end

  defp name_input(assigns) do
    ~H"""
    <.form_item>
      <:label>
        <.label_for field={@name}>{gettext "Event name"}*</.label_for>
      </:label>
      <:input>
        <.input field={@name} placeholder={gettext "Event name"} />
      </:input>
    </.form_item>
    """
  end

  defp cover_input(assigns) do
    ~H"""
    <.form_item>
      <:label>
        <label for={@uploads.cover.ref}>{gettext "Cover image"}</label>
      </:label>
      <:label_body>{gettext "Skip the upload? We'll pick a cool image for you!"}</:label_body>
      <:input>
        <section phx-drop-target={@uploads.cover.ref} class="text-primary">
          <article :for={entry <- @uploads.cover.entries} class="upload-entry">
            <figure>
              <.live_img_preview entry={entry} class="w-52" />
            </figure>
            <progress value={entry.progress} max="100">{entry.progress}%</progress>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
            >
              &times;
            </button>
          </article>
          <.live_file_input upload={@uploads.cover} />
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
    <div class="max-w-6xl  pt-6 px-4 pb-4  w-[680px] flex flex-col gap-4" data-role="new-event">
      <.simple_form for={@form} phx-change="validate" phx-submit="save" id="createEvent">
        {render_slot(@inner_block)}
      </.simple_form>
    </div>
    """
  end

  defp form_header(assigns) do
    ~H"""
    <.hero align="left">
      {gettext "Create a new event"}
    </.hero>
    """
  end

  slot :label, required: false
  slot :label_body, required: false
  slot :input, required: true

  defp form_item(assigns) do
    ~H"""
    <div class="flex max-w-6xl border-b-2 last:border-b-0 py-6">
      <div class="w-[240px]">
        <div class="font-bold text-primary">{render_slot(@label)}</div>
        <div class="text-sm text-secondary">{render_slot(@label_body)}</div>
      </div>
      <div class="min-w-12 grow">{render_slot(@input)}</div>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, form: form)
  end
end
