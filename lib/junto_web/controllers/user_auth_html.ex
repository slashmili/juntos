defmodule JuntoWeb.UserAuthHTML do
  use JuntoWeb, :html

  def new(assigns) do
    ~H"""
    <p>{gettext "Hello %{name}!", name: @external_user.name}</p>
    <p>
      {gettext "You are about to sign up with email %{email}, do you want to continue?",
        email: @external_user.email}
    </p>
    <.base_simple_form :let={_f} for={@form} action={~p"/users/auth/register"}>
      <.base_error :if={@form.action}>
        Oops, something went wrong! Please check the errors below.
      </.base_error>
      <:actions>
        <.base_button>{gettext "Yes!"}</.base_button>
      </:actions>
    </.base_simple_form>
    """
  end
end
