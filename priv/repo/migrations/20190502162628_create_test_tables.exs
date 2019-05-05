defmodule App.Repo.Migrations.CreateTestTables do
  use Ecto.Migration

  def change do
    create table(:tests) do
      add :a, :string
    end

    history()
  end

  def history do
    Agent.update runner(), fn state ->
      %{state | commands: create_update_history(state.commands)}
    end
  end

  defp create_update_history(commands) do
    Enum.reduce(commands, [], fn
      # if the create command was called then it we create a history version of
      # the table that create was being called on.
      {:create, table, subcommands} = command, acc ->
        history_table = Map.update!(table, :name, &(&1 <> "_history"))

        add_ref_id = [{:add, :ref_id,
         %Ecto.Migration.Reference{
           column: :id,
           name: nil,
           on_delete: :nothing,
           on_update: :nothing,
           prefix: nil,
           table: table.name,
           type: :id
         }, []}]

        subcommands = subcommands ++ add_ref_id
        history = {:create, history_table, subcommands}

        acc = [command | acc]
        [history | acc]

      # currently if the command is anything other than create we return the
      # list of commands
      # This function can be extended to handle other cases, like tables being
      # dropped etc.
      {_command, _table, _subcommands} = t, acc ->
        [t | acc]
    end)
  end

  defp runner do
    case Process.get(:ecto_migration) do
      %{runner: runner} -> runner
      _ -> raise "could not find migration runner process for #{inspect self()}"
    end
  end
end
