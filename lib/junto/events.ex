defmodule Junto.Events do
  @moduledoc """
  The Event context.
  """

  alias Junto.Accounts.User
  alias Junto.Events.Event
  alias Junto.Repo

  def create(%User{} = creator, attrs \\ %{}) do
    %Event{}
    |> Event.create_changeset(attrs)
    |> Event.put_creator(creator)
    |> Repo.insert()
  end

  def all() do
    Repo.all(Event)
  end
end
