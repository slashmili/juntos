Mimic.copy(Assent.Strategy.Github)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Juntos.Repo, :manual)
Application.put_env(:phoenix_test, :base_url, JuntosWeb.Endpoint.url())
