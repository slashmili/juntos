defmodule JuntosWeb.EventLive.Show do
  use JuntosWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div data-role="event-public-page">My Event</div>
    """
  end
end
