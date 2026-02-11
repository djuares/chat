defmodule ChatWeb.DirectControllerTest do
  use ChatWeb.ConnCase
  import Ecto.Query
  alias Chat.{Repo, Group, GroupMember, User}

  test "create/2 crea chat directo y agrega miembros", %{conn: conn} do
    # Crear usuarios
    Repo.insert!(%User{
      username: "damaris",
      name: "Damaris",
      password: "1234"
    })

    Repo.insert!(%User{
      username: "mateo",
      name: "Mateo",
      password: "1234"
    })

    # Simular usuario logueado (como hace AuthController)
    conn =
      conn
      |> init_test_session(%{})   # MUY IMPORTANTE
      |> put_session(:current_user, "damaris")
      |> post(~p"/home/directs", %{
        "group" => %{
          "name" => "mateo"
        }
      })

    assert redirected_to(conn) == ~p"/home/directs"

    # Buscar grupo direct creado
    group =
      Repo.one!(
        from g in Group,
          where: g.description == "direct"
      )

    assert group.name == "damaris-mateo"

    members =
      Repo.all(
        from gm in GroupMember,
          where: gm.group_id == ^group.id,
          select: gm.username
      )

    assert "damaris" in members
    assert "mateo" in members
  end

  test "index/2 muestra los chats directos del usuario", %{conn: conn} do
    # Crear usuarios
    Repo.insert!(%User{username: "damaris", name: "Dama", password: "123"})
    Repo.insert!(%User{username: "mateo", name: "Mateo", password: "123"})

    # Crear grupo direct
    group =
      Repo.insert!(%Group{
        id: "grupo-1",
        name: "damaris-mateo",
        description: "direct"
      })

    # Agregar miembros
    Repo.insert!(%GroupMember{group_id: group.id, username: "damaris", role: "admin"})
    Repo.insert!(%GroupMember{group_id: group.id, username: "mateo", role: "member"})

    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, "damaris")
      |> get(~p"/home/directs")

    assert html_response(conn, 200) =~ "mateo"
  end

  test "show/2 muestra el chat directo", %{conn: conn} do
    Repo.insert!(%User{username: "damaris", name: "Dama", password: "123"})
    Repo.insert!(%User{username: "mateo", name: "Mateo", password: "123"})

    group =
      Repo.insert!(%Group{
        id: "grupo-2",
        name: "damaris-mateo",
        description: "direct"
      })

    Repo.insert!(%GroupMember{group_id: group.id, username: "damaris", role: "admin"})
    Repo.insert!(%GroupMember{group_id: group.id, username: "mateo", role: "member"})

    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, "damaris")
      |> get(~p"/home/directs/#{group.id}")

    assert html_response(conn, 200) =~ "mateo"
  end

  describe "new direct message" do
    setup do
      user = %Chat.User{username: "damaris"}
      conn =
        build_conn()
        |> assign(:current_user, user)

      %{conn: conn, user: user}
    end

    test "new direct message renders form", %{conn: conn} do
      conn = get(conn, ~p"/home/directs/new")
      assert html_response(conn, 200) =~ "Crear chat"
    end

  end


end
