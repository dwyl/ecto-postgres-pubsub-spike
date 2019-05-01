defmodule App.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def up do
    execute """
    CREATE OR REPLACE FUNCTION notify_account_changes()
    RETURNS trigger AS $$
    BEGIN
      PERFORM pg_notify(
        'accounts_changed',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    create table(:accounts) do
      add(:username, :string, null: true)
    end

    flush()

    execute """
    CREATE TRIGGER accounts_changed
    AFTER INSERT OR UPDATE
    ON accounts
    FOR EACH ROW
    EXECUTE PROCEDURE notify_account_changes()
    """
  end

  def down do
    drop table(:accounts)
  end
end
