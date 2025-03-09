defmodule JuntosWeb.EventLive.Components do
  use Phoenix.Component
  use Gettext, backend: JuntosWeb.Gettext
  import JuntosWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :id, :string
  attr :start_datetime_field, Phoenix.HTML.FormField, doc: "@form[:start_datetime]"
  attr :end_datetime_field, Phoenix.HTML.FormField, doc: "@form[:end_datetime]"
  attr :time_zone_field, Phoenix.HTML.FormField, doc: "@form[:time_zone]"
  attr :show_time_zone_options, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}

  def datepicker(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="EventDatepickerLocalDateTime"
      data-start-datetime-id={@start_datetime_field.id}
      data-end-datetime-id={@end_datetime_field.id}
      data-time-zone-id={@time_zone_field.id}
      class="bg-neutral-secondary  p-2 rounded-lg flex flex-col gap-2 w-full max-w-md"
    >
      <div class="flex flex-col w-full gap-2">
        <div class="flex">
          <div class="flex self-center text-secondary">{gettext "Start"}</div>
          <div class="grow flex justify-end">
            <input
              class="rounded-lg text-base font-semibold text-primary bg-neutral-primary border border-neutral-secondary  focus:ring-0 px-3 py-2 outline-0 animated"
              type="datetime-local"
              name={@start_datetime_field.name}
              id={@start_datetime_field.id}
              value={@start_datetime_field.value}
            />
          </div>
        </div>
        <div class="flex">
          <div class="flex self-center text-secondary">{gettext "End"}</div>
          <div class="grow flex justify-end">
            <input
              class="rounded-lg text-base font-semibold text-primary bg-neutral-primary border border-neutral-secondary focus:ring-0 px-3 py-2 outline-0 animated"
              type="datetime-local"
              name={@end_datetime_field.name}
              id={@end_datetime_field.id}
              value={@end_datetime_field.value}
            />
          </div>
        </div>
      </div>
      <div>
        <button
          type="button"
          class="bg-neutral-primary w-full text-primary py-1.5 px-2.5 flex justify-center place-content-center rounded-lg text-sm font-medium self-center flex flex-row place-items-center cursor-pointer border border-neutral-secondary outline-0"
          phx-click="toggle-time-zone-selector"
        >
          <.icon name="hero-globe-alt" class="w-4 h-4" />
          <div>
            &nbsp {time_zone_to_str(@time_zone_field.value)}
          </div>
        </button>
        <input
          type="hidden"
          name={@time_zone_field.name}
          id={@time_zone_field.id}
          value={@time_zone_field.value}
        />

        <.dropdown
          :if={@show_time_zone_options}
          id="time-zone-options"
          show
          on_cancel={JS.push("toggle-time-zone-selector")}
        >
          <ul class="flex flex-col [&>button]:cursor-pointer space-y-2 [&>li]:p-2 [&>li]:w-full [&>li:hover]:bg-[var(--color-bg-neutral-primary-hover)] text-primary/6">
            <li :for={tz <- Juntos.Chrono.TimeZone.get_list_of_time_zones()}>
              <button
                type="button"
                phx-click={
                  hide_dropdown("time-zone-options")
                  |> JS.push("toggle-time-zone-selector")
                  |> JS.dispatch("juntos:force_set_value",
                    to: "##{@time_zone_field.id}",
                    detail: %{value: tz.zone_name}
                  )
                }
                class="cursor-pointer w-full flex items-start text-primary "
              >
                ({tz.offset_str}) {tz.zone_name}
              </button>
            </li>
          </ul>
        </.dropdown>
      </div>
    </div>
    """
  end

  defp time_zone_to_str(nil) do
    ""
  end

  defp time_zone_to_str(value) do
    case Juntos.Chrono.TimeZone.get_time_zone(value) do
      {:ok, tz} ->
        "#{tz.offset_str} #{tz.zone_name}"

      _ ->
        "GMT+00:00 UTC"
    end
  end

  attr :id, :string, required: true
  attr :api_key, :string, required: true

  def location_finder(assigns) do
    ~H"""
    <div id={@id} phx-hook="LocationFinder" data-api-key={@api_key}>
      <div class="mt-2 grid grid-cols-1">
        <input
          type="text"
          class="col-start-1 row-start-1 block w-full rounded-md bg-white
      py-1.5 pl-10 pr-10 text-base
      focus:outline focus:outline-2 focus:-outline-offset-2  sm:pr-9 "
          autocomplete="new-password"
          data-1p-ignore
        />
        <.icon
          name="hero-map-pin"
          class="input-leading-icon pointer-events-none col-start-1 row-start-1 ml-3 size-5 self-center text-gray-400 sm:size-4"
        />
        <.icon
          name="hero-x-mark"
          class="input-trailing-icon hidden cursor-pointer col-start-1 row-start-1 mr-3 size-5 self-center justify-self-end text-gray-400"
        />
      </div>
      <ul class="" role="listbox"></ul>
    </div>
    """
  end

  attr :show_desc, :boolean, required: true
  attr :value, :string, required: true

  attr :description_editor, Phoenix.HTML.FormField,
    doc: "a shadow form container for orignial value"

  def description_editor(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="toggle-sheet"
      class="w-md border border-neutral-secondary rounded-lg text-secondary bg-neutral-secondary  flex px-2 py-1 min-h-24 max-h-24 cursor-text outline-0 animated"
    >
      <span :if={@value in [nil, ""]}>
        {gettext "Share details about your event..."}
      </span>
      <span :if={@value not in [nil, ""]}>
        {summerize_description(@value)}
      </span>
    </button>
    <.bottom_sheet :if={@show_desc} id="description-editor" show on_cancel={JS.push("toggle-sheet")}>
      <:header>
        <h2 class="text-base text-primary font-bold">{gettext "Describe Your Event"}</h2>
      </:header>
      <:body class="overflow-y-auto rounded-lg bg-neutral-primary w-full border border-neutral-secondary">
        <.text_editor field={@description_editor} value={@value} editable autofocus />
      </:body>
      <:footer>
        <.button type="button" class="w-full" phx-click={JS.push("toggle-sheet")}>
          Save
        </.button>
      </:footer>
    </.bottom_sheet>
    """
  end

  def upload_image_area(assigns) do
    ~H"""
    <section
      id="uploadImageArea"
      phx-hook="DragAndDropBgChange"
      phx-drop-target={@upload_ref}
      class="text-primary w-md bg-neutral-secondary py-10 px-4 flex justify-center gap rounded-lg border-accent-brand border-dashed border-2 text-accent-brand font-medium transition-colors duration-300 gap-1 cursor-pointer"
      aria-label="upload"
    >
      <.icon name="hero-photo" /> {gettext "Upload an image"}
    </section>
    """
  end

  defp summerize_description(value) do
    Jason.decode!(value)
    |> do_summerize_description()
  end

  defp do_summerize_description(%{"content" => [head | _]}) do
    do_summerize_description(head)
  end

  defp do_summerize_description(%{"text" => text}) do
    "#{String.slice(text, 0, 20)}..."
  end

  defp do_summerize_description(_) do
    "..."
  end
end
