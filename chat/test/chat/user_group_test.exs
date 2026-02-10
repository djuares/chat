defmodule Chat.UserGroupTest do
  use ExUnit.Case, async: true

  alias Chat.{UserGroup, Group, GroupMember, Models.User}

  setup do
    # Crear un grupo ficticio para las pruebas
    group = %Group{id: "group_1", name: "Test Group"}
    members = [
      %GroupMember{user_id: "user_1", group_id: "group_1"},
      %GroupMember{user_id: "user_2", group_id: "group_1"}
    ]

    {:ok, pid} = UserGroup.start_link(group)

    {:ok, %{group: group, members: members, pid: pid}}
  end

  test "añadir un miembro al grupo", %{group: group, members: members} do
    new_member = %GroupMember{user_id: "user_3", group_id: group.id}

    assert :ok == UserGroup.add(new_member)
  end

  test "eliminar un miembro del grupo", %{group: group, members: members} do
    member_to_remove = hd(members)

    assert :ok == UserGroup.remove(member_to_remove)
  end

  test "conectar un miembro", %{members: members} do
    member = hd(members)
    fake_socket = self()

    assert :ok == UserGroup.connect(fake_socket, member)
  end

  test "desconectar un miembro", %{members: members} do
    member = hd(members)

    assert :ok == UserGroup.disconnect(member)
  end

  test "enviar un mensaje al grupo", %{group: group, members: members} do
    sender = %User{user_id: "user_1", username: "test_user", name: "Test User"}
    message = "Hello, group!"

    assert :ok == UserGroup.message(group.id, message, sender)
  end

  test "eliminar el grupo", %{group: group} do
    assert :ok == UserGroup.delete(group)
  end
end
