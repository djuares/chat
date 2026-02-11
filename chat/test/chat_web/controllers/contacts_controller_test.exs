defmodule ChatWeb.ContactsControllerTest do
  use ChatWeb.ConnCase

  alias Chat.{Repo, User, Contacts}

    setup do
      # Crear usuarios
      current_user = Repo.insert!(%User{username: "damaris", name: "Damaris", password: "1234"})
      contact_user = Repo.insert!(%User{username: "mateo", name: "Mateo", password: "1234"})

      # Retornar usuarios para usar en tests
      %{current_user: current_user, contact_user: contact_user}
    end


  test "create/2 agrega un contacto", %{conn: conn, current_user: current_user, contact_user: contact_user} do
    # Simular usuario logueado
    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, current_user.username)
      |> post(~p"/home/contacts", %{"contact_username" => contact_user.username})

    # Verificar redirección
    assert redirected_to(conn) == ~p"/home/contacts"

    # Verificar que el contacto se haya agregado
    contacts = Contacts.list_contacts(current_user.username)
    assert contact_user.username in Enum.map(contacts, & &1.username)
  end

  test "index/2 lista los contactos del usuario", %{conn: conn, current_user: current_user, contact_user: contact_user} do
    # Agregar un contacto manualmente
    {:ok, _} = Contacts.add_contact(current_user.username, contact_user.username)

    # Simular sesión del usuario
    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:current_user, current_user.username)
      |> get(~p"/home/contacts")

    # Verificar que la página cargó correctamente
    assert html_response(conn, 200) =~ contact_user.username
  end


end
