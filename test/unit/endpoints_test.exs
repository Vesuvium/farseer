defmodule FarseerTest.Endpoints do
  use ExUnit.Case
  import Dummy

  alias Farseer.Endpoints
  alias Farseer.Yaml

  test "the options function" do
    endpoint = %{"to" => :to, "hello" => :no, "request_headers" => :headers}
    expected = %{"to" => :to, "request_headers" => :headers}
    assert Endpoints.options(endpoint) == expected
  end

  test "the endpoint function" do
    dummy Confex, [{"get_env", fn _a, _b -> :path end}] do
      dummy Yaml, [{"load", %{"endpoints" => :ok}}] do
        result = Endpoints.endpoints()
        assert called(Confex.get_env(:farseer, :yaml_file))
        assert called(Yaml.load(:path))
        assert result == :ok
      end
    end
  end

  test "the register function" do
    dummy Endpoints, [{"options", :options}] do
      :ets.new(:farseer_test, [:set, :protected, :named_table])
      endpoint = %{"path" => "/", "methods" => ["get"], "to" => :to}
      Endpoints.register(:farseer_test, endpoint)
      assert called(Endpoints.options(endpoint))
      assert :ets.lookup(:farseer_test, "/") == [{"/", "GET", :options}]
    end
  end

  test "the register function with an endpoint without methods" do
    dummy Endpoints, [{"options", :options}] do
      :ets.new(:farseer_test, [:set, :protected, :named_table])
      endpoint = %{"path" => "/", "to" => :to}
      Endpoints.register(:farseer_test, endpoint)
      assert :ets.lookup(:farseer_test, "/") == [{"/", "GET", :options}]
    end
  end

  test "the init function" do
    dummy Confex, [{"get_env", fn _a, _b -> :farseer_test end}] do
      dummy Endpoints, [
        {"endpoints", fn -> [{"name", "endpoint"}] end},
        "register/2"
      ] do
        Endpoints.init()
        assert called(Confex.get_env(:farseer, :table))
        assert called(Endpoints.register(:farseer_test, "endpoint"))
      end
    end
  end
end
