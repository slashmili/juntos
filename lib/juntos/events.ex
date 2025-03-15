defmodule Juntos.Events do
  import Ecto.Query
  alias Juntos.Events.{Event, EventAttendee}
  alias Juntos.Accounts
  alias Juntos.{Repo, UrlShortner}
  alias Juntos.Events.Uploaders.CoverImage

  def change_event(event \\ %Event{}, attr \\ %{}) do
    Event.create_changeset(event, attr)
  end

  def create_event(attrs \\ %{}, %Accounts.User{} = creator) do
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

  def event_cover_url(%{cover_image: nil}) do
    %{
      media_type: nil,
      webp: nil,
      original: nil,
      jpg: nil
    }
  end

  def event_cover_url(event) do
    %{
      media_type: to_file_ext(event.cover_image.file_name),
      webp: CoverImage.url({event.cover_image, event}, :webp400x400),
      original: CoverImage.url({event.cover_image, event}, :original),
      jpg: CoverImage.url({event.cover_image, event}, :jpg400x400)
    }
  end

  defp to_file_ext(file_name) do
    file_name |> Path.extname() |> String.trim(".") |> String.to_atom()
  end

  @doc """
  Store the user as attendee and increase attendees count on event
  """
  def add_event_attendee(%Event{} = event, %Accounts.User{} = user) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :attendee,
        fn _context ->
          EventAttendee.create_changeset(%EventAttendee{}, %{})
          |> EventAttendee.put_user(user)
          |> EventAttendee.put_event(event)
        end
      )
      |> Ecto.Multi.update_all(
        :attendees_count,
        fn _context ->
          from(e in Event, where: e.id == ^event.id, update: [inc: [attendee_count: 1]])
        end,
        []
      )
      |> Repo.transaction()

    case result do
      {:ok, _result} -> :ok
      {:error, :attendee, ch, _} -> {:error, ch}
    end
  end

  def remove_event_attendee(%Event{} = event, %Accounts.User{} = user) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.one(:attendee, fn _ ->
        from(ea in EventAttendee, where: ea.event_id == ^event.id, where: ea.user_id == ^user.id)
      end)
      |> Ecto.Multi.delete(:delete_attendee, fn %{attendee: attendee} ->
        attendee
      end)
      |> Ecto.Multi.update_all(
        :attendees_count,
        fn _context ->
          from(e in Event, where: e.id == ^event.id, update: [inc: [attendee_count: -1]])
        end,
        []
      )
      |> Repo.transaction()

    case result do
      {:ok, _result} -> :ok
    end
  end
end
