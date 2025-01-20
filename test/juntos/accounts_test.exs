defmodule Juntos.AccountsTest do
  use Juntos.DataCase
  alias Juntos.Accounts, as: SUT
  import Juntos.AccountsFixtures

  describe "register_user/1" do
    test "requires email" do
      {:error, changeset} = SUT.register_user(%{})

      assert %{
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email when given" do
      {:error, changeset} = SUT.register_user(%{email: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"]
             } = errors_on(changeset)
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = SUT.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = SUT.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end
  end
end
