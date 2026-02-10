defmodule Chat.ContactsTest do
  use Chat.DataCase, async: true
  alias Chat.{Contacts, Repo, User}

  defp create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  describe "add_contact/2" do
    test "creates a contact relation between users" do
      user =
        create_user(%{
          username: "alice",
          password: "123",
          email: "alice@test.com",
          name: "Alice"
        })

      contact =
        create_user(%{
          username: "bob",
          password: "123",
          email: "bob@test.com",
          name: "Bob"
        })

      assert {:ok, _} =
               Contacts.add_contact(user.username, contact.username)

      assert Repo.aggregate(Contacts, :count) == 1
    end

    test "fails when contact already exists (unique constraint)" do
      user =
        create_user(%{
          username: "alice",
          password: "123",
          email: "alice@test.com",
          name: "Alice"
        })

      contact =
        create_user(%{
          username: "bob",
          password: "123",
          email: "bob@test.com",
          name: "Bob"
        })

      Contacts.add_contact(user.username, contact.username)

      assert {:error, changeset} =
               Contacts.add_contact(user.username, contact.username)

      assert %{user: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "list_contacts/1" do
    test "returns usernames of all contacts" do
      user =
        create_user(%{
          username: "alice",
          password: "123",
          email: "alice@test.com",
          name: "Alice"
        })

      bob =
        create_user(%{
          username: "bob",
          password: "123",
          email: "bob@test.com",
          name: "Bob"
        })

      carol =
        create_user(%{
          username: "carol",
          password: "123",
          email: "carol@test.com",
          name: "Carol"
        })

      Contacts.add_contact(user.username, bob.username)
      Contacts.add_contact(user.username, carol.username)

      contacts = Contacts.list_contacts(user.username)

      assert Enum.sort(contacts) ==  [%{status: :offline, username: "bob"}, %{status: :offline, username: "carol"}]
    end

    test "returns empty list when user has no contacts" do
      user =
        create_user(%{
          username: "alice",
          password: "123",
          email: "alice@test.com",
          name: "Alice"
        })

      assert Contacts.list_contacts(user.username) == []
    end
  end

  describe "remove_contact/2" do
    test "removes an existing contact" do
      user =
        create_user(%{
          username: "alice",
          password: "123",
          email: "alice@test.com",
          name: "Alice"
        })

      contact =
        create_user(%{
          username: "bob",
          password: "123",
          email: "bob@test.com",
          name: "Bob"
        })

      Contacts.add_contact(user.username, contact.username)

      {deleted, _} =
        Contacts.remove_contact(user.username, contact.username)

      assert deleted == 1
      assert Contacts.list_contacts(user.username) == []
    end

    test "returns 0 when contact does not exist" do
      user =
        create_user(%{
          username: "alice",
          password: "123",
          email: "alice@test.com",
          name: "Alice"
        })

      {deleted, _} =
        Contacts.remove_contact(user.username, "ghost")

      assert deleted == 0
    end
  end
end
