defmodule App.Repo.Migrations.AlterTestTables do
  use Ecto.Migration
  import App.HistoryTable

  def change do
    alter table(:tests) do
      add :b, :string
    end

    history()
  end
end
