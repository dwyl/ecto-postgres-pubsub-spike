defmodule App.Listener do
  use GenServer
  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    with {:ok, _pid, _ref} <- App.Repo.listen("accounts_changed") do
      {:ok, opts}
    else
      error ->
        {:stop, error}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "accounts_changed", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      IO.inspect(data, label: "====> data in handle info")
      {:noreply, :event_handled}
    else
      error ->
        {:stop, error, []}
    end
  end
end