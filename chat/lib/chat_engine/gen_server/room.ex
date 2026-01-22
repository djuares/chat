defmodule ChatEngine.GenServer.Room do
  use GenServer

  def start_link(room_name) do
    GenServer.start_link(__MODULE__, room_name, name: via_tuple(room_name))
  end

  def add_user(room_name, username) do
    GenServer.call(via_tuple(room_name), {:add_user, username})
  end

  def new_message(room_name, username, message) do
    GenServer.cast(via_tuple(room_name), {:new_message, username, message})
  end





  @impl GenServer
  def init(room_name) do
    {:ok, %{room_name: room_name, users: [], messages: []}}
  end

  @impl GenServer
  def handle_cast({:new_message, username, message} , state) do
    new_message = add_message(state.messages, {username, message})
    send_notifications(state.users, state.room_name, {username, message})
    {:noreply, %{state | messages: new_message}}
  end

  @impl GenServer
  def handle_call({:add_user, username}, _from, state) do
    new_users = [username | state.users]
    ChatEngine.GenServer.User.add_room(username, state.room_name)
    {:reply, :ok, %{state | users: new_users}}
  end

  defp add_message(messages, new_message) do
    case length(messages) do
      10 ->
        [_oldest | rest] = messages
        rest ++ [new_message]
      _  ->
        messages ++ [new_message]
    end
  end

  defp send_notifications(users, room_name, message) do
    Enum.each(users, fn username ->
      ChatEngine.GenServer.User.receive_message(username, room_name, message)
    end)
  end

  defp via_tuple(room_name) do
    {:via, Registry, {ChatEngine.Registry, {:room, room_name}}}
  end
end
