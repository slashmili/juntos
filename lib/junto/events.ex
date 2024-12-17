defmodule Junto.Events do
  @moduledoc """
  The Event context.
  """

  alias Junto.Accounts
  alias Junto.Events.Event
  alias Junto.Repo
  import Ecto.Query, warn: false

  def create(%Accounts.User{} = creator, attrs \\ %{}) do
    %Event{}
    |> Event.create_changeset(attrs)
    |> Event.put_creator(creator)
    |> Repo.insert()
    |> maybe_cast_datetime()
  end

  def all() do
    q = from e in Event, order_by: e.start_datetime_utc
    Repo.all(q)
  end

  def list_user_events(%Accounts.User{id: user_id}, filters \\ []) do
    base_query =
      from e in Event, where: e.creator_id == ^user_id, order_by: e.start_datetime_utc

    filters
    |> Enum.reduce(base_query, fn filter, query ->
      filter.(query)
    end)
    |> Repo.all()
    |> Enum.map(&maybe_cast_datetime/1)
  end

  def upcoming_event_filter(datetime) do
    fn q -> Ecto.Query.where(q, [e], e.end_datetime_utc > ^datetime) end
  end

  def past_event_filter(datetime) do
    fn q -> Ecto.Query.where(q, [e], e.end_datetime_utc < ^datetime) end
  end

  defp maybe_cast_datetime({:ok, event}) do
    {:ok, maybe_cast_datetime(event)}
  end

  defp maybe_cast_datetime({:error, _} = result) do
    result
  end

  defp maybe_cast_datetime(%Event{} = event) do
    {:ok, start_datetime} = DateTime.shift_zone(event.start_datetime_utc, event.time_zone)

    {:ok, end_datetime} = DateTime.shift_zone(event.end_datetime_utc, event.time_zone)

    %{event | start_datetime: start_datetime, end_datetime: end_datetime}
  end
end
