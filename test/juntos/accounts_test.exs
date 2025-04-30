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

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = SUT.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert {session_user, _} = SUT.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute SUT.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(SUT.UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute SUT.get_user_by_session_token(token)
    end
  end

  describe "create_otp_session/1" do
    setup do
      %{user: user_fixture()}
    end

    test "creates otp sessions", %{user: user} do
      assert otp_session = SUT.create_otp_session(user)
      assert otp_session.user_token.user_id == user.id
      assert otp_session.user.id == user.id
      assert String.length(otp_session.otp_code) == 6
    end
  end

  describe "validate_user_with_otp/2" do
    setup do
      %{user: user_fixture()}
    end

    test "returns user token when token is valid", %{user: user} do
      assert otp_session = SUT.create_otp_session(user)
      assert {:ok, user_token} = SUT.validate_user_with_otp(user, otp_session.url_token)
      assert user_token.user_id == user.id
    end

    test "returns error when token is invalid", %{user: user} do
      assert :error = SUT.validate_user_with_otp(user, "foobar")
    end
  end
end
