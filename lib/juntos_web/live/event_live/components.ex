defmodule JuntosWeb.EventLive.Components do
  use Phoenix.Component
  use Gettext, backend: JuntosWeb.Gettext
  import JuntosWeb.CoreComponents

  attr :id, :string
  attr :start_datetime_field, Phoenix.HTML.FormField, doc: "@form[:start_datetime]"
  attr :end_datetime_field, Phoenix.HTML.FormField, doc: "@form[:end_datetime]"
  attr :time_zone_field, Phoenix.HTML.FormField, doc: "@form[:time_zone]"

  def datepicker(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="EventDatepickerLocalDateTime"
      data-start-datetime-id={@start_datetime_field.id}
      data-end-datetime-id={@end_datetime_field.id}
      data-time-zone-id={@time_zone_field.id}
      class="bg-slate-100 p-2 rounded-lg flex flex-col gap-2 w-full max-w-[408px]"
    >
      <div class="flex flex-col w-full gap-2">
        <div class="flex">
          <div class="flex self-center text-slate-500">{gettext "Start"}</div>
          <div class="grow flex justify-end">
            <input
              class="rounderd-full text-base font-semibold text-slate-900 bg-slate-50 border-0 focus:ring-0"
              type="datetime-local"
              name={@start_datetime_field.name}
              id={@start_datetime_field.id}
              value={@start_datetime_field.value}
            />
          </div>
        </div>
        <div class="flex">
          <div class="flex self-center text-slate-500">{gettext "End"}</div>
          <div class="grow flex justify-end">
            <input
              class="rounderd-full font-semibold text-slate-900 bg-slate-50 border-0 focus:ring-0"
              type="datetime-local"
              name={@end_datetime_field.name}
              id={@end_datetime_field.id}
              value={@end_datetime_field.value}
            />
          </div>
        </div>
      </div>
      <div>
        <div class="bg-slate-200 py-1.5 px-2.5 flex justify-center place-content-center rounded-lg text-sm font-medium self-center">
          <.icon name="hero-globe-alt" class="w-4 h-4" /> &nbsp +01:00 Europe/Berlin
        </div>
        <input
          type="hidden"
          name={@time_zone_field.name}
          id={@time_zone_field.id}
          value={@time_zone_field.value || "UTC"}
        />
      </div>
    </div>
    """
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
end
