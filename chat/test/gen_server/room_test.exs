defmodule ChatEngine.GenServer.RoomTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias ChatEngine.GenServer.User
  alias ChatEngine.GenServer.Room

  setup do
    Registry.start_link(keys: :unique, name: ChatEngine.Registry)
    :ok
  end

  test "user can join a room" do
    {:ok, _user} = User.start_link("alice")
    {:ok, _room} = Room.start_link("lobby")

    assert :ok == Room.add_user("lobby", "alice")
    assert ["lobby"] == User.get_rooms("alice")
  end

  test "user can send and receive messages in a room" do
    output =
      capture_io(fn ->
        {:ok, _user1} = User.start_link("bob")
        {:ok, _user2} = User.start_link("carol")
        {:ok, _room} = Room.start_link("general")

        :ok = Room.add_user("general", "bob")
        :ok = Room.add_user("general", "carol")

        assert :ok == User.send_message("bob", "general", "Hello, Carol!")
        Process.sleep(30)
      end)

    assert output == "[general] bob to carol: Hello, Carol!\n"
    assert [{"bob", "Hello, Carol!"}] == Room.get_messages("general")
  end
end
