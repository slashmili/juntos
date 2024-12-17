defmodule Junto.EventsTest do
  use Junto.DataCase

  alias Junto.Events, as: SUT

  import Junto.AccountsFixtures
  import Junto.EventsFixtures
  @utc_time_zone "Etc/UTC"

  describe "create/1" do
    test "validates attrs" do
      user = user_fixture()
      assert {:error, changeset} = SUT.create(user, %{})

      assert changeset.errors == [
               {:name, {"can't be blank", [validation: :required]}},
               {:scope, {"can't be blank", [validation: :required]}},
               {:start_datetime, {"can't be blank", [validation: :required]}},
               {:end_datetime, {"can't be blank", [validation: :required]}}
             ]
    end

    test "creates an event in utc" do
      user = user_fixture()
      event_name = "Hello"
      event_desc = "description ...."
      start_datetime = DateTime.utc_now(:second)
      end_datetime = DateTime.utc_now(:second)

      params = %{
        name: event_name,
        scope: :private,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        description: event_desc,
        location: %{
          id: "929292",
          name: "XyZ GmbH",
          address: "Berliner str. 10, 10203 Berlin, Germany"
        }
      }

      assert {:ok, event} = SUT.create(user, params)

      assert to_string(event.id) =~ "evt_"
      assert event.name == event_name
      assert event.scope == :private
      assert DateTime.shift_zone!(event.start_datetime, @utc_time_zone) == start_datetime
      assert DateTime.shift_zone!(event.end_datetime, @utc_time_zone) == end_datetime
      assert event.time_zone == "UTC"
      assert event.description == event_desc

      assert event.location == %SUT.Event.Location{
               id: "929292",
               name: "XyZ GmbH",
               address: "Berliner str. 10, 10203 Berlin, Germany"
             }
    end

    test "creates events with UTC offset but virtual fields are in expected timezone" do
      user = user_fixture()
      start_datetime_in_utc = ~U[2024-12-29 14:00:00Z]
      end_datetime_in_utc = ~U[2024-12-29 14:01:00Z]

      start_datetime_in_jst = DateTime.shift_zone!(start_datetime_in_utc, "Asia/Tokyo")
      end_datetime_in_jst = DateTime.shift_zone!(end_datetime_in_utc, "Asia/Tokyo")

      params = %{
        id: nil,
        name: "Hello Tokyo 👋",
        scope: :private,
        start_datetime: start_datetime_in_jst,
        end_datetime: end_datetime_in_jst
      }

      assert {:ok, event} = SUT.create(user, params)
      assert event.time_zone == "Asia/Tokyo"

      assert event.start_datetime_utc == start_datetime_in_utc
      assert event.end_datetime_utc == end_datetime_in_utc

      assert event.start_datetime == start_datetime_in_jst

      assert event.end_datetime.time_zone == "Asia/Tokyo"
      assert event.start_datetime == start_datetime_in_jst
    end

    test "creates events with correct time zone" do
      user = user_fixture()
      start_datetime_in_utc = ~U[2024-12-29 14:00:00Z]
      end_datetime_in_utc = ~U[2024-12-29 14:01:00Z]

      start_datetime_in_jst = DateTime.shift_zone!(start_datetime_in_utc, "Asia/Tokyo")
      end_datetime_in_jst = DateTime.shift_zone!(end_datetime_in_utc, "Asia/Tokyo")

      params = %{
        id: nil,
        name: "Hello Tokyo 👋",
        scope: :private,
        start_datetime: start_datetime_in_jst,
        end_datetime: end_datetime_in_jst,
        location: nil,
        description: nil
      }

      assert {:ok, event} = SUT.create(user, params)
      assert event.time_zone == "Asia/Tokyo"

      assert event.start_datetime.time_zone == "Asia/Tokyo"
      assert DateTime.shift_zone!(event.start_datetime, @utc_time_zone) == start_datetime_in_utc

      assert event.end_datetime.time_zone == "Asia/Tokyo"
      assert DateTime.shift_zone!(event.start_datetime, @utc_time_zone) == start_datetime_in_utc
    end
  end

  describe "list_user_events/1" do
    test "list events that was created by the user" do
      user = user_fixture()
      created_event = event_fixture(%{creator: user})
      _other_events = event_fixture()

      assert [event] = SUT.list_user_events(user)
      assert event.id == created_event.id

      assert %DateTime{} = event.start_datetime
      assert event.start_datetime.time_zone == "Europe/Berlin"

      assert %DateTime{} = event.end_datetime
      assert event.end_datetime.time_zone == "Europe/Berlin"
    end

    test "list upcoming events" do
      user = user_fixture()

      created_event =
        event_fixture(%{
          creator: user,
          start_datetime: DateTime.shift_zone!(~U[2024-12-16 08:00:00Z], "Europe/Berlin"),
          end_datetime: DateTime.shift_zone!(~U[2024-12-16 18:00:00Z], "Europe/Berlin")
        })

      now = ~U[2024-12-16 15:05:28.784212Z]

      assert [event] = SUT.list_user_events(user, [SUT.upcoming_event_filter(now)])
      assert event.id == created_event.id
    end

    test "list past events" do
      user = user_fixture()

      created_event =
        event_fixture(%{
          creator: user,
          start_datetime: DateTime.shift_zone!(~U[2024-12-16 08:00:00Z], "Europe/Berlin"),
          end_datetime: DateTime.shift_zone!(~U[2024-12-16 18:00:00Z], "Europe/Berlin")
        })

      now = ~U[2024-12-16 19:05:28.784212Z]

      assert [event] = SUT.list_user_events(user, [SUT.past_event_filter(now)])
      assert event.id == created_event.id
    end
  end
end
