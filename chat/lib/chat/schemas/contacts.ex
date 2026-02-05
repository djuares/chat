defmodule Chat.Contacts do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key false
  schema "contacts" do
    belongs_to :username, Chat.User, references: :username, type: :string, foreign_key: :user
    belongs_to :contact_username, Chat.User, references: :username, type: :string, foreign_key: :contact
    timestamps()
  end

  @doc false
  def changeset(contact, params \\ %{}) do
    contact
    |> cast(params, [:user, :contact])
    |> validate_required([:user, :contact])
    |> unique_constraint([:user, :contact])
    |> foreign_key_constraint(:user)
    |> foreign_key_constraint(:contact)
  end

  def add_contact(user, contact) do
    %__MODULE__{}
    |> changeset(%{user: user, contact: contact})
    |> Chat.Repo.insert()
  end

  def remove_contact(user, contact) do
    from(c in __MODULE__,
      where: c.user == ^user and c.contact == ^contact
    )
    |> Chat.Repo.delete_all()
  end

  def list_contacts(user) do
    from(c in __MODULE__,
      where: c.user == ^user,
      join: u in Chat.User,
      on: c.contact == u.username,
      select: %{username: u.username}
    )
    |> Chat.Repo.all()
    |> Enum.map(& &1.username)
  end
end
