[
  import_deps: [:ecto, :ecto_sql, :phoenix, :mimic],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs",
    "storybook/**/*.exs"
  ],
  locals_without_parens: [
    gettext: 1,
    gettext: 2
  ]
]
