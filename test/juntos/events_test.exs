defmodule Juntos.EventsTest do
  use Juntos.DataCase
  alias Juntos.Events, as: SUT

  import Juntos.AccountsFixtures
  import Juntos.EventsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "change_event/2" do
    test "creates a changeset" do
      assert %Ecto.Changeset{} = SUT.change_event(%SUT.Event{}, %{name: "Hello"})
    end
  end

  @valid_attrs %{
    name: "event name",
    start_datetime: NaiveDateTime.utc_now(),
    end_datetime: NaiveDateTime.utc_now(),
    time_zone: "Europe/Berlin",
    location: nil
  }
  describe "create_event/1" do
    test "with valid data creates an event", %{user: user} do
      valid_attrs = @valid_attrs
      assert {:ok, event} = SUT.create_event(valid_attrs, user)

      assert event.creator_id == user.id
      assert event.slug
    end

    test "with location as Place", %{user: user} do
      valid_attrs = %{
        @valid_attrs
        | location: %{__type__: :place, address: "ad", id: "id", name: "name"}
      }

      assert {:ok, event} = SUT.create_event(valid_attrs, user)
      assert event.location == %Juntos.Events.Event.Place{id: "id", name: "name", address: "ad"}
    end

    test "with location as url", %{user: user} do
      valid_attrs = %{
        @valid_attrs
        | location: %{__type__: :url, link: "http://meetup.example.com"}
      }

      assert {:ok, event} = SUT.create_event(valid_attrs, user)
      assert event.location == %Juntos.Events.Event.Url{link: "http://meetup.example.com"}
    end

    test "with location as Address", %{user: user} do
      valid_attrs = %{
        @valid_attrs
        | location: %{__type__: :address, address: "Musterstrasse 10. Berlin"}
      }

      assert {:ok, event} = SUT.create_event(valid_attrs, user)
      assert event.location == %Juntos.Events.Event.Address{address: "Musterstrasse 10. Berlin"}
    end

    test "with invalid data returns error", %{user: user} do
      assert {:error, _} = SUT.create_event(%{}, user)
    end

    test "with invalid time zone, returns error", %{user: user} do
      valid_attrs = %{
        name: "event name",
        start_datetime: NaiveDateTime.utc_now(),
        end_datetime: NaiveDateTime.utc_now(),
        time_zone: "Moon/VallisAlpes"
      }

      assert {:error, changeset} = SUT.create_event(valid_attrs, user)
      assert errors_on(changeset) == %{time_zone: ["is invalid"]}
    end
  end

  describe "add_event_attendee/2" do
    test "with a user attending an event" do
      event = event_fixture()
      user = user_fixture()
      assert :ok = SUT.add_event_attendee(event, user)

      event = Juntos.Repo.reload!(event)
      assert event.attendee_count == 1
    end

    test "with a user attends an event twice" do
      event = event_fixture()
      user = user_fixture()
      assert :ok = SUT.add_event_attendee(event, user)
      assert {:error, ch} = SUT.add_event_attendee(event, user)
      assert errors_on(ch) == %{event_id: ["has already been taken"]}
    end
  end

  describe "remove_event_attendee/2" do
    test "with a user attending an event" do
      event = event_fixture()
      user = user_fixture()
      assert :ok = SUT.add_event_attendee(event, user)
      assert :ok = SUT.remove_event_attendee(event, user)

      event = Juntos.Repo.reload!(event)
      assert event.attendee_count == 0
    end
  end

  describe "is_attending?/2" do
    test "when given user is nil" do
      event = event_fixture()
      refute SUT.is_attending?(event, nil)
    end

    test "when given user is not attending" do
      event = event_fixture()
      user = user_fixture()
      refute SUT.is_attending?(event, user)
    end

    test "when given user is attending" do
      event = event_fixture()
      user = user_fixture()
      assert :ok = SUT.add_event_attendee(event, user)
      assert SUT.is_attending?(event, user)
    end
  end
end
