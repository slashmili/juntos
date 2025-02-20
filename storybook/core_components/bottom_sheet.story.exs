defmodule Storybook.Components.CoreComponents.BottomSheet do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.bottom_sheet/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "storybook-bottom-sheet-ex01",
          show: false
        },
        slots: [
          "",
          "<:body class=\"\">Hello</:body>"
        ]
      }
    ]
  end
end
