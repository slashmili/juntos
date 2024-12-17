defmodule JuntoWeb.EventLive.CreateEventForm do
  use Ecto.Schema

  alias JuntoWeb.EventLive.CreateEventForm

  embedded_schema do
    field :name, :string

    field :scope, Ecto.Enum, values: [:private, :public]
    field :start_date, :date
    field :start_time, :time
    field :start_datetime, :utc_datetime
    field :end_time, :time
    field :end_date, :date
    field :end_datetime, :utc_datetime
    field :time_zone, :string

    embeds_one :location, Location, primary_key: false, on_replace: :delete do
      field :id, :string
      field :name, :string
      field :address, :string
    end

    field :description, :string
  end

  def new(attrs \\ %{}) do
    default = default_datetime()
    attrs = Map.merge(default, attrs)
    schema = %CreateEventForm{}
    changeset(schema, attrs)
  end

  def apply(attrs \\ %{}) do
    attrs
    |> new()
    |> Ecto.Changeset.apply_action(:create)
  end

  def changeset(schema, attrs) do
    schema
    |> Ecto.Changeset.cast(attrs, [
      :scope,
      :name,
      :start_date,
      :start_time,
      :end_date,
      :end_time,
      :time_zone,
      :description
    ])
    |> Ecto.Changeset.validate_required([:name, :start_date, :end_date, :time_zone])
    |> maybe_cast_datetime(:start_date, :start_time, :start_datetime)
    |> maybe_cast_datetime(:end_date, :end_time, :end_datetime)
    |> maybe_validate_end_datetime()
    |> maybe_validate_start_datetime()
    |> Ecto.Changeset.cast_embed(:location, with: &location_chageset/2)
  end

  defp location_chageset(schema, params) do
    Ecto.Changeset.cast(schema, params, [:id, :name, :address])
  end

  defp maybe_validate_end_datetime(changeset) do
    start_datetime = Ecto.Changeset.get_change(changeset, :start_datetime)
    end_datetime = Ecto.Changeset.get_change(changeset, :end_datetime)

    case {start_datetime, end_datetime} do
      {%DateTime{}, %DateTime{}} ->
        if DateTime.compare(start_datetime, end_datetime) == :gt do
          changeset
          |> Ecto.Changeset.add_error(:end_date, "must be after %{start_datetime}",
            start_datetime: start_datetime
          )
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp maybe_validate_start_datetime(changeset) do
    case Ecto.Changeset.get_change(changeset, :start_datetime) do
      %DateTime{} = start_datetime ->
        if DateTime.compare(DateTime.utc_now(), start_datetime) == :gt do
          changeset
          |> Ecto.Changeset.add_error(:start_date, "must be in future")
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp maybe_cast_datetime(changeset, date_key, time_key, cast_to_key) do
    time_zone = Map.get(changeset.changes, :time_zone, "UTC")
    datetime = to_datetime(changeset.changes[date_key], changeset.changes[time_key], time_zone)
    Ecto.Changeset.change(changeset, %{cast_to_key => datetime})
  end

  defp to_datetime(nil, _, _) do
    nil
  end

  defp to_datetime(date, nil, time_zone) do
    to_datetime(date, ~T[00:00:00], time_zone)
  end

  defp to_datetime(date, time, time_zone) do
    case DateTime.new(date, time, time_zone) do
      {:ok, datetime} -> datetime
      _ -> nil
    end
  end

  defp default_datetime() do
    start_datetime = DateTime.shift(DateTime.utc_now(), %Duration{hour: 1})

    end_datetime = DateTime.shift(start_datetime, %Duration{hour: 10})

    %{
      "scope" => "private",
      "time_zone" => "UTC",
      "start_date" => Calendar.strftime(start_datetime, "%Y-%m-%d"),
      "start_time" => Calendar.strftime(start_datetime, "%H:%M"),
      "end_date" => Calendar.strftime(end_datetime, "%Y-%m-%d"),
      "end_time" => Calendar.strftime(end_datetime, "%H:%M")
    }
  end
end
