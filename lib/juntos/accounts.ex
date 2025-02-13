defmodule Juntos.Accounts.OtpSession do
  defstruct [:otp_code, :url_token, :user, :user_token]
end

defmodule Juntos.Accounts do
  alias Juntos.Accounts.{User, UserToken, ExternalAuthProvider, UserNotifier}

  alias Juntos.Repo

  def register_user(%ExternalAuthProvider.User{} = user) do
    %User{}
    |> User.registration_changeset(user)
    |> Repo.insert()
  end

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_user(email) do
    Repo.transaction(fn ->
      if user = get_user_by_email(email) do
        user
      else
        %User{}
        |> User.registration_changeset(%{email: email})
        |> Repo.insert!()
      end
    end)
  end

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def change_user(user \\ %User{}, attr \\ %{}) do
    User.registration_changeset(user, attr)
  end

  def create_otp_session(user) do
    otp_code = :crypto.strong_rand_bytes(3) |> Base.encode16()
    otp_token = otp_code <> :crypto.strong_rand_bytes(29)

    {encoded_token, user_token} =
      UserToken.build_otp_token(user, "otp", otp_token)

    Repo.insert!(user_token)

    %Juntos.Accounts.OtpSession{
      otp_code: otp_code,
      url_token: encoded_token,
      user_token: user_token,
      user: user
    }
  end

  def validate_user_with_otp(user, url_token) do
    with {:ok, query} <-
           UserToken.verify_otp_token_query(user, url_token),
         %UserToken{} = user_token <- Repo.one(query) do
      {:ok, user_token}
    else
      _ -> :error
    end
  end

  def deliver_user_otp_code(otp_session, confirmation_otp_url_fun) do
    UserNotifier.deliver_otp_code(
      otp_session.user,
      otp_session.otp_code,
      confirmation_otp_url_fun.(otp_session.url_token)
    )
  end

  def confirm_user!(user) do
    user
    |> User.confirm_changeset()
    |> Repo.update!()
  end
end
