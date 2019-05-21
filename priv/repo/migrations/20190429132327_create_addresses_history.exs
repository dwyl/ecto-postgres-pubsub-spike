defmodule App.Repo.Migrations.CreateAddressesHistory do
  use Ecto.Migration

  # I left this change command in the code but all the contents commented out as
  # a reference to how much code a user would need to write if they were not
  # using the history() function. See create_addresses migration for an exmaple
  # of the history function being called.
  def change do
    # create table(:addresses_history) do
    #   add :ref_id, references(:addresses, on_delete: :delete_all, column: :id, type: :id)
    #   add :name, :string
    #   add :address_line_1, :string
    #   add :address_line_2, :string
    #   add :city, :string
    #   add :postcode, :string
    #   add :tel, :string
    #
    #   timestamps()
    # end
    #
    # execute("""
    # CREATE OR REPLACE FUNCTION notify_address_changes()
    # RETURNS trigger AS $$
    # BEGIN
    #   PERFORM pg_notify(
    #     'addresses_changed',
    #     json_build_object(
    #       'operation', TG_OP,
    #       'record', row_to_json(NEW)
    #     )::text
    #   );
    #   RETURN NEW;
    # END;
    # $$ LANGUAGE plpgsql;
    # """, "")
    #
    # execute("""
    # CREATE TRIGGER addresses_changed_changed
    # AFTER INSERT OR UPDATE
    # ON addresses
    # FOR EACH ROW
    # EXECUTE PROCEDURE notify_address_changes()
    # """,
    # "DROP TRIGGER addresses_changed ON tests"
    # )
  end
end
