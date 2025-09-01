defmodule Juntos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JuntosWeb.Telemetry,
      Juntos.Repo,
      {DNSCluster, query: Application.get_env(:juntos, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Juntos.PubSub},
      # Start a worker by calling: Juntos.Worker.start_link(arg)
      # {Juntos.Worker, arg},
      # Start to serve requests, typically the last entry
      JuntosWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Juntos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JuntosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
