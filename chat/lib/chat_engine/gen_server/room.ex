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

  def get_messages(room_name) do
    GenServer.call(via_tuple(room_name), :get_messages)
  end


  # ----------------- Callbacks ----------------- #

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

  @impl GenServer
  def handle_call(:get_messages, _from, state) do
    {:reply, state.messages, state}
  end

  defp add_message(messages, new_message) do
    case length(messages) do
      length when length == 10 ->
        [_oldest | rest] = messages
        rest ++ [new_message]
      _other  ->
        messages ++ [new_message]
    end
  end

  defp send_notifications(users, room_name, message) do
    users
    |> Enum.filter(fn username -> username != elem(message, 0) end)
    |> Enum.each(fn username ->
      ChatEngine.GenServer.User.receive_message(username, room_name, message)
    end)
  end

  defp via_tuple(room_name) do
    {:via, Registry, {ChatEngine.Registry, {:room, room_name}}}
  end
end
