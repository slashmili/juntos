defmodule JuntoWeb.EventLive.Create do
  use JuntoWeb, :live_view
  import JuntoWeb.EventLive.Components

  alias JuntoWeb.EventLive.CreateEventForm
  alias Junto.Events

  @impl true
  def mount(_params, _session, socket) do
    changeset = CreateEventForm.new()

    {:ok,
     socket
     |> assign(
       gmap_suggested_places: [],
       place: nil,
       selected_scope: :private,
       force_rerender_map: false
     )
     |> assign_time_zone()
     |> assign_form(changeset)}
  end

  defp group_dropdown(assigns) do
    ~H"""
    <JuntoWeb.EventLive.Components.header_dropdown id="groupDropdown">
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
    </JuntoWeb.EventLive.Components.header_dropdown>
    """
  end

  defp group_dropdown_menu_items(assigns) do
    all_groups = ["Personal Event", "Group A", "Group B"]
    assigns = Map.put(assigns, :all_groups, all_groups)

    ~H"""
    <JuntoWeb.EventLive.Components.dropdown_list_button>
      <:item :for={group <- @all_groups}>
        <div class="flex p-2 create-event-dropdown-menu-group-selector ">
          {group}
        </div>
      </:item>
      <:item>
        <div class="my-auto p-2 text-left dark:text-slate-400 text-slate-500 hover:bg-gray-700/10  rounded-md cursor-pointer opacity-50">
          <.icon name="hero-plus" class="w-4 h-4 " /> Create Group
        </div>
      </:item>
    </JuntoWeb.EventLive.Components.dropdown_list_button>
    """
  end

  ### Reusable components

  def modal2(assigns) do
    ~H"""
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
    {:noreply, assign_time_zone(socket, zone_name)}
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
  def handle_event("submit", %{"create_event_form" => event_params}, socket) do
    event_params = Map.put(event_params, "location", socket.assigns.place)

    with {:ok, params} <- CreateEventForm.apply(event_params),
         {:ok, _event} <- Events.create(socket.assigns.current_user, Map.from_struct(params)) do
      {:noreply, push_navigate(socket, to: ~p"/home")}
    else
      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_info(:reset_map_rerender, socket) do
    {:noreply, assign(socket, :force_rerender_map, false)}
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, :form, form)
  end

  defp assign_time_zone(socket, zone_name \\ nil) do
    time_zone = zone_name || get_connect_params(socket)["timeZone"]

    {:ok, time_zone_struct} =
      case Junto.Chrono.Timezone.get_timezone(time_zone) do
        {:ok, _} = result -> result
        _ -> Junto.Chrono.Timezone.get_timezone("UTC")
      end

    assign(socket, :time_zone_value, time_zone_struct)
  end
end
