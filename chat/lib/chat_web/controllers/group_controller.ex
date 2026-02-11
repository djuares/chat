defmodule ChatWeb.GroupController do
  use ChatWeb, :controller

  alias Chat.{Repo, Group, GroupMember}

  # index
  import Ecto.Query

  def index(conn, _params) do
    user = conn.assigns.current_user

    groups =
      from(g in Group,
        join: gm in GroupMember,
        on: gm.group_id == g.id,
        where:
          gm.username == ^user.username and
          (is_nil(g.description) or g.description != "direct"),
        select: g
      )
      |> Repo.all()


    render(conn, :index, groups: groups)
  end


  # new
  def new(conn, _params) do
    changeset = Group.changeset(%Group{}, %{})
    render(conn, :new, changeset: changeset)
  end

  # create
  def create(conn, %{"group" => %{"name" => name}}) do
    user = conn.assigns.current_user
    Chat.Group.create!(name, user.username)

    conn
    |> put_flash(:info, "Grupo creado correctamente")
    |> redirect(to: ~p"/home/groups")
  end


  # show
  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    members = GroupMember.get_all_members(group.id)
    messages = Chat.GroupMessages.list_messages(group.id)

    render(conn, :show,
      group: group,
      members: members,
      messages: messages
    )
  end

  def add_member(conn, %{"group_id" => group_id, "username" => username}) do
    IO.inspect(group_id, label: "GROUP ID")
    IO.inspect(username, label: "USERNAME")

    # Agregar miembro
    Chat.GroupMember.add_membership(group_id, username, "member")

    conn
    |> put_flash(:info, "Miembro agregado correctamente")
    |> redirect(to: ~p"/home/groups/#{group_id}")
  end

  def remove_member(conn, %{"group_id" => group_id, "username" => username}) do

    from(gm in GroupMember,
      where:
        gm.group_id == ^group_id and
        gm.username == ^username
    )
    |> Repo.delete_all()

    conn
    |> put_flash(:info, "Miembro eliminado correctamente")
    |> redirect(to: ~p"/home/groups/#{group_id}")
  end

  def search(conn, %{"group_id" => group_id, "q" => q}) do
    group = Repo.get!(Group, group_id)
    members = GroupMember.get_all_members(group_id)
    messages = Chat.GroupMessages.search_messages(group_id, q)

    render(conn, :show,
      group: group,
      members: members,
      messages: messages,
      q: q
    )
  end

end
