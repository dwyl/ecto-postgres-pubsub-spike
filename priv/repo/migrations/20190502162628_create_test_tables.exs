defmodule App.Repo.Migrations.CreateTestTables do
  use Ecto.Migration
  import App.HistoryTable

  def change do
    create table(:tests) do
      add :a, :string
    end

    history()
  end
end
