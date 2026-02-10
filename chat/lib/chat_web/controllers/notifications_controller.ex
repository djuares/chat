defmodule ChatWeb.NotificationsController do
  import Ecto.Query

  use ChatWeb, :controller
  alias Chat.{GroupMember, GroupMessages, Group, User}

  def index(conn, _params) do
    username = conn.assigns.current_user.username
    last_online = get_session(conn, :last_online) || User.get_last_online(username)

    direct_notifications = get_direct_chats_notifications(username, last_online)
    group_notifications = get_group_chats_notifications(username, last_online)

    render(conn, :index, notifications: direct_notifications ++ group_notifications)
  end

  def show(conn, %{"id" => id}) do
    # Aquí podrías marcar las notificaciones como leídas o redirigir al chat correspondiente
    current_user = conn.assigns.current_user.username
    last_online = get_session(conn, :last_online) || User.get_last_online(current_user)

    group = Chat.Repo.get(Group, id)
    messages = GroupMessages.get_messages_since(id, last_online)

    case group.description do
      "direct" ->
        other_user = Chat.GroupMember.get_direct_chat_name(current_user, group.id)
        render(conn, :show, name: other_user, messages: messages)

      _ ->
        render(conn, :show, name: group.name, messages: messages)
    end
  end

  defp get_direct_chats_notifications(username, last_online) do
    from(gm in GroupMember,
      where: gm.username == ^username,
      join: g in Group,
      on: g.id == gm.group_id and g.description == "direct",
      join: m in GroupMessages,
      on: m.group_id == g.id and m.inserted_at > ^last_online,
      group_by: [g.id, g.name],
      select: %{id: g.id, name: g.name, unread_count: count(m.id)}
    )
    |> Chat.Repo.all()
    |> Enum.map(fn chat ->
        other_user = Chat.GroupMember.get_direct_chat_name(username, chat.id)

        %{
          id: chat.id,
          name: other_user,
          unread_count: chat.unread_count
        }
      end)
  end

  defp get_group_chats_notifications(username, last_online) do
    from(gm in GroupMember,
      where: gm.username == ^username,
      join: g in Group,
      on: g.id == gm.group_id and (is_nil(g.description) or g.description != "direct"),
      join: m in GroupMessages,
      on: m.group_id == g.id and m.inserted_at > ^last_online,
      group_by: [g.id, g.name],
      select: %{id: g.id, name: g.name, unread_count: count(m.id)}
    )
    |> Chat.Repo.all()
  end

end
