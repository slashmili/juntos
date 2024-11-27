defmodule JuntoWeb.EventLive.Create do
  use JuntoWeb, :live_view
  import JuntoWeb.EventLive.Components

  alias JuntoWeb.EventLive.CreateEventForm

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
  @impl true
  def mount(_params, _session, socket) do
    changeset = CreateEventForm.new()
    {:ok, timezone} = Junto.Chrono.Timezone.get_timezone("Europe/Berlin")

    {:ok,
     socket
     |> assign(
       gmap_suggested_places: [],
       place: nil,
       selected_scope: :public,
       force_rerender_map: false,
       timezone: timezone
     )
     |> assign_form(changeset)}
  end

  defp group_dropdown(assigns) do
    ~H"""
    <.header_dropdown id="groupDropdown">
      <:title>
        <div class="min-w-0 truncate">
          Personal Event
        </div>
      </:title>
      <div
        class="ml-[20px] sm:ml-[60px] p-2 w-60 create-event-dropdown-menu-style outline-white/80 select-none"
        style="background-color: #222a"
      >
        <div class="text-xs opacity-50">Choose the group of the event</div>
        <.group_dropdown_menu_items />
      </div>
    </.header_dropdown>
    """
  end

  defp group_dropdown_menu_items(assigns) do
    all_groups = ["Personal Event", "Group A", "Group B"]
    assigns = Map.put(assigns, :all_groups, all_groups)

    ~H"""
    <.dropdown_list_button>
      <:item :for={group <- @all_groups}>
        <div class="flex p-2 create-event-dropdown-menu-group-selector ">
          <%= group %>
        </div>
      </:item>
      <:item>
        <div class="my-auto p-2 text-left dark:text-slate-400 text-slate-500 hover:bg-gray-700/10  rounded-md cursor-pointer opacity-50">
          <.icon name="hero-plus" class="w-4 h-4 " /> Create Group
        </div>
      </:item>
    </.dropdown_list_button>
    """
  end

  defp scope_dropdown(assigns) do
    assigns = Map.put(assigns, :event_scopes, @event_scopes)

    ~H"""
    <.header_dropdown id="scopeDropdown">
      <:title>
        <div class="whitespace-nowrap">
          <.icon name={@event_scopes[@selected_scope].icon} class="w-4 h-4" /> <%= @event_scopes[
            @selected_scope
          ].title %>
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
        custom-phx-select={JS.push("select-scope", value: scope, loading: "#scopeDropdownBtn")}
        class="dark:hover:bg-white/5"
      >
        <div class="flex p-2">
          <div class="my-auto w-6"><.icon name={scope.icon} class="w-4 h4" /></div>
          <div class="text-sm pl-2 text-left">
            <div class="dark:text-slate-100 text-slate-900"><%= scope.title %></div>
            <div><%= scope.desc %></div>
          </div>
          <div class="my-auto w-6">
            <.icon :if={@selected_scope == scope.type} name="hero-check" class="w-4 h4" />
          </div>
        </div>
      </:item>
    </.dropdown_list_button>
    """
  end

  defp description(assigns) do
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
            name="desc"
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

  ### Reusable components

  def modal2(assigns) do
    ~H"""
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
          <%= render_slot(@title) %>

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
        <%= render_slot(@inner_block) %>
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
          class="w-full"
          tabindex="0"
          phx-click={item[:"custom-phx-select"]}
          phx-keydown={item[:"custom-phx-select"]}
          phx-key="Enter"
        >
          <%= render_slot(item) %>
        </button>
      </li>
    </menu>
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
    send(self(), :reset_map_rerender)
    {:noreply, assign(socket, place: place, force_rerender_map: true)}
  end

  @impl true
  def handle_event("select-place-update-address", place, socket) do
    {:noreply, assign(socket, place: place)}
  end

  @impl true
  def handle_event("deselect-place", _, socket) do
    {:noreply, assign(socket, :place, nil)}
  end

  @impl true
  def handle_event("select-timezone", %{"zone_name" => zone_name}, socket) do
    {:ok, timezone} = Junto.Chrono.Timezone.get_timezone(zone_name)
    {:noreply, assign(socket, :timezone, timezone)}
  end

  @impl true
  def handle_event("validate", %{"create_event_form" => event_params}, socket) do
    event_params = Map.put(event_params, "location", socket.assigns.place)
    changeset = CreateEventForm.new(event_params) |> Map.put(:action, :validate)
    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("event-ignore", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create-event", %{"create_event_form" => event_params}, socket) do
    event_params = Map.put(event_params, "location", socket.assigns.place)

    changeset =
      event_params
      |> CreateEventForm.new()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_info(:reset_map_rerender, socket) do
    {:noreply, assign(socket, :force_rerender_map, false)}
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, :form, form)
  end
end
