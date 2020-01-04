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

  test "id/2 with an id" do
    assert Ets.id("GET", {"GET", "", "hello"}) == {"GET", "", "hello"}
  end

  test "id/2" do
    assert Ets.id("GET", "/hello") == {"GET", "", "hello"}
  end

  test "insert/4" do
    :ets.new(:test, [:set, :protected, :named_table])

    dummy Ets, [{"table", fn -> :test end}, {"id", fn _a, _b -> :id end}] do
      Ets.insert(:method, :path, :path_rules, :method_rules)
      assert :ets.lookup(:test, :id) == [{:id, :path_rules, :method_rules}]
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
end
