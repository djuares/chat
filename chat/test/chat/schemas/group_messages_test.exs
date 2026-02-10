defmodule Chat.GroupMessagesTest do
  use Chat.RepoCase, async: true

  alias Chat.{Repo, GroupMessages, Group, User}

  defp insert_group(attrs \\ %{}) do
    defaults = %{
      id: Ecto.UUID.generate(),
      name: "grupo test"
    }

    Repo.insert!(struct(Group, Map.merge(defaults, attrs)))
  end

  defp insert_user(attrs \\ %{}) do
    defaults = %{
      username: "damaris"
    }

    Repo.insert!(struct(User, Map.merge(defaults, attrs)))
  end

  describe "changeset/2" do
    test "es válido con datos correctos" do
      group = insert_group()
      user  = insert_user()

      params = %{
        content: "hola mundo",
        group_id: group.id,
        sender: user.username
      }

      changeset = GroupMessages.changeset(%GroupMessages{}, params)

      assert changeset.valid?
    end

    test "es inválido si falta content" do
      group = insert_group()
      user  = insert_user()

      params = %{
        group_id: group.id,
        sender: user.username
      }

      changeset = GroupMessages.changeset(%GroupMessages{}, params)

      refute changeset.valid?
      assert %{content: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "list_messages/1" do
    test "devuelve los mensajes de un grupo ordenados por fecha" do
      group = insert_group()
      user  = insert_user()

      Repo.insert!(%GroupMessages{
        content: "primero",
        group_id: group.id,
        sender: user.username
      })

      Repo.insert!(%GroupMessages{
        content: "segundo",
        group_id: group.id,
        sender: user.username
      })

      messages = GroupMessages.list_messages(group.id)

      assert length(messages) == 2
      assert Enum.map(messages, & &1.content) == ["primero", "segundo"]
      assert Enum.all?(messages, & &1.sender_user)
    end
  end

  describe "search_messages/2" do
    test "filtra mensajes por contenido" do
      group = insert_group()
      user  = insert_user()

      Repo.insert!(%GroupMessages{
        content: "hola mundo",
        group_id: group.id,
        sender: user.username
      })

      Repo.insert!(%GroupMessages{
        content: "chau mundo",
        group_id: group.id,
        sender: user.username
      })

      results = GroupMessages.search_messages(group.id, "hola")

      assert length(results) == 1
      assert hd(results).content == "hola mundo"
    end

    test "no devuelve mensajes de otro grupo" do
      group1 = insert_group(%{name: "grupo 1"})
      group2 = insert_group(%{name: "grupo 2"})
      user   = insert_user()

      Repo.insert!(%GroupMessages{
        content: "mensaje secreto",
        group_id: group2.id,
        sender: user.username
      })

      results = GroupMessages.search_messages(group1.id, "mensaje")

      assert results == []
    end
  end
end
