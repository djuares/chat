defmodule ChatWeb.UserSocket do
  use Phoenix.Socket

  # Alias necesarios para buscar al usuario
  alias Chat.Repo
  alias Chat.User

  channel "room:*", ChatWeb.RoomChannel
  channel "status:*", ChatWeb.StatusChannel

  @impl true
  def connect(%{"token" => token}, socket, _info) do
    # 1. Verificamos que el token sea válido y no haya expirado (2 semanas)
    # "user socket" es la "sal" (salt) criptográfica. Debe coincidir con la que usas para firmar.
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
      {:ok, username} ->
        # 2. Buscamos al usuario real en la base de datos
        case Repo.get(User, username) do
          nil ->
            :error # El token es válido, pero el usuario fue borrado de la BD

          user ->
            # 3. Asignamos el usuario real al socket
            {:ok, assign(socket, :current_user, user)}
        end

      {:error, _reason} ->
        :error # Token inválido o expirado
    end
  end

  # Esto permite que LiveView identifique el socket por usuario (útil para desconexiones forzadas)
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user.username}"
end
