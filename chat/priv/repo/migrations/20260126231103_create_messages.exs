defmodule Chat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :sender_id,
          references(:users,
            column: :username,
            type: :string
          ),
          primary_key: true

      add :receipient_id,
          references(:users,
            column: :username,
            type: :string
          ),
          primary_key: true

      add :message, :text, null: false

      add :inserted_at, :utc_datetime_usec, primary_key: true
      add :updated_at, :utc_datetime_usec
    end
  end
end
