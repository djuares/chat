defmodule Chat.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end
  end
end
