defmodule App.Repo.Migrations.CreateAddressHistoryProcedure do
  use Ecto.Migration

  def up do
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

    flush()

    execute """
    CREATE TRIGGER addresses_changed
    AFTER INSERT OR UPDATE
    ON addresses
    FOR EACH ROW
    EXECUTE PROCEDURE notify_address_changes()
    """
  end

  def down do
    execute """
    DROP TRIGGER addresses_changed ON addresses
    """
  end
end
