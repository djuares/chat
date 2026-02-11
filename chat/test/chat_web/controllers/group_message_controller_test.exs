defmodule ChatWeb.GroupMessageControllerTest do
  use ChatWeb.ConnCase

  import Ecto.Query
  alias Chat.{Repo, Group, GroupMember, User, GroupMessages}

  test "create/2 envía un mensaje en grupo", %{conn: conn} do
    # Crear usuarios
    sender = Repo.insert!(%User{username: "damaris", name: "Damaris", password: "1234"})
    member = Repo.insert!(%User{username: "mateo", name: "Mateo", password: "1234"})

    # Crear grupo
    group =
      %Group{}
      |> Group.changeset(%{id: "grupo-1", name: "Grupo Test"})
      |> Repo.insert!()

    # Agregar miembros
    GroupMember.add_membership(group.id, sender.username, "admin")
    GroupMember.add_membership(group.id, member.username, "member")

    # Simular usuario logueado
    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, sender.username)
      |> post(~p"/home/groups/#{group.id}/messages", %{
        "message" => %{"content" => "Hola equipo!"}
      })

    # Verificar redirección
    assert redirected_to(conn) == ~p"/home/groups/#{group.id}"

    # Verificar que se guardó el mensaje
    message =
      Repo.one!(
        from m in GroupMessages,
          where: m.group_id == ^group.id and m.sender == ^sender.username
      )

    assert message.content == "Hola equipo!"
  end
end
