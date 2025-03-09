defmodule Juntos.ChronoTest do
  use Juntos.DataCase

  alias Juntos.Chrono, as: SUT

  describe "TimeZone.get_list_of_time_zones/1" do
    test "get list of Time zone" do
      assert hd(SUT.TimeZone.get_list_of_time_zones()) == %Juntos.Chrono.TimeZone{
               offset: 0,
               zone_name: "UTC",
               offset_str: "GMT+00:00",
               zone_short_name: "UTC"
             }
    end
  end

  describe "TimeZone.get_time_zone/2" do
    test "get a known time zone" do
      assert {:ok,
              %Juntos.Chrono.TimeZone{
                zone_name: "Europe/Berlin",
                offset: 3600,
                offset_str: "GMT+01:00",
                zone_short_name: "Berlin"
              }} = SUT.TimeZone.get_time_zone("Europe/Berlin")
    end

    test "get a unknown time zone" do
      assert {:error, :not_found} = SUT.TimeZone.get_time_zone("Europe/KL")
    end
  end
end
