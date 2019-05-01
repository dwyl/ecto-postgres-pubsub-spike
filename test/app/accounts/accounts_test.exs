defmodule App.AccountsTest do
  use App.DataCase

  alias App.{Accounts, AddressHistory, Repo}

  describe "addresses" do
    alias App.Accounts.Address

    @valid_attrs %{address_line_1: "some address_line_1", address_line_2: "some address_line_2", city: "some city", name: "some name", postcode: "some postcode", tel: "some tel"}
    @update_attrs %{address_line_1: "some updated address_line_1", address_line_2: "some updated address_line_2", city: "some updated city", name: "some updated name", postcode: "some updated postcode", tel: "some updated tel"}
    @invalid_attrs %{address_line_1: nil, address_line_2: nil, city: nil, name: nil, postcode: nil, tel: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_address()

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Accounts.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Accounts.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Accounts.create_address(@valid_attrs)
      assert address.address_line_1 == "some address_line_1"
      assert address.tel == "some tel"
    end

    test "create_address/1 with valid data also creates address_history" do
      assert {:ok, %Address{} = address} = Accounts.create_address(@valid_attrs)
      assert address.address_line_1 == "some address_line_1"
      address_history = Repo.get_by(AddressHistory, ref_id: address.id)
      refute is_nil(address_history)
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Accounts.update_address(address, @update_attrs)
      assert address.address_line_1 == "some updated address_line_1"
      assert address.tel == "some updated tel"
    end

    test "update_address/2 with valid data inserts new address into address history" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Accounts.update_address(address, @update_attrs)
      assert address.address_line_1 == "some updated address_line_1"

      assert length(Repo.all(Address)) == 1
      assert length(Repo.all(AddressHistory)) == 2
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_address(address, @invalid_attrs)
      assert address == Accounts.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Accounts.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Accounts.change_address(address)
    end
  end
end
