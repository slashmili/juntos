defmodule Juntos.Accounts.ExternalAuthProvider do
  @moduledoc """
    Implement External Auth Providers
  """

  defmodule User do
    @derive Jason.Encoder
    defstruct [:email, :sub, :name, :email_verified, :picture, :provider]

    def new(attrs, provider \\ nil) do
      %__MODULE__{
        email: attrs["email"],
        sub: to_string(attrs["sub"]),
        name: attrs["given_name"] || attrs["name"],
        email_verified: attrs["email_verified"],
        picture: attrs["picture"],
        provider: provider || attrs["provider"]
      }
    end
  end

  @doc """
  Requests authorize_url & state
  """
  def authorize_url(provider, redirect_uri_fn) do
    config = config!(provider, redirect_uri_fn)
    config[:strategy_mod].authorize_url(config)
  end

  @doc """
  Returns user info
  """
  def user_info(provider, params, state, redirect_uri_fn) do
    config =
      config!(provider, redirect_uri_fn)
      |> Keyword.put(:session_params, %{state: state})

    case config[:strategy_mod].callback(config, params) do
      {:ok, %{user: user_attrs}} -> {:ok, User.new(user_attrs, provider)}
      {:error, %Assent.InvalidResponseError{}} -> {:error, :invalid_response}
      {:error, %Assent.UnexpectedResponseError{}} -> {:error, :unexpected_response}
    end
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
    :juntos
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
      {strategy, Keyword.put(config, :strategy_mod, strategy_mod)}
    end)
  end

  defp config!(provider, redirect_uri_fn) do
    config = get_config()
    config = config[provider] || raise "No provider configuration for #{provider}"
    Keyword.put(config, :redirect_uri, redirect_uri_fn.(provider))
  end
end
