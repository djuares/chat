defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  @impl true
  def join("room:" <> group_id, _params, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:error, %{reason: "unauthorized"}}

      user ->
        case Chat.GroupMember.get_membership(group_id, user.username) do
          nil ->
            {:error, %{reason: "not a member of this group"}}

          member ->
            Chat.UserGroup.connect(socket.transport_pid, member)
            {:ok, socket |> assign(:room_id, group_id) |> assign(:current_user, user)}
        end
    end
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) do
    user = socket.assigns.current_user
    room_id = socket.assigns.room_id

    # El UserGroup guarda el mensaje en BD (pasa username, no el struct)
    Chat.UserGroup.message(room_id, body, user.username)

    # Broadcast para tiempo real via WebSocket
    broadcast!(socket, "new_msg", %{
      sender: user.username,
      content: body,
      inserted_at: Calendar.strftime(DateTime.utc_now(), "%d/%m/%Y %H:%M")
    })

    {:reply, :ok, socket}
  end
end
