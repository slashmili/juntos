defmodule Junto.Accounts.ExternalUserTest do
  use ExUnit.Case, async: true

  alias Junto.Accounts.ExternalUser, as: SUT

  describe "new/1" do
    test "maps github response" do
      user = %{
        "email" => "user@localhost.com",
        "email_verified" => true,
        "name" => "User",
        "picture" => "https://avatars.githubusercontent.com/u/1?v=4",
        "preferred_username" => "username",
        "profile" => "https://github.com/username",
        "sub" => 1
      }

      assert SUT.new(user) == %SUT{
               name: "User",
               sub: "1",
               email: "user@localhost.com",
               email_verified: true,
               picture: "https://avatars.githubusercontent.com/u/1?v=4"
             }
    end

    test "maps google response" do
      user = %{
        "email" => "user@gmail.com",
        "email_verified" => true,
        "family_name" => "Family",
        "given_name" => "Giben",
        "name" => "Giben family_name",
        "picture" => "https://lh3.googleusercontent.com/a/AliZWw=s96-c",
        "sub" => "113"
      }

      assert SUT.new(user) == %SUT{
               name: "Giben",
               sub: "113",
               email: "user@gmail.com",
               email_verified: true,
               picture: "https://lh3.googleusercontent.com/a/AliZWw=s96-c"
             }
    end
  end
end
