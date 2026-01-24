defmodule ChatEngine.GenServer.UserTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias ChatEngine.GenServer.User
  alias ChatEngine.GenServer.Room

  setup do
    Registry.start_link(keys: :unique, name: ChatEngine.Registry)
    :ok
  end

  test "user can join room" do
    {:ok, _user} = User.start_link("alice")
    {:ok, _room} = Room.start_link("lobby")

    assert :ok == Room.add_user("lobby", "alice")
    assert ["lobby"] == User.get_rooms("alice")
  end

  test "user can send messages" do
    {:ok, _user} = User.start_link("bob")
    {:ok, _room} = Room.start_link("general")

    :ok = Room.add_user("general", "bob")

    assert :ok == User.send_message("bob", "general", "Hello, world!")
    Process.sleep(20)
    assert [{"bob", "Hello, world!"}] == Room.get_messages("general")
  end

  test "user can receive messages" do
    output =
      capture_io(fn ->
        {:ok, _user1} = User.start_link("charlie")
        {:ok, _user2} = User.start_link("dave")
        {:ok, _room} = Room.start_link("random")

        :ok = Room.add_user("random", "charlie")
        :ok = Room.add_user("random", "dave")

        :ok = User.receive_message("dave", "random", {"charlie", "Hey Dave!"})
        Process.sleep(20)
      end)

    assert output == "[random] charlie to dave: Hey Dave!\n"
  end
end
