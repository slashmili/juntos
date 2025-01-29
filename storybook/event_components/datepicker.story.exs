defmodule Storybook.Components.EventComponents.Datepicker do
  use PhoenixStorybook.Story, :component
  def function, do: &JuntosWeb.EventLive.Components.datepicker/1
  def render_source, do: :function

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "storybook-event-datepicker",
          start_datetime_field: %Phoenix.HTML.FormField{
            form: nil,
            value: nil,
            id: "event_start_datetime",
            name: "event[start_datetime]",
            errors: [],
            field: :start_datetime
          },
          end_datetime_field: %Phoenix.HTML.FormField{
            form: nil,
            value: nil,
            id: "event_end_datetime",
            name: "event[end_datetime]",
            errors: [],
            field: :start_datetime
          },
          time_zone_field: %Phoenix.HTML.FormField{
            form: nil,
            value: nil,
            id: "event_time_zone",
            name: "event[time_zone]",
            errors: [],
            field: :start_datetime
          }
        },
        slots: []
      }
    ]
  end
end
