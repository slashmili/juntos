defmodule Junto.Accounts.ExternalAuthProviderBehaviour do
  @callback callback(atom(), map(), map(), function) :: {:ok, map()} | {:error, term()}
end

defmodule Junto.Accounts.AuthProvider do
  @moduledoc """
    Implement External Auth Providers
  """
  @behaviour Junto.Accounts.ExternalAuthProviderBehaviour

  alias Assent.Config

  @spec request(atom(), function) :: {:ok, map()} | {:error, term()}
  def request(provider, redirect_uri_fn) do
    config = config!(provider, redirect_uri_fn)

    config[:strategy].authorize_url(config)
  end

  @impl true
  def callback(provider, params, session_params, redirect_uri_fn, config \\ []) do
    config = Keyword.merge(config!(provider, redirect_uri_fn), config)

    result =
      config
      |> Assent.Config.put(:session_params, session_params)
      |> config[:strategy].callback(params)

    case result do
      {:ok, %{user: user} = params} ->
        user = Map.put(user, "provider", provider)
        {:ok, %{params | user: Junto.Accounts.ExternalAuthUser.new(user)}}

      rest ->
        rest
    end
  end

  defp config!(provider, redirect_uri_fn) do
    config = get_config()
    config = config[provider] || raise "No provider configuration for #{provider}"
    Config.put(config, :redirect_uri, redirect_uri_fn.(provider))
  end

  @raw_schema [
    google: [
      type: :non_empty_keyword_list,
      keys: [
        client_id: [
          type: :string,
          required: true
        ],
        client_secret: [
          type: :string,
          required: true
        ]
      ]
    ],
    github: [
      type: :non_empty_keyword_list,
      keys: [
        client_id: [
          type: :string,
          required: true
        ],
        client_secret: [
          type: :string,
          required: true
        ]
      ]
    ]
  ]

  @schema NimbleOptions.new!(@raw_schema)

  def provider_types do
    Keyword.keys(@raw_schema)
  end

  def get_config do
    :junto
    |> Application.get_env(__MODULE__)
    |> NimbleOptions.validate(@schema)
    |> to_ok!()
    |> prepare_for_assent
  end

  def to_ok!({:ok, config}) do
    config
  end

  defp prepare_for_assent(config) do
    strategies = %{github: Assent.Strategy.Github, google: Assent.Strategy.Google}

    Enum.map(config, fn {strategy, config} ->
      strategy_mod = Map.fetch!(strategies, strategy)
      {strategy, Keyword.put(config, :strategy, strategy_mod)}
    end)
  end
end
