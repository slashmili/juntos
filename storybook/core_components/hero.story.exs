defmodule Storybook.Components.CoreComponents.Hero do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.hero/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :hero,
        attributes: %{},
        slots: [
          "<:title>Let's get together</:title>",
          "<:subtitle>Discover conferences and events that fit your passion, online or in person.</:subtitle>",
          "<:body>From virtual conferences to live gatherings, our platform helps you explore and connect with experiences that match your interests. Dive into a world of possibilities and find your next must-attend event today!</:body>"
        ]
      }
    ]
  end
end
