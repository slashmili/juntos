defmodule JuntoWeb.EventLive.CreateEventFormTest do
  use Junto.DataCase, async: true

  alias JuntoWeb.EventLive.CreateEventForm, as: SUT

  describe "changeset/2" do
    test "casts to full start_datetime" do
      changeset = SUT.changeset(%SUT{}, %{start_date: "2020-01-01", start_time: "01:01"})
      assert changeset.changes.start_datetime == ~U[2020-01-01 01:01:00Z]
    end

    test "casts to full end_datetime" do
      changeset = SUT.changeset(%SUT{}, %{end_date: "2020-01-01"})
      assert changeset.changes.end_datetime == ~U[2020-01-01 00:00:00Z]
    end

    test "handles when no datetmie is provided" do
      changeset = SUT.changeset(%SUT{}, %{})
      assert changeset.changes == %{}
    end

    test "validates end_datetime is after start_datetime" do
      changeset =
        SUT.changeset(%SUT{}, %{
          start_date: "2020-01-01",
          start_time: "13:00",
          end_date: "2020-01-01",
          end_time: "12:00"
        })

      assert Junto.DataCase.errors_on(changeset).end_date == [
               "must be after 2020-01-01 13:00:00Z"
             ]
    end

    test "validates start_datetime is after now" do
      one_week_before = DateTime.shift(DateTime.utc_now(), %Duration{day: -7})

      changeset =
        SUT.changeset(%SUT{}, %{
          start_date: Calendar.strftime(one_week_before, "%Y-%m-%d"),
          start_time: "00:00"
        })

      assert Junto.DataCase.errors_on(changeset).start_date == [
               "must be in future"
             ]
    end

    test "validates location when it's provided" do
      params = %{
        location: %{
          :address => "street 1, 10000 Berlin, Germany",
          :id => "ChIJ8...2rFcz0E",
          :name => "Place XyZ"
        }
      }

      changeset = SUT.changeset(%SUT{}, params)
      assert changeset.changes.location.changes == params.location
    end
  end
end
