defmodule JuntoWeb.EventLive.Components do
  use Phoenix.Component

  import JuntoWeb.BaseComponents
  import JuntoWeb.CoreComponents
  alias Phoenix.LiveView.JS
  import JuntoWeb.Gettext

  @event_scopes %{
    public: %{
      order: 0,
      type: :public,
      title: "Public",
      icon: "hero-globe-alt",
      desc: "Show on your group. Could be listed and suggested "
    },
    private: %{
      order: 1,
      type: :private,
      title: "Private",
      icon: "hero-sparkles-solid",
      desc: "Unlisted. Only people with the link can register"
    }
  }

  attr :field, Phoenix.HTML.FormField, required: true

  def event_title_input(assigns) do
    ~H"""
    <div class="min-h-12">
      <div class="sr-only">{gettext "Event name"}</div>
      <.base_input
        type="textarea"
        field={@field}
        autofocus
        autocapitalize="words"
        spellcheck="false"
        class={["h-12 w-full create-event-textarea-style rounded-md", maybe_add_error_style(@field)]}
        placeholder={gettext "Event name"}
        onInput="this.parentNode.dataset.clonedVal = this.value"
        row="2"
        error-label-class="sr-only"
      />
      <script>
        const textarea = document.getElementById("<%= @field.id %>");
            //TODO: move it out of here
            textarea.addEventListener('input', () => {
            if (textarea.scrollHeight < 50) return;
                textarea.style.height = 'auto';
                textarea.style.height = `${textarea.scrollHeight}px`;
            });
                
          
      </script>
    </div>
    """
  end

  def datepick(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "flex gap-2 w-full px-3 py-2 animated create-event-button-style sm:hidden outline-none focus:outline-none",
        maybe_add_error_style(@start_date)
      ]}
      phx-click={base_show_modal("datepickModal")}
    >
      <div class="-z-[1]"><.base_icon name="hero-clock" class="w-4 h-4" /></div>
      <div class="min-w-0 text-left">
        <div class="font-medium truncate">{date_to_text(@start_datetime)}</div>
        <div class="text-sm truncate">
          {time_to_text(@start_datetime, @end_datetime, @time_zone_value)}
        </div>
      </div>
    </button>

    <.datepick_modal
      start_datetime={@start_datetime}
      start_date={@start_date}
      start_time={@start_time}
      end_datetime={@end_datetime}
      end_date={@end_date}
      end_time={@end_time}
      time_zone={@time_zone}
      time_zone_value={@time_zone_value}
    />
    """
  end

  defp datepick_modal(assigns) do
    ~H"""
    <.base_modal id="datepickModal">
      <div class="w-full max-w-2xl max-h-full bg-transparent">
        <div class="relative rounded-lg shadow-lg shadow-black bg-white/90 dark:bg-neutral-900/70 backdrop-blur-lg dark:text-white">
          <div class="p-4 flex flex-col gap-2">
            <div class="">
              <div class="font-semibold text-lg">{gettext "Event Time"}</div>
            </div>
            <.datepick_date
              date={@start_date}
              time={@start_time}
              datetime={@start_datetime}
              label={gettext "Start"}
            />
            <.datepick_date
              date={@end_date}
              time={@end_time}
              datetime={@end_datetime}
              label={gettext "End"}
            />
            <.datepick_timezone time_zone={@time_zone} time_zone_value={@time_zone_value} />
          </div>
        </div>
      </div>
    </.base_modal>
    """
  end

  defp datepick_date(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="flex items-center text-sm opacity-60">{@label}</div>
      <div class="pl-3 grow flex justify-end">
        <.input_datetime date={@date} time={@time} datetime={@datetime} />
      </div>
    </div>
    """
  end

  defp input_datetime(assigns) do
    assigns =
      Map.put(
        assigns,
        :input_class,
        "bg-transparent border-black/10 hover:border-black/40 dark:border-white/10 dark:hover:border-white/80 border focus:ring-0 focus:outline-none focus:border-black/40 dark:focus:border-white/80"
      )

    ~H"""
    <.base_input
      field={@date}
      data-popover-target={"popover-default" <> @date.id }
      class={[@input_class, "rounded-l-md", maybe_add_error_style(@date)]}
      type="date"
      error-label-class="sr-only"
      required
    />
    <.base_input
      value={Junto.Chrono.Formatter.to_hh_mm_str(@datetime.value)}
      field={@time}
      class={[@input_class, "-ml-[2px] rounded-r-md"]}
      type="time"
      required
    />
    <div
      data-popover
      id={"popover-default" <> @date.id }
      role="tooltip"
      class={[
        "invisible  text-black",
        @date.errors != [] && "bg-red-100 rounded-md px-2 py-1"
      ]}
    >
      <.base_error :for={msg <- Enum.map(@date.errors, &translate_error(&1))} :if={@date.errors}>
        {msg}
      </.base_error>
    </div>
    """
  end

  defp datepick_timezone(assigns) do
    ~H"""
    <.base_input
      type="hidden"
      field={@time_zone}
      value={@time_zone_value.zone_name}
      data-role="time_zone_value"
    />
    <div class="flex flex-row text-sm">
      <div class="flex items-center opacity-60">{gettext "Timezone"}</div>
      <div class="pl-3 grow flex justify-end"></div>
      <.dropdown id="timezoneDropdown">
        <:button
          id="timezoneDropdownBtnBtn"
          dropdown-toggle="timezoneDropdown"
          class="bg-transparent border-black/10 hover:border-black/40 dark:border-white/10 dark:hover:border-white/80 border rounded  px-1 py-2 focus:ring-0 focus:outline-none focus:border-black/40 dark:focus:border-white/80"
        >
          <div class="min-w-0 flex gap-2 m">
            <div class="dark:text-white/50">{@time_zone_value.offset_str}</div>
            <div class="inline truncate">{@time_zone_value.zone_short_name}</div>
            <div><.icon name="hero-chevron-down " class="h-4 w-4" /></div>
          </div>
        </:button>
        <div class="dark:bg-black/50 backdrop-blur-lg rounded-md w-80 shadow-black shadow-lg">
          <div class="bg-black/10 dark:bg-white/10 w-full rounded-t-md">
            <input
              tabindex="-1"
              type="text"
              class="bg-transparent dark:placeholder-white/40 text-sm outline-none focus:ring-0 border-none focus:outline-none focus:ring-0"
              placeholder="Search for a timzone"
            />
          </div>

          <div class="max-h-44 overflow-auto">
            <ul class="p-1">
              <li :for={timezone <- Junto.Chrono.Timezone.get_list_of_timezones()}>
                <button
                  type="button"
                  class="flex text-left w-full hover:bg-black/10 dark:hover:bg-white/10 rounded-md py-1 px-2"
                  phx-click={JS.push("select-timezone", value: %{zone_name: timezone.zone_name})}
                >
                  <div class="truncate grow">{timezone.zone_name}</div>
                  <div class="text-black/50 dark:text-white/50 base-1 flex justify-end">
                    {timezone.offset_str}
                  </div>
                </button>
              </li>
            </ul>
          </div>
        </div>
      </.dropdown>
    </div>
    """
  end

  def location_modal(assigns) do
    ~H"""
    <.modal id="locationModal">
      <div class="dark:bg-black/50 backdrop-blur-lg rounded-md shadow-black shadow-lg">
        <div
          id="gmap-new-event-lookup2"
          class="input-container -mt-2 -mx-1 rounded-t-md pb-1"
          phx-hook="GmapLookup"
          data-api-key={get_gmaps_api_key()}
        >
          <input
            type="text"
            id="locationModalTextarea"
            phx-change="event-ignore"
            class="bg-black/20 dark:bg-white/10 w-full rounded-t-md dark:placeholder-white/40 outline-none focus:ring-0 border-none focus:outline-none focus:ring-0 w-full"
            placeholder="Enter Location"
            autocomplete="off"
          />
          <div :if={@gmap_suggested_places == []}>&nbsp;</div>
          <div :if={@gmap_suggested_places}>
            <menu class="gmap-suggested-places">
              <li :for={place <- @gmap_suggested_places}>
                <button
                  type="button"
                  class="text-left w-full create-event-dropdown-menu-group-selector"
                  tabindex="0"
                  phx-click={JS.push("select-place", value: place) |> hide_modal("locationModal")}
                >
                  <.event_place_item name={place["name"]} location={place["address"]} />
                </button>
              </li>
            </menu>
          </div>
        </div>
      </div>
    </.modal>
    """
  end

  def location(assigns) do
    ~H"""
    <button
      class="flex gap-2 w-full px-3 py-2  animated create-event-button-style outline-none focus:outline-none"
      type="button"
      phx-click={show_modal("locationModal")}
    >
      <div class="-z-[1]"><.icon name="hero-map-pin" class="w-5 h-5" /></div>
      <div :if={is_nil(@place)}>
        <div class="text-left">{gettext "Add Event Location"}</div>
        <div class="text-sm text-left">{gettext "Offline location or virutal link"}</div>
      </div>
      <div :if={@place} class="grow">
        <div class="text-left font-medium">{@place["name"]}</div>
        <div class="text-left text-sm">{@place["address"]}</div>
      </div>
      <div :if={@place} class="pt-1 pr-1" phx-click="deselect-place" role="button">
        <div class="flex items-center justify-center rounded-full p-1 hover-block-custom">
          <.icon name="hero-x-mark" class="w-5 h-5 " />
        </div>
        <div class="sr-only">{gettext "close"}</div>
      </div>
    </button>
    <.location_modal gmap_suggested_places={@gmap_suggested_places} />
    <div :if={@place && @force_rerender_map != true}>
      <div
        data-place={Jason.encode!(@place)}
        data-map-id={get_gmaps_id()}
        id="google-map"
        class="h-32"
        phx-hook="Gmaps"
        data-api-key={get_gmaps_api_key()}
        phx-update="ignore"
      >
      </div>
    </div>
    """
  end

  defp event_place_item(assigns) do
    ~H"""
    <div class="flex p-2 dark:text-slate-400 text-slate-500 hover:bg-gray-700/10 rounded-md cursor-pointer">
      <div class="my-auto w-6"><.icon name="hero-map-pin" class="w-5 h5" /></div>
      <div class="pl-2">
        <div class="dark:text-slate-100 text-slate-900">{@name}</div>
        <div class="text-sm max-w-md">{@location}</div>
      </div>
    </div>
    """
  end

  def description(assigns) do
    ~H"""
    <button
      class="flex gap-2 w-full px-3 py-2  animated create-event-button-style outline-none focus:outline-none"
      phx-click={show_modal("eventDescriptionModal")}
      type="button"
    >
      <div>
        <.icon name="hero-document-text" class="w-5 h-5" />
      </div>
      <div>
        <div class="text-left">Event Description</div>
        <div class="text-sm text-left"></div>
      </div>
    </button>
    <.modal id="eventDescriptionModal">
      <div class="w-full max-w-2xl max-h-full bg-transparent shadow-lg backdrop-blur-lg shadow-black   bg-white/90 dark:bg-neutral-900/70  dark:text-white">
        <div class="rounded-t-lg">
          <div class="p-4 flex flex-col gap-2">
            <div class="flex flex-row">
              <div class="font-semibold text-lg">Event Description</div>
              <button
                type="button"
                class="rounded-full p-1 hover-block-custom text-gray-400 bg-transparent rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center "
                phx-click={hide_modal("eventDescriptionModal")}
              >
                <.icon name="hero-x-mark" class="w-4 h-4" />
                <span class="sr-only">Close modal</span>
              </button>
            </div>
          </div>
        </div>
        <div class="p-4 md:p-5 space-y-4 bg-gray-950">
          <.text_editor
            field={@field}
            placeholder="What's event about?"
            class="prose prose-sm sm:prose lg:prose-lg xl:prose-2xl mx-auto focus:outline-none prose max-w-none min-h-20 max-h-64 overflow-y-auto "
          />
        </div>
        <div class="rounded-b-2xl">
          <div class="p-4">
            <.base_button class="dark:bg-white bg-black dark:text-black text-white rounded-lg font-medium px-3 py-2">
              Done
            </.base_button>
          </div>
        </div>
      </div>
    </.modal>
    """
  end

  def scope_dropdown(assigns) do
    assigns = Map.put(assigns, :event_scopes, @event_scopes)

    ~H"""
    <.base_input field={@field} type="hidden" />
    <.header_dropdown id="scopeDropdown">
      <:title>
        <div class="whitespace-nowrap">
          <.icon name={@event_scopes[@selected_scope].icon} class="w-4 h-4" /> {@event_scopes[
            @selected_scope
          ].title}
        </div>
      </:title>
      <div class="!ml-[-15px] select-none z-50 pt-2 pb-2 px-1 w-72 create-event-dropdown-menu-style select-none">
        <.scope_dropdown_menu_items selected_scope={@selected_scope} event_scopes={@event_scopes} />
      </div>
    </.header_dropdown>
    """
  end

  def scope_dropdown_menu_items(assigns) do
    ~H"""
    <.dropdown_list_button>
      <:item
        :for={{_, scope} <- Enum.sort_by(@event_scopes, &elem(&1, 1).order)}
        custom-phx-select={
          JS.set_attribute({"value", scope.type}, to: "#create_event_form_scope")
          |> JS.push("select-scope", value: %{type: scope.type})
        }
        class="dark:hover:bg-white/5"
      >
        <div class="flex p-2">
          <div class="my-auto w-6"><.icon name={scope.icon} class="w-4 h4" /></div>
          <div class="text-sm pl-2 text-left">
            <div class="dark:text-slate-100 text-slate-900">{scope.title}</div>
            <div>{scope.desc}</div>
          </div>
          <div class="my-auto w-6">
            <.icon :if={@selected_scope == scope.type} name="hero-check" class="w-4 h4" />
          </div>
        </div>
      </:item>
    </.dropdown_list_button>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, required: false, default: ""
  slot :title, required: true
  slot :inner_block, required: true

  def header_dropdown(assigns) do
    ~H"""
    <.dropdown id={@id}>
      <:button id={@id <> "Btn"} dropdown-toggle={@id} class={@class <> "min-w-0"}>
        <div class="flex w-fit-d gap-2 px-4 py-1 items-center text-sm font-medium animated create-event-dropdown-style">
          {render_slot(@title)}

          <div class="-mt-[4px]">
            <.icon name="hero-chevron-down text-sm font-medium" class="h-4 w-4" />
          </div>
        </div>
      </:button>
      <div
        id={@id <> "NavigatorWrapper"}
        phx-hook="ListNavigator"
        data-list-navigator-button-id={@id <> "Btn"}
      >
        {render_slot(@inner_block)}
      </div>
    </.dropdown>
    """
  end

  slot :item, required: true do
    attr :class, :string, required: false
    attr :"custom-phx-select", :string, required: false
  end

  def dropdown_list_button(assigns) do
    ~H"""
    <menu class="rounded-sm">
      <li :for={item <- @item} class={[item[:class], "rounded-md outline-none focus:bg-gray-700/10"]}>
        <button
          type="button"
          class="w-full"
          tabindex="0"
          phx-click={item[:"custom-phx-select"]}
          phx-keydown={item[:"custom-phx-select"]}
          phx-key="Enter"
        >
          {render_slot(item)}
        </button>
      </li>
    </menu>
    """
  end

  defp date_to_text(start_datetime) do
    case start_datetime.value do
      %DateTime{} -> Junto.Chrono.Formatter.strftime(start_datetime.value, "%A, %d %B")
      _ -> "-"
    end
  end

  defp time_to_text(%{value: d1}, %{value: d2}, _) when is_nil(d1) or is_nil(d2) do
    "--"
  end

  defp time_to_text(start_datetime, end_datetime, timezone) do
    start_time = Junto.Chrono.Formatter.to_hh_mm_str(start_datetime.value)
    end_time = Junto.Chrono.Formatter.to_hh_mm_str(end_datetime.value)

    tz = timezone.offset_str

    if start_datetime.value.day != end_datetime.value.day do
      "#{start_time} --  #{Junto.Chrono.Formatter.strftime(end_datetime.value, "%d %b")}, #{end_time} #{tz}"
    else
      "#{start_time} -- #{end_time} #{tz}"
    end
  end

  defp maybe_add_error_style(field) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
    errors != [] && "!border-2 border-red-400 dark:border-red-200 animate-shake"
  end

  defp get_gmaps_api_key do
    # TODO: to delete dev key
    System.get_env("GMAP_API_KEY")
  end

  defp get_gmaps_id do
    System.get_env("GMAP_MAP_ID")
  end
end
