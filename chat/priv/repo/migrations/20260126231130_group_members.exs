defmodule Chat.Repo.Migrations.GroupMembers do
  use Ecto.Migration

  def change do
    create table(:group_members, primary_key: false) do
      add :group_id, references(:groups, type: :string, column: :id), primary_key: true
      add :username, references(:users, type: :string, column: :username), primary_key: true
      add :role, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
