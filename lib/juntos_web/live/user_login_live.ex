defmodule JuntosWeb.UserLoginLive do
  use JuntosWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.login_wrapper>
      <.hero_section />
      <.external_auth_section />
      <.line />
      <.login_form />
    </.login_wrapper>
    """
  end

  defp login_form(assigns) do
    ~H"""
    <.input_text
      type="email"
      id="email"
      placeholder={gettext "Your email address"}
      label={gettext "Email"}
      required
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
      <.button variant="outline">
        <.icon name="google" class="w-6 h-6" /> Continue with Google
      </.button>
      <.button variant="outline">
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

  defp login_wrapper(assigns) do
    ~H"""
    <div class="flex justify-center">
      <form
        data-role="login-dialog"
        class="max-w-6xl flex justify-center flex-col w-[343px] md:w-[448px] gap-6"
      >
        {render_slot(@inner_block)}
      </form>
    </div>
    """
  end
end
