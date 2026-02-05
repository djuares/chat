defmodule Unauthorized do
  defexception message: "Unauthorized", plug_status: 401
end

defmodule Chat.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:username, :string, autogenerate: false}
  schema "users" do
    field(:password, :string)
    field(:email, :string)
    field(:name, :string)
    field(:description, :string)
    field(:last_online, :utc_datetime_usec, default: DateTime.utc_now())

      many_to_many :contacts, Chat.User,
        join_through: Chat.Contacts,
        join_keys: [user: :username, contact: :username]

    timestamps()
  end

  def changeset(data, params \\ %{}) do
    data
    |> cast(params, [:username, :password, :email, :name, :description])
    |> validate_required([:username, :password, :email, :name])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:username, :email])
  end

  def verify_user(username, password) do
    user = Chat.Repo.get(__MODULE__, username)

    cond do
      user == nil -> raise Unauthorized
      user.password == password -> user
      true -> raise Unauthorized
    end
  end

  def update_last_online(username) do
    from(u in __MODULE__, where: u.username == ^username)
    |> Chat.Repo.update_all(set: [last_online: DateTime.utc_now()])
  end

  def get_last_online(username) do
    Chat.Repo.get(__MODULE__, username).last_online
  end

  def create_user(user_params) do
    changeset(%Chat.User{}, user_params)
    |> Chat.Repo.insert()
    |> case do
      {:ok, _user} -> :ok
      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map(fn {field, {msg, _}} -> "#{field}: #{msg}" end)
          |> Enum.join(", ")

        {:error, errors}
    end
  end

  def login_user(username, password) do
    Chat.Repo.get(__MODULE__, username)
    |> case do
      nil -> {:error, "Usuario no encontrado"}
      %Chat.User{} = user ->
        if user.password == password do
          {:ok, user}
        else
          {:error, "Contraseña incorrecta"}
        end
    end
  end

  def search(username, query, skip \\ 0, take \\ 10) do
    q0 =
      from(uc in Chat.UserConversations,
        where: uc.from_id == ^username or uc.to_id == ^username,
        select: uc.to_id
      )

    q =
      from(u in Chat.User,
        where: like(u.username, ^"%#{query}%") or like(u.name, ^"%#{query}%"),
        where: u.username not in subquery(q0) and u.username != ^username,
        select: [u.username, u.name],
        offset: ^skip,
        limit: ^take
      )

    Chat.Repo.all(q)
  end
end
