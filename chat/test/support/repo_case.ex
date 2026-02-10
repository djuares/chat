defmodule Chat.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Chat.Repo

      import Ecto
      import Ecto.Query
      import Ecto.Changeset
      import Chat.RepoCase
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Chat.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    :ok
  end

  def errors_on(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end)
end

end
