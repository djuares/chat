defmodule Chat.GroupMemberTest do
  use ExUnit.Case
  alias Chat.GroupMember
  alias Chat.Repo

  import Ecto.Query

  @test_group_name "test_group"
  setup do
    # Esto asegura que cada test use un sandbox y no afecte la DB real
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    Repo.delete_all(Chat.GroupMember)
    Repo.delete_all(Chat.User)
    Repo.delete_all(Chat.Group)
    create_user()
    create_group(@test_group_name)
    :ok
  end

  defp create_user(username \\ "user1") do
    %Chat.User{username: username, last_online: DateTime.utc_now()}
    |> Repo.insert!()
  end

  defp create_group(group_name) do
    %Chat.Group{id: Nanoid.generate(), name: group_name}
    |> Repo.insert!()
  end

  defp get_group_id(group_name) do
    Repo.one(from g in Chat.Group, where: g.name == ^group_name, select: g.id)
  end

  describe "changeset/2" do
    test "changeset valido con datos correctos" do
    attrs = %{group_id: "group1", username: "user1", role: "admin"}
    changeset = GroupMember.changeset(%GroupMember{}, attrs)

    assert changeset.valid?
    assert changeset.changes.group_id == "group1"
    assert changeset.changes.username == "user1"
    assert changeset.changes.role == "admin"
  end

  test "changeset valido sin el campo role" do
    attrs = %{group_id: "group1", username: "user1"}
    changeset = GroupMember.changeset(%GroupMember{}, attrs)

    assert changeset.valid?
  end

  test "changeset invalido sin el campo group_id" do
    attrs = %{username: "user1", role: "member"}
    changeset = GroupMember.changeset(%GroupMember{}, attrs)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).group_id
  end

  test "changeset invalido sin el campo username" do
    attrs = %{group_id: "group1", role: "member"}
    changeset = GroupMember.changeset(%GroupMember{}, attrs)

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).username
  end

  test "changeset invalido con attrs vacíos" do
    changeset = GroupMember.changeset(%GroupMember{}, %{})

    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).group_id
    assert "can't be blank" in errors_on(changeset).username
  end
  end

  describe "add_membership/3" do

    test "agrega un miembro exitosamente con todos los parámetros" do
      id = get_group_id(@test_group_name)
      assert {:ok, member} = GroupMember.add_membership(id, "user1", "admin")
      assert member.group_id == id
      assert member.username == "user1"
      assert member.role == "admin"
    end

    test "agrega un miembro con rol por defecto cuando no se especifica" do
      id = get_group_id(@test_group_name)
      assert {:ok, member} = GroupMember.add_membership(id, "user1")
      assert member.group_id == id
      assert member.username == "user1"
      assert member.role == "member"
    end

    test "falla al agregar un miembro sin group_id" do
      assert {:error, changeset} = GroupMember.add_membership(nil, "user1", "admin")
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).group_id
    end

    test "falla al agregar un miembro sin username" do
      id = get_group_id(@test_group_name)
      assert {:error, changeset} = GroupMember.add_membership(id, nil, "admin")
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).username
    end

    test "falla al agregar un miembro duplicado" do
      id = get_group_id(@test_group_name)
      # Primer insert exitoso
      assert {:ok, _member} = GroupMember.add_membership(id, "user1", "member")

      # Segundo insert con los mismos datos debe fallar
      assert {:error, changeset} = GroupMember.add_membership(id, "user1", "admin")
      assert "has already been taken" in errors_on(changeset) ||
             changeset.errors != []
    end

    test "permite agregar el mismo usuario a diferentes grupos" do
      create_group("other_group")

      id1 = get_group_id(@test_group_name)
      id2 = get_group_id("other_group")

      assert {:ok, member1} = GroupMember.add_membership(id1, "user1", "member")
      assert {:ok, member2} = GroupMember.add_membership(id2, "user1", "admin")

      assert member1.group_id == id1
      assert member2.group_id == id2
      assert member1.username == member2.username
    end

    test "permite agregar diferentes usuarios al mismo grupo" do
      id = get_group_id(@test_group_name)
      create_user("user2")

      assert {:ok, member1} = GroupMember.add_membership(id, "user1", "admin")
      assert {:ok, member2} = GroupMember.add_membership(id, "user2")
      assert member1.group_id == member2.group_id
      assert member1.group_id == member2.group_id
    end
  end

  describe "get_membership/2" do

    test "obtiene una membresía existente" do
      id = get_group_id(@test_group_name)
      {:ok, _member} = GroupMember.add_membership(id, "user1", "admin")

      result = GroupMember.get_membership(id, "user1")

      assert result != nil
      assert result.group_id == id
      assert result.username == "user1"
      assert result.role == "admin"
    end

    test "retorna nil cuando la membresía no existe" do
      id = get_group_id(@test_group_name)

      result = GroupMember.get_membership(id, "user1")

      assert result == nil
    end

    test "retorna nil con group_id inexistente" do
      result = GroupMember.get_membership("nonexistent_group", "user1")

      assert result == nil
    end

    test "retorna nil con username inexistente" do
      id = get_group_id(@test_group_name)

      result = GroupMember.get_membership(id, "nonexistent_user")

      assert result == nil
    end
  end

  describe "remove_membership/2" do
    test "elimina una membresía existente exitosamente" do
      id = get_group_id(@test_group_name)
      GroupMember.add_membership(id, "user1", "admin")

      {count, _} = GroupMember.remove_membership(id, "user1")

      assert count == 1
      assert GroupMember.get_membership(id, "user1") == nil
    end

    test "retorna 0 cuando la membresía no existe" do
      id = get_group_id(@test_group_name)

      {count, _} = GroupMember.remove_membership(id, "user1")

      assert count == 0
    end

    test "retorna 0 con group_id inexistente" do
      {count, _} = GroupMember.remove_membership("nonexistent_group", "user1")

      assert count == 0
    end

    test "retorna 0 con username inexistente" do
      id = get_group_id(@test_group_name)
      GroupMember.add_membership(id, "user1", "admin")

      {count, _} = GroupMember.remove_membership(id, "nonexistent_user")

      assert count == 0
      # Verifica que user1 sigue ahí
      assert GroupMember.get_membership(id, "user1") != nil
    end
  end

  describe "get_all_members/1" do

    test "retorna todos los miembros de un grupo" do
      id = get_group_id(@test_group_name)
      create_user("user2")
      create_user("user3")

      GroupMember.add_membership(id, "user1", "admin")
      GroupMember.add_membership(id, "user2", "member")
      GroupMember.add_membership(id, "user3", "member")

      members = GroupMember.get_all_members(id)

      assert length(members) == 3
      usernames = Enum.map(members, & &1.username) |> Enum.sort()
      assert usernames == ["user1", "user2", "user3"]
    end

    test "retorna lista vacía para grupo sin miembros" do
      id = get_group_id(@test_group_name)

      members = GroupMember.get_all_members(id)

      assert members == []
    end

    test "retorna lista vacía para grupo inexistente" do
      members = GroupMember.get_all_members("nonexistent_group")

      assert members == []
    end

    test "retorna mapas con los campos correctos" do
      id = get_group_id(@test_group_name)
      GroupMember.add_membership(id, "user1", "admin")

      [member] = GroupMember.get_all_members(id)

      assert Map.has_key?(member, :username)
      assert Map.has_key?(member, :role)
      assert Map.has_key?(member, :status)
      assert Map.has_key?(member, :last_online)

      assert member.username == "user1"
      assert member.role == "admin"
      assert member.status in [:online, :offline]
      assert %DateTime{} = member.last_online
    end
  end

  describe "get_direct_chat_name/2" do

    test "retorna el otro usuario en un chat directo" do
      id = get_group_id(@test_group_name)
      create_user("user2")

      GroupMember.add_membership(id, "user1", "member")
      GroupMember.add_membership(id, "user2", "member")

      chat_name_user1 = GroupMember.get_direct_chat_name("user1", id)
      chat_name_user2 = GroupMember.get_direct_chat_name("user2", id)

      assert chat_name_user1 == "user2"
      assert chat_name_user2 == "user1"
    end

    test "retorna nil cuando el grupo solo tiene un miembro" do
      id = get_group_id(@test_group_name)
      GroupMember.add_membership(id, "user1", "member")

      result = GroupMember.get_direct_chat_name("user1", id)

      assert result == nil
    end

    test "retorna nil para grupo sin miembros" do
      id = get_group_id(@test_group_name)

      result = GroupMember.get_direct_chat_name("user1", id)

      assert result == nil
    end

    test "retorna nil para grupo inexistente" do
      result = GroupMember.get_direct_chat_name("user1", "nonexistent_group")

      assert result == nil
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
