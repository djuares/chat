defmodule ChatWeb.AuthController do
  use ChatWeb, :controller

  alias Chat.User

  def new(conn, _params) do
    render(conn, :login)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
      case User.login_user(username, password) do
        {:error, message} ->
          conn
          |> put_flash(:error, message)
          |> render("login.html")

        {:ok, user} ->
            conn
            |> put_session(:current_user, user.username)
            |> put_flash(:info, "Bienvenido #{user.name}!")
            |> redirect(to: "/home")
      end
    end

  def new_user(conn, _params) do
    render(conn, "register.html")
  end

  def create_user(conn, %{"user" => user_params}) do

    case User.create_user(user_params) do
      :ok ->
        conn
        |> put_flash(:info, "Usuario creado correctamente")
        |> redirect(to: ~p"/login")

      {:error, errors} ->
        conn
        |> put_flash(:error, "Error al crear usuario: #{errors}")
        |> render("register.html")
    end
  end

  def delete(conn, _params) do
  conn
  |> configure_session(drop: true)   # borra toda la sesión
  |> put_flash(:info, "Has cerrado sesión correctamente")
  |> redirect(to: ~p"/")             # redirige al home
end

end
