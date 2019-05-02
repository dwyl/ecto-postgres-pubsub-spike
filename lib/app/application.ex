defmodule App.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      App.Repo,
      App.Listener,
      AppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
