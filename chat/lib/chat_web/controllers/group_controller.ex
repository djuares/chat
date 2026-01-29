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
        where: gm.username == ^user.username,
        select: g
      )
      |> Repo.all()

    render(conn, ChatWeb.GroupHTML, :index, groups: groups)
  end


  # new
  def new(conn, _params) do
    changeset = Group.changeset(%Group{}, %{})
    render(conn, ChatWeb.GroupHTML, :new, changeset: changeset)
  end

  # create
  def create(conn, %{"group" => %{"name" => name}}) do
    user = conn.assigns.current_user
    Chat.Group.create!(name, user.username)

    conn
    |> put_flash(:info, "Grupo creado correctamente")
    |> redirect(to: ~p"/groups")
  end


  # show
  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    members = GroupMember.get_all_members(group.id)
    messages = Chat.GroupMessages.list_messages(group.id)

    render(conn, ChatWeb.GroupHTML, :show,
      group: group,
      members: members,
      messages: messages
    )
  end

end
