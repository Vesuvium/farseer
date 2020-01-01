defmodule FarseerTest.Endpoints do
  use ExUnit.Case
  import Dummy

  alias Farseer.Endpoints
  alias Farseer.Yaml

  test "options/1" do
    endpoint = %{"to" => :to, "hello" => :no, "request_headers" => :headers}
    expected = %{"to" => :to, "request_headers" => :headers}
    assert Endpoints.options(endpoint) == expected
  end

  test "endpoints/0" do
    dummy Confex, [{"get_env", fn _a, _b -> :path end}] do
      dummy Yaml, [{"load", %{"endpoints" => :ok}}] do
        result = Endpoints.endpoints()
        assert called(Confex.get_env(:farseer, :yaml_file))
        assert called(Yaml.load(:path))
        assert result == :ok
      end
    end
  end

  test "method_name/1" do
    assert Endpoints.method_name("get") == "GET"
  end

  test "method_name/1 with a map" do
    assert Endpoints.method_name(%{"get" => %{}}) == "GET"
  end

  test "register/3" do
    dummy Endpoints, [{"options", :options}] do
      :ets.new(:farseer_test, [:set, :protected, :named_table])
      rules = %{"methods" => ["get"], "to" => :to}
      Endpoints.register(:farseer_test, "/", rules)
      assert called(Endpoints.options(rules))
      assert :ets.lookup(:farseer_test, "/") == [{"/", "GET", :options}]
    end
  end

  test "register/3 without methods" do
    dummy Endpoints, [{"options", :options}] do
      :ets.new(:farseer_test, [:set, :protected, :named_table])
      Endpoints.register(:farseer_test, "/", %{"to" => :to})
      assert :ets.lookup(:farseer_test, "/") == [{"/", "GET", :options}]
    end
  end

  test "init/0" do
    dummy Confex, [{"get_env", fn _a, _b -> :farseer_test end}] do
      dummy Endpoints, [
        {"endpoints", fn -> [{:path, :rules}] end},
        "register/3"
      ] do
        Endpoints.init()
        assert called(Confex.get_env(:farseer, :table))
        assert called(Endpoints.register(:farseer_test, :path, :rules))
      end
    end
  end
end
