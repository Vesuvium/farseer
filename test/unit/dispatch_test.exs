defmodule FarseerTest.Dispatch do
  use ExUnit.Case
  import Dummy

  alias Farseer.Dispatch
  alias Farseer.Ets
  alias Farseer.Handlers.Http

  test "init/1" do
    assert Dispatch.init("table") == "table"
  end

  test "call/2" do
    conn = %{method: :method, request_path: :path}

    dummy Http, ["handle/3"] do
      dummy Ets, [
        {"match", fn _a, _b -> [{:path, :path_rules, :method_rules}] end}
      ] do
        Dispatch.call(conn, :table)
        assert called(Ets.match(:method, :path))
        assert called(Http.handle(conn, :path_rules, :method_rules))
      end
    end
  end

  test "call an unmatched route" do
    conn = %{method: :method, request_path: :path}

    dummy Http, ["not_found"] do
      dummy Ets, [{"match", fn _a, _b -> [] end}] do
        Dispatch.call(conn, :table)
        assert called(Http.not_found(conn))
      end
    end
  end
end
