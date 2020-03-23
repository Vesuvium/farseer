defmodule FarseerTest.Endpoints do
  use ExUnit.Case
  import Dummy

  alias Farseer.Endpoints
  alias Farseer.Ets
  alias Farseer.Log
  alias Farseer.Rules

  test "options/1" do
    endpoint = %{"to" => :to, "hello" => :no, "request_headers" => :headers}
    expected = %{"to" => :to, "request_headers" => :headers}
    assert Endpoints.options(endpoint) == expected
  end

  test "endpoints/0" do
    dummy Confex, [{"get_env", fn _a, _b -> :path end}] do
      dummy Rules, [{"parse", :parse}, {"endpoints", :endpoints}] do
        result = Endpoints.endpoints()
        assert called(Confex.get_env(:farseer, :yaml_file))
        assert called(Rules.parse(:path))
        assert called(Rules.endpoints(:parse))
        assert result == :endpoints
      end
    end
  end

  test "handler/1" do
    assert Endpoints.handler(%{"handler" => "Handler"}) == "Handler"
  end

  test "handler/1 without an handler" do
    assert Endpoints.handler(%{}) == "Http"
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

  test "register_methods/3" do
    dummy Ets, [{"insert", fn _a, _b, _c, _d -> :insert end}] do
      dummy Endpoints, [
        {"method_name", :method_name},
        {"method_rules", fn _a, _b -> :method_rules end}
      ] do
        dummy Log, [{"endpoint", fn _a, _b -> :endpoint end}] do
          Endpoints.register_methods("/", :path_rules, ["get"])
          assert called(Endpoints.method_name("get"))
          assert called(Endpoints.method_rules("get", :method_name))
          assert called(Log.endpoint(:method_name, "/"))
        end
      end
    end
  end

  test "register/2" do
    rules = %{"methods" => ["get"], "to" => :to}

    dummy Endpoints, [
      {"options", :options},
      {"register_methods", fn _a, _b, _c -> :methods end}
    ] do
      assert Endpoints.register("/", rules) == :methods
      assert called(Endpoints.options(rules))
      assert called(Endpoints.register_methods("/", :options, ["get"]))
    end
  end

  test "register/2 without methods" do
    dummy Ets, [{"insert", fn _a, _b, _c, _d -> :insert end}] do
      dummy Endpoints, [{"options", :options}] do
        assert Endpoints.register("/", %{"to" => :to}) == :insert
        assert called(Ets.insert("GET", "/", :options, nil))
      end
    end
  end

  test "init/0" do
    dummy Ets, ["create_table/0"] do
      dummy Endpoints, [
        {"endpoints", fn -> [{:path, :rules}] end},
        "register/2"
      ] do
        Endpoints.init()
        assert called(Ets.create_table())
        assert called(Endpoints.register(:path, :rules))
      end
    end
  end
end
