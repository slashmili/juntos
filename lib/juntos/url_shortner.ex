defmodule Juntos.UrlShortner do
  @moduledoc """
  The UrlShortner context.
  """

  import Ecto.Query, warn: false

  alias Juntos.UrlShortner.Slug

  @sqids Sqids.new!(min_length: 10)

  def create_for_event(multi \\ Ecto.Multi.new(), event_id) do
    create_transaction(multi, %{
      resource: "event",
      resource_id: event_id
    })
  end

  def create_transaction(multi \\ Ecto.Multi.new(), attrs) do
    multi
    |> Ecto.Multi.one(:next_slug_id, fn _ ->
      from seq in fragment("SELECT nextval('slugs_id_seq') as id"), select: seq.id
    end)
    |> Ecto.Multi.insert(:slug, fn %{next_slug_id: next_slug_id} ->
      create_changeset(attrs, next_slug_id)
    end)
  end

  def generate_slug(id) do
    Sqids.encode!(Sqids.Hacks.dialyzed_ctx(@sqids), [get_seed(), id])
  end

  defp get_seed do
    Application.get_env(:juntos, __MODULE__, seed: 1)[:seed]
  end

  defp create_changeset(attrs, next_slug_id) do
    slug = generate_slug(next_slug_id)

    Slug.changeset(%Slug{id: next_slug_id, slug: slug}, attrs)
  end
end
