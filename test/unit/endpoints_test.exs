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

  test "method_rules/2" do
    assert Endpoints.method_rules("get", "GET") == nil
  end

  test "method_rules/2 with a map" do
    assert Endpoints.method_rules(%{"get" => :get}, "GET") == :get
  end

  test "register_methods/4" do
    :ets.new(:farseer_test, [:set, :protected, :named_table])

    dummy Endpoints, [
      {"method_name", :method_name},
      {"method_rules", fn _a, _b -> :method_rules end}
    ] do
      Endpoints.register_methods(:farseer_test, "/", :path_rules, ["get"])
      assert called(Endpoints.method_name("get"))
      assert called(Endpoints.method_rules("get", :method_name))

      assert :ets.lookup(:farseer_test, "/") == [
               {"/", :method_name, :path_rules, :method_rules}
             ]
    end
  end

  test "register/3" do
    rules = %{"methods" => ["get"], "to" => :to}

    dummy Endpoints, [
      {"options", :options},
      {"register_methods", fn _a, _b, _c, _d -> :methods end}
    ] do
      assert Endpoints.register(:table, "/", rules) == :methods
      assert called(Endpoints.options(rules))
      assert called(Endpoints.register_methods(:table, "/", :options, ["get"]))
    end
  end

  test "register/3 without methods" do
    dummy Endpoints, [{"options", :options}] do
      :ets.new(:farseer_test, [:set, :protected, :named_table])
      Endpoints.register(:farseer_test, "/", %{"to" => :to})
      assert :ets.lookup(:farseer_test, "/") == [{"/", "GET", :options, nil}]
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
