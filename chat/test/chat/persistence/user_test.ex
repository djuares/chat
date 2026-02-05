defmodule Chat.Persistence.UserTest do
  use Chat.RepoCase

  alias Chat.User

  test "It is posible to create a user" do
    user_params = %{
      "username" => "testuser",
      "password" => "password123",
      "email" => "testuser@example.com",
      "name" => "Test User"
    }
    assert :ok = User.create_user(user_params)
  end

  test "It is posible to login with correct credentials" do
    user_params = %{
      "username" => "testuser",
      "password" => "password123",
      "email" => "testuser@example.com",
      "name" => "Test User"
    }
    assert :ok = User.create_user(user_params)

    assert {:ok, %User{username: "testuser"}} = User.login_user("testuser", "password123")
  end

  test "It is not posible to login with incorrect credentials" do
    user_params = %{
      "username" => "testuser",
      "password" => "password123",
      "email" => "testuser@example.com",
      "name" => "Test User"
    }
    assert :ok = User.create_user(user_params)

    assert {:error, "Contraseña incorrecta"} = User.login_user("testuser", "wrongpassword")
    assert {:error, "Usuario no encontrado"} = User.login_user("nonexistentuser", "password123")
  end


end
