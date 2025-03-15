defmodule Juntos.Events.EventAttendee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Juntos.{Accounts, Events}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "event_attendees" do
    belongs_to :user, Accounts.User, type: :binary_id
    belongs_to :event, Events.Event, type: :binary_id
    timestamps type: :utc_datetime_usec
  end

  def create_changeset(event_attendee, attrs) do
    event_attendee
    |> cast(attrs, [])
    |> unique_constraint([:event_id, :user_id])
  end

  def put_user(%Ecto.Changeset{} = changeset, %Accounts.User{} = user) do
    put_assoc(changeset, :user, user)
  end

  def put_event(%Ecto.Changeset{} = changeset, %Events.Event{} = event) do
    put_assoc(changeset, :event, event)
  end
end
