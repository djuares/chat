defmodule ChatWeb.AuthController do
  use ChatWeb, :controller

  alias Chat.User
  alias Chat.Repo

  def new(conn, _params) do
    render(conn, :login)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
      case Repo.get_by(User, username: username) do
        nil ->
          conn
          |> put_flash(:error, "Usuario no encontrado")
          |> render("login.html")

        %User{} = user ->
          if user.password == password do
            conn
            |> put_session(:current_user, user.username)
            |> put_flash(:info, "Bienvenido #{user.name}!")
            |> redirect(to: "/home")
          else
            conn
            |> put_flash(:error, "Contraseña incorrecta")
            |> render("login.html")
          end
      end
    end

  def new_user(conn, _params) do
    render(conn, "register.html")
  end

  def create_user(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Usuario creado correctamente")
        |> redirect(to: ~p"/login")

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map(fn {field, {msg, _}} -> "#{field}: #{msg}" end)
          |> Enum.join(", ")

        conn
        |> put_flash(:error, "Error al crear usuario: #{errors}")
        |> render("register.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
  conn
  |> configure_session(drop: true)   # borra toda la sesión
  |> put_flash(:info, "Has cerrado sesión correctamente")
  |> redirect(to: ~p"/")             # redirige al home
end

end
