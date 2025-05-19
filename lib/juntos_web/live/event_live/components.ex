defmodule JuntosWeb.EventLive.Components do
  use Phoenix.Component
  use JuntosWeb, :verified_routes
  use Gettext, backend: JuntosWeb.Gettext
  import JuntosWeb.CoreComponents
  alias Phoenix.LiveView.JS
  alias Juntos.Events

  attr :id, :string
  attr :start_datetime_field, Phoenix.HTML.FormField, doc: "@form[:start_datetime]"
  attr :end_datetime_field, Phoenix.HTML.FormField, doc: "@form[:end_datetime]"
  attr :time_zone_field, Phoenix.HTML.FormField, doc: "@form[:time_zone]"
  attr :show_time_zone_options, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}

  def datepicker(assigns) do
    end_datetime_errors = field_to_errors(assigns.end_datetime_field)
    start_datetime_errors = field_to_errors(assigns.start_datetime_field)

    assigns =
      assigns
      |> assign(:end_datetime_errors, end_datetime_errors)
      |> assign(:start_datetime_errors, start_datetime_errors)

    ~H"""
    <div
      id={@id}
      phx-hook="EventDatepickerLocalDateTime"
      data-start-datetime-id={@start_datetime_field.id}
      data-end-datetime-id={@end_datetime_field.id}
      data-time-zone-id={@time_zone_field.id}
      class="bg-(--color-bg-neutral-tertiary)  flex w-full max-w-md flex-col gap-2 rounded-lg p-2"
    >
      <div class="flex w-full flex-col gap-2">
        <div class="flex">
          <div class="text-neutral-secondary flex self-center">{gettext "Start"}</div>
          <div class="flex grow justify-end">
            <input
              class={[
                "text-neutral-primary bg-neutral-primary border-neutral-secondary animated rounded-lg border px-3 py-2 text-base font-semibold outline-0 focus:ring-0",
                if(@start_datetime_errors != [], do: "border-(--color-border-status-error)")
              ]}
              type="datetime-local"
              name={@start_datetime_field.name}
              id={@start_datetime_field.id}
              value={@start_datetime_field.value}
              phx-throttle="2000"
            />
          </div>
        </div>
        <div class="flex">
          <div class="text-neutral-secondary  flex self-center">{gettext "End"}</div>
          <div class="flex grow justify-end">
            <input
              class={[
                "text-neutral-primary bg-neutral-primary border-neutral-secondary animated rounded-lg border px-3 py-2 text-base font-semibold outline-0 focus:ring-0",
                if(@end_datetime_errors != [], do: "border-(--color-border-status-error)")
              ]}
              type="datetime-local"
              name={@end_datetime_field.name}
              id={@end_datetime_field.id}
              value={@end_datetime_field.value}
              phx-throttle="1000"
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
        <div
          :if={@end_datetime_errors != [] or @start_datetime_errors != []}
          class="pt-0.5 errors text-sm text-(--color-text-status-error)"
          data-role="error-for-datetime"
        >
          <div :for={msg <- @start_datetime_errors}>{gettext "Start date"} {msg}</div>
          <div :for={msg <- @end_datetime_errors}>{gettext "End date"} {msg}</div>
        </div>

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

  defp field_to_errors(field) do
    errors =
      if Phoenix.Component.used_input?(field),
        do: field.errors,
        else: []

    Enum.map(errors, &JuntosWeb.CoreComponents.translate_error(&1))
  end

  attr :id, :string, required: false, default: nil
  attr :event, :any, required: true
  attr :past_event?, :boolean, required: false, default: false
  attr :manage_event?, :boolean, required: false, default: false

  def list_event_card(assigns) do
    ~H"""
    <div
      id={@id}
      class="flex w-full min-w-2xs max-w-3xl rounded-2xl border-1 border-(--color-border-neutral-primary) bg-(--color-bg-neutral-primary)/50 backdrop-blur-lg shadow-xl dark:shadow-slate-100/1 shadow-slate-900/4 px-3 place-self-center  hover:border-(--color-border-neutral-secondary)/50 animated cursor-pointer"
      role="link"
      phx-click={JS.navigate(~p"/#{@event.slug}")}
    >
      <div class="py-3  pr-1 flex-shrink-0">
        <.event_card_cover_image cover_image={Events.event_cover_url(@event)} />
      </div>
      <div class="grow flex flex-col pl-1  py-3">
        <div class="flex [&>*:first-child]:grow">
          <.event_card_schedule event={@event} past_event?={@past_event?} />
          <div class=" flex-shrink-0">
            <.event_card_manage_button
              :if={@manage_event?}
              event={@event}
              manage_event?={@manage_event?}
              past_event?={@past_event?}
            />
          </div>
        </div>
        <div class="grow font-bold text-base  flex flex flex-col justify-center text-sm min-[450px]:text-base ">
          <.link class="" navigate={~p"/#{@event.slug}"}>
            {@event.name}
          </.link>
        </div>
        <div class="flex">
          <div class="grow flex items-center  text-xs min-[450px]:text-sm gap-1">
            <.event_card_location event={@event} />
          </div>
          <.event_card_past_label :if={@past_event?} />
        </div>
      </div>
    </div>
    """
  end

  defp event_card_cover_image(%{cover_image: %{media_type: :gif}} = assigns) do
    ~H"""
    <picture class="">
      <img src={@cover_image.original} class="size-27 md:size-29 aspect-square rounded-lg" />
    </picture>
    """
  end

  defp event_card_cover_image(assigns) do
    ~H"""
    <picture class="">
      <source srcset={@cover_image.webp} type="image/webp" />
      <img src={@cover_image.jpg} class="size-27 md:size-29 aspect-square rounded-lg" />
    </picture>
    """
  end

  defp event_card_schedule(assigns) do
    ~H"""
    <div class="grow text-xs min-[450px]:text-sm flex items-center gap-1">
      <.icon
        name="material_date_range"
        class={[
          "icon-size-4 bg-(--color-bg-accent-brand-muted) rounded-full p-0.5",
          @past_event? == true && "bg-(--color-bg-status-disabled)"
        ]}
      />
      <span>
        <span class="hidden min-[450px]:block">{datetime_to_short_date(@event.start_datetime)}</span>
        <span class="min-[450px]:hidden">
          {datetime_to_ddmmyy(@event.start_datetime)}
        </span>
      </span>
      <span class="px-1"></span>
      <.icon
        name="material_schedule"
        class={[
          "icon-size-4 bg-(--color-bg-accent-brand-muted) rounded-full p-0.5",
          @past_event? == true && "bg-(--color-bg-status-disabled)"
        ]}
      /> {datetime_to_hh_mm(@event.start_datetime)}
    </div>
    """
  end

  defp event_card_manage_button(assigns) do
    ~H"""
    <div data-role="manage-event-button">
      <.button
        class="hidden min-[450px]:block"
        href={~p"/events/#{@event}/edit"}
        type="link"
        size="sm"
        variant={(@past_event? && "outline") || "secondary"}
      >
        {gettext "Manage"}
      </.button>

      <.button
        class="min-[450px]:hidden flex w-4 !min-w-1"
        href={~p"/events/#{@event}/edit"}
        type="link"
        size="sm"
        variant={(@past_event? && "outline") || "secondary"}
      >
        <.icon class="hidden sm:hidden text-sm" name="material_settings" />
      </.button>
    </div>
    """
  end

  defp event_card_past_label(assigns) do
    ~H"""
    <div class="flex-shrink-0" data-role="past-event-label">
      <div class="py-1 px-2 rounded-full border border-(--color-border-neutral-primary) bg-(--color-bg-neutral-secondary) text-xs font-medium">
        Past event
      </div>
    </div>
    """
  end

  defp event_card_location(%{event: %{location: %Juntos.Events.Event.Url{}}} = assigns) do
    ~H"""
    <div class="flex gap-1 justify-center items-center" data-role="online-event-label">
      <.icon name="material_videocam" class="icon-size-4" /> {gettext "Online"}
    </div>
    """
  end

  defp event_card_location(%{event: %{location: %Juntos.Events.Event.Address{}}} = assigns) do
    ~H"""
    <div class="flex gap-1 justify-center items-center" data-role="address-event-label">
      <.icon name="material_location_on" class="icon-size-4" /> {gettext "Custom"}
    </div>
    """
  end

  defp event_card_location(%{event: %{location: %Juntos.Events.Event.Place{}}} = assigns) do
    ~H"""
    <div class="flex gap-1 justify-center items-center" data-role="place-event-label">
      <.icon name="material_location_on" class="icon-size-4" /> {[
        @event.location.city || @event.location.name,
        @event.location.country
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")}
    </div>
    """
  end

  defp event_card_location(assigns) do
    ~H"""
    """
  end
end
