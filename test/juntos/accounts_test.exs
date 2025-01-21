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

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = SUT.generate_user_session_token(user)
      assert user_token = Repo.get_by(SUT.UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%SUT.UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end
end
