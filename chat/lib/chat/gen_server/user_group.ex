defmodule Chat.UserGroup do
  use GenServer

  defp via_tuple(group_id) do
    {:via, Registry, {Registry.ChatGroups, group_id}}
  end

  def start_link(%Chat.Group{} = group) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [group], name: via_tuple(group.id))
    GenServer.cast(pid, {:start})

    {:ok, pid}
  end

  @impl true
  def handle_call({:add, %Chat.GroupMember{} = member}, _from, %{"members" => members} = state) do
    Phoenix.PubSub.broadcast!(Chat.PubSub, member.username, %{
      "event" => "group:join",
      "membership" => member
    })

    broadcast(members, %{
      "event" => "group:member_join",
      "membership" => member
    })

    {:reply, :ok, %{state | "members" => [%Chat.Models.User{user: member} | members]}}
  end

  @impl true
  def handle_call({:remove, %Chat.GroupMember{} = member}, _from, %{"members" => members} = state) do
    broadcast(members, %{
      "event" => "group:member_leave",
      "membership" => member
    })

    {:reply, :ok,
     %{state | "members" => Enum.reject(members, &(&1.user.username === member.username))}}
  end

  @impl true
  def handle_call(
        {:connect, socket, %Chat.GroupMember{} = member},
        _from,
        %{"members" => members, "info" => group} = state
      ) do
    idx = Enum.find_index(members, &(&1.user.username == member.username))

    members =
      if idx != nil,
        do: List.update_at(members, idx, &%Chat.Models.User{&1 | connection: socket}),
        else: members

    # Deliver pending message to the user
    user = Chat.Repo.get(Chat.User, member.username)

    Chat.GroupMessages.get_messages_since(group.id, user.last_online)
    |> Enum.each(fn entry ->
      send(socket, %{
        "event" => "group:message_reply",
        "message" => entry.message,
        "sender" => entry.sender_id,
        "name" => user.name,
        "group" => group.id,
        "timestamp" => entry.inserted_at
      })
    end)

    {:reply, :ok, %{state | "members" => members}}
  end

  @impl true
  def handle_call(
        {:disconnect, %Chat.GroupMember{} = member},
        _from,
        %{"members" => members} = state
      ) do
    idx = Enum.find_index(members, &(&1.user.username == member.username))

    members =
      if idx != nil,
        do: List.update_at(members, idx, &%Chat.Models.User{&1 | connection: nil}),
        else: members

    {:reply, :ok, %{state | "members" => members}}
  end

  @impl true
  def handle_call(
        {:message, message, sender},
        _from,
        %{"info" => group} = state
      ) do

    message_info = %{
      content: message,
      sender: sender,
      group_id: group.id
    }

    send_message(message_info)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:start}, %{"members" => members} = state) do
    Enum.each(
      members,
      &Phoenix.PubSub.broadcast!(Chat.PubSub, &1.user.username, %{
        "event" => "group:join",
        "membership" => &1.user
      })
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete}, %{"members" => members, "info" => group} = state) do
    ## delete all messages
    Chat.Group.delete(group.id)
    broadcast(members, %{"event" => "group:delete", "group" => group})
    {:stop, :normal, state}
  end

  @impl true
  def init([group]) do
    members =
      Chat.GroupMember.get_all_members(group.id)
      |> Enum.map(fn x -> %Chat.Models.User{user: x} end)

    {:ok, %{"info" => group, "members" => members}}
  end

  defp broadcast(members, info) do
    online_users =
      Enum.filter(members, fn member -> member.connection != nil end)
      |> Enum.map(& &1.connection)

    Enum.each(online_users, fn pid -> send(pid, info) end)
  end

  defp send_message(message_info) do
    Chat.GroupMessages.changeset(%Chat.GroupMessages{}, %{
      "sender" => message_info.sender,
      "group_id" => message_info.group_id,
      "content" => message_info.content
    })
    |> Chat.Repo.insert!()
    # broadcast(members, info)
  end

  ## Starts the server if the app was restarted
  defp start_server(group_id) do
    case Registry.lookup(Registry.ChatGroups, group_id) do
      [] ->
        group = Chat.Repo.get!(Chat.Group, group_id)
        DynamicSupervisor.start_child(Chat.GroupSupervisor, {Chat.UserGroup, group})
      [{_pid, _}] ->
        :ok
    end
  end

  defp call(via_tuple, args) do
    {_registry_name, group_id} = elem(via_tuple, 2)
    start_server(group_id)

    GenServer.call(via_tuple, args)
  end

  defp cast(via_tuple, args) do
    {_registry_name, group_id} = elem(via_tuple, 2)
    start_server(group_id)

    GenServer.cast(via_tuple, args)
  end

  @spec message(String.t(), String.t(), String.t()) :: term()
  def message(group_id, message, sender) do
    call(via_tuple(group_id), {:message, message, sender})
  end

  @doc """
  Add a member to the server
  """
  @spec add(%Chat.GroupMember{}) :: term()
  def add(member) do
    call(via_tuple(member.group_id), {:add, member})
  end

  @doc """
  Remove a member to the server
  """
  @spec remove(%Chat.GroupMember{}) :: term()
  def remove(member) do
    call(via_tuple(member.group_id), {:remove, member})
  end

  @doc """
  Connect the member to the server once he is online
  """
  @spec connect(pid(), %Chat.GroupMember{}) :: term()
  def connect(socket, member) do
    call(via_tuple(member.group_id), {:connect, socket, member})
  end

  @doc """
  Disconnect the member to the server once he is online
  """
  @spec disconnect(%Chat.GroupMember{}) :: term()
  def disconnect(member) do
    call(via_tuple(member.group_id), {:disconnect, member})
  end

  @doc """
  Deletes the group and notifies all the members
  """
  @spec delete(%Chat.Group{}) :: term()
  def delete(group) do
    cast(via_tuple(group.id), {:delete})
  end
end
