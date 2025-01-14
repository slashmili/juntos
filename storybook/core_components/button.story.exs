defmodule Storybook.Components.CoreComponents.Button do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.button/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: [
          "Default Large"
        ]
      },
      %Variation{
        id: :default_medium,
        attributes: %{
          variant: "default",
          size: "md",
          type: "button"
        },
        slots: [
          "Default Medium"
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          variant: "default",
          disabled: true
        },
        slots: [
          "Default + Disabled"
        ]
      },
      %Variation{
        id: :secondary,
        attributes: %{
          variant: "secondary"
        },
        slots: [
          "Secondary Large"
        ]
      },
      %Variation{
        id: :secondary_with_icon,
        attributes: %{
          variant: "secondary",
          icon_right: "hero-arrow-right",
          icon_left: "hero-arrow-right"
        },
        slots: [
          "Secondary Large"
        ]
      },
      %Variation{
        id: :icon_only,
        attributes: %{
          icon_left: "hero-arrow-right",
          size: "md"
        },
        slots: [
          ""
        ]
      }
    ]
  end
end
