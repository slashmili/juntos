defmodule JuntosWeb.UserExternalAuthHTML do
  use JuntosWeb, :html

  def new(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex justify-center gap-6 pb-20 pt-10">
        <div
          data-role="login-dialog"
          class="flex w-[343px] max-w-6xl flex-col justify-center gap-8 md:w-[448px]"
        >
          <.link navigate={~p"/users/log_in"}><.icon name="hero-arrow-left" class="h-6 w-6" /></.link>
          <.hero>
            {gettext "Hello %{name}!", name: @external_auth_user.name}
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
    </Layouts.app>
    """
  end
end
