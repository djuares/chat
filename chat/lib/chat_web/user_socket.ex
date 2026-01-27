defmodule ChatWeb.UserSocket do
  use Phoenix.Socket

  channel "room:*", ChatWeb.RoomChannel

  @impl true
  def connect(%{"token" => token}, socket, _info) do
    # fake auth para empezar
    user = %{id: 1, username: "damaris", name: "Damaris"}

    {:ok, assign(socket, :current_user, user)}
  end

  def id(_socket), do: nil
end
