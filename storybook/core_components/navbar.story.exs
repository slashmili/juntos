defmodule Storybook.Components.CoreComponents.Navbar do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.navbar/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "button",
          class: "bg-emerald-400 hover:bg-emerald-500 text-emerald-800"
        },
        slots: [
          "Click me!"
        ]
      }
    ]
  end
end
