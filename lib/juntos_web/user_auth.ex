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
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
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

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule JuntoWeb.PageLive do
        use JuntoWeb, :live_view

        on_mount {JuntoWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{JuntoWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/users/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_session_token(user_token)
      end
    end)
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

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
