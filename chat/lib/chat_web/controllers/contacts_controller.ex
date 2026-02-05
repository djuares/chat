defmodule ChatWeb.ContactsController do
  use ChatWeb, :controller

  alias Chat.Contacts

  # plug :authenticate_user

  def index(conn, _params) do
    current_user = get_session(conn, :current_user)
    contacts = Contacts.list_contacts(current_user)
    render(conn, :index, contacts: contacts, username: current_user)
  end

  def create(conn, %{"contact_username" => contact_username}) do
    current_user = get_session(conn, :current_user)

    case Contacts.add_contact(current_user, contact_username) do
      {:ok, _contact} ->
        conn
        |> put_flash(:info, "Contacto agregado exitosamente.")
        |> redirect(to: ~p"/home/contacts")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error al agregar contacto.")
        |> redirect(to: ~p"/home/contacts")
    end
  end

  def delete(conn, %{"contact_username" => contact_username}) do
    current_user = get_session(conn, :current_user)
    Contacts.remove_contact(current_user, contact_username)

    conn
    |> put_flash(:info, "Contacto eliminado exitosamente.")
    |> redirect(to: ~p"/home/contacts")
  end
end
