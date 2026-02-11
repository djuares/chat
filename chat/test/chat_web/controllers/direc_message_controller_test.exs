defmodule ChatWeb.DirectMessageControllerTest do
  use ChatWeb.ConnCase

  import Ecto.Query
  alias Chat.{Repo, User, Group, GroupMember, GroupMessages}

  test "create/2 envía un mensaje directo", %{conn: conn} do
    sender = Repo.insert!(%User{username: "damaris", name: "Damaris", password: "1234"})
    recipient = Repo.insert!(%User{username: "mateo", name: "Mateo", password: "1234"})

    group =
      %Group{}
      |> Group.changeset(%{id: "grupo-1", name: "damaris-mateo", description: "direct"})
      |> Repo.insert!()

    GroupMember.add_membership(group.id, sender.username, "admin")
    GroupMember.add_membership(group.id, recipient.username, "member")

    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, sender.username)
      |> post(~p"/home/directs/#{group.id}/messages", %{
        "message" => %{"content" => "Hola Mateo!"}
      })

    assert redirected_to(conn) == ~p"/home/directs/#{group.id}"

    message =
      Repo.one!(
        from m in GroupMessages,
          where: m.group_id == ^group.id and m.sender == ^sender.username
      )

    assert message.content == "Hola Mateo!"
  end

end
