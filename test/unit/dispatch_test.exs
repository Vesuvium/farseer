defmodule FarseerTest.Dispatch do
  use ExUnit.Case
  import Dummy

  alias Farseer.Dispatch
  alias Farseer.Handler

  defmodule Conn do
    defstruct request_path: "/", method: "GET"
  end

  setup do
    :ets.new(:farseer_test, [:set, :protected, :named_table])
    {:ok, conn: %Conn{}}
  end

  test "the init function" do
    assert Dispatch.init("table") == "table"
  end

  test "call a matched routed", %{conn: conn} do
    dummy Handler, ["handle/2"] do
      :ets.insert(:farseer_test, {"/", "GET", "to"})
      Dispatch.call(conn, :farseer_test)
      assert called(Handler.handle(conn, "to"))
    end
  end

  test "call an unmatched route", %{conn: conn} do
    dummy Handler, ["not_found"] do
      Dispatch.call(conn, :farseer_test)
      assert called(Handler.not_found(conn))
    end
  end
end
