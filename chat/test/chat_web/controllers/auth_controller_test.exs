defmodule ChatWeb.AuthControllerTest do
  use ChatWeb.ConnCase, async: true

  alias Chat.User
  alias Chat.Repo
  alias Phoenix.Flash

  @valid_user %{
    "username" => "damaris",
    "password" => "1234",
    "name" => "Damaris",
    "email" => "damaris@example.com"
  }

  @invalid_user %{
    "username" => "",
    "password" => "",
    "name" => "",
    "email" => ""
  }

  describe "login" do
    setup %{conn: conn} do
      # Creamos usuario válido en la DB
      :ok = User.create_user(@valid_user)
      {:ok, conn: conn}
    end

    test "renderiza formulario de login", %{conn: conn} do
      conn = get(conn, ~p"/login")
      assert html_response(conn, 200) =~ "Iniciar sesión"
    end

    test "login exitoso con credenciales correctas", %{conn: conn} do
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"username" => @valid_user["username"], "password" => @valid_user["password"]}
        })

      # Redirección
      assert redirected_to(conn) == "/home"
      assert get_session(conn, :current_user) == @valid_user["username"]

      # Flash sin warnings
      conn = fetch_flash(conn)
      assert Flash.get(conn.assigns.flash, :info) =~ "Bienvenido #{@valid_user["name"]}!"
    end

    test "login falla con credenciales incorrectas", %{conn: conn} do
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"username" => @valid_user["username"], "password" => "wrong"}
        })

      assert html_response(conn, 200) =~ "Iniciar sesión"
      conn = fetch_flash(conn)
      assert Flash.get(conn.assigns.flash, :error) =~ "incorrecta"
      refute get_session(conn, :current_user)
    end
  end

  describe "registro de usuario" do
    test "renderiza formulario de registro", %{conn: conn} do
      conn = get(conn, ~p"/register")
      assert html_response(conn, 200) =~ "Crear usuario"
    end

    test "registro exitoso", %{conn: conn} do
      conn = post(conn, ~p"/register", %{"user" => @valid_user})

      assert redirected_to(conn) == ~p"/login"

      conn = fetch_flash(conn)
      assert Flash.get(conn.assigns.flash, :info) =~ "Usuario creado correctamente"

      # Verificamos que el usuario existe en la DB
      user = Repo.get_by!(User, username: @valid_user["username"])
      assert user.name == @valid_user["name"]
    end

    test "registro falla con datos inválidos", %{conn: conn} do
      conn = post(conn, ~p"/register", %{"user" => @invalid_user})
      assert html_response(conn, 200) =~ "Crear usuario"

      conn = fetch_flash(conn)
      assert Flash.get(conn.assigns.flash, :error) =~ "Error al crear usuario"
    end
  end

  describe "logout" do
    setup %{conn: conn} do
      # Inicializamos sesión para tests de logout
      conn = init_test_session(conn, current_user: @valid_user["username"])
      {:ok, conn: conn}
    end



  end
end
