defmodule App.Accounts.Account do
  use Ecto.Schema

  schema "accounts" do
    field(:username, :string)
  end
end