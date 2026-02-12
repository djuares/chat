defmodule Chat.GroupMember do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @primary_key false
  schema "group_members" do
    field :group_id, :string
    field :username, :string
    field :role, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:group_id, :username, :role])
    |> validate_required([:group_id, :username])
    |> unique_constraint([:group_id, :username], name: :group_members_pkey)
    |> foreign_key_constraint(:username, name: "group_members_username_fkey", message: "El usuario no existe en la base de datos")
  end

  def add_membership(group_id, username, role \\ "member") do
    %__MODULE__{}
    |> changeset(%{
      group_id: group_id,
      username: username,
      role: role
    })
    |> Chat.Repo.insert()
  end

  def get_membership(group_id, username) do
    Chat.Repo.one(
      from gm in __MODULE__,
        where: gm.group_id == ^group_id and gm.username == ^username
    )
  end

  def remove_membership(group_id, username) do
    from(gm in __MODULE__,
      where: gm.group_id == ^group_id and gm.username == ^username
    )
    |> Chat.Repo.delete_all()
  end

  def get_all_members(group_id) do
    import Ecto.Query

    online_users = ChatWeb.Presence.list("status:lobby") |> Map.keys() |> MapSet.new()

    from(m in Chat.GroupMember,
      where: m.group_id == ^group_id
    )
    |> Chat.Repo.all()
    |> Enum.map(fn member ->
      last_online = Chat.Repo.get(Chat.User, member.username).last_online
      status = if MapSet.member?(online_users, member.username), do: :online, else: :offline
      %{username: member.username, role: member.role, status: status, last_online: last_online}
    end)
  end

  # pre_condition: the group is a direct chat
  def get_direct_chat_name(username, group_id) do
    group_id
    |> get_all_members()
    |> Enum.map(& &1.username)
    |> Enum.find(fn member_username ->
        member_username != username
      end)
  end

end
