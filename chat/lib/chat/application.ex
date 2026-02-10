defmodule Chat.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Base de datos
      Chat.Repo,

      # PubSub
      {Phoenix.PubSub, name: Chat.PubSub},

      # Presencia
      ChatWeb.Presence,

      # Supervisor de grupos
      {DynamicSupervisor,
       strategy: :one_for_one,
       name: Chat.GroupSupervisor},

      # Endpoint
      ChatWeb.Endpoint,
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
