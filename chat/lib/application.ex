defmodule Chat.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ChatEngine.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: ChatEngine.Supervisor.Room},
      {DynamicSupervisor, strategy: :one_for_one, name: ChatEngine.Supervisor.User}
    ]

    opts = [strategy: :one_for_one, name: Chat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
