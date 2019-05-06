defmodule App.Repo.Migrations.CreateAddressHistoryProcedure do
  use Ecto.Migration

  def up do
    # creates a function which returns a trigger that returns the same record
    # that that the function was triggered by.
    execute """
    CREATE OR REPLACE FUNCTION notify_address_changes()
    RETURNS trigger AS $$
    BEGIN
      PERFORM pg_notify(
        'addresses_changed',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    # ensures that the code before this line is run first
    # flush()

    # creates a trigger that listends for is called after any insert or update
    # to the addresses table.
    execute """
    CREATE TRIGGER addresses_changed
    AFTER INSERT OR UPDATE
    ON addresses
    FOR EACH ROW
    EXECUTE PROCEDURE notify_address_changes()
    """
  end

  def down do
    # Drops the trigger on rollback
    execute """
    DROP TRIGGER addresses_changed ON addresses
    """
  end
end
