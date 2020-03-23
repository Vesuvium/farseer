defmodule FarseerTest.Ets do
  use ExUnit.Case
  import Dummy

  alias Farseer.Ets

  test "table/0" do
    dummy Confex, [{"get_env", fn _a, _b -> :confex end}] do
      assert Ets.table() == :confex
      assert called(Confex.get_env(:farseer, :table))
    end
  end

  test "id/2" do
    assert Ets.id("GET", "/hello") == {"GET", "", "hello"}
  end

  test "templated_id/1" do
    result = Ets.templated_id({"GET", "", "hello", "1"})
    assert result == {"GET", "", "hello", :"$1"}
  end

  test "insert/5" do
    :ets.new(:test, [:set, :protected, :named_table])
    row = {:id, :handler, :path_rules, :method_rules}

    dummy Ets, [{"table", fn -> :test end}, {"id", fn _a, _b -> :id end}] do
      Ets.insert(:method, :path, :handler, :path_rules, :method_rules)
      assert :ets.lookup(:test, :id) == [row]
    end
  end

  test "all/0" do
    :ets.new(:test, [:set, :protected, :named_table])
    :ets.insert(:test, {:id, 2, 3})

    dummy Ets, [{"table", fn -> :test end}] do
      assert Ets.all() == [[:id, 2, 3]]
    end
  end

  test "match/2" do
    id = {"GET", "", "/world"}
    :ets.new(:test, [:set, :protected, :named_table])
    :ets.insert(:test, {id, :path_rules, :method_rules})

    dummy Ets, [{"table", fn -> :test end}, {"id", fn _a, _b -> id end}] do
      assert Ets.match("GET", "/world") == [{id, :path_rules, :method_rules}]
    end
  end

  test "match/2 with a path fragment" do
    id = {"GET", "", "/world", "{{id}}"}
    template = {"GET", "", "/world", :"$1"}
    path = {"GET", "", "/world", "1"}
    :ets.new(:test, [:set, :protected, :named_table])
    :ets.insert(:test, {id, :handler, :path_rules, :method_rules})
    row = {id, :handler, :path_rules, :method_rules}

    dummy Ets, [
      {"table", fn -> :test end},
      {"id", fn _a, _b -> path end},
      {"templated_id", template}
    ] do
      assert Ets.match("GET", "/world/1") == [row]
    end
  end
end
