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
        ignore_modules: [
          ChatWeb,           # ignora el módulo principal
          ChatWeb.Endpoint,
          ChatWeb.Router,
          ChatWeb.UserSocket,
          ChatWeb.PageController,
          ChatWeb.PageView,
          ChatWeb.LayoutView,
          ChatWeb.ErrorHTML,
          ChatWeb.ErrorJSON,
          ChatWeb.Plugs.CurrentUser
          ]
      ],
      aliases: aliases(),
      listeners: [Phoenix.CodeReloader]
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
    setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
    "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
    "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
    "assets.build": ["compile", "tailwind chat", "esbuild chat"],
    "assets.deploy": [
        "tailwind chat --minify",
        "esbuild chat --minify",
        "phx.digest"
      ],
  ]
end

end
