defmodule ChatWeb.UserSocket do
  use Phoenix.Socket

  alias Chat.Repo
  alias Chat.User

  channel "room:*", ChatWeb.RoomChannel
  channel "status:*", ChatWeb.StatusChannel

  @impl true
  def connect(%{"token" => token}, socket, _info) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
      {:ok, username} ->
        case Repo.get(User, username) do
          nil ->
            :error

          user ->
            {:ok, assign(socket, :current_user, user)}
        end

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user.username}"
end
