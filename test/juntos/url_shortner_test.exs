defmodule Juntos.UrlShortnerTest do
  use Juntos.DataCase

  alias Juntos.UrlShortner, as: SUT
  alias Juntos.Repo

  describe "create_transaction/1" do
    test "creates transcation" do
      attrs = %{resource: "event", resource_id: "2c6bc717-2c63-427f-8672-9a97bdd84a77"}
      result = SUT.create_transaction(attrs)

      assert {:ok, %{slug: %{id: new_id}, next_slug_id: new_id}} =
               Repo.transaction(result)
    end
  end
end
