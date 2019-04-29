defmodule App.Repo.Migrations.CreateAddressesHistory do
  use Ecto.Migration

  def change do
    create table(:addresses_history) do
      add :name, :string
      add :address_line_1, :string
      add :address_line_2, :string
      add :city, :string
      add :postcode, :string
      add :tel, :string

      timestamps()
    end

  end
end
