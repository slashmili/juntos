defmodule Storybook.Components.CoreComponents.Button do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.CoreComponents.button/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :primary,
        attributes: %{},
        slots: [
          "Primary Large"
        ]
      },
      %Variation{
        id: :primary_medium,
        attributes: %{
          variant: "primary",
          size: "md",
          type: "button"
        },
        slots: [
          "Primary Medium"
        ]
      },
      %Variation{
        id: :disabled,
        attributes: %{
          variant: "primary",
          disabled: true
        },
        slots: [
          "Primary + Disabled"
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
      },
      %Variation{
        id: :outline,
        attributes: %{
          variant: "outline"
        },
        slots: [
          "Outline Large"
        ]
      },
      %Variation{
        id: :outline_disabled,
        attributes: %{
          variant: "outline",
          disabled: true,
          size: "md"
        },
        slots: [
          "Outline Disabled"
        ]
      },
      %Variation{
        id: :link,
        attributes: %{
          variant: "link"
        },
        slots: [
          "Link"
        ]
      }
    ]
  end
end
