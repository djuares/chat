defmodule Chat.Repo.Migrations.UserConversation do
  use Ecto.Migration

  def change do
    create table(:user_conversation) do
      add :username,
          references(:users, type: :string, column: :username),
          null: false

      add :group_id,
          references(:groups, type: :string, column: :id),
          null: false

      timestamps()
    end
  end
end
