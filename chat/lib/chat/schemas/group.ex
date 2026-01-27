defmodule Chat.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "groups" do
    field(:id, :string, primary_key: true)
    field(:name, :string)
    field(:description, :string)

    timestamps()
  end

  @doc false
  def changeset(group, params \\ %{}) do
    group
    |> cast(params, [:id, :name, :description])
    |> validate_required([:id, :name])
    |> unique_constraint([:id])
  end

  @spec create!(binary(), binary()) :: %Chat.Group{}
  def create!(group_name, username) do
    group_id = Nanoid.generate()

    changeset =
      Chat.Group.changeset(%Chat.Group{}, %{
        "id" => group_id,
        "name" => group_name
      })

    group = Chat.Repo.insert!(changeset)

    # Agregar el creador como miembro (por ejemplo rol admin)
    Chat.GroupMember.add_membership(group.id, username, "admin")

    group
  end

  def delete(group_id) do
    Chat.Repo.get!(Chat.Group, group_id)
    |> Chat.Repo.delete()
  end
end
