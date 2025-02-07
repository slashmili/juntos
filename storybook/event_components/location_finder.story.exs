defmodule Storybook.Components.EventComponents.LocationFinder do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.EventLive.Components.location_finder/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "storybook-event-location-finder",
          api_key: System.get_env("GMAP_API_KEY")
        },
        slots: []
      }
    ]
  end
end
