defmodule JuntosWeb.EventLive.New do
  use JuntosWeb, :live_view
  alias Juntos.Events

  @impl true
  def mount(_params, _session, socket) do
    changeset = Events.change_event()

    {:ok,
     socket
     |> assign(:uploaded_cover, [])
     |> assign(:show_desc, false)
     |> assign(:page_title, "Create a new event")
     |> allow_upload(:cover, accept: ~w(.jpg .jpeg .gif .png .webp), max_entries: 1)
     |> assign_form(changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-sheet", _params, socket) do
    {:noreply, socket |> assign(:show_desc, !socket.assigns.show_desc)}
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
        <.description_input show_desc={@show_desc} name={@form[:name]} />
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
        <.content_text>
          <.label_for field={@name}>{gettext "Event name"}*</.label_for>
        </.content_text>
      </:label>
      <:input>
        <.input field={@name} placeholder={gettext "Event name"} />
      </:input>
    </.form_item>
    """
  end

  defp description_input(assigns) do
    ~H"""
    <.form_item>
      <:label>
        <.content_text>
          <.label_for field={@name}>{gettext "Description"}*</.label_for>
        </.content_text>
      </:label>
      <:input>
        <.text_editor id="hello" name="ehllo" />
        <.button type="button" phx-click="toggle-sheet" class="text-sky-100">Open me</.button>
        <.bottom_sheet
          :if={@show_desc}
          id="description-editor"
          show
          on_cancel={JS.push("toggle-sheet")}
        >
          <:header>
            <h2 class="text-base text-primary font-bold">Describe Your Event</h2>
          </:header>
          <:body class="overflow-y-auto rounded-lg bg-neutral-primary w-full">
            <.text_editor id="hello" name="ehllo" />
          </:body>
          <:footer>
            <.button class="w-full" phx-click={JS.push("toggle-sheet")}>
              Save
            </.button>
          </:footer>
        </.bottom_sheet>
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
    <div class="flex flex-col w-full min-w-[320px]" data-role="new-event">
      <!--<div class="max-w-6xl  pt-6 px-4 pb-4  w-[764px] flex flex-col gap-4" data-role="new-event">-->
      <.simple_form for={@form} phx-change="validate" phx-submit="save" id="createEvent">
        <div class="flex flex-col gap-4 px-4 items-center">
          {render_slot(@inner_block)}
        </div>
      </.simple_form>
    </div>
    """
  end

  defp form_header(assigns) do
    ~H"""
    <section class="flex flex-col items-center w-full  max-w-md sm:max-w-lg md:max-w-3xl">
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
    <div class="flex flex-col md:flex-row md:justify-between w-full max-w-md sm:max-w-lg md:max-w-3xl border-b-2 last:border-b-0 border-neutral-secondary py-6 gap-2">
      <section class="w-full flex flex-col md:basis-4/10">
        <div class="font-bold text-primary">{render_slot(@label)}</div>
        <div class="text-sm text-secondary">{render_slot(@label_body)}</div>
      </section>
      <section class="flex  sm:justify-end md:basis-md">
        {render_slot(@input)}
      </section>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, form: form)
  end
end
