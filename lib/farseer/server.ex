defmodule Farseer.Server do
  require Logger

  alias Plug.Cowboy
  alias Farseer.Router

  def loop do
    loop()
  end

  def port, do: Confex.get_env(:farseer, :port)
  def compress, do: Confex.get_env(:farseer, :compress)

  def children do
    [
      {Cowboy,
       scheme: :http,
       plug: Router,
       options: [
         port: Farseer.Server.port(),
         compress: Farseer.Server.compress()
       ]}
    ]
  end

  def start(_type, _args) do
    Farseer.Endpoints.init()
    options = [strategy: :one_for_one, name: Farseer.Supervisor]

    Supervisor.start_link(Farseer.Server.children(), options)
    Logger.info("Farseer started!")

    Farseer.Server.loop()
  end
end
