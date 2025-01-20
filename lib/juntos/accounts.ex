defmodule Juntos.Accounts do
  alias Juntos.Accounts.User

  alias Juntos.Repo

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
end
