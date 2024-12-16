defmodule Junto.EventsTest do
  use Junto.DataCase

  alias Junto.Events, as: SUT

  import Junto.AccountsFixtures
  import Junto.EventsFixtures

  describe "create/1" do
    test "validates attrs" do
      user = user_fixture()
      assert {:error, changeset} = SUT.create(user, %{})

      assert changeset.errors == [
               {:name, {"can't be blank", [validation: :required]}},
               {:scope, {"can't be blank", [validation: :required]}},
               {:start_datetime, {"can't be blank", [validation: :required]}},
               {:end_datetime, {"can't be blank", [validation: :required]}},
               {:timezone, {"can't be blank", [validation: :required]}}
             ]
    end

    test "creates an event" do
      user = user_fixture()
      event_name = "Hello"
      event_desc = "description ...."
      start_datetime = DateTime.utc_now(:second)
      end_datetime = DateTime.utc_now(:second)
      {:ok, timezone} = Junto.Chrono.Timezone.get_timezone("Europe/Berlin")

      params = %{
        name: event_name,
        scope: :private,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        timezone: timezone.zone_name,
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
      assert event.start_datetime == start_datetime
      assert event.end_datetime == end_datetime
      assert event.timezone == timezone.zone_name
      assert event.description == event_desc

      assert event.location == %SUT.Event.Location{
               id: "929292",
               name: "XyZ GmbH",
               address: "Berliner str. 10, 10203 Berlin, Germany"
             }
    end
  end

  describe "list_user_events/1" do
    test "list events that was created by the user" do
      user = user_fixture()
      created_event = event_fixture(%{creator: user})
      _other_events = event_fixture()

      assert [event] = SUT.list_user_events(user)
      assert event.id == created_event.id
    end

    test "list upcoming events" do
      user = user_fixture()

      created_event =
        event_fixture(%{
          creator: user,
          start_datetime: ~U[2024-12-16 08:00:00.0Z],
          end_datetime: ~U[2024-12-16 18:00:00.0Z]
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
          start_datetime: ~U[2024-12-16 08:00:00.0Z],
          end_datetime: ~U[2024-12-16 18:00:00.0Z]
        })

      now = ~U[2024-12-16 19:05:28.784212Z]

      assert [event] = SUT.list_user_events(user, [SUT.past_event_filter(now)])
      assert event.id == created_event.id
    end
  end
end
