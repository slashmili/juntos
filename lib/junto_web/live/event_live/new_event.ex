defmodule JuntoWeb.EventLive.NewEvent do
  use JuntoWeb, :live_view
  alias JuntoWeb.CoreComponentsBackup

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
    {:ok,
     assign(socket,
       gmap_suggested_places: [],
       place: nil,
       selected_scope: :public
     )}
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

  defp event_title_input(assigns) do
    ~H"""
    <div class="min-h-12">
      <textarea
        id="titleTextarea"
        autofocus
        autocapitalize="words"
        spellcheck="false"
        class="h-12 w-full create-event-textarea-style"
        placeholder="Event Name"
        onInput="this.parentNode.dataset.clonedVal = this.value"
        row="2"
      />
      <script>
        const textarea = document.getElementById('titleTextarea');
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

  defp datepick(assigns) do
    ~H"""
    <button
      class="flex gap-2 w-full px-3 py-2  animated create-event-button-style sm:hidden outline-none focus:outline-none"
      phx-click={show_modal("datepickModal")}
    >
      <div class="-z-[1]"><.icon name="hero-clock" class="w-4 h-4" /></div>
      <div class="min-w-0 text-left">
        <div class="font-medium truncate">Tuesday, 12 November</div>
        <div class="text-sm truncate">07:00 -- 08:00</div>
      </div>
    </button>
    <.datepick_modal />
    """
  end

  defp datepick_modal(assigns) do
    ~H"""
    <.modal id="datepickModal" show={true}>
      <div class="w-full max-w-2xl max-h-full bg-transparent">
        <div class="relative rounded-lg shadow-lg shadow-black bg-white/90 dark:bg-neutral-900/70 backdrop-blur-lg dark:text-white">
          <div class="p-4 flex flex-col gap-2">
            <div class="">
              <div class="font-semibold text-lg">Event Time</div>
            </div>
            <.datepick_date label="Start" />
            <.datepick_date label="End" />
            <.datepick_timezone />
          </div>
        </div>
      </div>
    </.modal>
    """
  end

  defp datepick_timezone(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="flex items-center text-sm opacity-60">Timezone</div>
      <div class="pl-3 grow flex justify-end"></div>
      <CoreComponentsBackup.dropdown id="timezoneDropdown">
        <:button
          id="timezoneDropdownBtnBtn"
          dropdown-toggle="timezoneDropdown"
          class="bg-transparent dark:border-white/10 dark:hover:border-white/80 border rounded  px-1 py-2 focus:ring-0 focus:outline-none focus:border-white/80"
        >
          <div class="min-w-0 flex gap-2 m">
            <div class="dark:text-white/50">GMT+01:00</div>
            <div class="inline truncate">Berlin</div>
            <div><.icon name="hero-chevron-down " class="h-4 w-4" /></div>
          </div>
        </:button>
        <div class="bg-black/30 backdrop-blur-lg rounded-md w-80 max-h-48 overflow-auto shadow-black shadow-lg">
          <div class="bg-white/10 w-full rounded-t-md">
            <input
              tabindex="-1"
              type="text"
              class="bg-transparent placeholder-white/40 outline-none focus:ring-0 border-none focus:outline-none focus:ring-0"
              placeholder="Search for a timzone"
            />
          </div>
          <ul class="p-2">
            <li :for={_ <- Enum.to_list(1..20)}>
              <button class="flex text-left w-full hover:bg-white/10 rounded-md p-1">
                <div class="truncate grow">Europe/Berlin</div>
                <div class="dark:text-white/50 base-1 flex justify-end">GMT+1:00</div>
              </button>
            </li>
          </ul>
        </div>
      </CoreComponentsBackup.dropdown>
    </div>
    """
  end

  defp datepick_date(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="flex items-center text-sm opacity-60"><%= @label %></div>
      <div class="pl-3 grow flex justify-end">
        <input
          class="bg-transparent dark:border-white/10 dark:hover:border-white/80  border rounded-l-md outline-pink-500  focus:ring-0 focus:outline-none focus:border-white/80 "
          type="date"
          value="2024-05-23"
        />
        <input
          class="bg-transparent dark:border-white/10 dark:hover:border-white/80 border rounded-r-md outline-none focus:ring-0 focus:outline-none focus:border-white/80 -ml-[2px] "
          type="time"
          value="21:00"
          required
        />
      </div>
    </div>
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
    <CoreComponentsBackup.dropdown id={@id}>
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
    </CoreComponentsBackup.dropdown>
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
end
