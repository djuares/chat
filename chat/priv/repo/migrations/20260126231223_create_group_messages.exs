defmodule Chat.Repo.Migrations.CreateGroupMessages do
  use Ecto.Migration

  def change do
    create table(:group_messages) do
      add :group_id,
          references(:groups, type: :string, column: :id),
          null: false

      add :sender,
          references(:users, type: :string, column: :username),
          null: false

      add :content, :text, null: false

      timestamps()
    end
  end
end
