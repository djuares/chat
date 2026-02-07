defmodule ChatWeb.RoomChannelTest do
    use ChatWeb.ChannelCase, async: true

  test "join does not crash when user is not member" do
    socket =
      socket(ChatWeb.UserSocket, nil, %{
        current_user: %{username: "damaris"}
      })

    assert {:error, %{reason: "not a member of this group"}} =
             subscribe_and_join(socket, ChatWeb.RoomChannel, "room:group-1")
  end


end
