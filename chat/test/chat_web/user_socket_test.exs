defmodule ChatWeb.UserSocketTest do
  use ExUnit.Case
  alias ChatWeb.UserSocket

  test "connect always returns ok" do
    socket = %Phoenix.Socket{}
    assert {:ok, ^socket} = UserSocket.connect(%{}, socket, %{})
  end

test "id always returns nil" do
  socket = %Phoenix.Socket{}
  assert nil == UserSocket.id(socket)
end
end
