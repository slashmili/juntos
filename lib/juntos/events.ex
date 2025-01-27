defmodule Juntos.Events do
  alias Juntos.Events.Event
  alias Juntos.{Repo, UrlShortner}

  def change_event(event \\ %Event{}, attr \\ %{}) do
    Event.create_changeset(event, attr)
  end

  def create_event(attrs \\ %{}, %Juntos.Accounts.User{} = creator) do
    event_record_id = create_uuid()

    result =
      Ecto.Multi.new()
      |> UrlShortner.create_for_event(event_record_id)
      |> Ecto.Multi.insert(:event, fn context ->
        create_event_changeset(context, event_record_id, attrs, creator)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{event: event}} -> {:ok, event}
      {:error, :event, ch, _} -> {:error, ch}
    end
  end

  defp create_event_changeset(context, event_record_id, attrs, creator) do
    %Event{id: event_record_id, slug: context[:slug].slug}
    |> change_event(attrs)
    |> Event.put_creator(creator)
  end

  defp create_uuid do
    Ecto.UUID.generate()
  end
end
