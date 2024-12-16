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
  end

  def all() do
    q = from e in Event, order_by: e.start_datetime
    Repo.all(q)
  end

  def list_user_events(%Accounts.User{id: user_id}, filters \\ []) do
    base_query = from e in Event, where: e.creator_id == ^user_id, order_by: e.start_datetime

    filters
    |> Enum.reduce(base_query, fn filter, query ->
      filter.(query)
    end)
    |> Repo.all()
  end

  def upcoming_event_filter(datetime) do
    fn q -> Ecto.Query.where(q, [e], e.end_datetime > ^datetime) end
  end

  def past_event_filter(datetime) do
    fn q -> Ecto.Query.where(q, [e], e.end_datetime < ^datetime) end
  end
end
