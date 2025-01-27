defmodule Juntos.Chrono do
  @moduledoc """
    Time related helper module 
  """

  defmodule TimeZone do
    @moduledoc """
      Timezone related functions
    """
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
  end
end
