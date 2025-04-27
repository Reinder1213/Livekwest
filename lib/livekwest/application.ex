defmodule Livekwest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LivekwestWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:livekwest, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Livekwest.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Livekwest.Finch},
      # Start a worker by calling: Livekwest.Worker.start_link(arg)
      # {Livekwest.Worker, arg},
      # Start to serve requests, typically the last entry
      LivekwestWeb.Endpoint,
      {Registry, keys: :unique, name: Livekwest.QuizRegistry},
      Livekwest.QuizSupervisor,
      Livekwest.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Livekwest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivekwestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
