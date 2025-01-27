defmodule Juntos.EventsTest do
  use Juntos.DataCase
  alias Juntos.Events, as: SUT

  import Juntos.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "change_event/2" do
    test "creates a changeset" do
      assert %Ecto.Changeset{} = SUT.change_event(%SUT.Event{}, %{name: "Hello"})
    end
  end

  describe "create_event/1" do
    test "with valid data creates an event", %{user: user} do
      valid_attrs = %{
        name: "event name",
        start_datetime: NaiveDateTime.utc_now(),
        end_datetime: NaiveDateTime.utc_now(),
        time_zone: "Europe/Berlin"
      }

      assert {:ok, event} = SUT.create_event(valid_attrs, user)
      assert event.creator_id == user.id
      assert event.slug
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
end
