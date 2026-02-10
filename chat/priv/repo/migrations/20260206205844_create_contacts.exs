defmodule Chat.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :user, references(:users, column: :username, type: :string, on_delete: :delete_all)
      add :contact, references(:users, column: :username, type: :string, on_delete: :delete_all)

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:contacts, [:user, :contact])
  end
end
