defmodule JuntoWeb.EventLive.Home do
  use JuntoWeb, :live_view
  alias Junto.Events

  @impl true
  def mount(_params, _session, socket) do
    events = Events.all()

    {:ok,
     socket
     |> assign(events: events)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <dl>
      <div :for={event <- @events} data-role="event">
        <dt>{event.name}</dt>
      </div>
    </dl>
    """
  end
end
