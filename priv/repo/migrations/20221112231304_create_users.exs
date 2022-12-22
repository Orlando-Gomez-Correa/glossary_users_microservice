defmodule Greenhouse.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :middlename, :string
      add :lastname, :string, null: false
      add :second_lastname, :string
      add :phone, :string, null: false
      add :birthday, :string
      add :email, :string, null: false
      add :auth0_id, :string
      add :is_admin, :boolean, default: false, null: false
      add :image, :string
      add :timezone, :string
      add :language, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
