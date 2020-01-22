defmodule Farseer.Application do
  alias Farseer.Application
  alias Farseer.Log
  alias Farseer.Router
  alias Plug.Cowboy

  def port, do: Confex.get_env(:farseer, :port)
  def compress, do: Confex.get_env(:farseer, :compress)

  def children do
    [
      {Cowboy,
       scheme: :http,
       plug: Router,
       options: [
         port: Application.port(),
         compress: Application.compress()
       ]}
    ]
  end

  def start(_type, _args) do
    Farseer.Endpoints.init()
    options = [strategy: :one_for_one, name: Farseer.Supervisor]

    Log.server_start(Application.port())
    Supervisor.start_link(Application.children(), options)
  end
end
