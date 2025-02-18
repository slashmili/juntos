defmodule Storybook.Components.CoreComponents.ContentText do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.content_text/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :hero,
        attributes: %{},
        slots: [
          "Cover image",
          "<:subtitle>Discover conferences and events that fit your passion, online or in person.</:subtitle>",
          "<:body>From virtual conferences to live gatherings, our platform helps you explore and connect with experiences that match your interests. Dive into a world of possibilities and find your next must-attend event today!</:body>"
        ]
      }
    ]
  end
end
