defmodule Farseer.Body do
  alias Farseer.Body
  alias Plug.Conn
  alias Plug.Conn.Query

  def read({:ok, body, _conn}, ["application/json"]) do
    Jason.decode!(body)
  end

  def read({:ok, body, _conn}, ["application/x-www-form-urlencoded"]) do
    Query.decode(body)
  end

  def process(conn, nil) do
    Conn.read_body(conn) |> elem(1)
  end

  def process(conn, _method_rules) do
    conn
    |> Conn.read_body()
    |> Body.read(Conn.get_req_header(conn, "content-type"))
  end
end
