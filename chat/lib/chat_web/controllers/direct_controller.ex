defmodule ChatWeb.DirectController do
  use ChatWeb, :controller

  import Ecto.Query
  alias Chat.{Repo, Group, GroupMember}

  # index
  def index(conn, _params) do
    current_username = conn.assigns.current_user.username

    directs =
      from(g in Group,
        join: gm in GroupMember,
        on: gm.group_id == g.id,
        where:
          gm.username == ^current_username and
          g.description == "direct",
        distinct: g.id,
        select: g
      )
      |> Repo.all()
      |> Enum.map(fn group ->
        other_user =
          GroupMember.get_all_members(group.id)
          |> Enum.map(& &1.username)
          |> Enum.find(fn username ->
            username != current_username
          end)

        %{
          id: group.id,
          name: other_user
        }
      end)

    render(conn, :index, directs: directs)
  end


  # new
  def new(conn, _params) do
    changeset = Group.changeset(%Group{}, %{})
    render(conn, ChatWeb.DirectHTML, :new, changeset: changeset)
  end

  # create
  def create(conn, %{"group" => %{"name" => recipient}}) do
    sender = conn.assigns.current_user.username
    group_id = Nanoid.generate()

    group =
      %Chat.Group{}
      |> Chat.Group.changeset(%{
        "id" => group_id,
        "name" => "#{sender}-#{recipient}",
        "description" => "direct"
      })
      |> Chat.Repo.insert!()

    # creador
    Chat.GroupMember.add_membership(group.id, sender, "admin")

    # destinatario
    Chat.GroupMember.add_membership(group.id, recipient, "member")

    conn
    |> put_flash(:info, "Chat directo creado")
    |> redirect(to: ~p"/home/directs")
  end

  # show
  def show(conn, %{"id" => id}) do
    current_username = conn.assigns.current_user.username

    group = Chat.Repo.get!(Chat.Group, id)

    members = Chat.GroupMember.get_all_members(group.id)

    other_user =
      members
      |> Enum.find(fn member ->
        member.username != current_username
      end)
      |> then(fn
        nil -> nil
        member -> member
      end)


    messages = Chat.GroupMessages.list_messages(group.id)

    render(conn, :show,
      group: group,
      messages: messages,
      other_user: other_user
    )
  end

end
