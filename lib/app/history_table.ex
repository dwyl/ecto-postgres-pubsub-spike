defmodule App.HistoryTable do
  use Ecto.Migration

  def history do
    Agent.update runner(), fn state ->
      %{state | commands: create_update_history(state.commands)}
    end
    create_pg_notify_function(%{name: "tests"})
    create_drop_trigger(%{name: "tests"})
  end

  defp create_update_history(commands) do
    Enum.reduce(commands, [], fn
      # if the create command was called then it we create a history version of
      # the table that create was being called on.
      {:create, table, subcommands} = command, acc ->
        history_table = Map.update!(table, :name, &(&1 <> "_history"))
        subcommands = add_ref_id_to_subcommands(subcommands, table)
        history_command = {:create, history_table, subcommands}

        acc = [command | acc]
        [history_command | acc]

      # currently if the command is anything other than create we return the
      # list of commands
      # This function can be extended to handle other cases, like tables being
      # dropped etc.
      {_command, _table, _subcommands} = t, acc ->
        [t | acc]
    end)
  end

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

  def create_pg_notify_function(table) do
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

  def create_drop_trigger(table) do
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