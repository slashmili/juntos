defmodule JuntosWeb.EventLive.Show do
  use JuntosWeb, :live_view
  alias Juntos.Events

  @impl true
  def mount(params, _session, socket) do
    event = Juntos.Repo.get_by(Events.Event, slug: hd(params["path"]))

    {:ok,
     socket
     |> assign(:page_title, event.name)
     |> assign(:event, event)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div data-role="event-public-page">
      {@event.name}
      <.event_cover_image cover_image={Events.event_cover_url(@event)} />
    </div>
    """
  end

  defp event_cover_image(%{cover_image: %{media_type: :gif}} = assigns) do
    ~H"""
    <picture>
      <img src={@cover_image.original} width="400" height="400" />
    </picture>
    """
  end

  defp event_cover_image(assigns) do
    ~H"""
    <picture>
      <source srcset={@cover_image.webp} type="image/webp" />
      <img src={@cover_image.jpg} width="400" height="400" />
    </picture>
    """
  end
end
