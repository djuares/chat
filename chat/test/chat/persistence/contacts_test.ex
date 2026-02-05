defmodule Chat.ContactsTest do
  use Chat.RepoCase

  alias Chat.Contacts

  setup do
    user1_params = %{
      "username" => "user1",
      "password" => "password1",
      "email" => "user1@mail.com",
      "name" => "User One"
    }
    user2_params = %{
      "username" => "user2",
      "password" => "password2",
      "email" => "user2@mail.com",
      "name" => "User Two"
    }

    :ok = Chat.User.create_user(user1_params)
    :ok = Chat.User.create_user(user2_params)
  end

  test "It is possible to add and list contacts" do
    assert {:ok, _} = Contacts.add_contact("user1", "user2")
    contacts = Contacts.list_contacts("user1")
    assert contacts == ["user2"]
  end

  test "It is possible to remove contacts" do
    assert {:ok, _} = Contacts.add_contact("user1", "user2")
    contacts = Contacts.list_contacts("user1")
    assert contacts == ["user2"]

    {1, _} = Contacts.remove_contact("user1", "user2")
    contacts_after_removal = Contacts.list_contacts("user1")
    assert contacts_after_removal == []
  end

  test "It is not possible to add the same contact twice" do
    assert {:ok, _} = Contacts.add_contact("user1", "user2")
    assert {:error, _} = Contacts.add_contact("user1", "user2")
  end

  test "It is not possible to add a non-existent contact" do
    assert {:error, _} = Contacts.add_contact("user1", "nonexistentuser")
    assert {:error, _} = Contacts.add_contact("nonexistentuser", "user1")
  end
end
