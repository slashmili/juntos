defmodule JuntoWeb.EventLive.NewEvent do
  use JuntoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       gmap_suggested_places: [],
       place: nil,
       selected_scope: :public
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="create-event temporary h-screen bg-green-500/30 text-normal">
      <div class="banner">
        <picture>
          <source type="image/webp" srcset="images/junto-sample-banner.webp" />
          <img class="" src="images/junto-sample-banner.png" />
        </picture>
      </div>
      <div class="form-container">
        <div class="flex">
          <.group_dropdown />
          <.scope_dropdown selected_scope={@selected_scope} />
        </div>
        <.event_title_input />
        <.datepick />
        <.location_selector_dropdown gmap_suggested_places={@gmap_suggested_places} place={@place} />
        <div>
          <.text_editor
            name="desc"
            class="prose prose-sm sm:prose lg:prose-lg xl:prose-2xl mx-auto focus:outline-none prose max-w-none "
          />
        </div>
      </div>
      <div class="form-container"></div>
    </div>
    """
  end

  defp event_title_input(assigns) do
    ~H"""
    <div class="form-input-name">
      <div class="p-3">
        <textarea
          autofocus
          id="foo"
          class="hover:placeholder-gray-400"
          spellcheck="false"
          autocapitalize="words"
          placeholder="Event Name"
          onInput="this.parentNode.dataset.clonedVal = this.value"
          row="2"
        ></textarea>
        <script>
          const textarea = document.getElementById('foo');
          //TODO: move it out of here
          textarea.addEventListener('input', () => {
          if (textarea.scrollHeight < 50) return;
              textarea.style.height = 'auto';
              textarea.style.height = `${textarea.scrollHeight}px`;
          });
              
        </script>
      </div>
    </div>
    """
  end

  defp datepick(assigns) do
    ~H"""
    <div class="form-datepick">
      <div class="flex gap-2">
        <div class="datetime-container pt-1 pb-1">
          <div class="datetime-start-end-line"></div>
          <div class="datetime-start-end-container">
            <div class="icon-wrapper">
              <svg
                viewBox="0 0 100 100"
                class="dark:text-slate-400"
                xmlns="http://www.w3.org/2000/svg"
              >
                <circle cx="35" cy="35" r="35" />
              </svg>
            </div>
            <div class="text">Start</div>
            <.input_date />
            <.input_time />
          </div>
          <div class="datetime-start-end-container">
            <div class="icon-wrapper">
              <svg viewBox="0 0 100 100" class="" xmlns="http://www.w3.org/2000/svg">
                <circle cx="35" cy="35" r="35" stroke="currentColor" stroke-width="10" fill="none" />
              </svg>
            </div>
            <div class="text">End</div>
            <.input_date />
            <.input_time />
          </div>
        </div>

        <div class="timezone-container hover-block-custom">
          <.timezone_dropdown />
        </div>
      </div>
    </div>
    """
  end

  defp input_date(assigns) do
    ~H"""
    <div class="pt-1 bg-black/10 dark:bg-white/10 hover-block-custom rounded-tl-lg rounded-bl-lg hover-block-custom">
      <input class="picker bg-transparent  border-none outline-none" type="date" value="2024-05-23" />
    </div>
    """
  end

  defp input_time(assigns) do
    ~H"""
    <div class="pt-1 bg-black/10 dark:bg-white/10 rounded-tr-lg rounded-br-lg hover-block-custom">
      <input
        class="picker bg-transparent  border-none outline-none"
        type="time"
        value="21:00"
        required
      />
    </div>
    """
  end

  defp timezone_dropdown(assigns) do
    ~H"""
    <div class=""><.icon name="hero-globe-alt" class="w-4 h-4" /></div>
    <div class="text-sm font-medium">GMT+02:00</div>
    <div class="text-xs overflow-hidden text-ellipsis">Berlin</div>
    """
  end

  defp group_dropdown(assigns) do
    ~H"""
    <.dropdown class="form-header">
      <:button id="groupDropdownBtn" dropdown-toggle="group-dropdown" class="">
        <.event_group />
      </:button>
      <:menu class="select-none z-50" id="group-dropdown">
        <div
          class="ml-[60px] dropdown-menu-style p-2 w-60"
          phx-window-keydown={
            JS.remove_class("block", to: "#group-dropdown")
            |> JS.add_class("hidden", to: "#group-dropdown")
            |> JS.set_attribute({"aria-hidden", true}, to: "#group-dropdown")
            |> JS.focus(to: "#groupDropdownBtn")
          }
          phx-key="escape"
        >
          <div class="text-xs opacity-50">Choose the group of the event</div>

          <.dropdown_list>
            <:item>
              <a href="#">
                <div class="flex p-2 dropdown-menu-group-selector">
                  Personal Event
                </div>
              </a>
            </:item>
            <:item>
              <a href="#">
                <div class="flex p-2 dropdown-menu-group-selector">
                  Group B
                </div>
              </a>
            </:item>
            <:item>
              <a>
                <div class="my-auto p-2 dark:text-slate-400 text-slate-500 hover:bg-gray-700/10 rounded-md cursor-pointer opacity-50">
                  <.icon name="hero-plus" class="w-4 h-4 " /> Create Group
                </div>
              </a>
            </:item>
          </.dropdown_list>
        </div>
      </:menu>
    </.dropdown>
    """
  end

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

  defp scope_dropdown(assigns) do
    assigns = Map.put(assigns, :event_scopes, @event_scopes)

    ~H"""
    <.dropdown class="form-header flex justify-end">
      <:button
        id="scopeDropdownBtn"
        dropdown-delay="500"
        class="dropdown-style w-fit gap-2 px-4 py-1 justify-center items-center"
      >
        <div class="text-sm">
          <.icon name={@event_scopes[@selected_scope].icon} class="w-4 h-4" /> <%= @event_scopes[
            @selected_scope
          ].title %>
          <.icon name="hero-chevron-down" class="h-3 w-3" />
        </div>
      </:button>
      <:menu
        class="!ml-[-15px] select-none z-50 pt-2 pb-2 px-1 dropdown-menu-style w-72 "
        enable-li-navigator={true}
      >
        <.dropdown_list>
          <:item
            :for={{_, scope} <- Enum.sort_by(@event_scopes, &elem(&1, 1).order)}
            custom-phx-select={JS.push("select-scope", value: scope, loading: "#scopeDropdownBtn")}
          >
            <.scope_item scope={scope} checked={@selected_scope == scope.type} />
          </:item>
        </.dropdown_list>
      </:menu>
    </.dropdown>
    """
  end

  defp scope_item(assigns) do
    ~H"""
    <div class="flex p-2 dark:text-slate-400 text-slate-500 hover:bg-gray-700/10 rounded-md cursor-pointer">
      <div class="my-auto w-6"><.icon name={@scope.icon} class="w-4 h4" /></div>
      <div class="text-sm pl-2">
        <div class="dark:text-slate-100 text-slate-900"><%= @scope.title %></div>
        <div><%= @scope.desc %></div>
      </div>
      <div class="my-auto w-6">
        <.icon :if={@checked} name="hero-check" class="dark:text-white text-black w-4 h4" />
      </div>
    </div>
    """
  end

  defp event_group(assigns) do
    ~H"""
    <div class="flex dropdown-style w-fit gap-2 px-4 py-1 justify-center items-center ease-in-out duration-300">
      <.avatar />
      <div class="grow text-sm font-medium">Personal Event</div>
      <div class="align-middle">
        <.icon name="hero-chevron-down text-sm font-medium" class="h-4 w-4" />
      </div>
    </div>
    """
  end

  defp avatar(assigns) do
    ~H"""
    <span class="relative w-4 h-4 overflow-hidden bg-gray-100 rounded-full dark:bg-gray-600">
      <svg
        class="absolute w-4 h-4 text-gray-400 -left-1"
        fill="currentColor"
        viewBox="0 0 20 20"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          fill-rule="evenodd"
          d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
          clip-rule="evenodd"
        >
        </path>
      </svg>
    </span>
    """
  end

  defp location_selector_dropdown(assigns) do
    ~H"""
    <.dropdown class="relative">
      <:button id="placeDropdownBtn" dropdown-toggle="placeSelectorDropdown" class="w-full">
        <div class="flex flex-row gap-1 bg-black/5 pl-4 pt-1 pr-1 rounded-lg relative opacity-80 cursor-pointer pt-3 pb-3 select-none  hover-block-custom">
          <div>
            <.icon name="hero-map-pin" class="w-5 h-5" />
          </div>
          <div :if={is_nil(@place)}>
            <div class="text-left">Add Event Location</div>
            <div class="text-sm text-left">Offline location or virutal link</div>
          </div>

          <div :if={@place} class="grow">
            <div class="text-left font-medium"><%= @place["name"] %></div>
            <div class="text-left text-sm"><%= @place["address"] %></div>
          </div>
          <div
            :if={@place}
            class="pt-1 pr-1"
            onclick="return false;"
            phx-click="deselect-place"
            role="button"
          >
            <div
              data-tooltip-target="tooltip-default"
              class="hover:bg-red-100 flex items-center justify-center rounded-full p-1 hover-block-custom"
            >
              <.icon name="hero-x-mark" class="w-5 h-5 " />
            </div>

            <div
              id="tooltip-default"
              role="tooltip"
              class="absolute z-10 invisible inline-block p-2 text-sm text-white transition-opacity duration-300  rounded-lg shadow-sm tooltip dark:bg-neutral-300 dark:text-black bg-neutral-950"
            >
              Remove Location
              <div class="tooltip-arrow" data-popper-arrow></div>
            </div>
          </div>
        </div>
      </:button>

      <:menu class="select-none z-50 w-full" id="placeSelectorDropdown">
        <.place_lookup gmap_suggested_places={@gmap_suggested_places} />
      </:menu>
    </.dropdown>
    <div
      :if={@place}
      data-place={Jason.encode!(@place)}
      data-map-id={get_gmaps_id()}
      id="google-map"
      class="h-32"
      phx-hook="Gmaps"
      data-api-key={get_gmaps_api_key()}
      phx-update="ignore"
    >
    </div>
    """
  end

  defp place_lookup(assigns) do
    ~H"""
    <div class="pt-2 pb-2 px-1 outline outline-1 dark:outline-slate-700/50 outline-slate-700/10 shadow-xl bg-base-100 rounded-md text-base backdrop-blur-lg bg-white/80 dark:bg-black/80">
      <div
        id="gmap-new-event-lookup2"
        class="input-container bg-gray-700/10 dark:bg-gray-800 -mt-2 -mx-1 rounded-t-md pb-1"
        phx-hook="GmapLookup"
        data-api-key={get_gmaps_api_key()}
      >
        <textarea
          id="placeQueryTxt"
          class="p-3 focus:outline-none focus:border-teal focus:ring-0 dark:text-slate-100 h-10 border-0 resize-none p-0 w-full bg-transparent overflow-hidden focus:outline-none border border-transparent;"
          placeholder="Enter Location"
        ></textarea>
      </div>
      <div :if={@gmap_suggested_places}>
        <ul class="gmap-suggested-places">
          <li
            :for={place <- @gmap_suggested_places}
            tabindex="0"
            phx-click={JS.push("select-place", value: place)}
          >
            <.event_place_item name={place["name"]} location={place["address"]} />
          </li>
        </ul>
      </div>
    </div>
    """
  end

  defp event_place_item(assigns) do
    ~H"""
    <div class="flex p-2 dark:text-slate-400 text-slate-500 hover:bg-gray-700/10 rounded-md cursor-pointer">
      <div class="my-auto w-6"><.icon name="hero-map-pin" class="w-5 h5" /></div>
      <div class="pl-2">
        <div class="dark:text-slate-100 text-slate-900"><%= @name %></div>
        <div class="text-sm max-w-md"><%= @location %></div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("select-scope", %{"type" => type}, socket) do
    {:noreply, assign(socket, :selected_scope, String.to_existing_atom(type))}
  end

  @impl true
  def handle_event("gmap-suggested-places", places, socket) do
    {:noreply, assign(socket, :gmap_suggested_places, places)}
  end

  @impl true
  def handle_event("select-place", place, socket) do
    {:noreply, assign(socket, :place, place)}
  end

  @impl true
  def handle_event("deselect-place", _, socket) do
    {:noreply, assign(socket, :place, nil)}
  end

  defp get_gmaps_api_key do
    # TODO: to delete dev key
    "AIzaSyCCubqJSWvbLIQJdsZXyMj7olwYanekI6M"
  end

  defp get_gmaps_id do
    "300ffa0564ebe9c7"
  end
end
