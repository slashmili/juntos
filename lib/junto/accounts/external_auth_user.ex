defmodule Junto.Accounts.ExternalAuthUser do
  @derive Jason.Encoder
  defstruct [:email, :sub, :name, :email_verified, :picture, :provider]

  def new(attrs) do
    %__MODULE__{
      email: attrs["email"],
      sub: to_string(attrs["sub"]),
      name: attrs["given_name"] || attrs["name"],
      email_verified: attrs["email_verified"],
      picture: attrs["picture"],
      provider: attrs["provider"]
    }
  end
end
