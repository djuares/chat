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

  def get_messages_since(group_id, since_datetime) do
    from(m in __MODULE__,
      where: m.group_id == ^group_id and m.inserted_at > ^since_datetime,
      order_by: [asc: m.inserted_at],
      select: %{
        sender: m.sender,
        message: m.content,
        inserted_at: m.inserted_at
      }
    )
    |> Chat.Repo.all()
  end

  def search_messages(group_id, q) do
    from(m in __MODULE__,
      where: m.group_id == ^group_id and ilike(m.content, ^"%#{q}%"),
      order_by: [asc: m.inserted_at],
      preload: [:sender_user]
    )
    |> Chat.Repo.all()
  end

end
