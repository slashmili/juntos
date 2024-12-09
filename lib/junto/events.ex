defmodule Junto.Events do
  @moduledoc """
  The Event context.
  """

  alias Junto.Accounts.User
  alias Junto.Events.Event
  alias Junto.Repo
  import Ecto.Query, warn: false

  def create(%User{} = creator, attrs \\ %{}) do
    %Event{}
    |> Event.create_changeset(attrs)
    |> Event.put_creator(creator)
    |> Repo.insert()
  end

  def all() do
    q = from e in Event, order_by: e.start_datetime
    Repo.all(q)
  end
end
