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
    IO.inspect("App Listener start_link")
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    IO.inspect("App Listener init")
    with {:ok, _pid, _ref} <- App.Repo.listen("accounts_changed") do
      IO.inspect("App Listener init worked")
      {:ok, opts}
    else
      error ->
        IO.inspect("App Listener init error")
        {:stop, error}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "accounts_changed", payload}, _state) do
    IO.inspect("App Listener handle_info")
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      data
      |> inspect()
      |> Logger.info()

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end

  def handle_info(arg1, state) do
    IO.inspect("====================================")
    IO.inspect(arg1)
    IO.inspect(state)
    IO.inspect("====================================")
  end
end