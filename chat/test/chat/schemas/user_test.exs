defmodule Chat.UserTest do
  use ExUnit.Case
  alias Chat.User
  alias Chat.Repo

  # Esto asegura que cada test use un sandbox y no afecte la DB real
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    :ok
  end

  @valid_params %{
    username: "damaris",
    password: "123456",
    email: "damaris@example.com",
    name: "Damaris Juarez",
    description: "Test user"
  }

  describe "changeset/2" do
    test "valid params produce a valid changeset" do
      changeset = User.changeset(%User{}, @valid_params)
      assert changeset.valid?
    end

    test "missing required fields produces errors" do
      changeset = User.changeset(%User{}, %{})
      refute changeset.valid?
      assert %{username: _, password: _, email: _, name: _} = errors_on(changeset)
    end

    test "invalid email format produces error" do
      params = Map.put(@valid_params, :email, "invalidemail")
      changeset = User.changeset(%User{}, params)
      refute changeset.valid?
      assert %{email: _} = errors_on(changeset)
    end
  end

  describe "create_user/1" do
    test "creates a user with valid params" do
      assert :ok = User.create_user(@valid_params)
      user = Repo.get(User, @valid_params.username)
      assert user.email == @valid_params.email
    end

    test "fails when username or email is not unique" do
      # Primero inserto un usuario válido
      User.create_user(@valid_params)

      # Intento insertar de nuevo y espero que lance Ecto.ConstraintError
      assert_raise Ecto.ConstraintError, fn ->
        User.create_user(@valid_params)
      end
    end

    test "returns {:error, errors} for invalid params" do
      params = Map.put(@valid_params, :email, "bademail")
      assert {:error, errors} = User.create_user(params)
      assert errors =~ "email"
    end

  end

  describe "verify_user/2" do
    setup do
      User.create_user(@valid_params)
      :ok
    end

    test "raises error when username is wrong" do
      assert {:error, "Usuario no encontrado"} = User.verify_user("wronguser", "123456")
    end

    test "raises error when password is wrong" do
      assert {:error, "Contraseña incorrecta"} = User.verify_user(@valid_params.username, "wrongpassword")
    end
  end

  describe "login_user/2" do
    setup do
      User.create_user(@valid_params)
      :ok
    end

    test "returns {:ok, user} for correct credentials" do
      assert {:ok, user} = User.login_user(@valid_params.username, @valid_params.password)
      assert user.username == @valid_params.username
    end

    test "returns error tuple for incorrect username" do
      assert {:error, "Usuario no encontrado"} = User.login_user("wronguser", "123456")
    end

    test "returns error tuple for incorrect password" do
      assert {:error, "Contraseña incorrecta"} = User.login_user(@valid_params.username, "wrongpass")
    end
  end

  describe "update_last_online/1" do
    setup do
      User.create_user(@valid_params)
      :ok
    end

    test "updates last_online timestamp" do
      old_timestamp = User.get_last_online(@valid_params.username)
      :timer.sleep(1000) # Asegura que el nuevo timestamp sea diferente
      User.update_last_online(@valid_params.username)
      new_timestamp = User.get_last_online(@valid_params.username)
      assert new_timestamp > old_timestamp
    end
  end

  describe "get_last_online/1" do
    setup do
      User.create_user(@valid_params)
      :ok
    end

    test "returns the last_online timestamp" do
      timestamp = User.get_last_online(@valid_params.username)
      assert timestamp != nil
    end
  end

  # Helper para extraer errores del changeset
  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
