defmodule Juntos.Events do
  import Ecto.Query
  alias Juntos.Events.{Event, EventAttendee}
  alias Juntos.Accounts
  alias Juntos.{Repo, UrlShortner}
  alias Juntos.Events.Uploaders.CoverImage

  def change_event(event \\ %Event{}, attr \\ %{}) do
    Event.create_changeset(event, attr)
  end

  def get_event(queries) do
    event_q =
      from(e in Event)

    q = Enum.reduce(queries, event_q, fn q, event_q -> q.(event_q) end)
    Repo.one(q)
  end

  def update_event(event, attrs \\ %{}) do
    with {:ok, event = %Event{}} <-
           event
           |> Event.edit_changeset(attrs)
           |> Repo.update() do
      {:ok, event}
    end
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

  @default_image_covers [
    "/images/defaults/covers/01.jpg",
    "/images/defaults/covers/02.jpg",
    "/images/defaults/covers/03.jpg",
    "/images/defaults/covers/04.jpg",
    "/images/defaults/covers/05.jpg",
    "/images/defaults/covers/06.jpg"
  ]

  def event_cover_url(%{id: id, cover_image: nil}) do
    hashed_value = :crypto.hash(:md5, id) |> :binary.decode_unsigned()
    index = rem(hashed_value, length(@default_image_covers))
    image = Enum.at(@default_image_covers, index)

    %{
      media_type: to_file_ext(image),
      webp: nil,
      original: image,
      jpg: image
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

  def is_attending?(_event, nil) do
    false
  end

  def is_attending?(event, user) do
    q = from(ea in EventAttendee, where: ea.event_id == ^event.id, where: ea.user_id == ^user.id)
    Repo.aggregate(q, :count, :id) == 1
  end

  def list_future_events(queries \\ []) do
    from_dt = NaiveDateTime.utc_now()

    list_events_q =
      from(e in Event,
        where: e.start_datetime > ^from_dt,
        order_by: [desc: :start_datetime]
      )

    q = Enum.reduce(queries, list_events_q, fn q, list_events_q -> q.(list_events_q) end)

    Repo.all(q)
  end

  def list_user_events(%Accounts.User{} = user, queries \\ []) do
    base_query =
      from(e in Event,
        left_join: ea in EventAttendee,
        on: ea.event_id == e.id,
        where: e.creator_id == ^user.id or ea.user_id == ^user.id,
        distinct: e.id
      )

    list_events_q = from(e in subquery(base_query), order_by: [desc: e.start_datetime], limit: 4)
    q = Enum.reduce(queries, list_events_q, fn q, list_events_q -> q.(list_events_q) end)
    Repo.all(q)
  end

  def query_events_limit(limit) do
    fn query ->
      from(e in query, limit: ^limit)
    end
  end

  def query_events_offset(offset) do
    fn query ->
      from(e in query, offset: ^offset)
    end
  end

  def query_events_for_scope(%Juntos.Accounts.Scope{user: user}) do
    fn query ->
      from(e in query, where: e.creator_id == ^user.id)
    end
  end

  def query_events_where_id(id) do
    fn query ->
      from(e in query, where: e.id == ^id)
    end
  end
end
