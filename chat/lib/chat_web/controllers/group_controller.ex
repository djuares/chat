defmodule ChatWeb.GroupController do
  use ChatWeb, :controller

  alias Chat.{Repo, Group, GroupMember}

  # index
  def index(conn, _params) do
    groups = Repo.all(Group)
    render(conn, ChatWeb.GroupHTML, :index, groups: groups)
  end

  # new
  def new(conn, _params) do
    changeset = Group.changeset(%Group{}, %{})
    render(conn, ChatWeb.GroupHTML, :new, changeset: changeset)
  end

  # create
  def create(conn, %{"group" => group_params}) do
    group_params =
      Map.put(group_params, "id", Ecto.UUID.generate())

    changeset = Group.changeset(%Group{}, group_params)

    case Repo.insert(changeset) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Grupo creado correctamente")
        |> redirect(to: ~p"/groups")

      {:error, changeset} ->
        render(conn, ChatWeb.GroupHTML, :new, changeset: changeset)
    end
  end


  # show
  def show(conn, %{"id" => id}) do
    group = Repo.get!(Group, id)
    members = GroupMember.get_all_members(group.id)

    render(conn, ChatWeb.GroupHTML, :show,
      group: group,
      members: members
    )
  end
end
