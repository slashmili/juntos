defmodule Juntos.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Juntos.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    creator = attrs[:creator] || Juntos.AccountsFixtures.user_fixture()

    {:ok, event} =
      attrs
      |> Enum.into(%{
        name: "some name",
        start_datetime: NaiveDateTime.utc_now(),
        end_datetime: NaiveDateTime.utc_now(),
        time_zone: "Europe/Berlin"
      })
      |> Juntos.Events.create_event(creator)

    event
  end
end
