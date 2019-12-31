defmodule FarseerTest.Server do
  use ExUnit.Case
  import Dummy

  alias Farseer.Endpoints
  alias Farseer.Log
  alias Farseer.Server

  test "loop" do
    dummy Server, [{"loop", fn -> :loop end}] do
      assert Server.loop() == :loop
    end
  end

  test "the port function" do
    dummy Confex, ["get_env/2"] do
      Server.port()
      assert called(Confex.get_env(:farseer, :port))
    end
  end

  test "the compress function" do
    dummy Confex, ["get_env/2"] do
      Server.compress()
      assert called(Confex.get_env(:farseer, :compress))
    end
  end

  test "children" do
    dummy Server, [
      {"port", fn -> :port end},
      {"compress", fn -> :compress end}
    ] do
      result = Server.children()

      assert result[Plug.Cowboy] == [
               scheme: :http,
               plug: Farseer.Router,
               options: [port: :port, compress: :compress]
             ]
    end
  end

  test "start" do
    dummy Supervisor, ["start_link/2"] do
      dummy Endpoints, [{"init", fn -> :ok end}] do
        dummy Log, [{"server_start", :server_start}] do
          dummy Server, [
            {"port", fn -> "port" end},
            {"loop", fn -> :loop end},
            {"children", fn -> :children end}
          ] do
            assert Server.start(1, 2) == Server.loop()
            assert called(Endpoints.init())
            options = [strategy: :one_for_one, name: Farseer.Supervisor]
            assert called(Supervisor.start_link(Server.children(), options))
            assert called(Log.server_start("port"))
          end
        end
      end
    end
  end
end
