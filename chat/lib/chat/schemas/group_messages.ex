defmodule Chat.GroupMessages do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  schema "group_messages" do
    field :content, :string

    belongs_to :sender_user, Chat.User,
      foreign_key: :sender,
      references: :username,
      type: :string

    belongs_to :group, Chat.Group,
      foreign_key: :group_id,
      references: :id,
      type: :string

    timestamps()
  end

  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:group_id, :sender, :content])
    |> validate_required([:group_id, :sender, :content])
  end

  def list_messages(group_id) do
    from(m in __MODULE__,
      where: m.group_id == ^group_id,
      order_by: [asc: m.inserted_at],
      preload: [:sender_user]
    )
    |> Chat.Repo.all()
  end
end
