defmodule Junto.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Junto.Events` context.
  """
  alias Junto.Events

  def unique_event_name, do: "Event ##{System.unique_integer()}"

  def event_fixture(attrs \\ %{}) do
    {:ok, timezone} = Junto.Chrono.Timezone.get_timezone("Europe/Berlin")

    default = %{
      name: unique_event_name(),
      description: "description ....",
      start_datetime: DateTime.utc_now(),
      end_datetime: DateTime.utc_now(),
      timezone: timezone.zone_name,
      scope: :private,
      location: %{
        id: "929292",
        name: "XyZ GmbH",
        address: "Berliner str. 10, 10203 Berlin, Germany"
      },
      creator: Junto.AccountsFixtures.user_fixture()
    }

    params = Map.merge(default, Map.new(attrs))

    {:ok, event} = Events.create(params[:creator], params)
    event
  end
end
