defmodule JuntosWeb.UserExternalAuthHTML do
  use JuntosWeb, :html

  def new(assigns) do
    ~H"""
    <div class="flex justify-center pt-10 pb-20 gap-6">
      <div
        data-role="login-dialog"
        class="max-w-6xl flex justify-center flex-col w-[343px] md:w-[448px] gap-8"
      >
        <.link navigate={~p"/users/log_in"}><.icon name="hero-arrow-left" class="w-6 h-6" /></.link>
        <.hero>
          <:title>{gettext "Hello %{name}!", name: @external_auth_user.name}</:title>
          <:body>
            {gettext "You are about to sign up with email %{email}, do you want to continue?",
              email: @external_auth_user.email}
          </:body>
        </.hero>
        <.simple_form :let={_f} for={@form} action={~p"/users/auth/register"}>
          <:actions>
            <.button type="submit" class="w-full">
              {gettext "Yes, continue"}
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end
end
