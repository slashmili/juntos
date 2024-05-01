defmodule JuntoWeb.EventLive.NewEvent do
  use JuntoWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="create-event">
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
                class="mt-2 dropdown-content z-[1] menu p-2 border shadow-xl bg-base-100 rounded-md w-60 text-base gap-2"
              >
                <div class="text-xs opacity-50">Choose the group of the event</div>

                <ul>
                  <li><a><.avatar />Personal Event</a></li>
                  <li><a><div class="opacity-50">
                  <.icon name="hero-plus" class="w-4 h-4 " /> Create Group
                  </div>
                </a></li>
                </ul>
              </div>
            </div>
          </div>
          <div class="basis-1/2 border">left</div>
        </div>
      </div>
    </div>
    """
  end

  defp event_group(assigns) do
    ~H"""
    <div class="flex dark:bg-stone-700 hover:dark:bg-stone-600 bg-stone-100 ease-in-out duration-300 hover:bg-stone-200 rounded-lg  w-fit gap-2 px-4 py-1 cursor-pointer justify-center items-center">
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
