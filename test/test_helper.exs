ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Junto.Repo, :manual)
Mox.defmock(Junto.Accounts.AuthProvider.Mock, for: Junto.Accounts.ExternalAuthProviderBehaviour)
