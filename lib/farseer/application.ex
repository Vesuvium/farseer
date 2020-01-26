defmodule Farseer.Application do
  alias Farseer.Log
  alias Farseer.Router
  alias Plug.Cowboy

  use Application

  def port, do: Confex.get_env(:farseer, :port)
  def compress, do: Confex.get_env(:farseer, :compress)

  def children do
    [
      {Cowboy,
       scheme: :http,
       plug: Router,
       options: [
         port: Farseer.Application.port(),
         compress: Farseer.Application.compress()
       ]}
    ]
  end

  def start(_type, _args) do
    Farseer.Endpoints.init()
    options = [strategy: :one_for_one, name: Farseer.Supervisor]

    Log.server_start(Farseer.Application.port())
    Supervisor.start_link(Farseer.Application.children(), options)
  end
end
