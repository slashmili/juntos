defmodule Juntos.Chrono do
  @moduledoc """
    Time related helper module 
  """

  defmodule TimeZone do
    @moduledoc """
      Timezone related functions
    """

    defstruct [:zone_name, :offset, :offset_str, :zone_short_name]

    @known_timezones ~w(
      UTC
      US/Pacific US/Central US/Eastern America/Sao_Paulo
      Europe/Berlin Europe/Madrid Europe/Rome
      Europe/Amsterdam Europe/Paris Europe/Dublin
      Europe/Stockholm Europe/London Europe/Copenhagen Europe/Helsinki
      Asia/Kolkata Asia/Singapore Australia/Sydney
    )
    def known_timezones do
      @known_timezones
    end

    def get_list_of_time_zones(datetime \\ nil) do
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

        to_struct(zone_name, tzone[:utc_offset], tzone[:std_offset])
      end
    end

    defp to_struct(zone_name, utc_offset, std_offset) do
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

      %Juntos.Chrono.TimeZone{
        zone_name: zone_name,
        offset: offset,
        offset_str: "GMT#{sign}#{hours}:#{remaingin_minutes}",
        zone_short_name: List.last(String.split(zone_name, "/"))
      }
    end

    def get_time_zone(zone_name, datetime \\ nil) do
      datetime
      |> get_list_of_time_zones()
      |> Enum.find(&(&1.zone_name == zone_name))
      |> case do
        nil -> {:error, :not_found}
        timezone -> {:ok, timezone}
      end
    end
  end
end
