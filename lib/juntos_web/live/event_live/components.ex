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
      class="bg-neutral-secondary  flex w-full max-w-md flex-col gap-2 rounded-lg p-2"
    >
      <div class="flex w-full flex-col gap-2">
        <div class="flex">
          <div class="text-neutral-secondary flex self-center">{gettext "Start"}</div>
          <div class="flex grow justify-end">
            <input
              class="text-neutral-primary bg-neutral-primary border-neutral-secondary animated rounded-lg border px-3  py-2 text-base font-semibold outline-0 focus:ring-0"
              type="datetime-local"
              name={@start_datetime_field.name}
              id={@start_datetime_field.id}
              value={@start_datetime_field.value}
              phx-debounce="2000"
            />
          </div>
        </div>
        <div class="flex">
          <div class="text-neutral-secondary  flex self-center">{gettext "End"}</div>
          <div class="flex grow justify-end">
            <input
              class="text-neutral-primary bg-neutral-primary border-neutral-secondary animated rounded-lg border px-3 py-2 text-base font-semibold outline-0 focus:ring-0"
              type="datetime-local"
              name={@end_datetime_field.name}
              id={@end_datetime_field.id}
              value={@end_datetime_field.value}
              phx-debounce="2000"
            />
          </div>
        </div>
      </div>
      <div>
        <button
          type="button"
          class="bg-neutral-primary text-neutral-primary border-neutral-secondary flex flex w-full cursor-pointer flex-row place-content-center place-items-center justify-center self-center rounded-lg border px-2.5 py-1.5 text-sm font-medium outline-0"
          phx-click="toggle-time-zone-selector"
        >
          <.icon name="hero-globe-alt" class="h-4 w-4" />
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
          <ul class="text-neutral-primary flex flex-col space-y-2 [&>button]:cursor-pointer [&>li:hover]:bg-[var(--color-bg-neutral-primary-hover)] [&>li]:w-full [&>li]:p-2">
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
                class="text-neutral-primary flex w-full cursor-pointer items-start "
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
    <div id={@id} phx-hook="LocationFinder" data-api-key={@api_key} class="w-full">
      <div class="mt-2 grid grid-cols-1">
        <input
          type="text"
          class="bg-neutral-primary border-neutral-secondary text-neutral-primary animated col-start-1 row-start-1 block w-full rounded-md border py-1.5 pl-10 pr-10 text-base outline-0 sm:pr-9"
          autocomplete="new-password"
          placeholder={gettext "Search for a location"}
          data-1p-ignore
          phx-debounce="2000"
        />
        <.icon
          name="hero-map-pin"
          class="input-leading-icon size-5 sm:size-4 text-neutral-secondary pointer-events-none col-start-1 row-start-1 ml-3 self-center"
        />
        <.icon
          name="hero-x-mark"
          class="input-trailing-icon size-5 col-start-1 row-start-1 mr-3 hidden cursor-pointer self-center justify-self-end text-gray-400"
        />
      </div>
      <ul
        class="bg-neutral-primary border-neutral-secondary text-neutral-primary rounded-lg border text-base [&>li:first-child]:rounded-t-lg [&>li:hover]:bg-[var(--color-bg-neutral-primary-hover)] [&>li:last-child]:rounded-b-lg [&>li]:w-full [&>li]:cursor-pointer [&>li]:p-2 "
        role="listbox"
      >
      </ul>
    </div>
    """
  end

  attr :show_desc, :boolean, required: true
  attr :value, :string, required: true

  attr :description_editor, Phoenix.HTML.FormField,
    doc: "a form for orignial value container shadow"

  def description_editor(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="toggle-sheet"
      class="w-md border-neutral-secondary text-neutral-secondary bg-neutral-primary min-h-24 animated  flex max-h-24 cursor-text rounded-lg border px-2 py-1 outline-0"
    >
      <span :if={@value in [nil, ""]}>
        {gettext "Share details about your event..."}
      </span>
      <span :if={@value not in [nil, ""]}>
        {summerize_description(@value)}
      </span>
    </button>
    <.bottom_sheet
      :if={@show_desc}
      id="description-editor"
      show
      on_cancel={JS.push("toggle-sheet")}
      class="max-h-9/10 min-h-4/10"
    >
      <:header>
        <h2 class="text-neutral-primary text-base font-bold">{gettext "Describe Your Event"}</h2>
      </:header>
      <:body class="bg-neutral-primary border-neutral-secondary w-full overflow-y-auto rounded-lg border">
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
      class="text-neutral-primary w-full max-w-md bg-neutral-secondary gap border-accent-brand text-accent-brand flex cursor-pointer justify-center gap-1 rounded-lg border-2 border-dashed px-4 py-10 font-medium transition-colors duration-300"
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
