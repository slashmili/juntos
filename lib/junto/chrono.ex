defmodule Junto.Chrono do
  @moduledoc """
    Time related helper module 
  """

  defmodule Timezone do
    @moduledoc """
      Timezone related functions
    """

    defstruct [:zone_name, :offset, :offset_str, :base_datetime, :zone_short_name]
    @known_timezones ~w(
      UTC
      US/Pacific US/Central US/Eastern America/Sao_Paulo
      Europe/Berlin Europe/Madrid Europe/Rome
      Europe/Amsterdam Europe/Paris Europe/Dublin
      Europe/Stockholm Europe/London Europe/Copenhagen Europe/Helsinki
      Asia/Kolkata Asia/Tokyo Asia/Singapore Australia/Sydney
    )

    def get_list_of_timezones(datetime \\ nil) do
      datetime = datetime || DateTime.utc_now()

      iso_days =
        Calendar.ISO.naive_datetime_to_iso_days(
          datetime.year,
          datetime.month,
          datetime.day,
          datetime.hour,
          datetime.minute,
          datetime.second,
          datetime.microsecond
        )

      for zone_name <- @known_timezones do
        {:ok, tzone} =
          Tzdata.TimeZoneDatabase.time_zone_period_from_utc_iso_days(iso_days, zone_name)

        {zone_name, tzone[:utc_offset], tzone[:std_offset]}
      end
      |> Enum.sort(fn zone1, zone2 ->
        elem(zone1, 1) + elem(zone1, 2) < elem(zone2, 1) + elem(zone2, 2)
      end)
      |> Enum.map(fn {zone_name, utc_offset, std_offset} ->
        offset = utc_offset + std_offset
        minutes = div(offset, 60)
        hours = abs(div(minutes, 60))
        hours = String.pad_leading("#{hours}", 2, "0")
        remaingin_minutes = rem(minutes, 60)
        remaingin_minutes = String.pad_leading("#{remaingin_minutes}", 2, "0")

        sign =
          if offset < 0 do
            "-"
          else
            "+"
          end

        {zone_name, "GMT #{sign}#{hours}:#{remaingin_minutes}"}

        %Junto.Chrono.Timezone{
          zone_name: zone_name,
          offset: offset,
          offset_str: "GMT #{sign}#{hours}:#{remaingin_minutes}",
          base_datetime: datetime,
          zone_short_name: List.last(String.split(zone_name, "/"))
        }
      end)
    end

    def get_timezone(zone_name, datetime \\ nil) do
      datetime
      |> get_list_of_timezones()
      |> Enum.find(&(&1.zone_name == zone_name))
      |> case do
        nil -> {:error, :not_found}
        timezone -> {:ok, timezone}
      end
    end
  end

  defmodule Formatter do
    @moduledoc """
       Format DateTime
    """
    def to_hh_mm_str(%DateTime{} = datetime) do
      Calendar.strftime(datetime, "%H:%M")
    end

    def to_hh_mm_str(_) do
      nil
    end

    def strftime(datetime, string_format) do
      Calendar.strftime(datetime, string_format)
    end
  end
end
