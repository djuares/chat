defmodule Chat.GroupTest do
  use Chat.DataCase, async: true  # usa tu DataCase que configura sandbox
  alias Chat.{Group, GroupMember}

  import Ecto.Query

  describe "create!/2" do
      test "crea un grupo y agrega al creador como admin" do
        # Primero creamos el usuario en la DB
        user = %Chat.User{
          username: "alice",
          email: "alice@example.com",
          password: "password123"
        } |> Repo.insert!()

        group_name = "Test Group"

        # Ahora sí podemos crear el grupo
        group = Group.create!(group_name, user.username)

        assert group.id != nil
        assert group.name == group_name

        # Verificar que el grupo existe en la DB
        assert Repo.get(Group, group.id)

        # Verificar que el usuario fue agregado como admin
        member = Repo.get_by(Chat.GroupMember, group_id: group.id, username: user.username)
        assert member.role == "admin"
      end


    test "fallo al crear grupo sin nombre" do
      username = "alice"

      assert_raise Ecto.InvalidChangesetError, fn ->
        Group.create!(nil, username)
      end
    end
  end

  describe "delete/1" do
    test "elimina un grupo existente" do
      group = %Group{id: Nanoid.generate(), name: "To Delete"}
              |> Group.changeset(%{})
              |> Repo.insert!()

      {:ok, _deleted} = Group.delete(group.id)

      refute Repo.get(Group, group.id)
    end

    test "lanza error si el grupo no existe" do
      assert_raise Ecto.NoResultsError, fn ->
        Group.delete("nonexistent_id")
      end
    end
  end
end
