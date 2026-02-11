Application.ensure_all_started(:syn)
:syn.add_node_to_scopes([:chat_group])

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Chat.Repo, :manual)
