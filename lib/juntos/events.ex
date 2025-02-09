defmodule Juntos.Events do
  alias Juntos.Events.Event
  alias Juntos.{Repo, UrlShortner}
  alias Juntos.Events.Uploaders.CoverImage

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
end
