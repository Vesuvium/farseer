defmodule FarseerTest.Router do
  use ExUnit.Case, async: true
  use Plug.Test
  import Dummy

  alias Farseer.Dispatch
  alias Farseer.Router
  alias Plug.Conn

  @opts Router.init([])
  @table Application.get_env(:farseer, :table)

  test "the /_version route" do
    conn = conn(:get, "/_version")
    conn = Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "0.1.0"
  end

  test "forwarding a request to Dispatch" do
    dummy Dispatch, [
      {"call", fn conn, @table -> Conn.send_resp(conn, 200, "ok") end}
    ] do
      request = conn(:get, "/")
      response = Router.call(request, @opts)
      assert response.resp_body == "ok"
    end
  end
end
