defmodule ChatWeb.UserSocketTest do
  use ChatWeb.ChannelCase, async: true

  alias ChatWeb.UserSocket
  alias Chat.User
  alias Chat.Repo

  @salt "user socket"

  setup do
    # Creamos un usuario de prueba
    user = %User{
      username: "juan",
      password: "1234",
      name: "Juan",
      email: "juan@example.com"
    } |> Repo.insert!()

    # Token válido usando el endpoint correcto
    valid_token = Phoenix.Token.sign(ChatWeb.Endpoint, @salt, user.username)

    {:ok, user: user, valid_token: valid_token}
  end

 test "connect con token válido asigna current_user", %{valid_token: token, user: user} do
  {:ok, socket} =
    UserSocket.connect(%{"token" => token}, %Phoenix.Socket{endpoint: ChatWeb.Endpoint}, %{})

  # Cambiamos de id a username
  assert socket.assigns.current_user.username == user.username
end


  test "connect con token inválido retorna :error" do
    assert :error =
      UserSocket.connect(%{"token" => "badtoken"}, %Phoenix.Socket{endpoint: ChatWeb.Endpoint}, %{})
  end

  test "id/1 retorna el id basado en username", %{valid_token: token, user: user} do
    {:ok, socket} =
      UserSocket.connect(%{"token" => token}, %Phoenix.Socket{endpoint: ChatWeb.Endpoint}, %{})

    assert UserSocket.id(socket) == "user_socket:#{user.username}"
  end

end
