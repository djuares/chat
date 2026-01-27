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
    |> unique_constraint([:group_id, :username])
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
end
