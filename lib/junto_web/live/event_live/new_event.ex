defmodule JuntoWeb.EventLive.NewEvent do
  use JuntoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="create-event temporary bg-blue-300/30 dark:bg-blue-900/50">
      <div class="banner">
        <picture>
          <source type="image/webp" srcset="images/junto-sample-banner.webp" />
          <img class="" src="images/junto-sample-banner.png" />
        </picture>
      </div>
      <div class="form-container">
        <div class="flex">
          <.group_dropdown />
          <.scope_dropdown />
        </div>
        <.event_title_input />
        <.datepick />
        <.event_location_selector />
      </div>
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
          class=""
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

        <div class="timezone-container">
          <.timezone_dropdown />
        </div>
      </div>
    </div>
    """
  end

  defp input_date(assigns) do
    ~H"""
    <div class="pt-1 bg-black/10 hover:bg-black/20 dark:bg-white/10 dark:hover:bg-white/20 rounded-tl-lg rounded-bl-lg">
      <input class="picker bg-transparent  border-none outline-none" type="date" value="2024-05-23" />
    </div>
    """
  end

  defp input_time(assigns) do
    ~H"""
    <div class="pt-1 bg-black/10 hover:bg-black/20 dark:bg-white/10 dark:hover:bg-white/20 rounded-tr-lg rounded-br-lg">
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
      <:button id="group-dropdown-btn" dropdown-toggle="group-dropdown" dropdown-delay="500" class="">
        <.event_group />
      </:button>
      <:menu class="select-none z-50" id="group-dropdown">
        <div class="ml-[60px] p-2 outline outline-1 dark:outline-slate-700/50 outline-slate-700/10 shadow-xl rounded-md text-base backdrop-blur-lg dark:text-slate-400 text-slate-500 w-60 bg-white/80 dark:bg-black/80">
          <div class="text-xs opacity-50">Choose the group of the event</div>

          <ul class="rounded-sm">
            <li>
              <div class="flex p-2 dark:text-slate-100 text-slate-900 hover:bg-gray-700/10 rounded-md cursor-pointer">
                <a>Personal Event</a>
              </div>
            </li>
            <li>
              <a>
                <div class="my-auto p-2 dark:text-slate-400 text-slate-500 hover:bg-gray-700/10 rounded-md cursor-pointer opacity-50">
                  <.icon name="hero-plus" class="w-4 h-4 " /> Create Group
                </div>
              </a>
            </li>
          </ul>
        </div>
      </:menu>
    </.dropdown>
    """
  end

  defp scope_dropdown(assigns) do
    ~H"""
    <.dropdown class="form-header flex justify-end">
      <:button
        id="scope-dropdown-btn"
        dropdown-toggle="scope-dropdown"
        dropdown-delay="500"
        class="bg-black/10 hover:bg-black/20 transition ease-in-out duration-300  dark:bg-white/10 dark:hover:bg-white/20 rounded-lg  w-fit gap-2 px-4 py-1 cursor-pointer justify-center items-center"
      >
        <div class="text-sm">
          <.icon name="hero-globe-alt" class="w-4 h-4" /> Public
          <.icon name="hero-chevron-down" class="h-3 w-3" />
        </div>
      </:button>
      <:menu id="scope-dropdown" class="!ml-[-15px] select-none z-50">
        <div class="pt-2 pb-2 px-1 outline outline-1 dark:outline-slate-700/50 outline-slate-700/10 shadow-xl bg-base-100 rounded-md text-base backdrop-blur-lg w-72 bg-white/80 dark:bg-black/80">
          <ul class="rounded-sm">
            <li>
              <.scope_item icon="hero-globe-alt" checked={true}>
                <:title>Public</:title>
                <:desc>
                  Show on your group. Could be listed and suggested
                </:desc>
              </.scope_item>
            </li>
            <li>
              <.scope_item icon="hero-sparkles-solid" checked={false}>
                <:title>Private</:title>
                <:desc>
                  Unlisted. Only people with the link can register
                </:desc>
              </.scope_item>
            </li>
          </ul>
        </div>
      </:menu>
    </.dropdown>
    """
  end

  defp scope_item(assigns) do
    ~H"""
    <div class="flex p-2 dark:text-slate-400 text-slate-500 hover:bg-gray-700/10 rounded-md cursor-pointer">
      <div class="my-auto w-6"><.icon name={@icon} class="w-4 h4" /></div>
      <div class="text-sm pl-2">
        <div class="dark:text-slate-100 text-slate-900"><%= render_slot(@title) %></div>
        <div><%= render_slot(@desc) %></div>
      </div>
      <div class="my-auto w-6">
        <.icon :if={@checked} name="hero-check" class="dark:text-white text-black w-4 h4" />
      </div>
    </div>
    """
  end

  defp event_group(assigns) do
    ~H"""
    <div class="flex bg-black/10 hover:bg-black/20 dark:bg-white/10 dark:hover:bg-white/20 ease-in-out duration-300  rounded-lg  w-fit gap-2 px-4 py-1 cursor-pointer justify-center items-center">
      <.avatar />
      <div class="grow text-sm">Personal Event</div>
      <div class="">
        <.icon name="hero-chevron-down" class="h-3 w-3" />
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

  defp event_location_selector(assigns) do
    ~H"""
    <div class="w-full">
        <div class="flex flex-row gap-1 bg-black/5 pl-4 pt-1 pr-1 rounded-lg relative opacity-80 cursor-pointer hover:bg-black/20 pt-3 pb-3 select-none">
          <div>
            <.icon name="hero-map-pin" class="w-5 h-5" />
          </div>
          <div>
            <div>Add Event Location</div>
            <div class="text-sm">Offline location or virutal link</div>
          </div>
      </div>
      <ul tabindex="0" class="dropdown-content z-[1] ">
        <.event_location_lookup />
      </ul>
    </div>

    <div class="hidden">
      location https://jsfiddle.net/gh/get/library/pure/googlemaps/js-samples/tree/master/dist/samples/places-queryprediction/jsfiddle
    </div>
    """
  end

  defp event_location_lookup(assigns) do
    ~H"""
    <div class="w-full bg-red-700">
      <div class="input-container pt-1">
        <textarea class="w-full h-10 border-0 resize-none p-0 w-full bg-transparent overflow-hidden focus:outline-none border border-transparent;
    "></textarea>
      </div>
    </div>
    """
  end
end
