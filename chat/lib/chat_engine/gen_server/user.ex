defmodule ChatEngine.GenServer.User do
  use GenServer

  def start_link(username) do
    GenServer.start_link(__MODULE__, username, name: via_tuple(username))
  end

  def add_room(username, room_name) do
    GenServer.cast(via_tuple(username), {:add_room, room_name})
  end

  def send_message(username, room_name, message) do
    GenServer.cast(via_tuple(username), {:send_message, room_name, message})
  end

  def receive_message(username, room_name, {from_user, message}) do
    GenServer.cast(via_tuple(username), {:receive_message, room_name, from_user, message})
  end

  def get_rooms(username) do
    GenServer.call(via_tuple(username), :get_rooms)
  end



  @impl GenServer
  def init(username) do
    {:ok, %{username: username, rooms: []}}
  end

  @impl GenServer
  def handle_cast({:add_room, room_name}, state) do
    new_rooms = [room_name | state.rooms]
    {:noreply, %{state | rooms: new_rooms}}
  end

  @impl GenServer
  def handle_cast({:send_message, room_name, message}, state) do
    ChatEngine.GenServer.Room.new_message(room_name, state.username, message)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:receive_message, room_name, from_user, message}, state) do
    IO.puts("[#{room_name}] #{from_user} to #{state.username}: #{message}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get_rooms, _from, state) do
    {:reply, state.rooms, state}
  end

  defp via_tuple(username) do
    {:via, Registry, {ChatEngine.Registry, {:user, username}}}
  end
end
