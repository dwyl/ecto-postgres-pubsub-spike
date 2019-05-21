defmodule App.Accounts.AddressHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses_history" do
    field :ref_id, :integer
    field :address_line_1, :string
    field :address_line_2, :string
    field :city, :string
    field :name, :string
    field :postcode, :string
    field :tel, :string

    timestamps()
  end

  @doc false
  def changeset(address_history, attrs) do
    address_history
    |> cast(attrs, [:ref_id, :name, :address_line_1, :address_line_2, :city, :postcode, :tel])
    |> validate_required([:ref_id, :name, :address_line_1, :address_line_2, :city, :postcode, :tel])
  end
end
