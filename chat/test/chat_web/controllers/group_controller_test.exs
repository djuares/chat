defmodule ChatWeb.GroupControllerTest do
  use ChatWeb.ConnCase

  import Ecto.Query
  alias Chat.{Repo, Group, GroupMember, User}

  test "index/2 muestra solo los grupos del usuario", %{conn: conn} do
    # Crear usuario
    Repo.insert!(%User{
      username: "damaris",
      name: "Damaris",
      password: "1234"
    })

    # Crear grupo normal
    group =
      Repo.insert!(%Group{
        id: "grupo-1",
        name: "Grupo Test",
        description: "normal"
      })

    # Asociarlo al usuario
    Repo.insert!(%GroupMember{
      group_id: group.id,
      username: "damaris",
      role: "member"
    })

    # Crear grupo direct (NO debe aparecer)
    direct_group =
      Repo.insert!(%Group{
        id: "grupo-2",
        name: "Directo",
        description: "direct"
      })

    Repo.insert!(%GroupMember{
      group_id: direct_group.id,
      username: "damaris",
      role: "member"
    })

    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, "damaris")
      |> get(~p"/home/groups")

    html = html_response(conn, 200)

    assert html =~ "Grupo Test"
    refute html =~ "Directo"
  end

  test "new/2 renderiza formulario", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> get(~p"/home/groups/new")

    html = html_response(conn, 200)

    assert html =~ "<form"
  end

  test "create/2 crea grupo y agrega creador como miembro", %{conn: conn} do
    Repo.insert!(%User{
      username: "damaris",
      name: "Damaris",
      password: "1234"
    })

    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, "damaris")
      |> post(~p"/home/groups", %{
        "group" => %{
          "name" => "Nuevo Grupo"
        }
      })

    assert redirected_to(conn) == ~p"/home/groups"

    group =
      Repo.one!(
        from g in Group,
          where: g.name == "Nuevo Grupo"
      )

    assert group.description != "direct"

    member =
      Repo.one!(
        from gm in GroupMember,
          where:
            gm.group_id == ^group.id and
            gm.username == "damaris"
      )

    assert member.role == "admin" or member.role == "member"
  end

  describe "show/2" do
    test "muestra un grupo", %{conn: conn} do
      user = Repo.insert!(%User{
        username: "testuser",
        name: "Test User",
        password: "password"
      })

      group =
        Repo.insert!(%Group{
          id: "grupo-show",
          name: "Grupo Show"
        })

      conn =
        conn
        |> init_test_session(%{})
        |> put_session(:current_user, user.username)
        |> get(~p"/home/groups/#{group.id}")

      assert html_response(conn, 200) =~ "Grupo Show"
    end
  end

  describe "add_member/2" do
    test "agrega un miembro al grupo", %{conn: conn} do
      group =
        Repo.insert!(%Group{
          id: "grupo-2",
          name: "Grupo"
        })

      Repo.insert!(%User{username: "juan"})

      conn =
        post(conn, ~p"/home/groups/#{group.id}/members", %{
          "username" => "juan"
        })

      assert redirected_to(conn) == "/home/groups/#{group.id}"

      assert Repo.get_by(GroupMember,
               group_id: group.id,
               username: "juan"
             )
    end
  end

  describe "remove_member/2" do
    test "elimina un miembro", %{conn: conn} do
      group =
        Repo.insert!(%Group{
          id: "grupo-3",
          name: "Grupo"
        })

      Repo.insert!(%User{username: "juan"})

      Repo.insert!(%GroupMember{
        group_id: group.id,
        username: "juan",
        role: "member"
      })

      conn =
        delete(conn, ~p"/home/groups/#{group.id}/members/juan")

      assert redirected_to(conn) == "/home/groups/#{group.id}"

      refute Repo.get_by(GroupMember,
               group_id: group.id,
               username: "juan"
             )
    end
  end

  describe "search/2" do
    test "renderiza búsqueda", %{conn: conn} do
      user = Repo.insert!(%User{
        username: "testuser2",
        name: "Test User 2",
        password: "password"
      })

      group =
        Repo.insert!(%Group{
          id: "grupo-search",
          name: "Grupo Search"
        })

      conn =
        conn
        |> init_test_session(%{})
        |> put_session(:current_user, user.username)
        |> get(~p"/home/groups/#{group.id}/search?q=hola")

      assert html_response(conn, 200)
    end
  end
end
