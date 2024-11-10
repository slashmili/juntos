defmodule JuntoWeb.EventLive.NewEvent do
  use JuntoWeb, :live_view

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

  alias JuntoWeb.EventLive.NewEventComponents

  defp group_dropdown(assigns) do
    ~H"""
    <.header_dropdown id="groupDropdown">
      <:title>
        <div class="min-w-0 truncate">
          Personal Event
        </div>
      </:title>
      <div class="ml-[20px] sm:ml-[60px] p-2 w-60 create-event-dropdown-menu-style select-none">
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
    <.dropdown_list>
      <:item :for={group <- @all_groups}>
        <a href="#">
          <div class="flex p-2 create-event-dropdown-menu-group-selector">
            <%= group %>
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
      <div class="!ml-[-15px] select-none z-50 pt-2 pb-2 px-1 w-72 create-event-dropdown-menu-style select-none ">
        <.scope_dropdown_menu_items selected_scope={@selected_scope} event_scopes={@event_scopes} />
      </div>
    </.header_dropdown>
    """
  end

  def scope_dropdown_menu_items(assigns) do
    ~H"""
    <.dropdown_list>
      <:item
        :for={{_, scope} <- Enum.sort_by(@event_scopes, &elem(&1, 1).order)}
        custom-phx-select={JS.push("select-scope", value: scope, loading: "#scopeDropdownBtn")}
      >
        <div class="flex p-2 cursor-pointer">
          <div class="my-auto w-6"><.icon name={scope.icon} class="w-4 h4" /></div>
          <div class="text-sm pl-2">
            <div class="dark:text-slate-100 text-slate-900"><%= scope.title %></div>
            <div><%= scope.desc %></div>
          </div>
          <div class="my-auto w-6">
            <.icon :if={@selected_scope == scope.type} name="hero-check" class="w-4 h4" />
          </div>
        </div>
      </:item>
    </.dropdown_list>
    """
  end

  def event_title_input(assigns) do
    ~H"""
    <div class="min-h-12 py-3 pl-3">
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

  ### Reusable components
  alias JuntoWeb.CoreComponentsBackup
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

  def dropdown_list(assigns) do
    ~H"""
    <ul class="rounded-sm">
      <li
        :for={item <- @item}
        class={[item[:class], "rounded-md outline-none focus:bg-gray-700/10"]}
        tabindex="0"
        phx-click={item[:"custom-phx-select"]}
        phx-keydown={item[:"custom-phx-select"]}
        phx-key="Enter"
      >
        <%= render_slot(item) %>
      </li>
    </ul>
    """
  end
end
