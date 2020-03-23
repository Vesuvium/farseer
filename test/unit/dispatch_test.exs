defmodule FarseerTest.Dispatch do
  use ExUnit.Case
  import Dummy

  alias Farseer.Dispatch
  alias Farseer.Ets
  alias Farseer.Handlers.{Http, Json}

  test "init/1" do
    assert Dispatch.init("table") == "table"
  end

  test "call/2 with Http" do
    conn = %{method: :method, request_path: :path}
    row = {:path, "Http", :path_rules, :method_rules}

    dummy Http, ["handle/3"] do
      dummy Ets, [{"match", fn _a, _b -> [row] end}] do
        Dispatch.call(conn, :table)
        assert called(Ets.match(:method, :path))
        assert called(Http.handle(conn, :path_rules, :method_rules))
      end
    end
  end

  test "call/2 with Json" do
    conn = %{method: :method, request_path: :path}
    row = {:path, "Json", :path_rules, :method_rules}

    dummy Json, ["handle/3"] do
      dummy Ets, [{"match", fn _a, _b -> [row] end}] do
        Dispatch.call(conn, :table)
        assert called(Json.handle(conn, :path_rules, :method_rules))
      end
    end
  end

  test "call/2 with an unrecognized handler" do
    conn = %{method: :method, request_path: :path}
    row = {:path, :handler, :path_rules, :method_rules}

    dummy Http, ["handle/3"] do
      dummy Ets, [{"match", fn _a, _b -> [row] end}] do
        Dispatch.call(conn, :table)
        assert called(Http.handle(conn, :path_rules, :method_rules))
      end
    end
  end

  test "call/2 with an unmatched route" do
    conn = %{method: :method, request_path: :path}

    dummy Http, ["not_found"] do
      dummy Ets, [{"match", fn _a, _b -> [] end}] do
        Dispatch.call(conn, :table)
        assert called(Http.not_found(conn))
      end
    end
  end
end
