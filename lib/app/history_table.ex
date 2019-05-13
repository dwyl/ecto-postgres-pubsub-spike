defmodule App.HistoryTable do
  use Ecto.Migration

  @doc """
  This function is called in a migration file and is used to create / update
  history versions of the table being created / altered in the migration
  """
  def history do
    Agent.get_and_update(runner(), fn state ->
      {state, %{state | commands: add_history_commands(state.commands)}}
    end)
    |> create_trigger()
  end

  # This function handles creating a history version of a table that is being
  # created or updates the history table if the orginal tables is altered.
  defp add_history_commands(commands) do
    Enum.reduce(commands, [], fn
      # route to create a history version of the table being created
      {:create, table, subcommands} = command, acc ->
        history_table = Map.update!(table, :name, &(&1 <> "_history"))
        subcommands = add_ref_id_to_subcommands(subcommands, table)
        history_command = {:create, history_table, subcommands}

        acc = [command | acc]
        [history_command | acc]

      # route to alter the history version of the table being altered
      {:alter, table, subcommands} = command, acc ->
        history_table = Map.update!(table, :name, &(&1 <> "_history"))
        history_command = {:alter, history_table, subcommands}

        acc = [command | acc]
        [history_command | acc]

      # This function can be extended to handle other cases, like tables being
      # dropped etc. Right now we just return the command being called and do
      # nothing with the history tables.
      {_command, _table, _subcommands} = command, acc ->
        [command | acc]
    end)
  end

  # Adds the ref_id field to the list of commands. This ensures that the history
  # table is created with a ref_id column which references the id field of the
  # original table
  # This means that for now all tables using this function will need to have an
  # id column. This can potentially be changed in future but for now will be a
  # requirement
  defp add_ref_id_to_subcommands(subcommands, table) do
    ref_id = {:add, :ref_id,
     %Ecto.Migration.Reference{
       column: :id,
       name: nil,
       on_delete: :nothing,
       on_update: :nothing,
       prefix: nil,
       table: table.name,
       type: :id
     }, []}

    subcommands ++ [ref_id]
  end

  defp runner do
    case Process.get(:ecto_migration) do
      %{runner: runner} -> runner
      _ -> raise "could not find migration runner process for #{inspect self()}"
    end
  end

  # PostgreSQL trigger functions

  # Takes a command state and creates a trigger on the new table/tables being
  # created. Ignores tables with _history in the name so that is doesn't create
  # triggers on the history tables.
  defp create_trigger(state) do
    Enum.each(state.commands, fn
      {:create, table, _subcommands} = _command ->
        if not (table.name =~ "_history") do
          create_pg_notify_function(table)
          create_drop_trigger(table)
        end
      _ ->
        nil
    end)
  end

  defp create_pg_notify_function(table) do
    execute("""
    CREATE OR REPLACE FUNCTION notify_#{table.name}_changes()
    RETURNS trigger AS $$
    BEGIN
      PERFORM pg_notify(
        '#{table.name}_changed',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """, "")
  end

  defp create_drop_trigger(table) do
    execute("""
    CREATE TRIGGER #{table.name}_changed
    AFTER INSERT OR UPDATE
    ON #{table.name}
    FOR EACH ROW
    EXECUTE PROCEDURE notify_#{table.name}_changes()
    """,
    "DROP TRIGGER #{table.name}_changed ON tests"
    )
  end
end