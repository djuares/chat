defmodule Chat.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      compilers: Mix.compilers(),
      deps: deps(),
      test_coverage: [
        tool: ExCoveralls,
        exclude_files: [
          "chat/lib/chat_web/**",
        ],
        ignore_modules: [
          Chat,
          Chat.Repo
        ]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Rutas de compilación
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Aplicación
  def application do
    [
      mod: {Chat.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

# mix.exs
defp deps do
  [
    {:phoenix, "~> 1.8.3"},
    {:phoenix_ecto, "~> 4.7"},
    {:ecto_sql, "~> 3.10"},
    {:postgrex, ">= 0.0.0"},
    {:phoenix_html, "~> 3.3"},
    {:phoenix_live_reload, "~> 1.6"},
    {:phoenix_live_view, "~> 1.1"},
    {:phoenix_live_dashboard, "~> 0.8"},
    {:gettext, "~> 0.22"},
    {:swoosh, "~> 1.12"},
    {:jason, "~> 1.4"},
    {:bandit, "~> 1.6"},
    {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
    {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
    {:nanoid, "~> 2.1"},
    {:excoveralls, "~> 0.18.5", only: [:test, :dev]}
    ]
end

defp aliases do
  [
    setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"]
  ]
end

end
