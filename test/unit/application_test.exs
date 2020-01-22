defmodule FarseerTest.Application do
  use ExUnit.Case
  import Dummy

  alias Farseer.Application
  alias Farseer.Endpoints
  alias Farseer.Log

  test "the port function" do
    dummy Confex, ["get_env/2"] do
      Application.port()
      assert called(Confex.get_env(:farseer, :port))
    end
  end

  test "the compress function" do
    dummy Confex, ["get_env/2"] do
      Application.compress()
      assert called(Confex.get_env(:farseer, :compress))
    end
  end

  test "children" do
    dummy Application, [
      {"port", fn -> :port end},
      {"compress", fn -> :compress end}
    ] do
      result = Application.children()

      assert result[Plug.Cowboy] == [
               scheme: :http,
               plug: Farseer.Router,
               options: [port: :port, compress: :compress]
             ]
    end
  end

  test "start" do
    options = [strategy: :one_for_one, name: Farseer.Supervisor]

    dummy Supervisor, [{"start_link", fn _a, _b -> :start_link end}] do
      dummy Endpoints, [{"init", fn -> :ok end}] do
        dummy Log, [{"server_start", :server_start}] do
          dummy Application, [
            {"port", fn -> "port" end},
            {"children", fn -> :children end}
          ] do
            assert Application.start(1, 2) == :start_link
            assert called(Endpoints.init())
            assert called(Log.server_start("port"))
            assert called(Supervisor.start_link(:children, options))
          end
        end
      end
    end
  end
end
