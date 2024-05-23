defmodule JuntoWeb.EventLive.NewEvent do
  use JuntoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="create-event temporary bg-blue-300 dark:bg-blue-900/50">
      <div class="banner">
        <picture>
          <source type="image/webp" srcset="images/junto-sample-banner.webp" />
          <img class="" src="images/junto-sample-banner.png" />
        </picture>
      </div>
      <div class="form-container">
        <div class="flex">
          <div class="form-header">
            <div class="dropdown">
              <div tabindex="0" role="button"><.event_group /></div>
              <div
                tabindex="0"
                class=" mt-2 dropdown-content z-[1] menu pt-2 px-1 outline outline-1 dark:outline-slate-700/50 outline-slate-700/10 shadow-xl bg-base-100 dark:bg-base-100/80 backdrop-blur-lg rounded-md w-60 text-base gap-2"
              >
                <div class="text-xs opacity-50 pl-4">Choose the group of the event</div>

                <ul class="rounded-sm">
                  <li><a><.avatar />Personal Event</a></li>
                  <li>
                    <a>
                      <div class="opacity-50">
                        <.icon name="hero-plus" class="w-4 h-4 " /> Create Group
                      </div>
                    </a>
                  </li>
                </ul>

                <div
                  class="absolute left-20 -top-1.5 h-[10px] w-[10px]  bg-base-100 dark:bg-base-100/80 rotate-180"
                  style="clip-path: polygon(100% 0,0 0,50% 100%);"
                >
                </div>
              </div>
            </div>
          </div>
          <div class="basis-1/2">
            <div class="text-right"><.scope_dropdown /></div>
          </div>
        </div>
        <div class="h-12">
          some space
          <div class="p-3">
            <textarea
              autofocus
              id="foo"
              class="h-12 font-semibold text-4xl resize-none p-0 w-full bg-transparent overflow-hidden focus:outline-none border border-transparent"
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
          <.datepick />
        </div>
      </div>
    </div>
    """
  end

  defp datepick(assigns) do
    ~H"""
    <div>
      <div class="flex">
        <div class="flex flex-col gap-1 bg-black/5 pl-4 pt-1 pr-1 rounded relative">
          <div class="absolute border-dashed border-l-[1.5px] top-8 bottom-7 left-6 border-slate-500 dark:border-slate-400" style=""></div>
          <div class="flex h-11 gap-[1px]">
            <div class="pl-1 pt-4 opacity-80">
              <svg viewBox="0 0 100 100" class=" dark:text-slate-400 w-4 opacity-50" xmlns="http://www.w3.org/2000/svg"> <circle cx="35" cy="35" r="35" /> </svg>
            </div>
            <div class="p-2 w-16 opacity-80"> Start </div>
            <.input_date />
            <.input_time />
          </div>
          <div class="flex h-11 gap-[1px]">
            <div class="pl-1 pt-4  opacity-80">
              <svg viewBox="0 0 100 100" class="w-4 opacity-50" xmlns="http://www.w3.org/2000/svg"> <circle cx="35" cy="35" r="35" stroke="currentColor" stroke-width="10" fill="none" /> </svg>
            </div>
            <div class="p-2 w-16 opacity-80"> End </div>
            <.input_date />
            <.input_time />

          </div>
        </div>
      </div>
    </div>
    """
  end

  defp input_date(assigns) do
    ~H"""
    <div class="p-2 bg-black/10 hover:bg-black/20 dark:bg-white/10 dark:hover:bg-white/20 rounded-tl-lg rounded-bl-lg">
      <input class="picker bg-transparent  border-none outline-none" type="date" value="2024-05-23" />
    </div>
    """
  end

  defp input_time(assigns) do
    ~H"""
    <div class="p-2 bg-black/10 hover:bg-black/20 dark:bg-white/10 dark:hover:bg-white/20 rounded-tr-lg rounded-br-lg">
      <input class="picker bg-transparent  border-none outline-none" type="time" value="21:00" required />
    </div>
    """
  end

  defp scope_dropdown(assigns) do
    ~H"""
    <.dropdown>
      <:button>
        <div class="text-sm">
          <.icon name="hero-globe-alt" class="w-4 h-4" /> Public
        </div>
      </:button>
      <:item>
        <.scope_item icon="hero-globe-alt" checked={true}>
          <:title>Public</:title>
          <:desc>
            Show on your group. Could be listed and suggested
          </:desc>
        </.scope_item>
      </:item>
      <:item>
        <.scope_item icon="hero-sparkles-solid" checked={false}>
          <:title>Private</:title>
          <:desc>
            Unlisted. Only people with the link can register
          </:desc>
        </.scope_item>
      </:item>
    </.dropdown>
    """
  end

  defp scope_item(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-6"><.icon :if={@checked} name="hero-check" class="w-4 h4" /></div>
      <div class="w-6"><.icon name={@icon} class="w-4 h4" /></div>
      <div class="text-sm">
        <div><%= render_slot(@title) %></div>
        <div class="text-slate-400"><%= render_slot(@desc) %></div>
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
    <div class="avatar placeholder my-auto justify-class items-center">
      <div class="bg-neutral text-neutral-content rounded-full w-4 h-4">
        <span class="text-xs">I</span>
      </div>
    </div>
    """
  end
end
