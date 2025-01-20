defmodule Storybook.Components.CoreComponents.InputText do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.input_text/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "Label",
          placeholder: "Placeholder",
          icon_right: "hero-x-mark",
          icon_left: "hero-magnifying-glass"
        },
        slots: []
      }
    ]
  end
end
