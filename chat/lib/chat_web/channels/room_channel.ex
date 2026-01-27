defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  @impl true
  def join("room:" <> group_id, _params, socket) do
    user = socket.assigns.current_user

    case Chat.GroupMember.get_membership(group_id, user.username) do
      nil ->
        {:error, %{reason: "not a member of this group"}}

      member ->
        Chat.UserGroup.connect(socket.transport_pid, member)
        {:ok, assign(socket, :room_id, group_id)}
    end
  end

  @impl true
  def handle_in("new_msg", %{"body" => body}, socket) do
    Chat.UserGroup.message(
      socket.assigns.room_id,
      body,
      socket.assigns.current_user
    )

    {:noreply, socket}
  end
end
