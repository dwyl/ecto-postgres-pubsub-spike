defmodule App.Listener do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    with {:ok, _pid, _ref} <- App.Repo.listen("addresses_changed") do
      {:ok, opts}
    else
      error ->
        {:stop, error}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "addresses_changed", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      data.record
      |> create_address_history()
      |> IO.inspect(label: "===> ")

      {:noreply, :event_handled}
    else
      error ->
        {:stop, error, []}
    end
  end

  defp create_address_history(address_params) do
     params = Map.put(address_params, :ref_id, address_params.id)

     %App.AddressHistory{}
     |> App.AddressHistory.changeset(params)
     |> App.Repo.insert!()
  end
end