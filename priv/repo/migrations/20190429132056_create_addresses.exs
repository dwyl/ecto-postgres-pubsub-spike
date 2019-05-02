defmodule App.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :name, :string
      add :address_line_1, :string
      add :address_line_2, :string
      add :city, :string
      add :postcode, :string
      add :tel, :string

      timestamps()
    end

    create unique_index(:addresses, [:tel])
  end
end
