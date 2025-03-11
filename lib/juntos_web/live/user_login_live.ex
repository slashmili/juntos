defmodule JuntosWeb.UserLoginLive do
  use JuntosWeb, :live_view

  alias Juntos.Accounts

  @impl true
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user()

    {:ok,
     socket
     |> assign(
       trigger_submit: false,
       otp_session: nil,
       page_title: gettext("Login/Register")
     )
     |> assign_form(changeset)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.page_wrapper>
      <.login_form form={@form} trigger_submit={@trigger_submit}>
        <.hero_section />
        <.external_auth_section />
        <.line />
        <.auth_section
          form={@form}
          otp_session={@otp_session}
          trigger_submit={@trigger_submit}
          invalid_otp_session={assigns[:invalid_otp_session]}
        />
      </.login_form>
    </.page_wrapper>
    """
  end

  defp auth_section(assigns) do
    ~H"""
    <.input
      field={@form[:email]}
      type="email"
      placeholder={gettext "Your email address"}
      label={gettext "Email"}
      autocomplete="email webauthn"
      required
    />
    <.input
      :if={@otp_session != nil}
      field={@form[:otp_code]}
      type="text"
      label={gettext "OTP Code"}
      required
    />
    <div :if={@invalid_otp_session}>
      {gettext "Invalid Code"}
    </div>

    <input
      :if={@otp_session != nil and @trigger_submit == true}
      name="user[otp_token]"
      type="hidden"
      value={@otp_session.url_token}
    />
    <.button type="submit">{gettext "Continue"}</.button>
    """
  end

  defp line(assigns) do
    ~H"""
    <hr />
    """
  end

  defp external_auth_section(assigns) do
    ~H"""
    <section class="flex flex-col gap-2">
      <.button type="link" variant="outline" href={~p"/users/auth/google"}>
        <.icon name="google" class="w-6 h-6" /> Continue with Google
      </.button>
      <.button type="link" variant="outline" href={~p"/users/auth/github"}>
        <.icon name="github" class="w-6 h-6" /> Continue with Github
      </.button>
    </section>
    """
  end

  defp hero_section(assigns) do
    ~H"""
    <.hero>
      <:title>{gettext "Let's get together."}</:title>
      <:subtitle>{gettext "Please sign in or sign up to your Juntos account"}</:subtitle>
    </.hero>
    """
  end

  defp login_form(assigns) do
    ~H"""
    <div class="flex  w-[343px] max-w-6xl  justify-center md:w-[448px] " data-role="login-dialog">
      <.simple_form
        for={@form}
        class="flex flex-col gap-6"
        phx-submit="save"
        action={~p"/users/log_in"}
        phx-trigger-action={@trigger_submit}
      >
        <input name="_csrf_token" type="hidden" value={Phoenix.Controller.get_csrf_token()} />

        {render_slot(@inner_block)}
      </.simple_form>
    </div>
    """
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    assign(socket, form: form)
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, %{assigns: %{otp_session: nil}} = socket) do
    changeset = Accounts.change_user(%Accounts.User{}, user_params)

    {:ok, user} = Accounts.get_or_create_user(user_params["email"])

    otp_session = Accounts.create_otp_session(user)
    Accounts.deliver_user_otp_code(otp_session, &url(~p"/users/confirm/#{&1}"))

    {:noreply,
     socket
     |> assign(otp_session: otp_session)
     |> assign_form(changeset)}
  end

  def handle_event(
        "save",
        %{"user" => user_params},
        %{assigns: %{otp_session: otp_session}} = socket
      ) do
    changeset =
      Accounts.change_user(%Accounts.User{}, user_params)

    socket =
      if otp_session.otp_code == user_params["otp_code"] do
        Accounts.confirm_user!(otp_session.user)
        assign(socket, trigger_submit: true)
      else
        assign(socket, invalid_otp_session: true)
      end

    {:noreply,
     socket
     |> assign_form(changeset)}
  end
end
