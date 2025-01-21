defmodule JuntosWeb.UserAuth do
  use JuntosWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Juntos.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_juntos_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @external_auth_inflight_key :external_auth_inflight
  @external_auth_state_key :external_auth_state

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  @doc """
  Set conn to redirect to external auth

  It also sets `external_auth_state` into session for later validatoin
  """

  @provider_types Enum.map(Accounts.ExternalAuthProvider.provider_types(), &to_string/1)
  def external_auth_redirect(conn, provider) when provider in @provider_types do
    provider = String.to_existing_atom(provider)
    url = &url(~p"/users/auth/#{&1}/callback")

    case Accounts.ExternalAuthProvider.authorize_url(provider, url) do
      {:ok, %{url: url, session_params: %{state: state}}} ->
        {:ok,
         conn
         |> put_session(@external_auth_state_key, state)
         |> redirect(external: url)}

      {:error, _} = error ->
        error
    end
  end

  def external_auth_redirect(_, _) do
    {:error, :provider_not_supported}
  end

  @doc """
  Retrives user info and attempt to log in the user if there is an account already with the user's email
  Otherwise it sets a session and redirects user to /users/auth/register
  """
  def external_auth_user_log_in(conn, provider, params) when provider in @provider_types do
    provider = String.to_existing_atom(provider)
    url = &url(~p"/users/auth/#{&1}/callback")

    session_state = get_session(conn, @external_auth_state_key)

    with {:ok, user} <-
           Accounts.ExternalAuthProvider.user_info(provider, params, session_state, url) do
      # || Accounts.get_user_by_external_auth_user(user)
      lookup_result = Accounts.get_user_by_email(user.email)

      case lookup_result do
        nil ->
          {:ok,
           conn
           |> put_session(@external_auth_inflight_key, Jason.encode!(user))
           |> redirect(to: ~p"/users/auth/register")}

        user ->
          {:ok, log_in_user(conn, user)}
      end
    end
  end

  def external_auth_user_log_in(_coon, _provider, _params) do
    {:error, :provider_not_supported}
  end

  def external_auth_user_from_sessions(conn) do
    if user_json = get_session(conn, @external_auth_inflight_key) do
      {:ok, user} = Jason.decode(user_json)
      Accounts.ExternalAuthProvider.User.new(user, nil)
    end
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  defp signed_in_path(_conn), do: ~p"/"
end
